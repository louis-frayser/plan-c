#lang debug racket ; crud.rkt
(provide crud)

(require web-server/servlet web-server/templates xml)
(require "../config.rkt"
         "../http-basic-auth.rkt"
         (only-in "../db/db.rkt" db-get-rows)
         "../lib.rkt")
;;;;; ============================================================================
(define (crud bindings req)
  (define date (if (exists-binding? 'req_date bindings)
                   (extract-binding/single 'req_date bindings)
                   (get-ymd-string)))
  (define-values (def-stime def-dur hlink-dev-data-update)
    (values (now-str) "00:20" "<!-- -->"))
  (response/xexpr
   #:preamble #"<!DOCTYPE html>\n"
   `(html
     (head (title ,(string-append "Plan C | CRUD " %version%)) "\n"
           (link ((rel "stylesheet")(href "/files/styles.css")))
           (script ((src "/scripts/js/crud.js")(type "module")))
           (script ((src "/scripts/plan.js")(type "module")))
           )

     (body
      (h1 "CRUD") "\n"
      ,(string->xexpr (include-template "../../files/time-frame.html"))"\n"
      (h2 "Create, Read, Update, Delete") "\n"
      
     
       (form ((id "crud_form")(action ,%crud-url%) (method "get"))"\n"
             ,(gen-table #:for-date date #:for-user (request->user req)) "\n"
             (div ((id "hidden_vars"))))
      
      "\n"
      (dialog ((id "crud_dlg"))
              ,(add-form-action
               (string->xexpr (include-template "../../files/input-form.html"))
               (string-append %crud-url% "/update"))
              "\n")
     ))))

;;; -------------------------------------------------------------------------
(define (gen-table #:for-date (ymd  (get-ymd-string)) #:for-user user)
  (define tdata (db-get-rows #:for-date  ymd  #:user user))

  (define (gen-new-button)    '(button ((type "button")(class "crud_butt")(id "IDB_ADD"))"Add"))
  (define (gen-del-button)    '(button ((type "button")(class "crud_butt")(id "IDB_DEL"))"Del"))
  (define (gen-edit-button) '(button ((type "button")(class "crud_butt")(id "IDB_EDIT"))"Edit"))

  (define (gen-row rdata)
    (let* ((rowno (car rdata))
           (rowid (~s rowno))
           (selid (format "IDSEL~s" rowno))
           (iddstime (format "IDSTIME~s" rowno))
           (iddcat (format "IDCAT~s" rowno))
           (iddact (format "IDACT~s" rowno))
           (idddur (format "IDDUR~s" rowno)))
      `(tr
        (td (input
             ((type "radio")
              (class "sel_col") (id ,selid) (rowid ,rowid) (value ,rowid) (name "sel"))))
        (td ((id ,iddstime)) ,(second rdata))
        (td ((id ,iddcat )) ,(third rdata))
        (td ((id ,iddact)) ,(fourth rdata))
        (td ((id ,idddur)(class "duration")),(last rdata)))))

  `(table ((id "crud_table"))
          (caption ,(gen-new-button) ,(gen-del-button) ,(gen-edit-button)
                   (input ((id "crud_date")(name "req_date")(type "date") (value ,ymd)))
                   (a ((id "ida_ret")(href ,%servlet-path%)(title "Go back to main form"))
                      "Plan-C"))
          (thead
           (tr (th ((id "thsel"))"Select")
               (th "Start")
               (th ((id "thcat")) "Category")
               (th "Activity")
               (th ((class "duration"))"Duration")))
          "\n"
          ,@(add-between (map gen-row tdata) "\n") "\n"))
;;; -------------------------------------------------------------------------
