#lang racket
(provide *plan-c* *categories* *spc*)

(define *categories*
  '(Fitness |Music Practice| Maintenance Media PIM |Special Interest|))

(define *plan-c*
  `(plan-c
    2022-03-27
    ;
    (Fitness (Yoga 0:00)(Walking 0:00)(Pull-Ups 0:00)(Dance 0:00))
    (|Music Practice| (Cello/Guitar/Piano)
                      (Trombone/Trumpet/Flugelhorn)
                      (Clarinet/Flute/Recorder)
                      (Voice/Percussion/Dance))
    (Maintenance (SSS 0:00) (Kitchen:cook/clean 0:32)
                 (|Clean House|)(Laundry) (|Instrument Maint.|))
    (Media (News 0:00) (Social 1:05))
    (PIM (Planning 1:10) (SysAdm 2:20))
    ; 'Special Interest' will be taken from default categories
    ))
(define *spc*  '| |)
*plan-c*