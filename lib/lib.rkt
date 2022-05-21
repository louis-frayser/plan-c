#lang debug racket

(provide ~0 get-ymd-string hs:take-right (all-defined-out))

(require srfi/1 srfi/19)

;; ========================================================================
(require syntax/parse/define)
;; -------------------------------------------------------------------------
(define (hs:take-right n list/string)
  (define is-string (string? list/string))
  (define l (if is-string (string->list list/string) list/string))
  (define r0 (if (<= (length l ) n) l (take-right l n)))
  (if is-string (list->string r0) r0))
      
  
;; -------------------------------------------------------------------------

;(define-syntax-parse-rule (fn x:id rhs:expr) (lambda (x) rhs))
(define-syntax-parse-rule (info x:id)
  `( ,x x ,(length x)))

(define (~0 n) (~a n  #:align 'right #:min-width 2  #:pad-string "0"))

(define (integer  x)
  (inexact->exact (round x)))
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

(define (time-string->mins hh:mm-str)
  (let*-values ( ((h m0) (car+cdr (map string->number
                                       (string-split hh:mm-str ":") )))
                 ( (m) (first m0)))
    (+ (* h 60) m)))

(define (time-string->hrs hh:mm-str)
  (/ (time-string->mins hh:mm-str) 60))
;; .......................................................................

(define (a-month-ago-str)
  ;; Returns last-month on the cadinal day 1 before today
  (let*((jdn (current-julian-day))
        (jmonth-ago (integer (- jdn 30)))
        (month-ago (julian-day->date jmonth-ago)))
    (date->string month-ago "~Y-~m-~d")))

(define (time-elapsed-hmm-str since-hmm)
  ;; Elapsed time since given time (same day)
  (define now
    (let*((d (current-date )) ; local mins since midnight localtime
          (h (date-hour d))
          (m (date-minute d)))
      (+ (* h 60) m)))
  (define  then
    ((lambda()
      (define hr-min-lst (map string->number (string-split since-hmm ":") ))
      (let( (hrs (first hr-min-lst)) (mins (second hr-min-lst)) )
        (+ (* hrs 60) mins)) )))
  (let*-values ( ((hrs mins ) (quotient/remainder (-  now then) 60)) )
    (string-join (map number->string `(,hrs ,mins)) ":")
    (string-append
     (~a hrs) ":" (~a mins #:width 2 #:align 'right #:left-pad-string "0"))))

;; .......................................................................
;;; Get date string for today
(define get-ymd-string (lambda() (date->string (current-date) "~1")))
;
;; .......................................................................

(define (->string obj)
  ;; Converts all symbols to strings in a trie of all symbols
  (if (pair? obj) (map ->string obj) (symbol->string obj)))
;;; ------------------------------------------------------------------------
;;; DSK File I/O
(define (read-file path/string)
  (with-input-from-file path/string (lambda()(read))))

(define (write-file path sexpr)
  (with-output-to-file path
    (lambda() (displayln sexpr)) #:exists 'replace))

;;; ------------------------------------------------------------------
;;; ========================================================================