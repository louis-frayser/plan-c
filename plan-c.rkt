#lang racket

(provide proccess-input-form report-plan-c set-on-change!)
(require xml srfi/19 "plan-c-data.rkt")
 
(define *spc*  'nbsp)

(define *on-change* "location.href='.'")
(define (set-on-change! url-str) (set! *on-change* url-str))

;;; ==============================================================
;;;             INPUT FORM
(define (proccess-input-form bindings)
  (printf "process input: bindings: ~a\n" bindings))
  
(define (render-form)
  `(form 
    (label ((for "category"))"Category:")
    (input ((type "text")(name "category" ) (width "14")))
    (br)(br)
    (label ((for "activity"))"Activity:")
    (input ((type "text")(name "activity")(width "14")))
    (br)(br)
    (input ((type "submit")(class "taup")))

    ))
           
;;; ===============================================================
;;;              REPORT/DISPLAY
(define (report-plan-c)
  (report *plan-c*))

(define (report a-plan)
  (define (groups-html groups)
    (append '(table) 
            (map (lambda (c)(row-html c groups)) (plan-categories a-plan)) ))
  (let* ((datestr (plan-date a-plan))
         (datestru (string->date datestr "~Y-~m-~d"))
         (date (date->string datestru "~A ~1")))       
    `(html
      (head (title "Plan C")
            (link ((rel "stylesheet")(href "/styles.css")
                                     (type "text/css"))))
      (body ((class "container"))
       (h1 "Plan C")
       (h2  ,date)
     
       ,(groups-html (plan-groups a-plan))
       , (render-form)))))

;...............................................................
;; For each major category
(define (row-html category groups)
  (define (matching-group-html cat grps)
    (let* ( (match (dict-ref grps cat '())))
      (map (lambda(row)
             (cons 'tr (map (lambda(e) `(td ,e)) row)))
           (map (lambda(d) (cons *spc* (if ( = (length d) 2)
                                           d (cons *spc* d))))
                (map reverse match)))))
  ;;; Gets the sum of durations in a group
  (define (group-sum grpsym)
    (let* ((groups (plan-groups *plan-c*))
           (match (dict-ref groups category '()))
           (tstrs (map (lambda(gel)(if (pair? gel)
                                       (car gel) "0:00"))
                       (map cdr match)))
           
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
  (cons 'tbody (cons `(tr (th ,(group-sum category)) 
                          (th ((colspan "2"))
                              ,category))
                     (matching-group-html category groups))))
;...........................................................
     
(display-xml/content (xexpr->xml  (report *plan-c*) )); diagnostic
                              
