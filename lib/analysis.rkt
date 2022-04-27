#lang racket
;;;; Read database
;;;; Convert data in 'Music category into a time series date -vs time practiced
;;;;
(require srfi/19)
(require "config.rkt" "lib.rkt" "reports/series-to-svg.rkt")

(provide render-svg-img)


(define %dbdir "/usr/lucho/var/www/plan-c/lib/db")
(define svg-basename "music-practice-minutes-daily.svg")
(define svg-path 
  (build-path %orig-dir% "htdocs" svg-basename))

(define (read-file path/string)
  (with-input-from-file path/string (lambda()(read))))

(define (render-svg-to-file)
  ;; ddate/directory
  (define ddlist (map path->string (directory-list %dbdir)))

  ;; A list of date and associated files
  (define flist
    (map (lambda(d) (list d (directory-list (build-path %dbdir d))))
         ddlist))
  
  ;; Replae files with their contents
  (define assocs-by-datestr
    (map
     (lambda(pr)
       (define dbase (first pr))
       (list dbase
             (map (compose read-file (curry build-path %dbdir dbase)) 
                  (second pr))))
     flist))

  ;;; Assocs by date...
  (define assocs-by-date
    (map (lambda (pr)(list (first pr)  (second pr))) assocs-by-datestr))

  ;;; 1 assocs-by-date el
  (define abd (car assocs-by-date))

  ;;;; Returns the Music records only
  (define (music-practice abd)
    (list (car abd)
          (filter (compose (curry string=? "Music Practice") caar) (second abd))))

  (define music-by-date (map music-practice assocs-by-date))

  (define music-times-by-date
    (map (lambda(mbd)(list (car mbd ) (map cdr (second mbd)))) music-by-date))

  ;music-times-by-date

  (define music-time-series 
    (map
     (lambda(ctbd)( list (first ctbd) (apply string-time+ (second ctbd))))
     music-times-by-date) )
  ;(newline)
  ;music-time-series

  (define music-hours-daily
    (map (lambda(rec)(list (car rec)(exact->inexact (time-string->hrs (second rec)))))
         music-time-series))

  ;(newline)
  ;music-hours-daily

  (define music-minutes-daily
    (map (lambda(pr)
           (let* (( h (second pr))
                  ( m (inexact->exact (round (* h 60)))))
             (cons (car pr) m)))
         music-hours-daily))
  ;  music-minutes-daily
  ; (displayln (minutes-daily->svg-string music-minutes-daily))
  (minutes-daily->svg-file music-minutes-daily svg-path))

(define (render-svg-img)
  (render-svg-to-file)
  `(img ((id "daily_time" )(class "svg") (name "daly_chart")
                           (alt "Chart of time practiced per day")
                           (title "Day and duration of practice")
                           (src ,(string-append "/" svg-basename)))))
