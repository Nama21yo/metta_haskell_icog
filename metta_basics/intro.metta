; !(println! "Hello world")

; !(+ 1 3)

; (= (h) (Hello world))
; ! (h)

; ; kind of assigning varuables
; (= (only-a A) (Input A is accepted))
; ! (only-a A)
; ! (only-a B)

; ; some functionality of it
; (= (duplicate $x) ($x $x))
; ! (duplicate A)
; ! (duplicate 1.05)

; (= (triple $variable) ($variable $variable $variable))
; !(triple A)
; !(triple 123)
; !(triple  1.111)

; ; swapping
; (= (swap ($x $y)) ( $y $x))
; ! (swap (A B))
; ! (swap (123 456))

; ; arthimethic sum, 
; (= (sum ($x $y) ) (+ $x $y))
; !( sum (111 111) )

; (= (square $x) (* $x $x))
; ! (square 3)


; !(print-mods!)

; ; returns the second element
; (= (Cdr (Cons $x $xs)) $xs)
; ! (Cdr (Cons A (Cons B Nil)))

; ; checking whether  1st and 3rd element are equal
; (= (check ($x $y $x)) ($x $y))
; ! (check (B A B))
; ! (check (B A A)) ; will be unchanged

; ; non deterministic
; (= (bin) 0)
; (= (bin) 1)
; ! (bin)

; ; variables in function calls
; (= (brother Mike) Tom)
; (= (brother Sam) Bob)
; ! (brother $x)
; ! ((brother $x) is the brother of $x)



; (= (Car (Cons $x $xs)) $x)
; (= (Second (Cons $x $xs)) (Car $xs))
; ! (Second (Cons A (Cons B Nil)))

; !(bin)
; (= (bin2) ((bin) (bin)))
; ; This happens because each (bin) in the body is evaluated independent
; ! (bin2)

; (= (sum ($x $y)) (+ $x $y))
; (= (sum ($x $y $z)) (+ $x (+ $y $z)))
; ! (sum (triple (bin)))
; ! (sum (bin2))

; (= (f special-value) catched)
; (= (f $x) $x)
; ! (f A) ; A
; ! (f special-value) ; both catched and special-value

; !( square A)

; ! (* (+ 1 2) (- 8 3)) ; 15
; (= (square $x) (* $x $x))
; ! (square (+ 2 3)) ; 25
; (= (triple $x) ($x $x $x))
; (= (grid3x3 $x) (triple (triple $x)))
; ! (grid3x3 (square (+ 1 2))) ; ((9 9 9) (9 9 9) (9 9 9))


; ; ! (filter-atom (1 2 3 4 5) $x (> $x 3))

(= (sort Nil) Nil)
(= (sort (Cons $elem $list))
    (insertion_sort $elem (sort $list))
)
(= (insertion_sort $item Nil) (Cons $item Nil))
(= (insertion_sort $item (Cons $elem $list))
    (if (<= $item $elem)
    (Cons $item (Cons $elem $list))
    (Cons $elem (insertion_sort $item $list))
    )
)
; !(sort (Cons 1 (Cons 14 (Cons 2 Nil))) )
; ! (== (AND) (AND))

(= (append $item ()) (cons-atom $item ()))
(= (append $item $expr) 
   (let* (
     ($head (car-atom $expr))
     ($tail (cdr-atom $expr))
     ($appended-tail (append $item $tail))
   )
   (cons-atom $head $appended-tail)))
; ! (append 1 (3 2))