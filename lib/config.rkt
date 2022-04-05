#lang racket
(require  seq/iso yaml canonicalize-path "lib.rkt")


(provide config-nth-activity config-nth-category
         config-schema-categories config-schema-subcategories %orig-dir%)

(define %orig-dir% (find-system-path 'orig-dir))

;; --------------------------------------------------------------------
(define *config-schema
  (let* ((schema-file (build-path %orig-dir% "config/schema.yaml")))
    (with-input-from-file
        schema-file
      (lambda() (read-yaml)))))

(define (config-schema-categories) (hash-keys *config-schema))
(define (config-schema-subcategories cat)
  (hash-ref *config-schema cat)) 
(define (config-nth-category  n) (nth n (config-schema-categories) ))
(define (config-nth-activity cat-ix  act-ix)
  (nth act-ix (config-schema-subcategories (config-nth-category cat-ix)) ))

