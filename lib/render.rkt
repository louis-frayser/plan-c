#lang racket

(provide plan-c plan-report)
(require web-server/templates web-server/servlet)
(require xml srfi/19 (only-in seq/iso drop)
         "plan-c-data.rkt" "config.rkt"
         "generate-js.rkt" "lib.rkt" "db-files.rkt")
(define *spc*  'nbsp)
;;;  -------------------------------------------------------
;;; Generate Javascript to "scripts/option-controls.js"
(generate-js)
;;; =========================================================
;;;              REPORT/DISPLAY

(define (plan-report embed/url handle-input-form)
  (report (plan-c) embed/url handle-input-form) )

(define (report a-plan embed/url handle-input-form)
  ;; Punch a whole in the form elemet's attributes and insert  '(action ,embed/url)5
  (define (add-form-action form)
    (let* (( head (first form))
           (orig-atts (second form))
           (rest (drop  2 form ))
           (new-atts (cons `(action ,(embed/url handle-input-form)) orig-atts)))
      (append (list head new-atts ) rest)))

  (define (groups-html groups)
    (append '(table)
            (map (lambda (c)(row-html c groups)) (plan-categories a-plan)) ))
  ;; HTML starts here ...
  (let* ((datestr (plan-date a-plan))
         (datestru (string->date datestr "~Y-~m-~d"))
         (date (date->string datestru "~A ~1"))
         (meta-cont-val (string-append "120;url=" %servlet-path%)))
    `(html
      (head (title "Plan C") "\n"
            (link ((rel "stylesheet")(href "/files/styles.css")
                                     (type "text/css"))) "\n"
            (script ((src "/scripts/plan.js")(type "module")))) "\n"
      (body ((class "container")) "\n"
            (h1 "Plan C") "\n"
            ,(string->xexpr (include-template "../files/time-frame.html"))"\n"
            (div ((id "wrap")) "\n"
                 (div ((id "left_col"))
            ,(groups-html (plan-groups a-plan)) "\n" )
                 (div ((id "right_col"))
            ,(add-form-action (string->xexpr (include-template "../files/input-form.html"))))) "\n"))))
;...............................................................
;; For each major category, show  performed actions
(define (row-html category groups)
  (define (performed act) (and (> (length act) 1) (string>? (car act) "0:00")))
  (define (matching-group-html cat grps)
    (let* ( (match (dict-ref grps cat '())))
      (map (lambda(row)  ; row is a triplet
             (cons 'tr `((td ,(car row)) 
                         (td ((class "tentry"))
                             ,(cadr row)) (td ,(caddr row)))))
           (map (lambda(d) (cons *spc* (if ( = (length d) 2)
                                           d (cons *spc* d))))
                (filter performed (map reverse match))))))
  ;;; Gets the sum of durations in a group
  (define (group-sum)
    (let* ((groups (plan-groups (plan-c)))
           (match (dict-ref groups category '()))
           (tstrs (map (lambda(gel)
                         (if (pair? gel) (car gel) "0:00")) (map cdr match)))
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
  (cons 'tbody (cons `(tr (th ((class "tsum")) ,(group-sum))
                          (th ((colspan "2"))
                              ,category))
                     (matching-group-html category groups))))
;...........................................................
