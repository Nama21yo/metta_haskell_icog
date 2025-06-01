(Adam 23 2000 Male)
(Adam 50 5000 Male)
(Monica 21 500 Female)
(Joe 60 2500 Male)
(Pam 50 3000 Female)

(Joe isParentOf Adam)
(Pam isParentOf Adam)

(Joe isParentOf Monica)
(Pam isParentOf Monica)

; match method in Metta - It is used to match patterns
; Searches for all declared atoms corresponding to the given pattern inside space and returns the output template
; Parameters (Space, Pattern , Output)
; &self - take as a space the current file
; ! (match &self (Adam $x $y $z) ("Age of Adam" $x))
! (match &self (Adam 50 $y $z) ("Adam with 50 Age Salary" $y)) ; [("Adam with 50 Age Salary" 5000)]
! (match &self ($y isParentOf Adam) $y) ; [Joe, Pam]
! (match &self ($y isParentOf Adam) (match &self ($y $age $salary $gender) ($y $age $salary $gender))) ; [(Joe 60 2500 Male), (Pam 50 3000 Female)]

; metta is like functional paradigm programming 
; not purely functional but also logical functional programming langugae 

; We know that Monica and Adam are siblings how can we know that
; $x is $y's sibiling if $n is ParentOf $x and $n is Parent of $y;
; write a function for it
(= (isSibiling $x $y) 
        (match &self ($n isParentOf $x) (match &self ($n isParentOf $y) True)))

!(isSibiling Adam Monica) ;; returns 2 True's like this [True True]
! (isSibiling Adam Pam) ;; returns []

(= (isParent $x $y)
    (match &self ($x isParentOf $y) True)
)
!(isParent Joe Adam) ; [True]


; Metta and Python Integration; 
; Basically use the py-atom;
!((py-atom math.floor) 3.12) ;; 3
!((py-atom random.randint) 0 10)  ;; gives some random number
