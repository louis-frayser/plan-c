#lang racket

(provide (all-defined-out))

;; Default user for single-user-mode data in db.rkt
(define  %user% "frayser")

;; Database login credentials
(define-values ( %pg_user%  %pg_db% %pg_pass%) (values "frayser" "frayser" ""))

;; Defines where the 'target' indication is plotted
(define %practice-target-mins% 150)
