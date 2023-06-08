#lang racket

(provide db-update-from-disk)

(require (except-in srfi/19 date->string))
(require "../config.rkt" "db-common.rkt" "../lib.rkt")
(require (only-in racket/date date-display-format date*->seconds
                  date->string ))
(require db)
;; -------------------------------------------------------------------------
(date-display-format 'rfc2822) ;; Only for #'date->string in messages

(define (db-update-from-disk)

  (define (import-new-assocs-from-disk pgc)
    ;;; DB Import
    ;;; ========================================================================
    ;; Determine newest timestamp in %table%
    ;; Read data from disk files and import new recs into
    ;; %table%, newer than timestamp.
    ;;
    ;; When this utilty was created, the production db was based on files
    ;;  where as the development db was PostgreSQL.  It isn's expected that
    ;;  the dev system needs this utility.  It is no long posting new records
    ;;  directly to files.  The code is still active in dev mode just for
    ;;  simulating prod mode.  The process is nearly the same for both modes
    ;;  execpt devel mode inserts into "assocs_dev" instead of "assocs."
    ;;
    ;; 1. Get time of newest record.
    ;; 2. Find import files newer than newest record.
    ;; 3. Import files as assocs and stuff into %table%.

    (define last-record-ctime
      (try-query
       query-maybe-value
       pgc
       (string-append "SELECT date_trunc('minute', MAX(ctime)) FROM " %table%)))

    (define d (cond ((sql-null? last-record-ctime)
                     (make-date 0 0 0 0 1 1 2022 -25200))
                    (else (let* ((t last-record-ctime)
                                 (y (sql-timestamp-year t))
                                 (mo (sql-timestamp-month t))
                                 (d (sql-timestamp-day t))
                                 (h (sql-timestamp-hour t))
                                 (m (sql-timestamp-minute t)))
                            (make-date 0 0 m h d mo y -25200)))))

    ;;; Find Files newer than newest RDBM record...
    (define (get-ctime pth)
      (define sb (file-or-directory-stat pth))
      (hash-ref sb 'change-time-seconds) )

    (define (get-assoc-paths-since-secs #:since (beginning 0))
      (define (predicate pth)
        (define pathstr (path->string pth))

        (define date-part
          (let (( match (regexp-match #rx"[0-9]...-..-.." pathstr)))
            (and match (car match))))
        (define beginning-ymd
          (let* ((date (seconds->date beginning))
                 (y (date-year date))
                 (m (date-month date))
                 (d (date-day date)))
            (string-append (~a y) "-" (~0 m) "-" (~0 d))))

        (and (and date-part (string>=? date-part beginning-ymd))
             (regexp-match #rx"2...-.*/assoc-.*.scm" pathstr)
             (>= (get-ctime pathstr) beginning) pth))

      (find-files predicate %db-base-dir%
                  #:skip-filtered-directory? #f #:follow-links? #f))
    (define (stime path) (time-second (date->time-utc (assoc-path->date path))))

    (define (get-assocs-since-secs #:since (beginning 0))
      (define (file->assoc p)
        (let*((a   (read-file p))
              (d (cdr a)))
          (cons (car a) (list d (seconds->date (stime p)) %user%))))
      (map file->assoc (get-assoc-paths-since-secs #:since beginning)))

    (define(do-insert rec) (query-exec pgc (print-sql rec #:to-string? #t)))

    (define ascs (get-assocs-since-secs #:since (date*->seconds d)))
    (printf "\nDate (~a) and \n\tabs second of last insert: ~a\n"
            (date->string d #t) (date*->seconds d ))

    (printf "Inserting ~a new records \n\n" (length ascs))

    (map do-insert ascs))
  ;;
  (define (create-table pgc)
    (displayln (string-append "Creating table: " %table%))
    (let* ((base (string-append "create-" %table% ".sql"))
           (path (build-path %orig-dir% "scripts/sql" base ))
           (sqls (string-split (file->string path) ";")))
      (for-each (curry query-exec pgc) sqls)))
  ;;
  (define pg-conn
    (postgresql-connect #:user     %pg_user%
                        #:database %pg_db%
                        #:password %pg_pass%))
  (define (table-exists)
    ((lambda()
       (query-exec pg-conn "CREATE SCHEMA IF NOT EXISTS plan_c;")
       (query-exec pg-conn "set search_path = plan_c, public;")
       (define result (query-rows pg-conn
                                  "SELECT true FROM  pg_catalog.pg_tables
            WHERE schemaname = 'plan_c'
            AND   tablename  = $1;" %table%))
       (pair? result))))
  ;;
  (displayln "DB Import:")

  (unless (table-exists) (create-table pg-conn))

  (displayln "Importing newest assocs from disk...")
  (void (import-new-assocs-from-disk pg-conn))

  (disconnect pg-conn)

  (displayln "OK import\n"))
;;; ----------------------------------------------------------------------------
