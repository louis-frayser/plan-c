#lang debug racket

(provide assoc->rdbms db-get-assocs db-get-current-assoc-groups db-get-music-durations-by-day)

(require (except-in srfi/19 date->string) db )
(require "config.rkt"
         "db-common.rkt"
         "dbupdate-from-disk.rkt"
         "lib.rkt"
         )
(require (only-in racket/date date*->seconds date->string date-display-format))

;; This is for switching from a simple file db to RDBMS
(db-update-from-disk) ; Read in any db records written to disk

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
  (define pgc
    (postgresql-connect #:user     %pg_user%
                        #:database %pg_db%
                        #:password %pg_pass%))
  (query-exec pgc "SET search_path=plan_c,\"$user\",public"))
;;; ----------------------------------------------------------------------------

(define (make-rec path user)
  (define (read-file path/string)
    (with-input-from-file path/string (lambda()(read))))
  (define stat (file-or-directory-stat path))
  (define date (seconds->date (hash-ref stat 'modify-time-seconds)))
  (define assoc (read-file path))
  (cons (car assoc) (list (cdr assoc ) date user) ))

;;; ............................................................................

(define (db-get-music-durations-by-day #:since (beginning "2022-01-01"))
  (define (rec->list r)
    (define day (~0 (last (string-split (vector-ref r 0)))))
    (define _t (vector-ref r 1))
    (define tmstr (string-append (~0 (sql-interval-hours _t)) ":"
                                 (~0 (sql-interval-minutes _t))))
    (list day tmstr))
  ;;; Musical Practice only for dates actually practiced
  (define sql
    (string-append
     "SELECT format('%s %s', extract(DOY from stime), extract(day from stime))
         AS day, sum(duration)
       FROM " %table%
              " WHERE category = 'Music Practice'
        AND stime >= timestamp '" beginning "'"
                                  " GROUP BY day
      ORDER BY day;"))
  (fill (map rec->list (query-rows pgc sql))))

;;; ............................................................................
;;; Get todays records as associations ((category activity) . duration )
;;; NOTE:  WE NEED TODAYS DATA in Posetgres -- SEE: #'db-update-from-disk
(define (db-get-assocs #:since (beginning "2022-01-01"))
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
     "select format('%5s', date_trunc('day', stime))"
     " as day,category,activity,duration"
     " from " %table%
     " where stime >= timestamp '" beginning "';"))
  (map massage (query-rows pgc sql)))

(define (db-get-current-assoc-groups)
  (define (group-by-category assocs)
    (define (f  g)
      (let ((cat (caaar g))
            (durats (map cdr g))
            (acts (map cadar g)))
        (cons cat (map list acts durats))))
    (map  f (group-by caar assocs)))
  ;;; Musical Practice only for dates actually practiced

  (group-by-category (db-get-assocs #:since (get-ymd-string))))
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
  (define sql (assoc->rdbms-insert-string assoc user))
  (define (db-fail ex)
    (eprintf "\nTrapped ~a\n for ~a\nWriting assoc to disk instead.\n" ex sql)
    #f)
  (with-handlers ((exn:fail? db-fail))
    (query pgc sql)))

;;; ============================================================================
;;; DEMOS (requires  "#lang demo racket" )
;;; Music for time studied per instrument past 30-days
;  #RRR (db-get-music-durations-by-day #:since (a-month-ago-str))
;  #R(db-get-current-assoc-groups)
#;(let ((gs (db-get-current-assoc-groups)))
    (displayln gs)
    (displayln (length gs)))

;;; ----------------------------------------------------------------------------
