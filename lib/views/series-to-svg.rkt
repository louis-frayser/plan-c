#lang debug racket ;; series-to-svg.rkt
;;;; bargraph from a data series
;;; ==========================================================================
(provide minutes-daily->svg-file instrument-summary->svg-file)
(require srfi/13)
(require simple-svg)
(require (only-in racket-hacks integer take-end))
(require "../db/db-files.rkt" "../lib.rkt" "../config.rkt")
;;; --------------------------------------------------------------------------

(define canvas-size '(395 . 333 )) ; 25.384 x Number of instruments
;;; ------------------------------------------------------------------------

(define *sstyle-blk
  (let ([_sstyle (sstyle-new)])
    (sstyle-set! _sstyle 'stroke "black")
    (sstyle-set! _sstyle 'stroke-width 1)
    _sstyle))

(define *sstyle-gry
  (let ([_sstyle (sstyle-new )])
    (sstyle-set! _sstyle 'stroke "#aaaaaa" )
    (sstyle-set! _sstyle 'stroke-width 1)
    (sstyle-set! _sstyle 'stroke-dasharray "4 1")
    _sstyle))

(define %sstyle-red
  (let ([_sstyle (sstyle-new )])
    (sstyle-set! _sstyle 'stroke "red" )
    (sstyle-set! _sstyle 'stroke-width 1)
    (sstyle-set! _sstyle 'stroke-dasharray "0")
    _sstyle))               

;;; ..........................................................................
(define-values (margin xmargin bot_margin) (values 5 5 5 ))
(define w 10)
(define dx 13)
(define hmax 270 #; (*4.5 60)); 4-1/2 hrs
(define xmax (integer (+  margin (* 30.5 dx))) )
(define ymax (+ hmax margin))
(define (rand-h) (random 0 hmax))

(define (use-rect@ x y w h #:horiz? (horiz? #f))
  (let (( rect (svg-def-rect w (min h hmax)))
        [_sstyle (sstyle-new)]
        (y_adj (if (> (+ h y) hmax ) hmax (- hmax h (- y bot_margin))))) ; limit h to hmax
    (sstyle-set! _sstyle 'fill "#3f9f3f")
    (svg-use-shape rect _sstyle #:at?  (cons x  (if horiz? y y_adj  )))))

(define (use-text@ tx x y)
  (let ([text (svg-def-text tx #:font-size? 11)]
        [_sstyle (sstyle-new)])
    (sstyle-set! _sstyle 'fill "black")
    (svg-use-shape text _sstyle #:at? `(,x .,y))))
;; ............................................................................
(define (horizontal-bar-graph series)
  ;; series must be alist of (string . integer), ie: label x minutes
  ;; scale = canvas-width - label-width - magin(s) / (15 * 60)
  ;; scale: expecting 15hrs / month per instrument
  (define-values (dy label-width) (values dx 48))
  (define (bar-graph5h)
    (let loop ( (y margin) (rest-data series)
                           (ix (and (pair? series)(caar series))))
      (cond
        ((null? rest-data ) #t)
        (else
         (let* ((mins (cdar rest-data))
                (hrs (exact->inexact (/ mins 60.0)))
                (scaled (integer (* mins 0.34))) ; scale to fit canvas-width
                (y-adj (+ y (integer (* 1.5 margin)))))
           (use-rect@ (+ margin label-width) y scaled  w  #:horiz? #t)
           (use-text@  ix margin y-adj)
           (use-text@ (string-append (~r hrs #:precision '(= 1)
                                         #:min-width 4 #:pad-string "\u2000")
                                     " hrs")
                      (integer (/ (car canvas-size) 2)) y-adj)
           (loop (+ y dy) (cdr rest-data)
                 (and (pair? (cdr rest-data)) (caadr rest-data)) )))))
    (svg-show-default))
  bar-graph5h)
;;;............................................................................

(define (vertical-bar-graph series #:sma (sma-series #f))
  ;; if series is an alist then use car as an index (ix), else count 1,2,3...
  ;;; ix must be string.
  ;;; NOTE: If series is > 30 elements the plot is truncated due to imgae size, so
  ;;; we limit _series to 30.
  (define _series
    (take-end
     30
     (cond
       ( (and (pair? series) (pair? (car series)) (pair? (cdar series)))
         (error "assoc list series must be a list of dotted pairs!"))
       ((and (pair? series) (pair? (car series)))
        (map (lambda(pr)(cons (string-take-right (car pr) 2) (cdr pr)))
             series))
       (else (let loop ( (rest series) (i 1) (acc '()))
               (if (pair? rest)
                   (loop (cdr rest) (+ i 1)
                         (cons (cons (number->string i) (car rest)) acc))
                   (reverse acc)))))))

  (define (bar-graph5)
    ;;; Number (and invert) each SMA value with counter => a series of pairs
    ;;; Shift x +(width/2) to place line vertices in middle of bars
    (define (label-series x0 dx series)
      (define (offset x) (integer (+ x (/ w 2))))
      (do ( (x (offset x0) (+ x dx))
            (vrest series (cdr vrest))
            (acc null (cons (cons x (- ymax (car vrest))) acc)))
        ( (null? vrest) (reverse acc))))
    ;;; Horiz grid lines
    (define lbl-x (integer (- xmax (* 2 w))))
    (define (use-hline y #:style (style *sstyle-gry))
      (let* ((yval (- ymax y))
             [line (svg-def-line `(0 . ,yval) `(,xmax . ,yval))])
        (svg-use-shape line style #:at? '(0 . 0))))
    
    ;;; ..
    (let loop ( (x margin ) (rest-data _series)
                            (ix (and (pair? _series)(caar _series))))
      (cond
        ((null? rest-data ) #t)
        (else 
         (use-rect@ x 0 w (min (cdar rest-data) hmax)) ; vertical bar; hmax is 4.5hr data clip
         (use-text@  ix x (+ (* 2 margin) (+ ymax 2))) ; horiz axis label
         (loop (+ x dx) (cdr rest-data)
               (and (pair? (cdr rest-data)) (caadr rest-data)) ))))
    ;; Polyline plot for SMA  
    (when sma-series
      (let* ((xs (label-series margin dx sma-series))
             (polyline (svg-def-polyline xs)))
        (svg-use-shape polyline *sstyle-blk #:at? '(0 . 0))))
    ;; Lables for amplitude
    (use-hline 0) ;lowest value (0)
    (use-hline  %practice-target-mins% #:style %sstyle-red) ; target
    (do ( (y 30 (+ y 30)) (n 4 (- n 1/2 ))) ; 4-1/2 hrs of grid
      ( (> y ymax) (void))
      (use-hline y)
      (when (and (integer? n) (> n 0)) ; verticle axis labels
        (use-text@  (string-append (number->string n) "h") lbl-x (+ y 4))))
    (svg-show-default))
  bar-graph5)
;; ...........................................................................

(define (bar-graph 
         series #:orientation (orient 'vertical) #:sma (sma-series #f))
  ((case orient
     ('vertical   (lambda(xs)(vertical-bar-graph xs #:sma sma-series)))
     ('horizontal horizontal-bar-graph)
     (else
      (lambda(_)
        (error (string-append
                "bargraph: Got " (format "'~v'! " orient)
                "#:orientation must be 'vertical or 'horizontal")))))
   series))

;;; --------------------------------------------------------------------------

(define (minutes-daily->svg-string series #:sma (sma-series #f))
  (svg-out (car canvas-size) 
           (cdr canvas-size) (bar-graph series #:sma sma-series)))
(define (instrument-summary->svg-string series)
  (svg-out (car canvas-size) (integer (/  (cdr canvas-size) 2))
           (bar-graph series #:orientation 'horizontal)))

(define (minutes-daily->svg-file series path #:sma (sma-series #f))
  (with-output-to-file path
    (lambda() (displayln (minutes-daily->svg-string series #:sma sma-series)))
    #:exists 'replace))

(define (instrument-summary->svg-file series path)
  (write-file path (instrument-summary->svg-string series)))

;;; ==========================================================================
#;(begin ; DEMO
    (define data-series
      (do ( (i 1 (+ i 1)) (h (rand-h) (rand-h)) (acc '() (cons h acc)))
        ( (>= i 31) (cons h acc))))

    (series->svg-file data-series "/tmp/foo.svg"))

#;(displayln (minutes-daily->svg-string '(("ab" . 1) ("bc" . 2) ("dx" . 3))))
#;(displayln (minutes-daily->svg-string '(1 2 3 4 5 6 )))
#;(displayln (instrument-summary->svg-string
              '(("ab" . 30) ("bc" . 60) ("dx" . 90))))


  
