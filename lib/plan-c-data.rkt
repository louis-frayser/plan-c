#lang racket
;;;; *input-plan* is user input, all symbols.
;;;; retrieve-plan-c() is automated input, all strings
(require "lib.rkt")

(provide retrieve-plan-c (struct-out plan) plan-assocs plan-categories 
         plan-key=? plan-keys plan-list->groups)

(struct plan (version date groups))

(define (->string obj) 
  (if (pair? obj) (map ->string obj) (symbol->string obj)))

(define *input-plan*
  (let ((path
         (if (directory-exists? "lib")
             "lib/db/manual-input.scm"  "../lib/db/manual-input.scm")))
    (with-input-from-file path
      (lambda() 
        (let ((val (read)))
          (if (and (pair? val) (eq? (car val) 'plan))
              (plan (cadr val) (caddr val) (cadddr val))
              (error "Invalid user input:\
 db/manual-input.scm!")))))))

(define retrieve-plan-c   
  (let ((pc (plan "C" (symbol->string (plan-date *input-plan*))
                  (->string (plan-groups *input-plan*)))))
    (lambda() pc)))

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
;; ====================================================================
