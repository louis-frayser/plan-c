#lang racket
;;;; *input-plan* is user input, all symbols.
;;;; *plan-c* is automated input, all strings
(provide *plan-c* (struct-out plan) plan-categories )

(define (->string obj)
  (if (pair? obj) (map ->string obj) (symbol->string obj)))

(struct plan (version date groups))

(define *input-plan*
  (plan 'C '2022-03-28
        '((Fitness (Yoga 0:00)(Walking 0:00)(Pull-Ups 0:00)(Dance 0:00))
          (|Music Practice| (Cello/Guitar/Piano)
                            (Trombone/Trumpet/Flugelhorn)
                            (Clarinet/Flute/Recorder)
                            (Voice/Percussion/Dance))
          (Maintenance (SSS 0:00) (Kitchen:cook/clean 0:00)
                       (|Clean House|)(Laundry) (|Instrument Maint.|))
          (Media (News 0:00) (Social 2:00))
          (PIM (Planning 0:10) (SysAdm 0:30))
          (|Special Interest|) )))

(define *plan-c*
  (plan "C" (symbol->string (plan-date *input-plan*))
        (->string (plan-groups *input-plan*))))
(define (plan-categories a-plan)  (map car (plan-groups a-plan)))
(plan-groups *plan-c*)