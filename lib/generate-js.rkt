#lang racket
(require seq/iso "config.rkt")
(provide generate-js)
;;; ============================================================
(define (js-list l)
  (format "['~a']" (apply string-append (intersperse "', '" l))))
(define (js-list-ar l) ; List of js arrays  =>  array of arrays
  (format "[~a];\n" (apply string-append (intersperse ",\n  " l))))

(define (options-array.js-str)
  (let ((cats (config-schema-categories)))
    ;; Cats...
    (printf "export const Categories = ~a;\n" (js-list cats))
    (newline)
    ;; Actions...
    (displayln "export const ActionsByCatIx=") 
    (displayln
     (js-list-ar (map js-list
                      (map (lambda(cat)
                             (config-schema-subcategories cat))
                           cats)))))
  "") ; "" avoids <void> being output to file

(options-array.js-str); <= TESTING

(define (generate-js)
  (with-output-to-file "scripts/options-array.js"
    (lambda()(displayln (options-array.js-str))) #:exists 'replace))
