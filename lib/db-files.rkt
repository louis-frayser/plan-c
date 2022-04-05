#lang racket
; ====================================================================
;;; Disk Database...
(provide put-assoc-to-db retrieve-plan-c)

(require srfi/13 srfi/19 "config.rkt" "lib.rkt" "plan-c-data.rkt")
;;; ------------------------------------------------------------------
(define get-db-dir-for-date
  (lambda(date) 
    (build-path (get-db-base-dir) date)))

(define (get-current-db-dir)
  (get-db-dir-for-date (get-ymd-string)))

(define (get-db-base-dir) (build-path %orig-dir% "lib/db"))

(define (get-assoc-pathname-for ymd-str)
  (build-path
   (get-db-base-dir) (date->string (current-date) "~1/assoc-~T.scm")))
;;; ..................................................................
(define retrieve-plan-c  ; Get plan from permanent storage
  (lambda()
    (or (get-current-plan) (empty-plan))))
;  
(define (get-plan-for-date datestr)
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
;;; .....................................................................
(define (get-current-plan)
  (get-plan-for-date (get-ymd-string)))
;
(define (put-assoc-to-db assoc) 
  ;; put in db-basedir/yyyy-mm-dd
  (put-assoc-to-db-for-date (get-ymd-string) assoc))
  
(define (put-assoc-to-db-for-date dstr assoc)
  (let* ((dest (get-assoc-pathname-for dstr))
         (destdir (call-with-values
                   (lambda()(split-path dest)) (lambda(dir _f _) dir))))
    (unless (directory-exists? destdir)           
      (make-directory destdir))
    (with-output-to-file dest
      ;; Don't use display or print!
      (lambda()(writeln assoc)))))
