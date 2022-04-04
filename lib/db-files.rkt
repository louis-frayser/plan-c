#lang racket
; ====================================================================
;;; Disk Database...
(provide retrieve-plan-c)
(require "lib.rkt" "plan-c-data.rkt")
;;; ------------------------------------------------------------------
(define get-db-dir-for-date
  (lambda(date) 
    (build-path (get-db-base-dir) date)))

(define (get-current-db-dir)
  (get-db-dir-for-date (get-ymd-string)))

(define get-db-base-dir
  (lambda()
    (if (directory-exists? "db")
        "db"  "lib/db")))
(debug (get-current-db-dir)) 

;;; ..................................................................
(define retrieve-plan-c  ; Get plan from permanent storage
  (lambda()
    (or (get-current-plan) (empty-plan))))
;  
(define (get-plan-for-date datestr)
  (let ((ddir (get-db-dir-for-date datestr)))
    (if (directory-exists? ddir)
        (let ((dlist (directory-list ddir)))
          (if (null? dlist)
              (empty-plan)
              (plan "C" datestr (plan-list->groups (map file->string dlist)))))
        (empty-plan))))
    
(define (get-current-plan)
  (get-plan-for-date (get-ymd-string)))