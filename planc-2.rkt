#lang racket
(provide report-plan-c)
(require xml (only-in srfi/19 string->date date->string)
         "plan-c-data.rkt")
 
;*plan-c* ; Debug
(define (report-plan-c)
  (report *plan-c*))

(define (report a-plan)
  (let* ( (datestr (symbol->string (cadr a-plan)))
          (datestru (string->date datestr "~Y-~m-~d"))
          (date (date->string datestru "~A ~1"))
          (groups (cddr a-plan)))
    `(html
      (head (title "Plan C")
            (link
             ((rel "stylesheet")(href "/styles.css")(type "text/css"))))
      (body
       (h1 "Plan C")
       (h2  ,date)
       ,(groups-html groups)))))

;;
(define (groups-html groups)
  (append '(table) 
          (map (lambda (c)(row-html c groups)) *categories*)) )
;
;; For each major category
(define (row-html category groups)
  ;; groups are variblae data to display under categories
  (cons 'tbody 
        (cons `(tr (th "0:00")
                   (th ((colspan "2")),(symbol->string category)))
              (matching-group-html category groups))))

(define (matching-group-html cat grps)
  (let* ( (match (dict-ref grps cat '())))
    (map (lambda(row)
           (cons 'tr (map (lambda(e) `(td ,(symbol->string e))) row)))
         (map (lambda(d) (cons *spc* (if ( = (length d) 2)
                                        d (cons *spc* d))))
              (map reverse match)))))
     
(display-xml/content (xexpr->xml  (report *plan-c*) ))

;;
(newline)
