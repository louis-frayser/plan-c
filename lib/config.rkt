#lang racket

(provide %auth-db-path% %auth-db-path% %crud-url% %db-base-dir% %dev%
         %orig-dir%
         %pg_user% %pg_db% %pg_pass%
         %practice-target-mins%
         %port%
         %production% %servlet-path% %user% %version%
         config-nth-activity config-nth-category config-schema-categories
         config-schema-subcategories get-all-instrument-templates)

(require  seq/iso yaml "../config/plan-c-rc.scm")

;(provide %port%)

;;;NOTE: this must run from the program's home: see plan-c, the shell script.
(define %orig-dir%
  (begin
    (cond ((directory-exists? "../../htdocs")
           (current-directory "../.."))
          ((directory-exists? "../htdocs")
           (current-directory "..")))
    (current-directory)))
;;; ..................................................................

(define %dev% (file-exists? (build-path %orig-dir% "devel" )))
(define %production% (not %dev%))
;;; ..................................................................

(define %port% (if %production% 8008 8000))
(define %version% (string-append (file->string
                                  (build-path %orig-dir% "files/version")) 
                                 (if %production% " pro" " dev")))

(define %db-base-dir% (build-path %orig-dir% "files/db"))
;;; ..................................................................

(define %servlet-path% "/servlets/PLAN-C")
(define %crud-url% (string-append %servlet-path% "/crud"))
(define %auth-db-path% (path->string (build-path  %orig-dir% "config/passwd")))
;; --------------------------------------------------------------------
(define *config-schema
  (let* ((schema-file (build-path %orig-dir% "config/schema.yaml")))
    (with-input-from-file
        schema-file
      (lambda() (read-yaml)))))

(define (config-schema-categories) (sort(hash-keys *config-schema) string<?))
(define (config-schema-subcategories cat)
  (hash-ref *config-schema cat))
(define (config-nth-category  n) (nth n (config-schema-categories) ))
(define (config-nth-activity cat-ix  act-ix)
  (nth act-ix (config-schema-subcategories (config-nth-category cat-ix)) ))

(define (get-all-instrument-templates)
  (map (lambda(i)(cons (list "Music Practice" i) "0:00"))
       (config-schema-subcategories "Music Practice")))
