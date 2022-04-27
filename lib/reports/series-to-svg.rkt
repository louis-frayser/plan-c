#lang racket
;;;; bargraph from a data series
;;; ==========================================================================
(provide minutes-daily->svg-file minutes-daily->svg-string)

(require simple-svg)
;;; --------------------------------------------------------------------------

(define outfile (path->string (build-path (current-directory) "route5.svg")))
(define canvas_size 800)
;;; ------------------------------------------------------------------------
(define *sstyle
  (let ([_sstyle (sstyle-new)])
    (sstyle-set! _sstyle 'stroke "green")
    (sstyle-set! _sstyle 'stroke-width 1)
    _sstyle))
;;; ............................................................................
(define margin 10)
(define w 10)
(define dx 15)
(define hmax 270 #; (*4.5 60)); 4-1/2 hrs
(define xmax (+  margin (* 30.5 dx))) (define ymax (+ hmax margin))
(define (rand-h) (random 0 hmax))
(define (use-rect@ x y w h)
  (let (( rect (svg-def-rect w h))
        [_sstyle (sstyle-new)])  
    (sstyle-set! _sstyle 'fill "green")
    (svg-use-shape rect _sstyle #:at?  (cons x  (- ymax h)))))

(define (use-text@ tx x y)
  (let ([text (svg-def-text tx #:font-size? 12)]
        [_sstyle (sstyle-new)])
    (sstyle-set! _sstyle 'fill "black")
    (svg-use-shape text _sstyle #:at? `(,x .,y))))
;;;............................................................................
(define (bar-graph5 series)
  (define (bar-graph)   ;; passing-in data as arg <= FIXME!
    (let loop ( (x margin ) (rest-data series  ) (ix 1 ))
      (cond 
        ((null? rest-data ) #t)
        (else
         (use-rect@ x margin w (car rest-data)) 
         (use-text@ (number->string ix) x (+ margin ymax))
         (loop (+ x dx) (cdr rest-data) (+ ix 1)))))
    (svg-show-default))
  bar-graph)
;;; ---------------------------------------------------------------------------

(define (minutes-daily->svg-string series)
  (svg-out canvas_size canvas_size (bar-graph5 series)))

(define (minutes-daily->svg-file series path)
  (with-output-to-file path
    (lambda() (displayln (minutes-daily->svg-string series)))
    #:exists 'replace))
;;; ============================================================================
#;(begin
  (define data-series
    (do ( (i 1 (+ i 1)) (h (rand-h) (rand-h)) (acc '() (cons h acc)))
      ( (>= i 31) (cons h acc))))

  (series->svg-file data-series "/tmp/foo.svg"))