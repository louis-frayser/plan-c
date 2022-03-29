#lang racket
(require yaml)

(provide config-schema-categories config-schema-subcategories)

(define *config-schema
  (with-input-from-file "config/schema.yaml"
  (lambda() (read-yaml))))

(define (config-schema-categories) (hash-keys *config-schema))
(define (config-schema-subcategories cat)
  (hash-ref *config-schema cat))