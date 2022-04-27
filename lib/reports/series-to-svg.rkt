#lang debug racket
;;;; bargraph from a data series
;;; ==========================================================================
(provide minutes-daily->svg-file minutes-daily->svg-string)
(require srfi/13)
(require simple-svg)
;;; --------------------------------------------------------------------------

(define outfile (path->string (build-path (current-directory) "route5.svg")))
(define canvas_size '(370 . 300 ))
;;; ------------------------------------------------------------------------
(define *sstyle
  (let ([_sstyle (sstyle-new)])
    (sstyle-set! _sstyle 'stroke "green")
    (sstyle-set! _sstyle 'stroke-width 1)
    _sstyle))
;;; ............................................................................
(define margin 5)
(define w 10)
(define dx 12)
(define hmax 270 #; (*4.5 60)); 4-1/2 hrs
(define xmax (+  margin (* 30.5 dx))) (define ymax (+ hmax margin))
(define (rand-h) (random 0 hmax))
(define (use-rect@ x y w h)
  (let (( rect (svg-def-rect w h))
        [_sstyle (sstyle-new)])  
    (sstyle-set! _sstyle 'fill "green")
    (svg-use-shape rect _sstyle #:at?  (cons x  (- ymax h)))))

(define (use-text@ tx x y)
  (let ([text (svg-def-text tx #:font-size? 11)]
        [_sstyle (sstyle-new)])
    (sstyle-set! _sstyle 'fill "black")
    (svg-use-shape text _sstyle #:at? `(,x .,y))))
;;;............................................................................
(define (bar-graph series)
  ;; if series is an alist then use car as an index (ix), else count 1,2,3...
  ;;; ix must be string.
  (define _series
    (cond
      ((and (pair? series) (pair? (car series)))
       (map (lambda(pr)(cons (string-take-right (car pr) 2) (cdr pr)))
       series))
      (else (let loop ( (rest series) (i 1) (acc '())) 
              (if (pair? rest)
                  (loop (cdr rest) (+ i 1)
                        (cons (cons (number->string i) (car rest)) acc))
                  (reverse acc))))))                                                   
  (define (bar-graph5)
    (let loop ( (x margin ) (rest-data _series)
                            (ix (and (pair? _series)(caar _series))))
      (cond 
        ((null? rest-data ) #t)
        (else 
         (use-rect@ x margin w (cdar rest-data)) 
         (use-text@  ix x (+ (* 2 margin) ymax))
         (loop (+ x dx) (cdr rest-data)
               (and (pair? (cdr rest-data)) (caadr rest-data)) ))))
    (svg-show-default))
  bar-graph5)
;;; ---------------------------------------------------------------------------

(define (minutes-daily->svg-string series)
  (svg-out (car canvas_size) (cdr canvas_size) (bar-graph series)))

(define (minutes-daily->svg-file series path)
  (with-output-to-file path
    (lambda() (displayln (minutes-daily->svg-string series)))
    #:exists 'replace))
;;; ============================================================================
#;(begin ; DEMO
    (define data-series
      (do ( (i 1 (+ i 1)) (h (rand-h) (rand-h)) (acc '() (cons h acc)))
        ( (>= i 31) (cons h acc))))

    (series->svg-file data-series "/tmp/foo.svg"))