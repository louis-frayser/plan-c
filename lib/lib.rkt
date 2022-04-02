#lang racket
(provide debug strtime+)
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
        (~a hrs) ":" (~a mins #:min-width 2 #:left-pad-string "0" ))))))

(define (debug . values)
  (newline)
  (void (map (lambda(v)(printf "DEBUG: ~v\n" v)) values)))

;; (strtime+ "1:22" "2:35") ; => "3:57" Test