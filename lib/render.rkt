#lang debug racket

(provide plan-report render-page)

(require web-server/servlet web-server/templates)
(require xml srfi/19 (only-in seq/iso drop)
         "plan-c-data.rkt" "config.rkt" "form-input.rkt"
         "generate-js.rkt" "db-files.rkt" "lib.rkt" "analysis.rkt")
(define *spc*  'nbsp)

;;;  -------------------------------------------------------
;;; Generate Javascript to "scripts/option-controls.js"
(generate-js)
;;; =========================================================
;;;               REPORT/DISPLAY
(define (render-page embed/url)
  (response/xexpr #:preamble #"<!DOCTYPE html>\n"
                  (plan-report embed/url handle-input-form-thunk)))

(define (handle-input-form-thunk req)
  (handle-input-form req render-page))

(define (plan-report embed/url handle-input-form)
  (report (get-plan-c) embed/url handle-input-form) )

(define (report a-plan embed/url handle-input-form)
  ;; Punch a whole in the form elemet's attributes; insert'(action ,embed/url)
  (define (add-form-action form)
    (let* (( head (first form))
           (orig-atts (second form))
           (rest (drop  2 form ))
           (new-atts (cons `(action ,(embed/url handle-input-form)) orig-atts)))
      (append (list head new-atts ) rest)))

  (define (groups-html a-plan) ; Show detail of groups of activity data
    (append '(table)
            (map (lambda (c)(row-html c (plan-groups a-plan)))
                 (plan-categories a-plan))))

  (define (summary-html)
    (define groups (filter pair? (plan-groups a-plan)))
    (define tstrings (map cadr (apply append (map cdr groups))))
    `(div (p ((id "ttotal"))
             "Daily total: " ,(apply string-time+ tstrings))))

  ;; HTML starts here ...
  `(html
    (head (title "Plan C") "\n"
          (meta ((http-equiv "refresh")(content "1200; url=/"))) "\n"
          (link ((rel "stylesheet")(href "/files/styles.css")
                                   (type "text/css")))
          "\n"
          (script ((src "/scripts/plan.js")(type "module"))))
    "\n"
    (body ((class "container"))
          "\n"
          (h1 "Plan C")
          "\n"
          ,(string->xexpr (include-template "../files/time-frame.html"))"\n"
          (div ((id "wrap"))
               "\n"
               (div ((id "left_col"))
                    ,(groups-html a-plan)  ; Include a table from group data
                    "\n"
                    ,(summary-html)
                    ,(render-svg-img)
                    ,(render-svg-time/instrument)); Link to graph
               (div ((id "right_col"))
                    ,(add-form-action ; Add 'action' attribute
                      (string->xexpr  ;  to included form
                       (include-template "../files/input-form.html")))))
          "\n")))
;...............................................................
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
;...........................................................
