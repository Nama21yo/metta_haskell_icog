; How to create a new space use 
; use bind! and new-space
; new-space Creates new Atomspace which could be used further in the program as a separate from &self Atomspace
; create a new space
!(bind! &smith-family (new-space))

; add an atom
; add-atom : identifier space , atom
! (add-atom &smith-family (Parent George William))
! (add-atom &smith-family (Parent Martha William))
; do the pattern matching
!(match &smith-family $x $x)


; so in general how we can add atom to the atomspace
; (Parent Bya Nati)
; !(add-atom &self (Parent Bya Nati))


; remove a member from space
! (remove-atom &smith-family (Parent Martha William))
!(match &smith-family $x $x)


; update a member on metta : Use add and remove together
; which means remove old atom, add a new instance of the atom 

; let's understanf let and let*
; they enable us to store values with in temporary variables in the scope of an expression

! (let $x (+ 1 2) (* $x 4)) ; and it is possible to use it after the expression

! (let* 
    (
        ($x (+ 1 2))
        ($y (+ 1 $x))
        ($z (* 8 $y))
    )
    (
        $z ;; can hold my value in here
    )
)

; ! update-atom 
(= (update-atom $space $oldAtom $newAtom)
    (
        let $x
        (remove-atom $space $oldAtom)
        (add-atom $space $newAtom)
    )
)
 
!(add-atom &smith-family (Age William 11))
!(update-atom &smith-family (Age William 11) (Age William 12))

!(match &smith-family $x $x)
; 

; because (get-space) will create a brand new space each time.

; One workaround for this issue in a functional programming style is to 
; wrap the whole program into a function, 
(= (main $space)
   (let () (add-atom $space (Parent Bob Ann))
     (match $space (Parent $x $y) ($x $y))
   )
)
! (main (new-space)) ; (Bob Ann)


; imports in metta
; people_kb.metta
(Female Pam)
(Male Tom)
(Male Bob)
(Female Liz)
(Female Pat)
(Female Ann)
(Male Jim)
(Parent Tom Bob)
(Parent Pam Bob)
(Parent Tom Liz)
(Parent Bob Ann)
(Parent Bob Pat)
(Parent Pat Jim)

; main.metta
! (import! &people people_kb)
(= (get-sister $x)
   (match &people
     (, (Parent $y $x)
        (Parent $y $z)
        (Female $z))
     $z
   )
)
! (get-sister Bob)
