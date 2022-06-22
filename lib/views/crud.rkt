#lang debug racket
(provide crud)

(require web-server/servlet web-server/templates)
(require xml (only-in seq/iso drop)
         "../analysis.rkt" "../config.rkt"
         "../db.rkt"
         "../db-api.rkt"
         "../form-input.rkt"
         "../generate-js.rkt"
         "../lib.rkt"
         "../plan-data.rkt")
;;; ============================================================================
(define (gen-table)
  (define tdata (db-get-rows
                 #:for-date  (get-ymd-string) #:user "frayser"))

  (define (gen-row rdata) `(tr
                            (td ,(car rdata))    
                            (td ,(second rdata)) 
                            (td ,(third rdata))  
                            (td ,(last rdata))))
  `(table ((id "crud-table"))
    (tr (th "Start") (th "Category") (th "Activity") (th "Duration")) "\n"
    ,@(add-between (map gen-row tdata) "\n") "\n"))
#R (gen-table)
;;; ----------------------------------------------------------------------------
(define (crud bindings req)
  (response/xexpr
   #:preamble #"<!DOCTYPE html>\n"
   `(html
     (head (title ,(string-append "Plan C | CRUD " %version%)) "\n"
           (link ((rel "stylesheet")(href "/files/styles.css"))))
                                                   
     (body
      (h1 "CRUD") "\n"
      (h2 "Create, Read, Update, Delete") "\n"
     ,(gen-table) "\n")
   )))
