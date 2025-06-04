!(println! "Hello world")

; some more methods

(: map-expr (-> (-> $t $t) Expression Expression))
(= (map-expr $f $expr)
    (if (== $expr ()) ()
        (let* (($head (car-atom $expr))
                ($tail (cdr-atom $expr))
                ($head-new ($f $head))
                ($tail-new (map-expr $f $tail))
        )
        (cons-atom $head-new $tail-new)
    )
    )
)

! (map-expr not (False True False False)) ; [(True False True True)]
; 

; Custom cdr and car for lists

(= (car (Cons $x $xs)) $x)
(= (cdr (Cons $x $xs)) $xs)
! (cdr (Cons 1 (Cons 2 (Cons 3 Nil)))) ; [(Cons 2 (Cons 3 Nil))]

; Changing Tuple to a list
(= (to-list $expr)
   (if (== $expr ()) Nil
     (Cons (car-atom $expr)
           (to-list (cdr-atom $expr)))
   )
)
! (to-list (False (True False) False False))


(= (to-tree $expr)
   (case (get-metatype $expr)
      ((Expression
         (if (== $expr ()) Nil
             (Cons (to-tree (car-atom $expr))
                   (to-tree (cdr-atom $expr)))
         ))
       ($_ $expr)
      )
   )
)
! (to-tree (False (True False) False False))
;

