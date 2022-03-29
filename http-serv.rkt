#lang racket

(require web-server/servlet
         web-server/servlet-env
         "plan-c.rkt")

(define %cwd (current-directory))

(define (display-data)
  (response/xexpr  #:preamble #"<!DOCTYPE html>\n"
                   (report-plan-c)))
(define (start req)
  (let ((bindings (request-bindings req)))
    (when (exists-binding? 'change bindings)
      (proccess-input-form bindings))
    (display-data)))

;;; This starts servelet with param "start respons/xepr" (above) 
(serve/servlet  start #:extra-files-paths (list %cwd ))

(define (on-change)
  (displayln "ON CHANGE")
  (display-data))
