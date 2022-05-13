#lang debug racket
;;;; Read database
;;;; Convert data in 'Music category into a time series date -vs time practiced
;;;;
(require "config.rkt" "db.rkt" "lib.rkt" "reports/series-to-svg.rkt"
         "db-files.rkt")

(provide render-svg-img render-svg-time/instrument)


(define (music-time-series)
  ;; Replace files with their contents
  (define assocs-by-datestr
    (take-right (get-assocs-by-datestr #:since (a-month-ago-str)) 30 ))

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
(define (get-music-minutes-daily)
  (define music-minutes-daily
    (map (lambda(rec)(cons (car rec) (time-string->mins (second rec))))
         (or (db-get-music-durations-by-day #:since (a-month-ago-str))
             (music-time-series))))
  music-minutes-daily)
;; ...........................................................................

(define (render-svg-img) ; Render <img> with a random tag in it's URL
  (define svg-basename "music-practice-minutes-daily.svg")
  (define (render-svg-to-file)
    (define svg-path (build-path %orig-dir% "htdocs" svg-basename))
    (minutes-daily->svg-file (get-music-minutes-daily) svg-path))
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
            (or (db-get-assocs #:since (a-month-ago-str))
                (get-assocs #:since (a-month-ago-str)))))

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
;; ============================================================================

#;(displayln (minutes-daily->svg-string (get-music-minutes-daily)))
#;(render-svg-time/instrument)

