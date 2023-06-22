#lang racket ;lib.rkt

(provide ~0 add-form-action days-ago->string elapsed->start-time-str 
         get-ymd-string hs:take-right read-file stderr
        now-hh-mm-str now-str string-time+  time-elapsed-hmm-str time-string->mins write-file )

(require (except-in srfi/1 drop) srfi/19
         db)
(require (only-in racket-hacks drop))
;; ========================================================================
(require syntax/parse/define)
(define stderr (current-error-port))
;; -------------------------------------------------------------------------
(define (hs:take-right n list/string)
  (define is-string (string? list/string))
  (define l (if is-string (string->list list/string) list/string))
  (define r0 (if (<= (length l ) n) l (take-right l n)))
  (if is-string (list->string r0) r0))
;; -------------------------------------------------------------------------
#;(define-syntax-parse-rule (info x:id)
  `( ,x x ,(length x)))

(define (~0 n) (~a n  #:align 'right #:min-width 2  #:pad-string "0"))


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
;
(define (time-string->mins hh:mm-str)
  (let*-values ( ((h m0) (car+cdr (map string->number
                                       (string-split hh:mm-str ":") )))
                 ( (m) (first m0)))
    (+ (* h 60) m)))

(define (time-string->hrs hh:mm-str)
  (/ (time-string->mins hh:mm-str) 60))

;; ...........................................................................

(define (days-ago->date days-ago)
  (seconds->date (- (current-seconds)  (* days-ago (* 24 3600)))))

(define (days-ago->string ndays)
  (date->string (days-ago->date ndays) "~Y-~m-~d"))

;; ...........................................................................
(define (time-elapsed-hmm-str (since-hmm "00:00"))
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
(define (now-hh-mm-str) (time-elapsed-hmm-str "00:00"))
;; .......................................................................

(define (elapsed->start-time-str elapsed-str); Calculate start from elapsed time
  (let* ((e-h+m (map string->number (string-split elapsed-str ":")))
          (esecs (+ (* 3600 (car e-h+m)) (* 60 (cadr e-h+m)) ))
          (ssecs (- (current-seconds) esecs))
          (stime (seconds->date ssecs)))
    (date->string stime "~Y-~m-~dT~H:~M")))
;; .......................................................................
;;; Get date string for today
(define get-ymd-string (lambda() (date->string (current-date) "~1")))
;;.......................................................................

(define (->string obj)
  ;; Converts all symbols to strings in a trie of all symbols
  (if (pair? obj) (map ->string obj) (symbol->string obj)))

(define (now-str)  (string-append (get-ymd-string) "T" (now-hh-mm-str)))
;;; ------------------------------------------------------------------------
;;; DSK File I/O
(define (read-file path/string)
  (with-input-from-file path/string (lambda()(read))))

(define (write-file path sexpr)
  (with-output-to-file path
    (lambda() (displayln sexpr)) #:exists 'replace))
;;; -------------------------------------------------------------------------
(define (add-form-action form action-url)
  ;; form is sxml
    (let* (( head (first form))
           (orig-atts (second form))
           (rest (drop  2 form ))
           (new-atts (cons `(action ,action-url) orig-atts)))
      (append (list head new-atts ) rest)))

;;; ========================================================================