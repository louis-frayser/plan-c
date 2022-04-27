#lang racket
;;;; Read database
;;;; Convert data in 'Music category into a time series date -vs time practiced
;;;;
(require srfi/19)
(require "config.rkt" "lib.rkt" "reports/series-to-svg.rkt")


(define %dbdir "/usr/lucho/var/www/plan-c/lib/db")
(define svg-path 
  "/usr/lucho/var/www/plan-c/htdocs/music-practice-minutes-daily.svg"
  #;(build-path %orig-dir% "htdocs/music-practice-minutes-daily.svg"))

(define (read-file path/string)
  (with-input-from-file path/string (lambda()(read))))
  
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

(newline)
*music-hours-daily

(define *minutes
  (map (lambda(pr)(define h (second pr)) (inexact->exact (round (* h 60))))
       *music-hours-daily))
*minutes

(displayln (minutes-daily->svg-string *minutes))
(minutes-daily->svg-file *minutes svg-path)