#lang racket

(provide (all-defined-out))

(define %production% #f)
(define %port% (if %production% 8008 8000))
(define %version% (if %production% "0.0.1 pro" "0.0.1 dev"))

;; Default user for single-user-mode data
(define  %user% "frayser")

;; Database login credentials
(define-values ( %pg_user%  %pg_db% %pg_pass%) (values "frayser" "frayser" ""))
