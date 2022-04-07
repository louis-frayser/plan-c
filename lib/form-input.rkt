#lang racket

(provide handle-input-form plan-c process-input-form plan-report render-page (struct-out plan))
(require web-server/templates web-server/servlet)
(require xml srfi/19 (only-in seq/iso drop)
         "plan-c-data.rkt" "config.rkt" "render.rkt"
         "generate-js.rkt" "lib.rkt" "db-files.rkt")

(define (render-page embed/url)
  (response/xexpr  #:preamble #"<!DOCTYPE html>\n"
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
  (eprintf "\nDEBUG: process-input-form: bindings == ~v\n\n" bindings)
  (define (changed-key cx ax) (list (config-nth-category cx)
                                    (config-nth-activity cx ax)))
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

  (define(->int sm)(string->number(extract-binding/single sm bindings)))
  ;
  (let*( (cx (->int 'category ))
         (ax (->int 'activity ))
         (timestr (extract-binding/single 'duration bindings))
         (new-assoc (cons (changed-key cx ax) timestr)))
    (put-assoc-to-db new-assoc)
    (let* ( (orig-assocs (plan-assocs (plan-c)))
            (new-assocs+ (new-assocs orig-assocs new-assoc))
            (new-groups (plan-list->groups new-assocs+))
            (new-plan
             (plan (plan-version (plan-c)) (plan-date (plan-c)) new-groups) ))
      (plan-c new-plan)))
  (send/suspend/dispatch render-page))
 
