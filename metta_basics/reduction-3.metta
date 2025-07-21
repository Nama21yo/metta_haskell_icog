(Green Sam)
(= (Green Sam) T)

! (match &self (Green $who) $who) ; wont' reduce to T
! (match &self (Green $who) $who)
; !(assertEqual (match &self (Green $who) $who) Sam)

(= (double $x) (+ $x $x))
!(eval (double 5)) ; Returns (+ 5 5)
!(eval (+ 5 5)) ; Returns 10

!(chain (+ 2 3) $x (* $x 2)) ; Evaluates (+ 2 3) to 5, binds it to $x, then evaluates (* $x 2), returning 10.
(= (print-each $x) (println! $x))
!(for-each-in-atom (1 3 5 62 2 5) print-each)
; Prints: 1 3 5 62 2 5 in separate lines
; Then it returns: ()

(= (has_zero_right_identity plus) True)
(= ($op $x 0) (if (has_zero_right_identity $op) $x NotReducable))
!(plus $y 0)
; (: quote (-> Atom Atom))
! (quote (plus $y 0))

(= (reduce $term) 
    (case (get-metatype $term)
        ( 
            (Symbol (symbol $term))
            (Grounded (grounded $term))
            (Variable (variable $term))
            (Expression (expression $term))
        )
    )
)
! (reduce  A)
! (get-metatype "hjksdkjgfkj") ; strings re grounded
! (reduce "A")
!(reduce 1)
! (reduce +)
!(reduce ())
!(reduce (+ 1 1)) ;; will reduce it
! (reduce $a)
!(reduce (+ a b))
; 
