#lang racket
;; This module manages the name space for database access
;; Old flat-file names were "get-xx" and rdbm functions are "db-get-xx"
;; In order to avoid accidents, we keep the  old names but sus it out
;; here where flat-file functions are referred to as "raw:get-xx"
;; Hopefully by only importing db-api.rkt, conflicts as be avoided.
(provide get-assocs get-assocs-by-datestr get-current-assoc-groups
         put-assoc-to-db)

(require db "db.rkt" (prefix-in raw: "db-files.rkt"))

(define-values (get-assocs-by-datestr     
                get-assocs
                put-assoc-to-db
                get-current-assoc-groups)

  (if (db-connected?) 
      (values   db-get-assocs-by-datestr
                db-get-assocs    
                assoc->rdbms
                db-get-current-assoc-groups)

      (values  raw:get-assocs-by-datestr
               raw:get-assocs
               raw:put-assoc-to-db  
               raw:get-current-assoc-groups)))