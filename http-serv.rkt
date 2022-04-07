#lang racket

(require web-server/servlet "lib/config.rkt" "plan-c.rkt" "lib/lib.rkt")
(provide/contract (start (request? . -> . response?)))


(define (start req)
  (let* ((bindings (request-bindings req)))
    (when (exists-binding? 'change bindings)
      (process-input-form bindings)
      (redirect/get)))
  (send/suspend/dispatch render-page))
  
;;; This starts the servelet with param "start respons/xepr" (above)
(require web-server/servlet-env "plan-c.rkt")
(serve/servlet start
               #:launch-browser? #t
               #:quit? #f
               #:listen-ip #f
               #:port 8000
               #:extra-files-paths (list %orig-dir%
                                         (build-path %orig-dir% "htdocs"))
               #:servlet-path %servlet-path%)
