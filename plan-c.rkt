#lang racket

(provide plan-c process-input-form plan-report (struct-out plan))
(require web-server/templates web-server/http/bindings )
(require xml srfi/19 seq/iso
         "lib/plan-c-data.rkt" "lib/config.rkt"
         "lib/generate-js.rkt" "lib/lib.rkt")
(define *spc*  'nbsp)
(define plan-c (make-parameter (retrieve-plan-c)))
(define (performed act) (and (> (length act) 1) (string>? (car act) "0:00")))
;;; ==============================================================
;;;             INPUT FORM
(define (process-input-form bindings)
  ;;; We are looking at a form that changes only one trie key (cat,act)
  ;;; The pair is of numerical indices representing strings in config
  ;;; config-schema-categories() and config-schema-subcategories()
  ;;; After decoding  the numbers into to strings, the struct is
  ;;; addressible for "update".
  (printf "process-input-form: bindings == ~v\n\n" bindings)
  (define (changed-key cx ax) (list (config-nth-category cx)
                                    (config-nth-activity cx ax)))
  ;;; adding in the  time from the original activity 
  (define (new-assocs orig-assocs new-assoc )
    (let*-values (( (key) (car new-assoc))
                  ((replace-assocs keep-assocs )
                   (partition (lambda(a) (debug a)
                                (plan-key=? (car a) key)) orig-assocs))
                  ((DEBUG)     (debug replace-assocs))
                  ((matching-assoc)  ;list of 0 or 1
                   (if (pair? replace-assocs) (car replace-assocs) #f)))
      (let* ((base-dur  (if (pair? matching-assoc)
                            (cdr matching-assoc) "0:00"))
             (xtra-dur (cdr new-assoc)) (D*(debug (cons xtra-dur base-dur)))
             (tot-dur (strtime+ base-dur xtra-dur))
             (adj-new-assoc (cons (car new-assoc) tot-dur)))
        (cons adj-new-assoc keep-assocs))))
;
(define(->int sm)(string->number(extract-binding/single sm bindings)))
;
(let*( (cx (->int 'category ))
       (ax (->int 'activity ))
       (timestr (extract-binding/single 'duration bindings))
       (new-assoc (cons (changed-key cx ax) timestr))
       (orig-assocs (plan-assocs (plan-c)))
       (new-assocs+ (new-assocs orig-assocs new-assoc))
       (new-groups (plan-list->groups new-assocs+))
       (keep (filter
              (lambda(assoc)
                (not (plan-key=? (car assoc) (changed-key cx ax))))
              orig-assocs))
       
       (new-plan
        (plan (plan-version (plan-c)) (plan-date (plan-c)) new-groups) ))
  (debug (plan-groups new-plan))
  (plan-c new-plan)))
                 
;;;  ------------------------------------------------------
;;; Generate Javascript to "scripts/option-controls.js"
(generate-js)
;;; ========================================================
;;;              REPORT/DISPLAY
(define (plan-report)
  (report (plan-c)))

(define (report a-plan)
  (define (groups-html groups)
    (append '(table) 
            (map (lambda (c)(row-html c groups)) (plan-categories a-plan)) ))
  (let* ((datestr (plan-date a-plan))
         (nada (debug datestr))
         (datestru (string->date datestr "~Y-~m-~d"))
         (date (date->string datestru "~A ~1")))       
    `(html
      (head (title "Plan C")
            (link ((rel "stylesheet")(href "/files/styles.css")
                                     (type "text/css")))
            (script ((src "/scripts/plan.js")(type "module"))))
      (body ((class "container"))
            (h1 "Plan C")
            (h2  ,date)
            ,(groups-html (plan-groups a-plan))
            , (string->xexpr (include-template
                              "files/input-form.html"))))))
;...............................................................
;; For each major category, show  performed actions
(define (row-html category groups)
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
  (cons 'tbody (cons `(tr (th ((class "tsum")) ,(group-sum)) 
                          (th ((colspan "2"))
                              ,category))
                     (matching-group-html category groups))))
;...........................................................
