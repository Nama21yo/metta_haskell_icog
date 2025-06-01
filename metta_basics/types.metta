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
(: a A)
(: b B)
; The type of expression (a b) will be (A B). 
; The type of a tuple is a tuple of types of its elements. 
! (get-type (a b))
