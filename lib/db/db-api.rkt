#lang racket
;; This module manages the name space for database access
;; Old flat-file names were "get-xx" and rdbm functions are "db-get-xx"
;; In order to avoid accidents, we keep the  old names but sus it out
;; here where flat-file functions are referred to as "raw:get-xx"
;; Hopefully by only importing db-api.rkt, conflicts as be avoided.
(provide db-exec  get-assocs get-assocs-by-datestr get-current-assoc-groups
         get-max-ctime-string
         put-assoc-to-db update-assoc-from-bindings)

(require db "db.rkt" (prefix-in raw: "db-files.rkt"))

(define-values (get-assocs-by-datestr     
                get-assocs
                put-assoc-to-db
                get-current-assoc-groups
                update-assoc-from-bindings
                get-max-ctime-string)

  (if (db-connected?) 
      (values   db-get-assocs-by-datestr
                db-get-assocs    
                assoc->rdbms
                db-get-current-assoc-groups
                db-update-assoc-from-bindings
                db-get-max-ctime-string)

      (values  raw:get-assocs-by-datestr
               raw:get-assocs
               raw:put-assoc-to-db  
               raw:get-current-assoc-groups
               #f  ; No flat-file based alternative
               "00:00" ;; No calculated startime for files db
               )))