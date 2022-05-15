#lang racket

(provide (all-defined-out))

;; Default user for single-user-mode data
(define  %user% "frayser")

;; Database login credentials
(define-values ( %pg_user%  %pg_db% %pg_pass%) (values "frayser" "frayser" ""))
