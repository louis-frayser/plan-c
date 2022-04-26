#lang racket
;;;; Read database
;;;; Convert data in 'Music category into a time series date -vs time practiced
;;;;
(require srfi/19)
(require syntax/parse/define)
(require "lib.rkt" "reports/gen-svg.rkt")
;(define-syntax-parse-rule (fn x:id rhs:expr) (lambda (x) rhs))

(define-syntax-parse-rule (info x:id)
  `( ,x x ,(length x)))

(define (read-file path/string)
  (with-input-from-file path/string (lambda()(read))))
  
(define %dbdir "/usr/lucho/var/www/plan-c/lib/db")

;; ddate/directory
(define *ddlist (map path->string (directory-list %dbdir)))

;*ddlist

;; A list of date and associated files
(define *flist
  (map (lambda(d)
         (list d (directory-list (build-path %dbdir d))))
       *ddlist))

(void (map displayln `(,*flist ,(length *flist))))

;; Replae files with their contents
'|FIXME-reading-only-1'st|
(define *assocs-by-datestr
  (map
   (lambda(pr)
     (define dbase (first pr))
     (list dbase
           (map (compose read-file (curry build-path %dbdir dbase)) 
                (second pr))))
   *flist))

(info *assocs-by-datestr )

;;; Assocs by date...
(define *assocs-by-date
  (map (lambda (pr)(list (first pr)  (second pr))) *assocs-by-datestr))

(info *assocs-by-date)

;;; 1 assocs-by-date el
(define *abd (car *assocs-by-date))

;;;; Returns the Music records only
(define (music-practice abd)
  (list (car abd)
        (filter (compose (curry string=? "Music Practice") caar) (second abd))))

(define *music-by-date (map music-practice *assocs-by-date))

(define *music-times-by-date
  (map (lambda(mbd)(list (car mbd ) (map cdr (second mbd)))) *music-by-date))

*music-times-by-date

(define *music-time-series (map
                            (lambda(ctbd)( list (first ctbd) (apply string-time+ (second ctbd))))
                            *music-times-by-date) )
(newline)
*music-time-series

(define *music-hours-daily
  (map (lambda(rec)(list (car rec)(exact->inexact (time-string->hrs (second rec)))))
       *music-time-series))

*music-hours-daily
(newline)

(require simple-svg)

(define of "music-practice-daily.svg")

(let ([canvas_size 600])
  (with-output-to-file
      of #:exists 'replace
    (lambda ()
      (printf
       "~a\n"
       (svg-out
        canvas_size canvas_size
        (lambda ()
          (let ([_sstyle (sstyle-new)])
            (sstyle-set! _sstyle 'stroke "blue")'
            (sstyle-set! _sstyle 'fill "green")
            (sstyle-set! _sstyle 'stroke-width 2)
 
            (letrec
                ([rectangle
                  (lambda (x y width height)
                    (let ([ rect [svg-def-rect width height]])
                      (svg-use-shape rect _sstyle #:at? (cons x y))))])
              (rectangle 0 0 600 600)
              (svg-show-default))))))))
  (printf "file written: ~v\n" of))


(let ([canvas_size 600])
  (with-output-to-file
      of #:exists 'replace
    (lambda ()
      (printf
       "~a\n"
       (svg-out
        canvas_size canvas_size
        (lambda ()
          (let ([_sstyle (sstyle-new)])
            (sstyle-set! _sstyle 'stroke "blue")'
            (sstyle-set! _sstyle 'fill "green")
            (sstyle-set! _sstyle 'stroke-width 2)
 
            (letrec
                ([rectangle
                  (lambda (x y width height)
                    (let ([ rect [svg-def-rect width height]])
                      (svg-use-shape rect _sstyle #:at? (cons x y))))])
              (rectangle 0 0 600 600)
              (svg-show-default)))))))))