#lang racket

(provide ->string debug get-ymd-string strtime+)
(require srfi/19)
;; ========================================================================
(define (debug . values)
  (newline)
  (void (map (lambda(v)(printf "DEBUG: ~v\n" v)) values)))
;; -------------------------------------------------------------------------
;;; Add time-duration strings
(define (strtime+ strt1 strt2)
  (let*((2lists (map (lambda(s)(string-split s ":"))(list strt1 strt2)))
        (2Nlists (map (lambda(ls)(map string->number ls)) 2lists))
        (mins-ea (map (lambda(nlist)
                        (+ (* 60 (car nlist)) (cadr nlist))) 2Nlists))
        (tmins (apply + mins-ea)))
    (call-with-values
     (lambda()(quotient/remainder tmins 60))
     (lambda(hrs mins)
       (string-append
        (~a hrs) ":" (~a mins #:align 'right 
                         #:min-width 2 #:left-pad-string "0" ))))))
;; .......................................................................
;;; Get date string
(define get-ymd-string (lambda() (date->string (current-date) "~1")))
;
;; .......................................................................

(define (->string obj)
  ;; Converts all symbols to strings in a trie of all symbols
  (if (pair? obj) (map ->string obj) (symbol->string obj)))

;;; ========================================================================