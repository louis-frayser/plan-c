#lang racket

(require web-server/servlet
         web-server/servlet-env
         "planc-2.rkt")
(define %cwd (current-directory))
  
;;; This is the server
(define (server-proc req)
  (response/xexpr
   (report-plan-c)))

;;; Debug
%cwd

;;; This kicks it off...
(serve/servlet server-proc #:extra-files-paths
               (list
                %cwd
                (build-path "/home/frayser/public_html/css")))
