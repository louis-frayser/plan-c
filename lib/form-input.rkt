#lang debug racket

(provide handle-input-form process-input-form)
(require web-server/servlet debug
         "plan-c-data.rkt" "config.rkt" "lib.rkt" "db-files.rkt")

;;; ==============================================================
;;;              INPUT FORM
(define (handle-input-form req render-page) 
  (process-input-form (request-bindings req) render-page))

(define (process-input-form bindings render-page)
  ;;; We are looking at a form that changes only one trie key (cat,act)
  ;;; The pair is of numerical indices representing strings in config
  ;;; config-schema-categories() and config-schema-subcategories()
  ;;; After decoding  the numbers into to strings, the struct is
  ;;; addressible for "update".
  (void #RRR bindings); (debug-value "process-input-form.rkt: ~v" bindings)
  ;;; adding in the  time from the original activity
  (define (new-assocs orig-assocs new-assoc )
    (let*-values (( (key) (car new-assoc))
                  ((replace-assocs keep-assocs )
                   (partition (lambda(a) 
                                (plan-key=? (car a) key)) orig-assocs))
                  ((matching-assoc)  ;list of length 0 or 1
                   (if (pair? replace-assocs)
                       (car replace-assocs) (cons key "0:00"))))
      (let* ((base-dur (cdr matching-assoc))
             (xtra-dur (cdr new-assoc))
             (tot-dur (string-time+ base-dur xtra-dur))
             (adj-new-assoc (cons (car new-assoc) tot-dur)))
        (cons adj-new-assoc keep-assocs))))

  (define(->str sm)(extract-binding/single sm bindings))
  ;
  (let*((changed-key (map ->str (list 'category 'activity)))
        (timestr (->str 'duration ))
        (new-assoc (cons changed-key timestr)))
    (put-assoc-to-db new-assoc))

  (send/suspend/dispatch render-page))
 
