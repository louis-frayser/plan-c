#lang debug racket
(provide crud)

(require web-server/servlet)
(require "../config.rkt"
         "../db.rkt"
         "../lib.rkt")
;;; ============================================================================
(define (gen-table #:for-date (ymd  (get-ymd-string)))
  (define tdata (db-get-rows
                 #:for-date  ymd  #:user "frayser"))

  (define (gen-row rdata) `(tr
                            (td ,(car rdata))    
                            (td ,(second rdata)) 
                            (td ,(third rdata))  
                            (td ,(last rdata))))
  `(table ((id "crud-table")) (caption (a ((href ,%servlet-path%)) ,ymd))
          (tr (th "Start")
              (th ((id "cat-col")) "Category")
              (th "Activity") (th "Duration")) "\n"
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
