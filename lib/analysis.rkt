#lang debug racket
;;;; Read database
;;;; Convert data in 'Music category into a time series date -vs time practiced
;;;;
(require srfi/43
         "config.rkt" "db-api.rkt"
         "lib.rkt" "reports/series-to-svg.rkt")

(provide render-svg-img render-svg-time/instrument)

(define (music-time-series #:since (sdate (a-month-ago-str)) #:limit (limit 30))
  ;; Replace files with their contents
  (define assocs-by-datestr
    (hs:take-right limit (get-assocs-by-datestr #:since sdate)))

  ;;; Assocs by date...
  (define assocs-by-date
    (map (lambda (pr)(list (first pr)  (second pr))) assocs-by-datestr))

  ;;;; Returns the Music records only
  (define (music-practice abd)
    (list (car abd)
          (filter
           (compose (curry string=? "Music Practice") caar) (second abd))))

  (define music-by-date (map music-practice assocs-by-date))

  (define music-times-by-date
    (map (lambda(mbd)(list (car mbd ) (map cdr (second mbd)))) music-by-date))

  (map (lambda(ctbd)( list (first ctbd) (apply string-time+ (second ctbd))))
       music-times-by-date) )
;;
;; -----------------------------------------------------------------------------
(define (get-music-minutes-daily #:since (sdate (a-month-ago-str))
                                 #:limit (lim 30))
  (map (lambda(rec)(cons (car rec) (time-string->mins (second rec))))
       (music-time-series #:since sdate #:limit lim )))
;; ...........................................................................

;; SMA for music-time-series 
;; FIXME: Does not handle cases where there's not enough data
;;; returns #f in this case
(define (_music-mins-sma #:n (n 30) )
  ;; Need 2n-1 = 59 samples
  (define lim (- (* 2 n) 1))
  (define working-vec
    (list->vector
     (map cdr
          (get-music-minutes-daily 
           #:since (days-ago->string (* 2 n)) #:limit lim))))
  (define sum0 (apply + (vector->list (vector-copy working-vec 0 (- n 1)))))
  
  (define (cons-sum i acc val) ;; calculae sum, then div result by n
    (cons (+ (car acc) val (- (vector-ref working-vec i))) acc))
  (reverse (map (compose integer (curry * (/ 1 n))) 
                (vector-fold cons-sum
                             (list sum0)
                             (vector-copy working-vec n (- (* 2 n) 1))))))

(define (music-mins-sma #:n (n 30) )
  (with-handlers ( (exn:fail? (lambda(ex) #f)))  (_music-mins-sma #:n n)))
;; ...........................................................................

(define (render-svg-img) ; Render <img> with a random tag in it's URL
  (define svg-basename "music-practice-minutes-daily.svg")
  (define (render-svg-to-file)
    (define svg-path (build-path %orig-dir% "htdocs" svg-basename))
    (minutes-daily->svg-file (get-music-minutes-daily) svg-path
                             #:sma (music-mins-sma #:n 30)))
  (render-svg-to-file)   ; The tag is to force reloading.
  `(a ((href "/"))
      (img ((id "daily_time" )
            (class "svg") (name "daly_chart")
            (alt "Chart of time practiced per day")
            (title "Day and duration of practice")
            (src ,(string-append "/" svg-basename "?" (~a (random))))))))
;; -----------------------------------------------------------------------------
;;; Get agregate practice-duration by instrument:
(define (get-music-group-summary)

  (define (get-music-assocs)
    (filter (compose (curry string=? "Music Practice") caar)
            (get-assocs #:since (a-month-ago-str))))

  (define assoc-activity cadar )
  (define assoc-instrument assoc-activity )

  (define (group-by-activity assocs )
    (group-by assoc-activity assocs string=?))

  (define (group-by-instrument assocs)
    (group-by-activity  assocs))

  (define (activity-group-data igroup) (map cdr igroup))

  (define (group-activity activity-group) (cadar (map car activity-group)))
  (define activity-group-name group-activity)

  (define (group-summary-minutes activity-group)
    (define (_group-summary group-name group-data)
      (cons group-name (time-string->mins (apply string-time+ group-data))))

    (_group-summary (activity-group-name activity-group)
                    (activity-group-data activity-group)))

  (map group-summary-minutes
       (group-by-instrument
        (append (get-music-assocs) (get-all-instrument-templates)))))
;; ----------------------------------------------------------------------------
(define (render-svg-time/instrument)
  (define (pair>=? a0 a1)
    (not (pair<? a0 a1)))
  (define (pair<? a0 a1)
    (< (cdr a0) (cdr a1)))
  (let* ((filebase "htdocs/instrument-summary.svg")
         (url (string-append "/" filebase))
         (path (build-path %orig-dir% filebase)))
    (instrument-summary->svg-file (sort (get-music-group-summary) pair>=?) path)
    `(a ((href "/"))
        (img ((src ,url)(id "ins-summary")
                        (title "30-day Accumulated time by instrument")
                        (class "svg")(name "ins-summary"))))))
;; ----------------------------------------------------------------------------
;; ============================================================================
#;  (music-mins-sma #:n 30)

#;(displayln (minutes-daily->svg-string (get-music-minutes-daily)))
#;(render-svg-time/instrument)

