#lang debug web-server ;; http-serv.rkt

(provide interface-version)

(require web-server/servlet
         "lib/config.rkt" "lib/views/form-input.rkt" "lib/http-basic-auth.rkt"
         "lib/lib.rkt" "lib/views/render.rkt" "lib/views/crud.rkt")

(define interface-version 'stateless)

(provide/contract (start (request? . -> . response?)))

(define (start req)
  (define path (path->string (url->path (request-uri req))))
  (define bindings (request-bindings req))
  (newline stderr)
  #R (request-client-ip req)
  #R path
  #R (request-post-data/raw req)
  #R bindings
  (cond [(and %auth-db-path% (not (authenticated? %auth-db-path% req)))
         (response
          401 #"Unauthorized"
          (current-seconds)
          TEXT/HTML-MIME-TYPE
          (list
           (make-basic-auth-header
            "Authentication required"))
          void)]
        [(regexp-match "/crud" path) (crud bindings req)] 
        [(exists-binding? 'change bindings)
         (handle-input-form req render-page)]
        [else (send/back (render-page))]))
;;; This starts the servelet with param "start respons/xepr" (above)
(require (only-in web-server/servlet-env serve/servlet))
(serve/servlet start
               #:command-line?  %production%
               #:listen-ip #f
               #:port %port%
               #:extra-files-paths (list %orig-dir%
                                         (build-path %orig-dir% "htdocs"))
               #:servlet-path %servlet-path%
               #:servlet-regexp	(regexp
                                 (format "^~a.*" (regexp-quote %servlet-path%)))

               )
