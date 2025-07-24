(: generate (-> (-> $a Number) Number Number Expression))
; (= (generate $nextFunc $start 0)
;    ())
(= (generate $nextFunc $start $n)
      (if (< $n 1)
          ()
        ;   (chain  (eval ($nextFunc $start)) $nextVal
            (let $nextEl (generate $nextFunc ($nextFunc $start) (- $n 1))
                 (cons-atom $start $nextEl)
                ; (trace! (DEBUG: Result $nextEl) (cons-atom $start $nextEl))
            )
        ;   )
      )
)



(= (increment $x) (+ $x 1))
(= (double $x) (* $x 2))

! (generate increment 1 5)
;;  (1 2 3 4 5)

(generate double 1 4)
;;  (1 2 4 8)
