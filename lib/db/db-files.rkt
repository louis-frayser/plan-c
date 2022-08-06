#lang racket
;;; ====================================================================
;;; Simple file-based datase of (key . data) assocs

(provide get-current-assoc-groups get-assocs get-assocs-by-datestr
         put-assoc-to-db read-file write-file)

(require db srfi/19 "../config.rkt"  "../lib.rkt" "plan-data.rkt")
;;; ---------------------------------------------------------------------

(define (get-assocs #:since (beginning "2022-01-01"))
  (define file->assoc read-file)
  (map file->assoc (get-assoc-paths #:since beginning)))
;;; .....................................................................

(define (get-assocs-by-datestr #:since (beginning "2022-01-01"))
  (define (get-assoc-paths-by-date #:since (beginning "2022-01-01"))
    ;; ddate/directory
    (define ddlist
      (filter (curry string<=? beginning)
              (map path->string (directory-list %db-base-dir%))))
    ;; A list of date and associated files
    (map (lambda(d) (list d (directory-list (build-path %db-base-dir% d))))
         ddlist))
  ;; Return association grouped by date. A starting date can be specified.
  (map
   (lambda(pr)
     (define dbase (first pr))
     (list dbase
           (map (compose read-file (curry build-path %db-base-dir% dbase))
                (second pr))))
   (get-assoc-paths-by-date #:since beginning)))
;;; ------------------------------------------------------------------
(define (get-current-assoc-groups) ; Get plan from permanent storage
  (define (get-current-assocs)
    (define assocs (get-assocs-by-datestr #:since (get-ymd-string)))
    (if (pair? assocs)
        (cadar assocs)
        null))
  (assocs->groups (get-current-assocs)))
;;; .....................................................................

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
;;; .....................................................................

(define (put-assoc-to-db assoc user #:tstamp _ignored) ; Ignore start time
  (define (put-assoc-to-db-for-date dstr assoc) ;;; WRITE only if RDBM ins fails
    (define (get-assoc-pathname-for ymd-str)
      (build-path
       %db-base-dir% (date->string (current-date) "~1/assoc-~T.scm")))
    (let* ((dest (get-assoc-pathname-for dstr))
           (destdir (call-with-values
                     (lambda()(split-path dest)) (lambda(dir _f _) dir))))
      (unless (directory-exists? destdir)
        (make-directory destdir))
      (with-output-to-file dest
        ;; Don't use display or print!
        (lambda()(writeln assoc)))))
  ;; put in db-basedir/yyyy-mm-dd
  (put-assoc-to-db-for-date (get-ymd-string) assoc))
