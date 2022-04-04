#lang racket
(require  seq/iso yaml canonicalize-path)

(provide config-nth-activity config-nth-category
         config-schema-categories config-schema-subcategories)

(define *config-schema
  (let* ((base "config/schema.yaml")
         (base+ "../config/schema.yaml"))
    (with-input-from-file
        (if (file-exists? base ) base base+ )
      (lambda() (read-yaml)))))

(define (config-schema-categories) (hash-keys *config-schema))
(define (config-schema-subcategories cat)
  (hash-ref *config-schema cat)) 
(define (config-nth-category  n) (nth n (config-schema-categories) ))
(define (config-nth-activity cat-ix  act-ix)
  (nth act-ix (config-schema-subcategories (config-nth-category cat-ix)) ))

