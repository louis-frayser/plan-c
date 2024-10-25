#lang debug racket

(provide assoc->rdbms db-connected? db-exec
         db-get-assocs db-get-assocs-by-datestr
         db-get-current-assoc-groups db-get-max-ctime-string
         db-get-rows db-update-assoc-from-bindings)

(require (except-in srfi/19 date->string)
         web-server/http/bindings
         db)
(require (only-in racket-hacks  get-ymd-string))
(require "../config.rkt"
         "db-common.rkt"
         "db-files.rkt"
         "dbupdate-from-disk.rkt"
         "../lib.rkt"
         )
(require (only-in racket/date date*->seconds date->string date-display-format))
(require (only-in racket-hacks string->sql-interval string->sql-timestamp)) 
;; This is for switching from a simple file db to RDBMS
(db-update-from-disk) ; Read in any db records written to disk
;;; ----------------------------------------------------------------------------
#;(define (sql-ts->ymd-string ts)
    (string-join
     (map ~0 
          (list sql-timestamp-year sql-timestamp-month sql-timestamp-day)) "-"))
;;; ----------------------------------------------------------------------------
(define (fill sx) ;; Fill in a series to account for missing days
  (let loop ((rest sx) (n (and (pair? sx)
                               (string->number (caar sx)))) (acc '()))
    (cond ( (null? rest) (reverse acc))
          (else
           (let* ((want (string->number (caar rest)))
                  (n (if (> n want) want n))
                  (insert? (< n want))
                  (acc1 (if insert?
                            (cons (list (~0 n) "00:00") acc)
                            (cons (car rest) acc)))
                  (rest1 (if insert?
                             rest
                             (cdr rest))))
             (loop rest1  (+ n 1) acc1))))))
;;; ----------------------------------------------------------------------------
;;; Set up a persistant PostgreSQL connection
(begin
  (define %pgc
    (postgresql-connect #:user     %pg_user%
                        #:database %pg_db%
                        #:password %pg_pass%))
  (query-exec %pgc "SET search_path=plan_c,\"$user\",public"))

(define (db-connected?)
  (connected? %pgc))

(define (db-exec sql) (try-query query-exec %pgc sql))
;;; ----------------------------------------------------------------------------

(define (make-rec path user)
  (define (read-file path/string)
    (with-input-from-file path/string (lambda()(read))))
  (define stat (file-or-directory-stat path))
  (define date (seconds->date (hash-ref stat 'modify-time-seconds)))
  (define assoc (read-file path))
  (cons (car assoc) (list (cdr assoc ) date user) ))

;;; ............................................................................
;;; Get records as associations ((category activity) . duration )
;;; NOTE:  Also consider importing any recs writen directly to disk
;;;; SEE: #'db-update-from-disk (Invoded above everytime the system starts)
(define (db-get-assocs #:for-user user #:since (beginning "2022-01-01"))
  (define (massage data)
    (let*((l (vector->list data) )
          (rest (cdr l))
          (key (list (first rest) (second rest)))
          (itv (third rest))
          (hrs (sql-interval-hours itv))
          (mns (sql-interval-minutes itv))
          (tsl (map (compose ~0 number->string) (list hrs mns)))
          (ts (string-join tsl ":")))
      (cons key ts)))
  (define sql
    (string-append
     "SELECT format('%5s', date_trunc('day', stime))"
     " AS day,category,activity,duration"
     " FROM " %table%
     " WHERE stime >= timestamp '" beginning "' "
     " AND usr ='" user "'"
     " ORDER BY stime;"))
  (map massage (query-rows %pgc sql)))


(define (db-get-current-assoc-groups #:for-user user)
  (define (group-by-category assocs)
    (define (f  g)
      (let ((cat (caaar g))
            (durats (map cdr g))
            (acts (map cadar g)))
        (cons cat (map list acts durats))))
    (map  f (group-by caar assocs)))

  (group-by-category (db-get-assocs #:for-user user #:since (get-ymd-string))))
;;; ----------------------------------------------------------------------------
;;; assocs as the CDRs of dates from "stime"
;;; Curently user is hardcoded in planc-rc.scm, but could be stored in the assoc
(define (db-get-sdate+assocs #:since (beginning "2022-01-01")
                             #:user user)
  (define (massage rcrd)
    (let*((l (vector->list rcrd) )
          (stime (car (string-split (car l))))
          (rest (cdr l))
          (key (list (first rest) (second rest)))
          (itv (third rest)) ; duration
          (hrs (sql-interval-hours itv))
          (mns (sql-interval-minutes itv))
          (tsl (map (compose ~0 number->string) (list hrs mns)))
          (ts (string-join tsl ":"))
          (r0 (cons key ts)))
      (list stime r0)))
  ;;; .........................................................................
  (define sql
    (string-append
     "select format('%5s', date_trunc('day', stime))"
     " as day,category,activity,duration"
     " from " %table%
     " where stime >= timestamp '" beginning "' and usr = '" user "'"
     " ORDER by stime; "))
  (map massage (query-rows %pgc sql)))
;;; ............................................................................

(define (db-get-assocs-by-datestr  #:since (beginning "2022-01-01")
                                   #:user user )
  (let* ( (date.assocs (db-get-sdate+assocs #:user user #:since beginning))
          (gs (group-by car date.assocs string=? ))
          (a-gs (map (lambda(g)
                       (list (caar g) (map cadr g))) gs)))
    a-gs))
;;; ----------------------------------------------------------------------------
(define (db-get-rows #:user user #:for-date (date (get-ymd-string)))
  (define sql (string-append "SELECT id, stime, category, activity, duration
FROM " %table% " "
       "WHERE usr = '" user "' 
 AND stime >= '" date "'
 AND stime < timestamp '" date "' + '1 day'"))

  (define rows (try-query query-rows  %pgc sql ))

  (define (row->rec vec)
    (define (dur si)
      (string-append (~0 (sql-interval-hours si))
                     ":"
                     (~0 (sql-interval-minutes si))))
    (define (stime st)
      (string-append
       (~0 (sql-timestamp-hour st))
       ":"
       (~0 (sql-timestamp-minute st))))
   
    (list
     (vector-ref vec 0)
     (stime (vector-ref vec 1))
     (vector-ref vec 2)
     (vector-ref vec 3)
     (dur (vector-ref vec 4))))

  (map row->rec rows))
;;; ------------------------------------------------------------------
(define (db-get-max-ctime-string)
  (define ctmax
    (try-query
     query-maybe-value
     %pgc
     (string-append "SELECT date_trunc('minute', MAX(ctime)) FROM " %table%)))
  (if (sql-null? ctmax)
      (string-append (get-ymd-string) " 00:00")
      (let* ((t ctmax)
             (y (sql-timestamp-year t))
             (mo (sql-timestamp-month t))
             (d (sql-timestamp-day t))
             (h (sql-timestamp-hour t))
             (m (sql-timestamp-minute t)))
        (format "~a-~a-~a ~a:~a"
                (~0 y)  (~0 mo) (~0 d )  (~0 h )  (~0 m)))))
                 

;;; ----------------------------------------------------------------------------

(define (assoc->rdbms-insert-string assoc user #:tstamp (tstamp (current-date)))
  (define key (car assoc))
  (define val (cdr assoc))
  (define date tstamp)
  (define rec (cons key (list val date user)))
  (define sql (print-sql rec #:to-string? #t))
  sql)
;;; ----------------------------------------------------------------------------

(define (assoc->rdbms assoc user #:tstamp (tstamp (current-date)))
  (define sql (assoc->rdbms-insert-string assoc user  #:tstamp tstamp))
  (define (db-fail ex)
    (eprintf "\nTrapped ~a\n for ~a\nWriting assoc to disk instead.\n" ex sql)
    (put-assoc-to-db assoc user))
  (with-handlers ((exn:fail? db-fail))
    (query %pgc sql)))

;;; ----------------------------------------------------------------------------
(define (db-update-assoc-from-bindings bindings)
  ;; Extract fields from binding and update assocs/assocs_dev or recno
  ;; Note user (usr) is ignored: Validation shold check user-vs-recno, and
  ;;   format and data of other values.
 
  (define statement
    (format "UPDATE ~s SET category=$1, activity=$2, stime=$3, duration=$4 WHERE id=$5" 
            %table%))
  (define pst  (prepare %pgc statement))
  #RRR (prepared-statement-parameter-types pst)
  (let ((rowno (extract-binding/single 'rowno bindings))
        (category (extract-binding/single 'category bindings))
        (activity (extract-binding/single 'activity bindings))
        (stime (extract-binding/single 'stime bindings))
        (duration (extract-binding/single 'duration bindings))
        (change   (extract-binding/single 'change bindings)))
    (let ((bds (bind-prepared-statement pst (list category activity
                                                  (string->sql-timestamp stime)
                                                  (string->sql-interval duration)
                                                  (string->number rowno)))))
      (db-exec bds)))
  ;; Maybe send-back .../crud?req-date=(string-take stime 10)
  ;; NOTE:  The caller crud/update is handling the return value
  )
;; (db-update-assoc-from-bindings #f)
;;; ============================================================================
;;; DEMOS (requires  "#lang demo racket" )
;;; Music for time studied per instrument past 30-days
;  #RRR (db-get-music-durations-by-day #:since (a-month-ago-str))
;  #R(db-get-current-assoc-groups #:for-user "guest")
#;(let ((gs (db-get-current-assoc-groups #:for-user "guest")))
    (displayln gs)
    (displayln (length gs)))

;;; ----------------------------------------------------------------------------
