#lang racket

(provide plan-report render-page)

(require web-server/servlet web-server/templates)
(require xml (only-in seq/iso drop)
         "analysis.rkt" "config.rkt"
         "db/db-api.rkt"
         "form-input.rkt"
         "generate-js.rkt"
         "lib.rkt"
         "db/plan-data.rkt")
;;; =========================================================================
(define *spc*  'nbsp)

;;;  ------------------------------------------------------------------------
;;; Generate Javascript to "scripts/option-controls.js"
(generate-js)
;;;  ------------------------------------------------------------------------
;;;               REPORT/DISPLAY
(define (render-page embed/url)
  (response/xexpr #:preamble #"<!DOCTYPE html>\n"
                  (plan-report embed/url handle-input-form-thunk)))

(define (handle-input-form-thunk req)
  (handle-input-form req render-page))

(define (plan-report embed/url handle-input-form)
  (report (get-current-assoc-groups) embed/url handle-input-form))
;;; ...........................................................................

(define (report assoc-groups embed/url handle-input-form)
  ;; Punch a whole in the form elemet's attributes; insert'(action ,embed/url)
  (define (add-form-action form)
    (let* (( head (first form))
           (orig-atts (second form))
           (rest (drop  2 form ))
           (new-atts (cons `(action ,(embed/url handle-input-form)) orig-atts)))
      (append (list head new-atts ) rest)))

  (define (groups-html) ; Show detail of groups of activity data
    (append `(table
              (caption (a ((href ,%crud-url%)) "Daily Activity")))
            (map (lambda (c)(row-html c assoc-groups))
                 (assoc-groups->categories assoc-groups))))

  (define sum    ; current total duration for todays activities
    ((lambda()
       (define groups (filter pair? assoc-groups))
       (define tstrings (map cadr (apply append (map cdr groups))))
       (apply string-time+ tstrings))))

  (define def-dur ; Default duration for input form
    (time-elapsed-hmm-str sum))

  (define (summary-html)
    `(div (p ((id "ttotal")) "Daily total: " ,sum)))

  ;; HTML starts here ...
  `(html
    (head (title ,(string-append "Plan C " %version%)) "\n"
          (meta ((http-equiv "refresh")(content "300; url=/"))) "\n"
          (link ((rel "stylesheet")(href "/files/styles.css")
                                   (type "text/css")))
          "\n"
          (script ((src "/scripts/plan.js")(type "module"))))
    "\n"
    (body ((class "container"))
          "\n"
          (h1 ,(if %production% "Plan C" "Plan C (Dev)"))
          "\n"
          ,(string->xexpr (include-template "../files/time-frame.html"))"\n"
          (div ((id "wrap"))
               "\n"
               (div ((id "left_col"))
                    ,(groups-html)  ; Include a table made from group data
                    "\n"
                    ,(summary-html)
                    ,(render-svg-img)
                    ,(render-svg-time/instrument)); Link to graph
               (div ((id "right_col"))
                    ,(add-form-action ; Add 'action' attribute
                      (string->xexpr  ;  to included form
                       (include-template "../files/input-form.html")))))
          "\n")))
;............................................................................

;; For each major category, show  performed actions
(define (row-html category groups)
  (define (performed act) (and (> (length act) 1)(string>? (car act) "00:00")))
  (define (matching-group-html cat grps)
    (let* ( (cmatch (dict-ref grps cat '()))
            (perfed  (filter performed (map reverse cmatch))))
      (map (lambda(row)  ; row is a triplet
             (cons 'tr `((td ,(car row))
                         (td ((class "tentry"))
                             ,(cadr row)) (td ,(caddr row)))))
           (map (lambda(d) (cons *spc* (if ( = (length d) 2)
                                           d (cons *spc* d))))
                perfed))))
  ;;; Gets the sum of durations in the matching group
  (define (group-sum groups)
    (let* ((cmatch (dict-ref groups category '()))
           (tstrs (map (lambda(gel)
                         (if (pair? gel) (car gel) "0:00")) (map cdr cmatch)))
           (splits (map (lambda(s)(string-split s ":")) tstrs))
           (nsplits (map (lambda(pr)(map string->number pr))
                         splits))
           (tot-seconds (+ (* (apply + (map car nsplits)) 3600)
                           (* (apply + (map cadr nsplits))  60)))
           (timestr
            (call-with-values
             (lambda()(quotient/remainder tot-seconds 3600))
             (lambda(h m)
               (format "~a:~a" h
                       (~a #:width 2
                           #:align 'right #:pad-string "0"
                           (round (/ m 60))))))))
      timestr))
  (cons 'tbody (cons `(tr (th ((class "tsum")) ,(group-sum groups))
                          (th ((colspan "2"))
                              ,category))
                     (matching-group-html category groups))))
;;; ...........................................................................
;;; ---------------------------------------------------------------------------
;;; ===========================================================================
