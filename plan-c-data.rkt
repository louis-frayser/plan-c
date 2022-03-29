#lang racket
;;;; *input-plan* is user input, all symbols.
;;;; *plan-c* is automated input, all strings
(provide *plan-c* (struct-out plan) plan-categories )

(define (->string obj) 
  (if (pair? obj) (map ->string obj) (symbol->string obj)))

(struct plan (version date groups))

(define *input-plan*
  (with-input-from-file "db/manual-input.scm"
    (lambda() (let ((val (read)))
      (if (and (pair? val) (eq? (car val) 'plan))
          (plan (cadr val) (caddr val) (cadddr val))
          (error "Invalid user input: db/manual-input.scm!"))))))
    
  (define *plan-c*
    (plan "C" (symbol->string (plan-date *input-plan*))
          (->string (plan-groups *input-plan*))))

  (define (plan-categories a-plan)  (map car (plan-groups a-plan)))
  (plan-groups *plan-c*)