#lang debug racket
; ====================================================================
;;; Disk Database....
(provide (all-defined-out))

(require srfi/13 srfi/19 "config.rkt" "lib.rkt" "plan-c-data.rkt")
;;; ------------------------------------------------------------------

(define (read-file path/string)
  (with-input-from-file path/string (lambda()(read))))

(define (write-file path sexpr)
  (with-output-to-file path
    (lambda() (displayln sexpr)) #:exists 'replace))

(define file->assoc read-file)
;;; ------------------------------------------------------------------

(define %db-base-dir% (build-path %orig-dir% "lib/db"))
;;; ..................................................................

(define get-plan-c  ; Get plan from permanent storage
  (lambda()
    (define (get-current-plan)
      (define (get-plan-for-date datestr)
        (define get-db-dir-for-date
          (lambda(date) 
            (build-path %db-base-dir% date)))
        (define (file-ok? f)(string-suffix-ci? ".scm" (path->string f)))
        (define (filter-files files )(filter file-ok? files))
        (let ((ddir (get-db-dir-for-date datestr)))
          (if (directory-exists? ddir)
              (let ((dlist (directory-list ddir  #:build? #t)))
                (if (null? dlist)
                    (empty-plan)
                    (let ((assocs
                           (map (lambda(pth)(with-input-from-file pth read))
                                (filter-files dlist))))
                      (plan "C" datestr (plan-list->groups assocs)) )))
              (empty-plan))))
      (get-plan-for-date (get-ymd-string)))
    (or (get-current-plan) (empty-plan))))
;;; .....................................................................

;
(define (put-assoc-to-db assoc) 
  ;; put in db-basedir/yyyy-mm-dd
  (put-assoc-to-db-for-date (get-ymd-string) assoc))
  
(define (put-assoc-to-db-for-date dstr assoc)
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
;;; .....................................................................
(define (get-assoc-paths-by-date #:since (beginning "2022-01-01"))
  ;; ddate/directory
  (define ddlist
    (filter (curry string<=? beginning)
            (map path->string (directory-list %db-base-dir%))))

  ;; A list of date and associated files
  (map (lambda(d) (list d (directory-list (build-path %db-base-dir% d))))
       ddlist))

(define (get-assocs)
  (define (get-assoc-paths)
    (define (predicate pth)
      (regexp-match #rx"2...-.*/assoc-.*.scm" (path->string pth)))
    (find-files predicate %db-base-dir%
                #:skip-filtered-directory? #f #:follow-links? #f))
    (map file->assoc (get-assoc-paths)))
  