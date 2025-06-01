; all evaluations in MeTTa are secretly or explicitly nondeterministic.
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
(Parent Jim Lil)

(= (get-parent-entries $x $y)
    (match &self (Parent $x $y) ($x is Parent of $y))
)

(= (get-parents $x)
    (match &self (Parent $y $x) $y)
)

; !(get-parent-entries Tom $_)
; ! (get-parents Bob)


; (= (get-grand-parents $x)
;     (let*
;         (
;             ($parent (get-parents $x))
;         )
;         (
;             (match &self (Parent $grand_parent $parent) (Grand Parent Of $x is $grand_parent))
;         )
;     )
; )
; It can also be implemented like this
(= (get-grand-parents $x)
   ((get-parents (get-parents $x))))
; !(get-grand-parents Pat)
; !(get-grand-parents Ann)
; !(get-grand-parents Jim)
; !(get-grand-parents Bob)


; from facts to rules
; We can easily go from premises to conclusions with conclude, 
; or to verify conclusions by searching for suitable premises with deduce.
(Implies (Parent $x $y) (Child $y $x))
; This operation is called unification, 
; and it is available in MeTTa in addition to match.
! (match &self (Implies $A (Child $x Tom)) $A)
! (match &self (Implies (Parent Bob $y) $B) $B)

(= (deduce $B)
    (match &self (Implies $A $B) (match &self $A $B))
)
(= (conclude $A)
    (match &self (Implies $A $B)  (match &self $A $B))
)
; The overa;; cahain of transfromtaion can be viewed
; 1. (conclude (Parent Bob $y))
; 2. (match &self (Implies (Parent Bob $y) $B)
;           (match &self (Parent Bob $y) $B))
; 3. (match &self (Parent Bob $y) (Child $y Bob))
; 4. (Child Ann Bob)

! (deduce (Child $x Tom))
! (conclude (Parent Bob $y))


; Unification
! (unify (parent $x Bob)
    (parent Tom $y)
    ($x $y) ; if sucessful
    Fail ; fallback
)

! (unify &self (Parent $x Bob) $x Fail) ; [Tom] It can be enabled to work as match

; nested queries and recursive graph traversal

; Composite queries contain a few patterns 
; (united by , into one expression), which should be satisfied simultaneously. 
(= (get-sister $x)
    (match &self 
        (, (Parent $y $x) ; find his parent
            (Parent $y $z) ; find his all childs
            (Female $z) ; filter the childs who are Females
        )
        ($z is Sister of $x)
    )
    
)
! (get-sister Bob)
! (get-sister Pat) ; [(Pat is Sister of Pat), (Ann is Sister of Pat)]
; how to correct it?

; "Uncle is a brother of a parent" rather than "Uncle is a male child of a parent of a parent, but not the parent"
(= (parent $x $y) (match &self (Parent $x $y) $x))
; recursive function
(= (predecessor $x $z) (parent $x $z))
(= (predecessor $x $z) (predecessor $x (parent $y $z)))

!(predecessor $x Lil)
;

