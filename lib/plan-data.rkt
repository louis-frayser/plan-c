#lang racket

(provide assoc-key=? assocs->groups assoc-groups->categories )
;;; ......................................................................

(define (assoc-key=? k1 k0)
  (and (apply string=? (map car `(,k1 ,k0)))
       (apply string=? (map cadr `(,k1 ,k0)))))
;; .......................................................................

(define (assocs->groups a-list)
  (let ((cgroups (group-by caar a-list)))
    (map (lambda(g)
           (cons (caaar g)(map (lambda(a)(list (cadar a) (cdr a))) g)))
         cgroups)))
;; .......................................................................

(define (assoc-groups->categories assoc-groups) (map car assoc-groups))
;;; ======================================================================
