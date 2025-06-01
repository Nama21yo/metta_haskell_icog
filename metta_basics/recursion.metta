(= (length ()) 0) ; base case
(= (length (:: $x $xs))
    (+ 1 (length $xs)))
! ((:: A (:: B (:: C ()))))

; (:: A (:: B (:: C ())))
;     │     │     │  │
;     │     │     │  └── Empty list
;     │     │     └── Element C
;     │     └── List containing C
;     │
;     └── List containing B and C
; Breaking Down (:: A (:: B (:: C ())))
; Let's analyze this step by step:

; () is the empty list
; (:: C ()) creates a list with one element C
; (:: B (:: C ())) adds B to the front of that list
; (:: A (:: B (:: C ()))) adds A to the front of the list
! (length (:: A (:: B (:: C ()))))




; higher order function
(= (apply-twice $f $x)
    ($f ($f $x))
)
(= (square $x) (* $x $x))
(= (duplicate $x) ($x $x))

!(apply-twice square 2) ; (square (square 2))
!(apply-twice duplicate 2)
!(apply-twice 1 2)


; map  in a metta

(= (map $f ()) ())
(= (map $f (:: $x $xs))
    (:: ($f $x) (map $f $xs))
)

! (map square (:: 1 (:: 2 (:: 3 ()))))

; again recursion of factorial

( = (factorial $x)
    (if (> $x 0)
        (* $x (factorial (- $x 1)))
        1  
    )
)
; def factorial(n):
;     if n > 0:
;         return n * factorial(n-1)
;     else:
;         return 1

!(factorial 5)

(= (fact 0) 1)                 ; Base case for fact
(= (fact $n)                   ; Recursive case for fact
   (* $n (fact (- $n 1))))
; ! (fact 5) will be infinite loop

!(> 1 0)
! (< 0 1)
! (< 1 0)

; just like switch case 
(= (facti $x)
   (case $x
     ((0 1)
      ($_ (* $x (facti (- $x 1)))))
   )
)
! (facti 5) ; 120

; zipping using recursion
; (= (zip () ()) ())
; (= (zip (:: $x $xs) (:: $y $ys))
;     (:: ($x $y) (zip $xs $ys))
; )

; !(zip (::A (:: B ())) (::1 (::2 ())))

; (= (zip () ()) ())
; (= (zip (:: $x $xs) (:: $y $ys))
;    (:: ($x $y) (zip $xs $ys)))
; ! (zip (:: A (:: B ())) (:: 1 (:: 2 ()))) ; (:: (A 1) (:: (B 2) ()))

(= (zip () ()) ())
(= (zip (:: $x $xs) (:: $y $ys))
 (:: ($x $y) (zip $xs $ys))
)
!(zip (:: A (:: B ()))
     (:: 1 (:: 2 ()))
     )