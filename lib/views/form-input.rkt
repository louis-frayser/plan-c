#lang racket

(provide crud/update handle-input-form process-input-form)

(require web-server/servlet srfi/19 (only-in srfi/13 string-take)
         "../config.rkt" "../db/db-api.rkt" "../http-basic-auth.rkt")

;;; ==============================================================
;;;              INPUT FORM
(define (handle-input-form req render-page)
  (define user (request->user req))
  (process-input-form (request-bindings req) user render-page))

(define (process-input-form bindings user render-page)
  ;;; We are looking at a form that changes only one trie key (cat,act)
  ;;; The pair is of numerical indices representing strings in config
  ;;; config-schema-categories() and config-schema-subcategories()
  ;;; After decoding  the numbers into to strings, the struct is
  ;;; addressible for "update".
  ;;; adding in the  time from the original activity

  (define(->str sm)(extract-binding/single sm bindings))
  (define stime (if (exists-binding? 'stime bindings)
                    (string->date (->str 'stime) "~Y-~m-~dT~H:~M")
                    (current-date)))
  ;
  (let*((changed-key (map ->str (list 'category 'activity)))
        (timestr (->str 'duration ))
        (new-assoc (cons changed-key timestr)))
    (put-assoc-to-db new-assoc user #:tstamp stime))
  (redirect-to %servlet-path%))
;; .........................................................................................

(define (crud/update bindings req)
  ;; Bings has all the data necessary for an update
  (update-assoc-from-bindings bindings)
  (redirect-to
   (string-append %crud-url% "?req_date=" (string-take (extract-binding/single 'stime bindings) 10))))