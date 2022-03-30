#lang racket
(require yaml canonicalize-path )

(provide config-schema-categories config-schema-subcategories)

(define *config-schema
  (let* ((base "config/schema.yaml")
         (base+ "../config/schema.yaml"))
    (with-input-from-file
        (if (file-exists? base ) base base+ )
    (lambda() (read-yaml)))))

(define (config-schema-categories) (hash-keys *config-schema))
(define (config-schema-subcategories cat)
  (hash-ref *config-schema cat))
