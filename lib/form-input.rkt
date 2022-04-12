#lang debug racket

(provide handle-input-form process-input-form plan-report render-page (struct-out plan))
(require web-server/servlet)
(require "plan-c-data.rkt" "config.rkt" "render.rkt" debug "lib.rkt" "db-files.rkt")

(define (render-page embed/url)
  (response/xexpr #:preamble #"<!DOCTYPE html>\n"
                   (plan-report embed/url handle-input-form)))

;;; ==============================================================
;;;              INPUT FORM
(define (handle-input-form req) (process-input-form (request-bindings req)))
(define (process-input-form bindings)
  ;;; We are looking at a form that changes only one trie key (cat,act)
  ;;; The pair is of numerical indices representing strings in config
  ;;; config-schema-categories() and config-schema-subcategories()
  ;;; After decoding  the numbers into to strings, the struct is
  ;;; addressible for "update".
  (void #RRR bindings); (debug-value "process-input-form with bindings: ~v"  bindings)
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
             (tot-dur (strtime+ base-dur xtra-dur))
             (adj-new-assoc (cons (car new-assoc) tot-dur)))
        (cons adj-new-assoc keep-assocs))))

  (define(->str sm)(extract-binding/single sm bindings))
  ;
  (let*((changed-key (map ->str (list 'category 'activity)))
        (timestr (->str 'duration ))
        (new-assoc (cons changed-key timestr)))
    (put-assoc-to-db new-assoc))

  (send/suspend/dispatch render-page))
 
