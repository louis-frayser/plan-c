#lang racket

(require web-server/servlet web-server/servlet-env "plan-c.rkt")

(define %cwd (current-directory))
(define %files-dir 
  (build-path "/home/frayser/Desktop/Work/src/plan-c/files"))

(define (render-page)
  (response/xexpr  #:preamble #"<!DOCTYPE html>\n"
                   (report-plan-c)))

(define (start req)
  (let ((bindings (request-bindings req)))
    (when (exists-binding? 'change bindings)
      (proccess-input-form bindings))
    (render-page)))

;;; This starts servelet with param "start respons/xepr" (above) 
(serve/servlet start #:extra-files-paths (list %files-dir %cwd ))
