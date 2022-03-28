#lang racket

(require web-server/servlet
         web-server/servlet-env
         "plan-c.rkt")

(define %cwd (current-directory))

(define (start req)
  (response/xexpr
   (report-plan-c)))

;;; This starts servelet with param "start respons/xepr" (above) 
(serve/servlet  start #:extra-files-paths (list %cwd ))

