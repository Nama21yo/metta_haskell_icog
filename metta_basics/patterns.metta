; [relationship Subject Object]
(Parent Tom Bob) ; Expression
(Parent Pam Bob)
(Parent Tom Liz)
(Parent Bob Ann)

; there is a grounded function called match
; It takes 3 arguments
;  >> grounded atom referencing a Space
;  >> pattern atom to be matches
; >> output pattern (typically containing variables from the input pattern)

! (match &self ($x Tom Bob) $x)
(Parent Bob Ann)
! (match &self (Parent Bob Ann) (Bob is Ann's father))

! (match &self (Parent Bob Joe) (Bob is Joe's father))

! (match &self (Parent $x Bob) $x)