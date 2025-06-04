; However, MeTTa has two functions to send information to the console output:
;  println! and trace!

! (println! "This is a string") ; [STDOUT] "This is a string"
! (println! ($v1 "string" 5))


; trace! accepts two arguments, the first is the atom to print, and the second is the atom to return. 
; Both are evaluated before passing to trace!, which type is (-> %Undefined% $a $a), 
; meaning that the reduced type of the whole trace! expression is the same as the reduced type of the second argument:

! (get-type (trace! (Expecting 3) (+ 1 2))) ; Number

; trace! can be considered as a syntactic sugar for the following construction using println! and let

(: my-trace (-> %Undefined% $a $a))
(= (my-trace $out $res)
   (let () (println! $out) $res))
! (my-trace (Expecting 3) (+ 1 2))

(Parent Bob Ann)
! (trace! "Who is Anna`s parent?" ; print this expression
   (match &self (Parent $x Ann)
          ($x is Ann`s parent)))  ; return the result of this expression
!(trace! "Who is Bob`s child?"  ; print this expression
   (match &self (Parent Bob $x)
          ($x is Bob`s child))) ; return the result of this expression

; There is a useful combination of trace!, quote, 
; and let for printing an expression together with its evaluation result, which is then returned.
(: trace-eval (-> Atom Atom))
(= (trace-eval $expr)
   (let $result $expr
        (trace! (EVAL: (quote $expr) --> $result)
                $result)))
(Fruit apple)
(= (fruit $x)
   (match &self (Fruit $x) $x))
; (EVAL: (quote (fruit $x)) --> apple) is printed to stdout
! (Overall result is (trace-eval (fruit $x))) ; (Overall result is apple)

(Parent Bob Ann)
! (assertEqual
   (match &self (Parent $x Ann) $x)
   (unify (Parent $x Ann) (Parent Bob $y) $x Failed)) ; ()
! (assertEqual (+ 1 2) 3) ; ()
! (assertEqual (+ 1 2) (+ 1 4)) ; Error-expression

; for checking if isn't reducable and for non-determinism use this one
(Parent Bob Ann)
(Parent Pam Ann)
! (assertEqualToResult
    (match &self (Parent $x Ann) $x)
    (Bob Pam))  ; ()
(= (bin) 0)
(= (bin) 1)
! (assertEqualToResult (bin) (0 1)) ; ()
! (assertEqualToResult (+ 1 2) (3)) ; ()
! (assertEqualToResult
    (+ 1 untyped-symbol)
   ((+ 1 untyped-symbol))) ; ()
! (assertEqualToResult (+ 1 2) ((+ 1 2))) ; Error


; if you need to get non-deterministic result explicitly use superpose
(= (bin2) (superpose (0 1)))

! (+ 2 (superpose (3 4 5))) ; [5, 6, 7]
; It is just like pretending the forest is a tree

(= (ikb) international-klien-blue)
(= (color) green)
(= (color) yellow)
(= (color) (ikb))

! (assertEqual
    (match &self (= (color) $x) $x)
    (superpose ((ikb) yellow green)) ; ()
)
! (assertEqualToResult
    (match &self (= (color) $x) $x)
    ((ikb) yellow green) ; Error
)


! (collapse (color)) ; (greenm yellow, international-klien-blue)
; 
