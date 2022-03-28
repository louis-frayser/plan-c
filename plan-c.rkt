#lang racket

(provide report-plan-c)
(require xml srfi/19 "plan-c-data.rkt")

(define *spc*  '| |)

(define (report-plan-c)
  (report *plan-c*))

(define (report a-plan)
  (define (groups-html groups)
    (append '(table) 
            (map (lambda (c)(row-html c groups)) *categories*)) )
  (let* ((datestr (plan-datestr a-plan))
         (datestru (string->date datestr "~Y-~m-~d"))
         (date (date->string datestru "~A ~1")))       
    `(html
      (head (title "Plan C")
            (link ((rel "stylesheet")(href "/styles.css")
                                     (type "text/css"))))
      (body
       (h1 "Plan C")
       (h2  ,date)
       ,(groups-html (plan-groups a-plan))))))

;...............................................................
;; For each major category
(define (row-html category groups)
    (define (matching-group-html cat grps)
    (let* ( (match (dict-ref grps cat '())))
      (map (lambda(row)
             (cons 'tr (map (lambda(e) `(td ,(symbol->string e))) row)))
           (map (lambda(d) (cons *spc* (if ( = (length d) 2)
                                           d (cons *spc* d))))
                (map reverse match)))))
  ;;; Gets the sum of durations in a group
  (define (group-sum grpsym)
    (let* ((groups (cddr *plan-c*))
           (match (dict-ref groups category '()))
           (tsyms (map (lambda(gel)(if (pair? gel)
                                       (car gel) '0:00))
                       (map cdr match)))
           (tstrs(map symbol->string tsyms))
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
                              ,(symbol->string category)))
                     (matching-group-html category groups))))
;...........................................................
     
(display-xml/content (xexpr->xml  (report *plan-c*) )); diagnostic


                              
