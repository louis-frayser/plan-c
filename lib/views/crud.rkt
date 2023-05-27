#lang debug racket ; crud.rkt
(provide crud)

(require web-server/servlet)
(require "../config.rkt"
         (only-in "../db/db.rkt" db-get-rows)
         "../lib.rkt")
;;;;; ============================================================================
(define (crud bindings req)
  (define date (if (exists-binding? 'req_date bindings)
                   (extract-binding/single 'req_date bindings)
                   (get-ymd-string)))
  (response/xexpr
   #:preamble #"<!DOCTYPE html>\n"
   `(html
     (head (title ,(string-append "Plan C | CRUD " %version%)) "\n"
           (link ((rel "stylesheet")(href "/files/styles.css")))
           (script ((src "/scripts/js/crud.js")#;(type "module")))
           )
                                                   
     (body 
      (h1 "CRUD") "\n"
      (h2 "Create, Read, Update, Delete") "\n"
      (form ((id "crud_form")(action ,%crud-url%) (method "get"))"\n"
            ,(gen-table #:for-date #R  date) "\n") "\n" )
     )))

;;; -------------------------------------------------------------------------
(define (gen-table #:for-date (ymd  (get-ymd-string)))
  (define tdata (db-get-rows
                 #:for-date  ymd  #:user "frayser"))

  (define (gen-row rdata)
    (let ((id (~s (car rdata))))
    `(tr
      (td (input ((type "radio") (id ,id) (value ,id) (name "sel"))))
      (td ,(second rdata))
      (td ,(third rdata))
      (td ,(fourth rdata))
      (td ,(last rdata)))))
  
  `(table ((id "crud_table"))
          (caption (a ((href ,%servlet-path%)
                       (title "Go back to main form"))
                      (input ((id "crud_date")(name "req_date")(type "date") (value ,ymd)))))
          (tr (th "Select")
              (th "Start")
              (th ((id "cat-col")) "Category")
              (th "Activity")
              (th "Duration"))
          "\n"
          ,@(add-between (map gen-row #R tdata) "\n") "\n"))
;;; -------------------------------------------------------------------------
