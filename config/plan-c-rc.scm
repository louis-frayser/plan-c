#lang racket

(provide (all-defined-out))

(define %production% #t)
(define %port% (if %production% 8008 8000))
(define %version% (if %production% "0.0.1 pro" "0.0.1 dev"))
(define-values ( %pg_user%  %pg_db% %pg_pass%) (values "frayser" "frayser" ""))
