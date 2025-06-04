; Arthimetic operators
; (-> Number Number Number).

; Addition
! (+ 1 3) ; 4

; Subtraction
! (- 6 2.2) ; 3.8

; Multiplication
! (* 7.3 9) ; 65.7

; Division
! (/ 25 5) ; 5 or 5.0

; Modulus
! (% 24 5) ; 4


; Less than
! (< 1 3)

; Greater than
! (> 3 2)

; Less than or equal to
! (<= 5 6.2)

; Greater than or equal to
! (>= 4 (+ 2 (* 3 5))); False


! (== 4 (+ 2 2)) ; True
! (== "This is a string" "Just a string") ; False
! (== (A B) (A B)) ; True
! (== (A B) (A (B C))) ; False

; Test if both the given expressions are True
! (and (> 4 2) (== "This is a string" "Just a string")) ; False

; Test if any of the given expressions is True
! (or (> 4 2) (== "This is a string" "Just a string")) ; True

; Negates the result of a given Bool value
! (not (== 5 5)) ; False
! (not (and (> 4 2) (< 4 3))) ; True
; 
; 
