#lang racket

(provide %table%)
(provide assoc-path->date print-sql print-sql-string try-query )

(require "../config.rkt" "../lib.rkt" )
(require srfi/19)
(require db)

(define %table% (if %production% "assocs" "assocs_dev"))

;; Set the search path and check that tables are accessable

(define (print-sql rec #:to-string? (to-string #f))
  (define fmt
    (string-append
     "INSERT INTO " %table% 
     " (\"category\", \"activity\", \"duration\", \"stime\", \"usr\" ) "
     "VALUES ('~a', '~a', interval '~a', timestamp (0) '~a', '~a');\n"))
  (define key (car rec))
  (define cat (car key))
  (define act (cadr key))
  (define dat (cdr rec))
  (define dur (car dat))
  (define ts  (cadr dat))
  (define usr (caddr dat))
  (define stm
    (format "~a-~a-~aT~a:~a:~a"
            (date-year ts) (date-month ts) (date-day ts)
            (date-hour ts) (~0 (date-minute ts)) (~0 (date-second ts))))
  (define sql (format fmt cat act dur stm usr))
  (if to-string
      sql
      (displayln sql)))

;;; ............................................................................
(define (print-sql-string rec) (print-sql rec #:to-string? #t))
;;; ............................................................................

(define (try-query query-func pgc sql )
  (define (db-fail ex)
    (eprintf "\nTrapped ~a\n for ~s\nReturning #f\n" ex sql)
    #f)
  (with-handlers ((exn:fail? db-fail))
    (query-func pgc sql)))
;;; ............................................................................

(define (assoc-path->date path)
  (define-values (date-str basename)
    (apply values (map path->string (take-right (explode-path path) 2))))
  (define time-str (car (regexp-match #rx"[0-9].:..:.." basename)))
  (string->date  (string-append date-str "T" time-str) "~Y-~m-~dT~H:~M:~S"))
