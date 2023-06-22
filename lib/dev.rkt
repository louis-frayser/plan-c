#lang racket ; dev.rkt
(require "db/db-api.rkt")
(provide do_reload_assocs_dev)
(define (do_reload_assocs_dev)
  (db-exec "CALL redo_assocs_dev();"))