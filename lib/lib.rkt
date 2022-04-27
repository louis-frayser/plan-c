#lang racket

(provide (all-defined-out))
(require srfi/1 srfi/19)

;; ========================================================================
(require syntax/parse/define)

;(define-syntax-parse-rule (fn x:id rhs:expr) (lambda (x) rhs))
(define-syntax-parse-rule (info x:id)
  `( ,x x ,(length x)))

;; -------------------------------------------------------------------------
;;; Add time-duration strings
(define (string-time+ .  strings)
  (with-handlers ((exn:fail? (lambda(exn)(eprintf "strtime+: ~v ~v~n"
                                                  strings  exn))))
    (let*((lists (map (lambda(s)(string-split s ":")) strings))
          (nlists (map (lambda(ls)(map string->number ls)) lists))
          (mins-ea (map (lambda(nlist)
                          (+ (* 60 (car nlist)) (cadr nlist))) nlists))
          (tmins (apply + mins-ea)))
      (call-with-values
       (lambda()(quotient/remainder tmins 60))
       (lambda(hrs mins)
         (string-append
          (~a hrs) ":" (~a mins #:align 'right 
                           #:min-width 2 #:left-pad-string "0" )))))))

(define (time-string->hrs hh:mm-str)
  (let*-values ( ((h m0) (car+cdr (map string->number
                                       (string-split hh:mm-str ":") )))
                 ( (m) (first m0)))
    (+ h  (/ m 60))))


;; .......................................................................
;;; Get date string
(define get-ymd-string (lambda() (date->string (current-date) "~1")))
;
;; .......................................................................

(define (->string obj)
  ;; Converts all symbols to strings in a trie of all symbols
  (if (pair? obj) (map ->string obj) (symbol->string obj)))

;;; ========================================================================