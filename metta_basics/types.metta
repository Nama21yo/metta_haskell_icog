; to designate that the symbol atom a h
; as a custom type A one needs to add the expression (: a A) to the space (program).
(: a A)
(: b B)
(: A Type)

! (get-type a) ; A
! (get-type b) ; B
! (get-type c) ; %Undefined%
! (get-type A) ; Type
! (get-type B) ; %Undefined%

;types of expression
; The type of expression (a b) will be (A B). 
; The type of a tuple is a tuple of types of its elements. 
! (get-type (a b))

; function type
(: foo (-> A B)) ; takes an argumnet of type A and returns of type of B
! (get-type (foo a))


! (foo a) ; no error
! (get-type (foo b)) ; no result he result meaning that this expression has no valid type.
! (b foo) ; notice: no error but this [(b foo)]
! (get-type (b foo)) ; (B (-> A B))
! (foo b) ; type error

; gradual typing
(: foo (-> A B))
(: a A)
! (get-type (foo c)) ; [B]
! (get-type (g a)) ; [%Undefined%]
; g and c are of %Undefined% type, while foo and a are typed. 
; The result can be different depending on which type is not defined, 
; of the function or its argument.


;multiple arguments
; This function takes two atoms of type A and B and returns an atom of type C
(: foo2 (-> A B C))
(: a A)
(: b B)

! (get-type (foo2 a b)) ; C
! (get-type (foo2 b a)) ; empty
! (get-type (foo2 a)) ; empty
! (foo2 a c) ; no error
; ! (foo2 b a) ; type error (the interpreter stops on error)
; ! (foo2 c) ; would also be type error

;function with no argument
(: const-a (-> A))
(= (const-a) a)
! (const-a)

; nested expressions
(: foo (-> A B))
(: bar (-> B B A))

! (get-type (bar (foo a) (foo a))) ; [A]
! (get-type (foo (bar (foo a) (foo a)))) ; [B]

(: foo-pair (-> (A B) C)) ; type signatures can be nested expressions

! (get-type (foo-pair a b)) ; empty
! (get-type (foo-pair (a b))) ; C

(: foo (-> (-> A B) C))
(: bar (-> A B))

! (get-type (foo bar)) ; C
! (get-type (foo (bar a))) ; empty
; (foo (bar a)), in turn, is badly typed, 
; because the type of (bar a) is reduced to B, 
; which does not correspond to (-> A B) expected by foo.
(: foo (-> C (-> A B)))
(: bar (-> B A))
(: a A)
(: c C)

! (get-type ((foo c) a)) 

! (get-type (+ 1 a)) ; empty
! (get-type (+ 1 b)) ; Number
! (+ 1 b) ; no error, not reduced
! (+ 1 a) ; type error

; recursive dataatypes
(: Z Nat) ; Z is "zero"
(: S (-> Nat Nat)) ; S "constructs" the next number
! (S Z) ; this is "one"
! (S (S Z)) ; this is "two"
! (get-type (S (S (S Z)))) ; Nat
! (get-type (S S)) ; not Nat but empty


(: Greater (-> Nat Nat Bool))
(= (Greater (S $x) Z)
    True
)
(= (Greater Z $x) False)

(= (Greater (S $x) (S $y))
    (Greater $x $y)
)
! (Greater (S Z) (S Z)) ; False
! (Greater (S (S Z)) (S Z)) ; True

(: NilNum ListNum)
(: ConsNum (-> Number ListNum ListNum))
! (get-type (ConsNum 1 (ConsNum 2 (ConsNum 3 NilNum)))) ; ListNum
! (ConsNum 1 (ConsNum "S" NilNum)) ; BadType
;

