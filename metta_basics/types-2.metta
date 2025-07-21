; Its type system revolves around atoms (the basic building blocks of MeTTa programs) and supports three fundamental type-related concepts: Symbols, Expressions, and Arrow Types

; Symbol Typing
; They may have explicit type but mostly undefined type

; : is used to assign types
(: Sam Human) ; Sam is a type of Human
! (get-type Sam) ; [Human]
! (get-type Bob); [%Undefined%]

; Expression Types
; They have the type of there elements
(: blue Color)
(: balloon Object)
! (get-type (blue balloon))     ; Type is (Color Object)

; Arrow Types
; Used to define function types
; ! (get-type 2)
(: add (-> Number Number Number))
! (get-type (add 2 3))

(: sqrt-math (-> Number Number))
! (sqrt-math 10)
!( get-type (sqrt-math 10))

; Supports Parametric or generic Types
; use variables for generic types
(: Nil (List $t))
(: Cons (-> $t (List $t)  (List $t)))

; Better Parametic Type
; (: List (-> Type Type))
; (: Nil (List $t))
; (: Cons (-> $t (List $t) (List $t)))

! (Cons 1 (Cons 2 Nil))   ; Type: (List Number)
; ! (Cons True (Cons 1 Nil)) ; Type error: $t can’t be both Bool and Number

; Recursive Types
(: Nat Type)
(: Z Nat)
(: S (-> Nat Nat))
! (S (S Z))
! (get-type (S (S Z)))

; Tree Type
(: Tree Type)
(: Empty Tree)
(: Node (-> $t Tree Tree Tree))

! (get-type (Node 5
                (Node 3 Empty Empty)    ; Left subtree
                (Node 7 Empty Empty)))  ; Right subtree
(: contains (-> Tree $t Bool))
(= (contains Empty $val) False)                ; Base case: empty tree
(= (contains (Node $node-val $left $right) $val)
   (if (== $node-val $val)                    ; Check current node
       True
       (if (contains $left $val)              ; Recurse left
           True
           (contains $right $val))))          ; Recurse right

! (contains (Node 5
                (Node 3 Empty Empty)    ; Left subtree
                (Node 7 Empty Empty)) 3)    ; Returns True
! (contains (Node 5
                (Node 3 Empty Empty)    ; Left subtree
                (Node 7 Empty Empty)) 10)   ; Returns False
; 


