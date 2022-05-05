#lang debug racket
;;;; bargraph from a data series
;;; ==========================================================================
(provide minutes-daily->svg-file instrument-summary->svg-file
         #;minutes-daily->svg-string)
(require srfi/13)
(require simple-svg)
(require "../db-files.rkt" "../lib.rkt")
;;; --------------------------------------------------------------------------

(define canvas-size '(395 . 305 )) ; 25.384 x Number of instruments
;;; ------------------------------------------------------------------------
(define *sstyle
  (let ([_sstyle (sstyle-new)])
    (sstyle-set! _sstyle 'stroke "green")
    (sstyle-set! _sstyle 'stroke-width 1)
    _sstyle))
;;; ..........................................................................
(define margin 5)
(define w 10)
(define dx 12)
(define hmax 270 #; (*4.5 60)); 4-1/2 hrs
(define xmax (+  margin (* 30.5 dx))) (define ymax (+ hmax margin))
(define (rand-h) (random 0 hmax))

(define (use-rect@ x y w h #:horiz? (horiz? #f))
  (let (( rect (svg-def-rect w h))
        [_sstyle (sstyle-new)])
    (sstyle-set! _sstyle 'fill "#3f9f3f")
    (svg-use-shape rect _sstyle #:at?  (cons x  (if horiz? y (- ymax h))))))

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
                (hrs (/ mins 60.0))
                (scaled (integer (* mins 0.34))) ; scale to fit canvas-width
                (y-adj (+ y (integer (* 1.5 margin)))))
           (use-rect@ (+ margin label-width) y scaled  w  #:horiz? #t)
           (use-text@  ix margin y-adj)
           (use-text@ (string-append (~a #:width 3 hrs) " hrs")
                      (integer (/ (car canvas-size) 2)) y-adj)
           (loop (+ y dy) (cdr rest-data)
                 (and (pair? (cdr rest-data)) (caadr rest-data)) )))))
    (svg-show-default))
  bar-graph5h)
;;;............................................................................

(define (virtical-bar-graph series)
  ;; if series is an alist then use car as an index (ix), else count 1,2,3...
  ;;; ix must be string.
  (define _series
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
;; ...........................................................................

(define (bar-graph series #:orientation (orient 'virtical))
  ((case orient
     ('virtical   virtical-bar-graph)
     ('horizontal horizontal-bar-graph)
     (else
      (lambda(_)
        (error (string-append
                "bargraph: Got " (format "'~v'! " orient) 
                "#:orientation must be 'virtical or 'horizontal")))))
   series))

;;; ---------------------------------------------------------------------------

(define (minutes-daily->svg-string series)
  (svg-out (car canvas-size) (cdr canvas-size) (bar-graph series)))
(define (instrument-summary->svg-string series)
  (svg-out (car canvas-size) (integer (/  (cdr canvas-size) 2))
           (bar-graph series #:orientation 'horizontal)))

(define (minutes-daily->svg-file series path)
  (with-output-to-file path
    (lambda() (displayln (minutes-daily->svg-string series)))
    #:exists 'replace))

(define (instrument-summary->svg-file series path)
  (write-file path (instrument-summary->svg-string series)))

;;; ===========================================================================
#;(begin ; DEMO
    (define data-series
      (do ( (i 1 (+ i 1)) (h (rand-h) (rand-h)) (acc '() (cons h acc)))
        ( (>= i 31) (cons h acc))))

    (series->svg-file data-series "/tmp/foo.svg"))

#;(displayln (minutes-daily->svg-string '(("ab" . 1) ("bc" . 2) ("dx" . 3))))
#;(displayln (minutes-daily->svg-string '(1 2 3 4 5 6 )))
#;(displayln (instrument-summary->svg-string
              '(("ab" . 30) ("bc" . 60) ("dx" . 90))))

