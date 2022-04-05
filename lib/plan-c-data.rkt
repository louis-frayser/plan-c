#lang racket
(require "lib.rkt" "config.rkt")

(provide  empty-plan (struct-out plan) plan-assocs plan-categories 
         plan-key=? plan-keys plan-list->groups plan-show)

(struct plan (version date groups))

(define (plan-show pln)
  (with-output-to-string
    (lambda()
      (writeln
       `(plan ,(plan-version pln) ,(plan-date pln) ,(plan-groups pln))))))
;
;; ......................................................................
(define (empty-plan)
  (plan "C" (get-ymd-string) (map list (config-schema-categories))))
;; .......................................................................

(define (plan-categories a-plan)  (map car (plan-groups a-plan)))

(define (plan-key=? k1 k0)
  (and (apply string=? (map car `(,k1 ,k0))) 
       (apply string=? (map cadr `(,k1 ,k0)))))

;;; Returns all paired keys. Skips those without values > "0:00"
(define (plan-keys aplan)
  (let* ( (groups (plan-groups aplan))
          (cats  (map car groups)))
    (apply append 
           (map (lambda(c)
                  (let ( (acts
                          (filter (lambda(a)(> (length a) 1)) 
                                  (dict-ref groups c))) ) 
                    (map  (lambda (a)(list c (car a))) acts))) cats))))

;;; Returns assocs that have values as list of (key . value)
(define (plan-assocs a-plan)
  (let* ((groups (plan-groups a-plan))
         (cats (map car groups))
         (cgroups (map (lambda(c)(cons c (dict-ref groups c))) cats))
         (assocgs (map (lambda(cg)
                         (let ((c (car cg)))
                           (map (lambda(act)(cons c act)) (cdr cg))))
                       cgroups))
         (assocs (apply append assocgs))
         (valid-assocs (filter (lambda(a)(> (length a) 2)) assocs)))
    (map (lambda(l) (cons (list (car l) (cadr l))
                          (caddr l)))valid-assocs)))
;; ...................................................................... 

(define (plan-list->groups a-list)
  (let ((cgroups (group-by caar a-list)))
    (map (lambda(g)
           (cons (caaar g)(map (lambda(a)(list (cadar a) (cdr a))) g))) 
         cgroups)))
;; ...........................................................

;;; ===================================================================
