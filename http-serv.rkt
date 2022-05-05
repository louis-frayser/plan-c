#lang racket

(require web-server/servlet
         "lib/config.rkt" "lib/form-input.rkt" "lib/http-basic-auth.rkt"
         "lib/render.rkt")

(provide/contract (start (request? . -> . response?)))

(define (start req)
  (cond [(and %auth-db-path% (not (authenticated? %auth-db-path% req)))
         (response
          401 #"Unauthorized"
          (current-seconds)
          TEXT/HTML-MIME-TYPE
          (list
           (make-basic-auth-header
            "Authentication required"))
          void)]

        (else
         (let* ((bindings (request-bindings req)))
           (when (exists-binding? 'change bindings)
             (process-input-form bindings render-page)
             (redirect/get)))
         (send/suspend/dispatch render-page))))

;;; This starts the servelet with param "start respons/xepr" (above)
(require web-server/servlet-env)
(serve/servlet start
               #:listen-ip #f
               #:port 8000
               #:extra-files-paths (list %orig-dir%
                                         (build-path %orig-dir% "htdocs"))
               #:servlet-path %servlet-path%)
