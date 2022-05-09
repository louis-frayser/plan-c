#lang racket
(require db
         "db-files.rkt" "config.rkt")

(define (get-assoc-paths #:since (beginning "2022-01-01"))
  (define (predicate pth)
    (define pathstr (path->string pth))
    (define date-part
      (let (( match (regexp-match #rx"[0-9]...-..-.." pathstr)))
        (and match (car match))))
    (and (and date-part (string>=? date-part beginning))
         (regexp-match #rx"2...-.*/assoc-.*.scm" pathstr)))
  (find-files predicate %db-base-dir%
              #:skip-filtered-directory? #f #:follow-links? #f))

(define *paths (get-assoc-paths))

(define *path (car *paths))

(define (make-rec path)
  (define stat (file-or-directory-stat path))

  (define date (seconds->date (hash-ref stat 'modify-time-seconds)))

  (define assoc (read-file path))

  (cons (car assoc) (list (cdr assoc ) date) ))

(define rec (make-rec *path))

(define recs (map make-rec *paths))

(define (print-sql rec #:to-string? (to-string #f))
  (define fmt (string-append "INSERT INTO plan_c.assocs_import "
                             "( category, activity, duration, ctime ) "
                             "VALUES ('~a', '~a', interval '~a', timestamp (0) '~a' );\n"))
  (define key (car rec))
  (define cat (car key))
  (define act (cadr key))
  (define dat (cdr rec))
  (define dur (car dat))
  (define ts  (cadr dat))
  (define (~0 n) (~a n  #:align 'right #:min-width 2  #:pad-string "0"))
  (define ctm
    (format "~a-~a-~aT~a:~a:~a"
            (date-year ts) (date-month ts) (date-day ts)
            (date-hour ts) (~0 (date-minute ts)) (~0 (date-second ts))))
  (define sql (format fmt cat act dur ctm))
  (if to-string
      sql
      (displayln sql)))
                      
(define (print-sql-string rec)
  (print-sql rec #:to-string? #t))
  
  
#;(for-each print-sql recs)

(define pgc
    (postgresql-connect #:user "frayser"
                        #:database "frayser"
                        #;#:password #;password))

(define( do-insert rec)
  (query-exec pgc (print-sql rec #:to-string? #t)))

#;(do-insert rec)

(for-each do-insert recs)

(disconnect pgc)
