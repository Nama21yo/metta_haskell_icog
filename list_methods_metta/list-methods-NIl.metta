; List Data Structure
(: List (-> $a Type))
(: Nil (List $a))
(: Cons (-> $a (List $a) (List $a)))

; Conditional Definition
(= (if True $x $y) $x)
(= (if False $x $y) $y)

; Insert an element to presumably sorted list
(= (insert $x Nil) (Cons $x Nil))
(= (insert $x (Cons $head $tail))
    (if (< $x $head)
        (Cons $x (Cons $head $tail))
        (Cons $head (insert $x $tail))
    )
)
; ! (insert 1 Nil)
; ! (insert 2 (insert 1 Nil))
; ! (insert 3 (insert 2 (insert 1 Nil)))

; Sort a list
(= (sort Nil) Nil)
(= (sort (Cons $head $tail)) (insert $head (sort $tail)))
; !(sort (Cons 1 Nil))
; !(sort (Cons 3 (Cons 1 (Cons 2 Nil))))


; Check if an element is inside a lisr
(= (elem $x Nil) False)
(= (elem $x (Cons $head $tail)) (if (== $x $head) True (elem $x $tail)))

; !(elem 1 (Cons 3 (Cons 1 (Cons 2 Nil))))
; !(elem 5 (Cons 3 (Cons 1 (Cons 2 Nil))))

; remove duplicaes from a list
(= (uniq $acc Nil) Nil)
(= (uniq $acc (Cons $head $tail))
    (if (elem $head $acc)
        (uniq $acc $tail)
        (Cons $head (uniq (Cons $head $acc) $tail))
    )
)
(= (uniq $1) (uniq Nil $1)) ;;?

; !(uniq (Cons 2 (Cons 3 (Cons 1 (Cons 2 Nil)))))
; !(uniq (Cons 2 (Cons 3 (Cons 3 (Cons 2 Nil)))))

; Set Implementation
(= (insert_uniq $x Nil) (Cons $x Nil))
(= (insert_uniq $x (Cons $head $tail))
    (if (== $x $head)
        (Cons $head $tail)
        (if (< $x $head)
            (Cons $x (Cons $head $tail))
            (Cons $head (insert_uniq $x $tail))
        )
    )
)

; !(== (insert_uniq 1 Nil) (Cons 1 Nil))
; !(insert_uniq 2 (insert_uniq 3 (insert_uniq 2  (insert_uniq 1 Nil))))

; check this in mettalog
(= (f $x $y $z) (+ (+ $x $y) $z))
; !(f 5 7 $z)

(= (eval2 ($f $x))
   (if (== (get-metatype $x) Variable)
       ($f $x)
       (match &self (:= ($f $x) $r)
                    (if (== (get-metatype $r) Expression)
                        (eval $r)
                        $r))))
(:= (f $x) 
    (if (== (get-metatype $x) Variable) 
    "don't reduce the function, just return (f $x)"
    $x))

!(eval2 (f $a))
; !(eval2 (f (a b c)))

(:< Nat Quantity)
(:< Float Quantity)
(: f (-> Quantity Atom))
(= (f $x) ($x is accepted))
(: One Nat)
(: Pi Float)
(: January Month)
!(f One) ; ok
!(f Pi) ; ok
!(f January) ; error
; 
