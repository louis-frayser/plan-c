#lang racket

(require web-server/servlet
         web-server/servlet-env
         "plan-c.rkt")

(define %cwd (current-directory))
  
(define (start req)
  (response/xexpr
   (report-plan-c)))

;;; This kicks it off...
(serve/servlet start #:extra-files-paths
               (list
                %cwd
                (build-path "/home/frayser/public_html/css")))
