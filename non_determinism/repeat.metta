; (: repeat (-> Atom Expression))
(= (repeat $elem) 
   (superpose ($elem (repeat $elem))))


(: repeatN (-> Atom Number Expression))
; (= (repeatN $elem 0) ())
(= (repeatN $elem $n)
   (if (> $n 0)
     (let $nextEl (repeatN $elem (- $n 1))  
        (cons-atom $elem $nextEl)
     )
     ()))
; !(repeat x)  ; infinite

!(repeatN x 5)
;;  (x x x x x)
