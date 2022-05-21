#lang racket

(provide handle-input-form process-input-form)
(require web-server/servlet debug
         "plan-data.rkt" "config.rkt" "lib.rkt" "db-api.rkt")

;;; ==============================================================
;;;              INPUT FORM
(define (handle-input-form req render-page)
  (define user (car (request->basic-credentials req)))
  (process-input-form (request-bindings req) user render-page))

(define (process-input-form bindings user render-page)
  ;;; We are looking at a form that changes only one trie key (cat,act)
  ;;; The pair is of numerical indices representing strings in config
  ;;; config-schema-categories() and config-schema-subcategories()
  ;;; After decoding  the numbers into to strings, the struct is
  ;;; addressible for "update".
  ;;; adding in the  time from the original activity

  (define(->str sm)(extract-binding/single sm bindings))
  ;
  (let*((changed-key (map ->str (list 'category 'activity)))
        (timestr (->str 'duration ))
        (new-assoc (cons changed-key timestr)))
    (put-assoc-to-db new-assoc user))
  (send/suspend/dispatch render-page))
