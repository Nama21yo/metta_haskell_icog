; (: repeat (-> Atom Expression))
(= (repeat $elem) 
   (superpose ($elem (repeat $elem))))


(= (add $x) (+ 1 $x))
; (: repeatN (-> Atom Number Expression))
; (= (repeatN $elem 0) ())
(= (repeatN $elem $n)
   (if (> $n 0)
     (let $nextEl (repeatN $elem (- $n 1))  
        (cons-atom $elem $nextEl)
     )
     ()))
; !(repeat x)  ; infinite

!(repeatN x 5)
!(repeatN (add 2) 6)
;;  (x x x x x)
