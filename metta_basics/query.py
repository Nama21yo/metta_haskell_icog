
I know it is possible to use the type of a function to filter its arguments

(: only-string (-> String String))
(: only-number (-> Number Number ))

(= (only-string $v) $v)
(= (only-number $v) $v)
Is this different than a type Error?

lexey Potapov
4 months ago




If you pass a wrongly typed argument to such a function, there will be the type error. If you have another function with a certain type, then there is no utility in these functions, e.g., for

(: my-numeric-func (-> Number Number)
(= (my-numeric-func $x) .... does something ....)
there should be not too much difference between (my-numeric-func SOMETHING) and (my-numeric-func (only-number SOMETHING)) except the place where the type error occurs.
However, if you have a function with undefined (or variable) argument type, and you want to insist that the argument you are passing to it has a certain type, then using typed id functions as a way to restrict the input type may make sense. Or I didn't get what you mean.

2 replies

Douglas Miles
4 months ago
oh yeah it was so that depending on the type of parameters passed the system can do something special with different types.. (rather than using them as filters the way i had in these cases)   

4mo ago
i was going to let  spaces that defined different types for the same function names cascade (inheritance-wise) instead of having the closest space give an Error.. it was going to skip over it and find the function with the correct type.. so was looking for how to emulate this in H-E.. Since I think we used to not throw an Error, i was thinking i just forgot how ..

though i do see a way in H-E anyway.. just testing for the type and running Empty if it is wrong.  And writing a meta-interpreter in hyperon that does a pre-check on types 


Alexey Potapov
4 months ago




There was a recent change to propagate error messages from internal expressions to external expressions. It might cause changes in the behavior you are interested in. I'm not sure.
In any case, if the function is typed as (-> Variable Bool), then there should be type error if its first argument is not Variable. Otherwise, type errors will not work in other cases. I cannot come up with a way to replace type errors with empty results based purely on the type system. If we had in-place type definitions, then something like this would work:

(= (is-var (: $x Variable)) True)
(= (is-var (: $x Atom)) Empty)
But this cannot work,  because type definitions are not attached to specific equalities

(: is-var (-> Variable Bool))
(: is-var (-> Atom Bool))
(= (is-var $x)) True)
(= (is-var $x) Empty)
Of course, you can use either get-metatype to explicitly check if atom is a variable, or use case-statement to catch error messages and turn them into Empty.... Well, it's funny enough, but it is difficult to use case here, because the input variable matches against Error expression case.

Show more
3 replies

Douglas Miles
4 months ago
Otherwise, type errors will not work in other cases.

yup .. I see, had to go all the way with type errors 


Douglas Miles
4 months ago
 I cannot come up with a way to replace type errors with empty results based purely on the type system.

I had to use type flags 

(these flags are set by type params on the function's symbol.. if not set one a functions  or the space defining the function)

https://github.com/trueagi-io/metta-wam/blob/master/prolog/metta_lang/metta_typed_functions.pl#L437-L441


Douglas Miles
4 months ago
But this cannot work,  because type definitions are not attached to specific equalities

Hah, at first i thought they were in H-E so i implemented that in MeTTaLog  

https://github.com/trueagi-io/metta-wam/blob/master/prolog/metta_lang/metta_typed_functions.pl#L105-L114

(you may notice that example I commented out the type declarations.  (after all H-E doesn't correspond it anyway))

it still works because: MismatchFail (about types)  :

parse fails non- string
+ fails non numbers
on the upside can still get similar behaviours in H-E if the programmer defines all their own functions .. return Empty on "virtual" type mismatches as long as they only declare their function args as Atom or %Undefined%

d
Metta Coders
Follow

Alexey Potapov
4 months ago
It does work for is-variable instead of filter-variable:

(: empty-error (-> Atom Atom))
(= (empty-error $x)
     (case $x (
       ((Error $1 $2) Empty)
       ($_ $x)
   )))
(: is-variable (-> Variable Bool))
(= (is-variable $x) True)
!(empty-error (is-variable $x))
!(empty-error (is-variable 1))
It's not too elegant, though

3 replies

Douglas Miles
4 months ago
smart way to create the error catcher 


Douglas Miles
3 months ago
@Alexey Potapov  I am trying to find the trick where you used case to capture empty such as..

!(case 
   (match &self (found it) Found)
    ((Empty NoResults)
     ((Error $a $b) (Error $a $b))
    ($captured $captured))))
Is this correct?   Sorry ok it is current i believe 


Alexey Potapov
3 months ago
Yes, it is correct. Although, instead of match you can also use unify ... but if you have multiple cases to parse match results, then match with Empty case might be better. Also, currently, match doesn't return bindings in contrast to unify, and the choice between them may follow from this difference in behavior


Douglas Miles
5 months ago
can someone explain this?

metta+>!(help! capture)
Function capture: (-> Atom Atom) Wraps an atom and captures the current space
Parameters:
  (type Atom) Function name which space needs to be captured
Return: (type Atom) Function
[()]
4 replies

Douglas Miles
4 months ago
@Vitaly Bogdanov 


Douglas Miles
4 months ago
or perhaps a test for capture

From docs I assumed it works like..

>a
>b
>!(capture ab)
[ab]
>!(ab)
[a,b]
but didnt seem to 


Vitaly Bogdanov
4 months ago
@Douglas Miles see this issue https://github.com/trueagi-io/hyperon-experimental/issues/354
capture is a one workaround before some proper fix is implemented. 


Vitaly Bogdanov
4 months ago
capture inputs some function and captures &self space, returning wrapped function. When the result of capture is called it is called in a context of the captured space.

;; Inference control experiment using PLN as inference controller,
;; alpha version.
;;
;; It is an evolutionary step over rnd-inf-ctl.metta in that
;;
;; 1. It takes an inferential context, corresponding to other premises
;;    surrounding a particular recursive backward chainer call.
;;
;; 2. Given the current query and its surrounding context, it
;;    formulates a PLN query expressing an estimate of how promising
;;    that query is.
;;
;; The corpus is based on the propositional calculus of
;;
;; https://us.metamath.org/mpeuni/mmtheorems1.html

;;;;;;;;;;;;;;;;;
;; ;;;;;;;;;;; ;;
;; ;; Utils ;; ;;
;; ;;;;;;;;;;; ;;
;;;;;;;;;;;;;;;;;

;;;;;;;;;
;; Nat ;;
;;;;;;;;;

;; Define Nat
(: Nat Type)
(: Z Nat)
(: S (-> Nat Nat))

;; Define cast functions between Nat and Number
(: fromNumber (-> Number Nat))
(= (fromNumber $n) (if (<= $n 0) Z (S (fromNumber (- $n 1)))))
(: fromNat (-> Nat Number))
(= (fromNat Z) 0)
(= (fromNat (S $k)) (+ 1 (fromNat $k)))

;;;;;;;;;;;;;;;;;;;;;
;; De Bruijn Index ;;
;;;;;;;;;;;;;;;;;;;;;

;; Define DeBruijn type and constructors.
(: DeBruijn Type)
(: z DeBruijn)
(: s (-> DeBruijn DeBruijn))

;; Convert Nat to DeBruijn
(: toDeBruijn (-> Nat DeBruijn))
(= (toDeBruijn Z) z)
(= (toDeBruijn (S $k)) (s (toDeBruijn $k)))

;;;;;;;;;;;
;; Maybe ;;
;;;;;;;;;;;

;; Define Maybe type
(: Maybe (-> $a Type))
(: Nothing (Maybe $a))
(: Just (-> $a (Maybe $a)))

;;;;;;;;;;
;; Pair ;;
;;;;;;;;;;

;; Pair type and constructor
(: Pair (-> $a $b Type))
(: MkPair (-> $a $b (Pair $a $b)))

;; Pair access functions
(: fst (-> (Pair $a $b) $a))
(: snd (-> (Pair $a $b) $b))

;;;;;;;;;;;
;; Until ;;
;;;;;;;;;;;

;; Add 1
(: succ (-> Number Number))
(= (succ $n) (+ 1 $n))

;; Loop-like function ported from Haskell.  Iterate applying a given
;; function till some condition is reached.
(: until (-> (-> $a Bool)               ; Predicate
             (-> $a $a)                 ; Next
             $a                         ; Initial value
             $a))                       ; Final value
(= (until $p $f $x)
   (if ($p $x) $x (until $p $f ($f $x))))

;; Test until
(: until.test.p (-> Number Bool))
(= (until.test.p $n) (== $n 10))
!(assertEqual
  (until until.test.p succ 0)
  10)

;;;;;;;;;;
;; List ;;
;;;;;;;;;;

;; Declaration of List data type and constructors
(: List (-> $a Type))
(: Nil (List $a))
(: Cons (-> $a (List $a) (List $a)))

;; Build a list from an expression, containing all the sub-expressions
;; as elements of the list.
(: List.fromExpression (-> Expression (List $a)))
(= (List.fromExpression $expr)
   (if (== $expr ())
       Nil
       (let* (($head (car-atom $expr))
              ($tail (cdr-atom $expr)))
         (Cons $head (List.fromExpression $tail)))))

;; Return the maximum between two value given a certain less than
;; predicate.
(: maxWith (-> (-> $a $a Bool) $a $a Bool))
(= (maxWith $lt $x $y) (if ($lt $x $y) $y $x))

;; Return a maximum element of a non empty list, given a certain less
;; than predicate.
(: List.maxElementWith (-> (-> $a $a Bool) (List $a) $a))
(= (List.maxElementWith $lt (Cons $head $tail))
   (case $tail
     ((Nil $head)
      ($else (let $met (List.maxElementWith $lt $tail)
               (maxWith $lt $head $met))))))

;; Fold a List from right to left
(: List.foldr (-> (-> $a $b $b) $b (List $a) $b))
(= (List.foldr $f $i Nil) $i)
(= (List.foldr $f $i (Cons $h $t)) ($f $h (List.foldr $f $i $t)))

;; Fold a List from left to right
(: List.foldl (-> (-> $b $a $b) $b (List $a) $b))
(= (List.foldl $f $i Nil) $i)
(= (List.foldl $f $i (Cons $h $t)) (List.foldl $f ($f $i $h) $t))

;; Define List.append (concatenate two lists).
(: List.append (-> (List $a) (List $a) (List $a)))
(= (List.append $xs $ys) (List.foldr Cons $ys $xs))

;; Test List.append
!(assertEqual
  (List.append (Cons a (Cons b Nil)) (Cons c (Cons d Nil)))
  (Cons a (Cons b (Cons c (Cons d Nil)))))

;; Define List.appendElem that appends an element at the end of a
;; list.
(: List.appendElem (-> (List $a) $a (List $a)))
(= (List.appendElem $xs $x) (List.append $xs (Cons $x Nil)))

;; Define List.elemIndex that returns the index of an element in a
;; List, if it exists.
(: List.elemIndex (-> $a (List $a) (Maybe Nat)))
(= (List.elemIndex $x Nil) Nothing)
(= (List.elemIndex $x (Cons $head $tail))
   (if (== $x $head)
       (Just Z)
       (case (List.elemIndex $x $tail)
         (((Just $k) (Just (S $k)))
          (Nothing Nothing)))))

;; Test List.elemIndex
!(assertEqual (List.elemIndex 42 (Cons 0 (Cons 1 Nil))) Nothing)
!(assertEqual (List.elemIndex 42 (Cons 0 (Cons 42 Nil))) (Just (S Z)))

;; Define List.length
(: List.length (-> (List $a) Nat))
(= (List.length Nil) Z)
(= (List.length (Cons $head $tail)) (S (List.length $tail)))

;; Define List.map
(: List.map (-> (-> $a $b) (List $a) (List $b)))
(= (List.map $f Nil) Nil)
(= (List.map $f (Cons $x $xs)) (Cons ($f $x) (List.map $f $xs)))

;; Test List.map
(: List.map.test.foo (-> Number Number))
(= (List.map.test.foo $x) (+ 1 $x))
!(assertEqual
  (List.map List.map.test.foo (Cons 1 (Cons 2 (Cons 3 Nil))))
  (Cons 2 (Cons 3 (Cons 4 Nil))))

;;;;;;;;;;;;;;;;;;;;;
;; Match over list ;;
;;;;;;;;;;;;;;;;;;;;;

;; Similar to match but takes a list of terms instead of a space.
(: match' (-> (List Atom) $a $a $a))
(= (match' Nil $pattern $rewrite) (empty))
(= (match' (Cons $head $tail) $pattern $rewrite) (let $pattern $head $rewrite))
(= (match' (Cons $head $tail) $pattern $rewrite) (match' $tail $pattern $rewrite))

;; Test match' on empty list
!(assertEqualToResult
  (match' Nil ($x $y) ($y $x))
  ())

;; Test match' on singleton
!(assertEqual
  (match' (Cons (A B) Nil) ($x $y) ($y $x))
  (B A))

;; Test match' on pair
!(assertEqualToResult
  (match' (Cons (A B) (Cons (C D) Nil)) ($x $y) ($y $x))
  ((B A)
   (D C)))

;;;;;;;;;;;;;;;;;;
;; Delayed Call ;;
;;;;;;;;;;;;;;;;;;

;; Data structure to carry around function calls without running them.
;; The DCall.runARITY method is used to run a DCall on demand.

;; Parameterized type representing a delayed call of a certain type
;; signature, operator followed by operands
(: DCall (-> Type    ; Output type of a nullary operator
             Type))
(: DCall (-> Type    ; Input type of first operand
             type    ; Output type of a unary operator
             Type))
(: DCall (-> Type    ; Input type of first operand
             Type    ; Input type of second operand
             type    ; Output type of a unary operator
             Type))
(: DCall (-> Type    ; Input type of first operand
             Type    ; Input type of second operand
             Type    ; Input type of third operand
             type    ; Output type of a unary operator
             Type))
(: DCall (-> Type    ; Input type of first operand
             Type    ; Input type of second operand
             Type    ; Input type of third operand
             Type    ; Input type of fourth operand
             type    ; Output type of a unary operator
             Type))

;; DCall data constructors
(: MkDCall (-> (-> $a) (DCall $a)))                    ; Nullary
(: MkDCall (-> (-> $a $b) $a (DCall $a $b)))           ; Unary
(: MkDCall (-> (-> $a $b $c) $a $b (DCall $a $b $c)))  ; Binary
(: MkDCall (-> (-> $a $b $c $d)
               $a $b $c
               (DCall $a $b $c $d)))                   ; Ternary
(: MkDCall (-> (-> $a $b $c $d $e)
               $a $b $c $d
               (DCall $a $b $c $d $e)))                ; Quaternary

;; Run a nullary DCall
(: DCall.run0 (-> (DCall $a) $a))
(= (DCall.run0 (MkDCall $f)) ($f))
;; Run a unary DCall
(: DCall.run1 (-> (DCall $a $b) $b))
(= (DCall.run1 (MkDCall $f $x)) ($f $x))
;; Run a binary DCall
(: DCall.run2 (-> (DCall $a $b $c) $c))
(= (DCall.run2 (MkDCall $f $x $y)) ($f $x $y))
;; Run a ternary DCall
(: DCall.run3 (-> (DCall $a $b $c $d) $d))
(= (DCall.run3 (MkDCall $f $x $y $z)) ($f $x $y $z))
;; Run a Quaternary DCall
(: DCall.run4 (-> (DCall $a $b $c $d $e) $e))
(= (DCall.run4 (MkDCall $f $x $y $z $w)) ($f $x $y $z $w))

;;;;;;;;;;;;;;;;
;; Test DCall ;;
;;;;;;;;;;;;;;;;

(: foo (-> Number))
(= (foo) 42)
(: bar (-> Bool String))
(= (bar $x) (if $x "True" "False"))
(: baz (-> String Number Bool))
(= (baz $x $y) (and (== $x "abc") (== $y 42)))
(: qux (-> Number Bool String Atom))
(= (qux $x $y $z) (R $x $y $z))
(: quux (-> Number Bool String Number Atom))
(= (quux $x $y $z $w) (S $x $y $z $w))

;; Test foo wrapped in a DCall
!(assertEqual
  (DCall.run0 (MkDCall foo))
  42)

;; Test bar wrapped in a DCall
!(assertEqual
  (DCall.run1 (MkDCall bar True))
  "True")

;; Test baz wrapped in a DCall
!(assertEqual
  (DCall.run2 (MkDCall baz "abc" 42))
  True)

;; Test qux wrapped in a DCall
!(assertEqual
  (DCall.run3 (MkDCall qux 42 True "abc"))
  (R 42 True "abc"))

;; Test qux wrapped in a DCall
!(assertEqual
  (DCall.run4 (MkDCall quux 42 True "abc" 42))
  (S 42 True "abc" 42))

;;;;;;;;;;;;;;;;;;;;
;; Estimate DCall ;;
;;;;;;;;;;;;;;;;;;;;

;; Data structure containing a value estimating the probability of
;; success associated to a DCall

;; Parameterized type representing a pair of estimate and assocated
;; delayed call of a certain type signature, operator followed by
;; operands
(: EDCall (-> Type    ; Output type of a nullary operator
              Type))
(: EDCall (-> Type    ; Input type of first operand
              type    ; Output type of a unary operator
              Type))
(: EDCall (-> Type    ; Input type of first operand
              Type    ; Input type of second operand
              type    ; Output type of a unary operator
              Type))
(: EDCall (-> Type    ; Input type of first operand
              Type    ; Input type of second operand
              Type    ; Input type of third operand
              type    ; Output type of a unary operator
              Type))
(: EDCall (-> Type    ; Input type of first operand
              Type    ; Input type of second operand
              Type    ; Input type of third operand
              Type    ; Input type of fourth operand
              type    ; Output type of a unary operator
              Type))

;; EDCall data constructors
(: MkEDCall (-> Number     ; Estimate
                (DCall $a) ; Nullary DCall
                (EDCall $a)))
(: MkEDCall (-> Number        ; Estimate
                (DCall $a $b) ; Unary DCall
                (EDCall $a $b)))
(: MkEDCall (-> Number           ; Estimate
                (DCall $a $b $c) ; Binary DCall
                (EDCall $a $b $c)))
(: MkEDCall (-> Number              ; Estimate
                (DCall $a $b $c $d) ; Ternary DCall
                (EDCall $a $b $c $d)))
(: MkEDCall (-> Number                 ; Estimate
                (DCall $a $b $c $d $e) ; Quaternary DCall
                (EDCall $a $b $c $d $e)))

;; Less than predicate over EDCall objects of same signature.  Compare
;; their estimates.
(: EDCall.lt0 (-> (EDCall $a) (EDCall $a) Bool))
(= (EDCall.lt0 (MkEDCall $le (MkDCall $lf))
               (MkEDCall $re (MkDCall $rf)))
   (< $le $re))
(: EDCall.lt1 (-> (EDCall $a $b) (EDCall $a $b) Bool))
(= (EDCall.lt1 (MkEDCall $le (MkDCall $lf $lx))
               (MkEDCall $re (MkDCall $rf $rx)))
   (< $le $re))
(: EDCall.lt2 (-> (EDCall $a $b $c) (EDCall $a $b $c) Bool))
(= (EDCall.lt2 (MkEDCall $le (MkDCall $lf $lx $ly))
               (MkEDCall $re (MkDCall $rf $rx $ry)))
   (< $le $re))
(: EDCall.lt3 (-> (EDCall $a $b $c $d) (EDCall $a $b $c $d) Bool))
(= (EDCall.lt3 (MkEDCall $le (MkDCall $lf $lx $ly $lz))
               (MkEDCall $re (MkDCall $rf $rx $ry $rz)))
   (< $le $re))
(: EDCall.lt4 (-> (EDCall $a $b $c $d $e) (EDCall $a $b $c $d $e) Bool))
(= (EDCall.lt4 (MkEDCall $le (MkDCall $lf $lx $ly $lz $lw))
               (MkEDCall $re (MkDCall $rf $rx $ry $rz $rw)))
   (< $le $re))

;; Test EDCall
!(assertEqual
  (EDCall.lt0 (MkEDCall 0.9 (MkDCall foo))
              (MkEDCall 0.2 (MkDCall foo)))
  False)
!(assertEqual
  (EDCall.lt1 (MkEDCall 0.3 (MkDCall bar False))
              (MkEDCall 0.6 (MkDCall bar True)))
  True)
!(assertEqual
  (EDCall.lt2 (MkEDCall 0.4 (MkDCall baz "abc" 42))
              (MkEDCall 0.5 (MkDCall baz "def" 24)))
  True)
!(assertEqual
  (EDCall.lt3 (MkEDCall 0.2 (MkDCall qux 42 True "abc"))
              (MkEDCall 0.1 (MkDCall qux 24 False "def")))
  False)
!(assertEqual
  (EDCall.lt4 (MkEDCall 0.2 (MkDCall quux 42 True "abc" 42))
              (MkEDCall 0.3 (MkDCall quux 24 False "def" 24)))
  True)

;; Test taking the max of two EDCalls
(: EDCalls.test.foo (-> $a $b $c $c))
(= (EDCalls.test.foo $x $y $z) $z)
(: EDCalls.test.bar (-> $a $b $c $c))
(= (EDCalls.test.bar $x $y $z) $z)
!(assertEqual
  (maxWith EDCall.lt3
           (MkEDCall 0.9 (MkDCall EDCalls.test.foo Nil Z (: ax1 T1)))
           (MkEDCall 0.8 (MkDCall EDCalls.test.bar Nil Z (: ax2 T2))))
  (MkEDCall 0.9 (MkDCall EDCalls.test.foo Nil Z (: ax1 T1))))

;; Run a nullary EDCall
(: EDCall.run0 (-> (EDCall $a) $a))
(= (EDCall.run0 (MkEDCall $estimate (MkDCall $f))) ($f))
;; Run a unary EDCall
(: EDCall.run1 (-> (EDCall $a $b) $b))
(= (EDCall.run1 (MkEDCall $estimate (MkDCall $f $x))) ($f $x))
;; Run a binary EDCall
(: EDCall.run2 (-> (EDCall $a $b $c) $c))
(= (EDCall.run2 (MkEDCall $estimate (MkDCall $f $x $y))) ($f $x $y))
;; Run a ternary EDCall
(: EDCall.run3 (-> (EDCall $a $b $c $d) $d))
(= (EDCall.run3 (MkEDCall $estimate (MkDCall $f $x $y $z))) ($f $x $y $z))
;; Run a quaternary EDCall
(: EDCall.run4 (-> (EDCall $a $b $c $d $e) $e))
(= (EDCall.run4 (MkEDCall $estimate (MkDCall $f $x $y $z $w)))
   ($f $x $y $z $w))

;;;;;;;;;
;; PLN ;;
;;;;;;;;;

;; Define PLN TruthValue type and its constructor MkSimpleTruthValue
(: PLN.TruthValue Type)
(: PLN.MkSimpleTruthValue (-> Number    ; Strength
                              Number    ; Confidence
                              PLN.TruthValue))

;; Define PLN Term type.  PLN terms are expressions defining the
;; objects that the PLN predicates can take in input.  To not be
;; confused with PLN connectors such as ∧ and constants such ⊥, PLN
;; terms are surrounded by underscore characters when needed.  So for
;; instance a formula
;;
;; (∧ P Q)
;;
;; can be represented at the object level as
;;
;; (_∧_ _P_ _Q_)
;;
;; We need to do that because in this experiment we reason about Θ, a
;; ternary predicate relating theories, proofs and theorems, thus we
;; need a way to represent them at the object level.
(: PLN.Term Type)

;; Define PLN Term DeBruijn index constructors at the object level.
(: PLN.Term.DeBruijn Type)
(: _z_ PLN.Term.DeBruijn)
(: _s_ (-> PLN.Term.DeBruijn PLN.Term.DeBruijn))

;; Make sure that _z_ and _s_ can be typed as PLN.Term as well
(: _z_ PLN.Term)
(: _s_ (-> PLN.Term.DeBruijn PLN.Term))

;; Define axiom and inference rule names as PLN terms
(: _ax-1_ PLN.Term)
(: _ax-2_ PLN.Term)
(: _ax-3_ PLN.Term)
(: _ax-mp_ PLN.Term)
(: _mp2.1_ PLN.Term)
(: _mp2.2_ PLN.Term)
(: _mp2.3_ PLN.Term)
(: _mp2b.1_ PLN.Term)
(: _mp2b.2_ PLN.Term)
(: _mp2b.3_ PLN.Term)
(: _a1i.1_ PLN.Term)
(: _PC_ PLN.Term)
(: _𝜑_ PLN.Term)
(: _𝜓_ PLN.Term)
(: _𝜒_ PLN.Term)

;; Define PLN Term logical connectors at the object level.  NEXT:
;; support PLN.Term.DeBruijn.
(: _→_ (-> PLN.Term PLN.Term PLN.Term))
(: _∧_ (-> PLN.Term PLN.Term PLN.Term))
(: _∨_ (-> PLN.Term PLN.Term PLN.Term))
(: _¬_ (-> PLN.Term PLN.Term))

;; Define typing relationship at the object level.
(: _:_ (-> PLN.Term PLN.Term PLN.Term))

;; Define PLN Statement type.  A PLN statement represents a predicate
;; or conditioned predicate.
(: PLN.Statement Type)

;; Define PLN Statement constructors ∧, ∨, ¬.  Note that these
;; connectors represent in fact pointwise predicate connectors.  So
;; that (∧ P Q) is a predicate resulting from the pointwise
;; conjunction of P and Q, themselves predicates.
(: ∧ (-> PLN.Statement PLN.Statement PLN.Statement))
(: ∨ (-> PLN.Statement PLN.Statement PLN.Statement))
(: ¬ (-> PLN.Statement PLN.Statement))

;; Define PLN Statement constants ⊥ and ⊤, which are also pointwise
;; predicates corresponding respectively to the predicate that returns
;; always False and the predicate that returns always True.  Please do
;; not confuse ⊤ and T.  ⊤ is the top predicate, while T is an upper
;; case letter of the Latin alphabet.  Before you start cursing me to
;; no end for that decision, please consider that the type checker
;; will be able to catch your potential typos.
(: ⊤ PLN.Statement)
(: ⊥ PLN.Statement)

;; Define PLN Statement existential quantifier ∃.  For now we avoid
;; concerns about its semantics, including the interval aspect
;; explained in the PLN book.  Since Θ is deterministic anyway, let's
;; see how far we can go with a crisp version of this quantifier.
;; NEXT: DeBruijn or PLN.DeBruijn?
(: ∃ (-> DeBruijn PLN.Statement PLN.Statement))

;; Define PLN Statement constructors from a set of primitive
;; predicates.  For now only Θ, a ternary predicate representing the
;; relationship between theory, proof and theorem, is used.  A theory
;; is a collection of axioms and inference rules, for now encoded as a
;; list of PLN terms.  Even though Θ is completely deterministic, it
;; is treated as probabilistic to cope with the insufficient knowledge
;; and resources about it.  Indeed, Θ is semi-computable at best, thus
;; it is pointless to hope we can ever know everything about.  For
;; that reason, Θ (or any other PLN predicates) has the following
;; underlying type signature
;;
;; Θ : Theory -> Proof -> Theorem -> Ω -> Bool
;;
;; where Ω is the sample space of the underlying probability space.
(: Θ (-> (List PLN.Term) PLN.Term PLN.Term PLN.Statement))

;; Define PLN judgement type and its constructor.  A judgement is a
;; PLN statement alonside its assigned truth value, constructed with
;; the ≞ connector.
(: PLN.Judgement Type)
(: ≞ (-> PLN.Statement PLN.TruthValue PLN.Judgement))

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reduce PLN statements ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Reduce PLN statement.  For now it only supports neutral element
;; elimination.
(: PLN.reduce (-> PLN.Statement PLN.Statement))
(= (PLN.reduce $stm)
   (case (get-metatype $stm)
     ((Symbol $stm)
      (Grounded $stm)
      (Expression (case $stm
                    (;; Nullary
                     (() ())
                     ;; Unary
                     (($x) ((PLN.reduce $x)))
                     ;; Binary
                     (($x $y) ((PLN.reduce $x) (PLN.reduce $y)))
                     ;; Ternary
                     ;; →
                     ((→ $x ⊤) ⊤)
                     ((→ ⊤ $x) (PLN.reduce $x))
                     ((→ $x ⊥) (¬ (PLN.reduce $x)))
                     ((→ ⊥ $x) ⊤)
                     ;; ∧
                     ((∧ $x ⊤) (PLN.reduce $x))
                     ((∧ ⊤ $x) (PLN.reduce $x))
                     ((∧ ⊥ $x) ⊥)
                     ((∧ $x ⊥) ⊥)
                     ;; ∨
                     ((∨ $x ⊤) ⊤)
                     ((∨ ⊤ $x) ⊤)
                     ((∨ $x ⊥) (PLN.reduce $x))
                     ((∨ ⊥ $x) (PLN.reduce $x))
                     ;; Other ternary
                     (($x $y $z) ((PLN.reduce $x)
                                  (PLN.reduce $y)
                                  (PLN.reduce $z)))
                     ;; Quaternary
                     (($x $y $z $w) ((PLN.reduce $x)
                                     (PLN.reduce $y)
                                     (PLN.reduce $z)
                                     (PLN.reduce $w)))
                     ;; Otherwise
                     ($else (Error $stm "Not supported in PLN.reduce")))))
      ($else (Error (get-metatype $stm) "Not supported in PLN.reduce")))))

!(assertEqual
  (PLN.reduce (∧ (Θ _PC_ z _𝜑_) ⊤))
  (Θ _PC_ z _𝜑_))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Convert backward chainer call to PLN ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Convert the arguments of a backward chainer call to a PLN judgement
;; such that its truth value reflects how likely the holes in the
;; arguments of the call (the environment, the query and its
;; surrounding premises) can be filled within the provided depth.
;;
;; So for instance, if the backward chainer call is
;;
;; (bc (Cons (: a1i.1 𝜑) Nil)
;;     Nil
;;     (fromNumber 1)
;;     (: $prf (→ 𝜓 𝜑)))
;;
;; thus
;;
;; - the environment is (Cons (: a1i.1 𝜑) Nil)
;; - the query is (: $prf (→ 𝜓 𝜑))
;; - the surrounding premises are Nil
;; - the depth 1
;;
;; would be converted into the following PLN query
;;
;; (∃ z (Θ (Cons (_:_ _a1i.1_ _𝜑_) PC) z (_→_ _𝜓_ _𝜑_)) ∧ (depth_lte z 1))
;;
;; where
;;
;; - z is the first De Bruijn index,
;;
;; - all symbols of the logic have been dropped to the object level
;;   (or mesa level), by being surrounded with _.  So for instance, :
;;   becomes _:_, a1i.1 becomes _a1i.1_, → becomes _→_, etc.
;;
;; - The ternary predicate Θ is a PLN predicate representing the
;;   relationship between Theory, Proof and Theorem, in this
;;   respective argument order.  It is also a partial function mapping
;;   its first two arguments, Theory and Proof to the third one,
;;   Theorem.  Meaning, given a theory and a proof, there is at most
;;   one corresponding theorem.  It is partial because not all proof
;;   terms are actually well formed proofs.
;;
;; - The binary predicate depth_lte is true iff the depth of the first
;;   argument is equal or below the number provided as second
;;   argument.
;;
;; Informally, the PLN statement above should be read as
;;
;; There exists a proof z of (→ 𝜓 𝜑), with a maximum depth of 1,
;; within theory (Cons (: a1i.1 𝜑) PC).
;;
;; where the theory includes the static theory PC and its environment
;; (: a1i.1 𝜑).  Note that in this experiment the static part of the
;; theory is hardcoded in the backward chainer.  In general the theory
;; must be completely provided, but here, for the sake of simplicity
;; we will simply hide its description under the symbol PC, which
;; stands for Propositional Calculus.
;;
;; NEXT: support depth.
(: toPLN (-> (List $a)                  ; Theory
             (List $a)                  ; Surrounding premises
             Nat                        ; Maximum Depth
             $a                         ; Query
             PLN.Judgement))            ; PLN judgement
(= (toPLN $thry $ctx $depth (: $prf $type))
   (let* (;; Turn the context into a PLN statement
          ((MkPair $vars $plnctx) (contextToPLN $thry Nil $ctx))
          ;; Turn the query into a PLN statement
          ((MkPair $nvars $plnstm) (queryToPLN $thry $vars (: $prf $type)))
          ;; Build the conjunction of query and context and reduce it
          ($plnred (PLN.reduce (∧ $plnstm $plnctx))))
     ;; Wrap existential quantifiers around the reduced PLN statement
     (variablesToPLN (List.length $nvars) $plnred)))

;; Given a number of variables and a PLN statement containing De
;; Bruijn indices corresponding to these variables, wrap existential
;; quantifiers around the given PLN statement.
(: variablesToPLN (-> Nat             ; Number of variables
                      PLN.Statement   ; PLN statement to be
                                      ; existentially quantified
                      PLN.STatement)) ; Resulting PLN statement
(= (variablesToPLN Z $plnstm) $plnstm)
(= (variablesToPLN (S $k) $plnstm)
   (∃ (toDeBruijn $k) (variablesToPLN $k $plnstm)))

;; Convert a theory in PLN format
(: theoryToPLN (-> (List $a) (List PLN.Term)))
(= (theoryToPLN $thry) (List.map typingToPLN $thry))

;; Convert a typing relationship in PLN format.  It is meant to be
;; called by theoryToPLN thus does not require to update variables as
;; it is assumed that theories have no holes in them (it is an
;; interesting thought to allow holes in theories though).  It is also
;; why the converter outputs a PLN term instead of a PLN statement,
;; because the output is meant to exist at the object level, as a data
;; point of Θ.
(: typingToPLN (-> $a PLN.Term))
(= (typingToPLN $tyr)
   (case (get-metatype $tyr)
     ((Symbol (symbolToPLN $tyr))
      (Expression
       (if-decons-expr $tyr $hdtyr $tltyr
                       ;; Non-empty expression
                       (let* (;; Call typingToPLN on head
                              ($hdpln (typingToPLN $hdtyr))
                              ;; Call typeToPLN on tail
                              ($tlpln (typingToPLN $tltyr)))
                         ;; Cons result
                         (cons-atom $hdpln $tlpln))
                       ;; Empty expression
                       ()))
      ($else (Error $tyr "Case not supported in typingToPLN")))))

;; Like toPLN but takes the query and the surrounding premises all at
;; once, called context.  It does not take other parameters like
;; depth.  Additionally, it takes a list of variables encountered so
;; far in the context that has been consumed.  It outputs a pair of
;; list of all variables encountered so far and a PLN proposition as a
;; conjunction of Θ propositions.
(: contextToPLN (-> (List $a)                   ; Theory
                    (List Variable)             ; Variables so far
                    (List $a)                   ; Context
                    (Pair (List Variable) PLN.Statement))) ; Variables
                                                           ; and PLN
                                                           ; statement
(= (contextToPLN $thry $vars Nil)
   (MkPair $vars ⊤))
(= (contextToPLN $thry $vars (Cons $head $tail))
   (let* (;; Turn the head into an atomic Θ proposition
          ((MkPair $nvars $headpln) (queryToPLN $thry $vars $head))
          ;; Turn the tail into a conjunction of Θ propositions
          ((MkPair $nnvars $tailpln) (contextToPLN $thry $nvars $tail)))
     (MkPair $nnvars (∧ $headpln $tailpln))))

;; Like contextToPLN but only takes a single query in argument
;; alongside a list of variables so far encountered.  It returns a
;; pair of list of variables encountered so far and a PLN statement
;; corresponding to a Θ atomic proposition.
(: queryToPLN (-> (List $a)                   ; Theory
                  (List Variable)             ; Variables encountered so far
                  $a                          ; Query
                  (Pair (List Variable) PLN.Statement))) ; Variables
                                                         ; and PLN
                                                         ; statement
(= (queryToPLN $thry $vars (: $prf $thrm))
   (let* (;; Convert theory into PLN term
          ($thrypln (theoryToPLN $thry))
          ;; Convert proof into PLN term, and accumulate new variables
          ((MkPair $nvars $prfpln) (proofToPLN $vars $prf))
          ;; Convert type into PLN term, and accumulate new variables
          ((MkPair $nnvars $thrmpln) (typeToPLN $nvars $thrm)))
     (MkPair $nnvars (Θ $thrypln $prfpln $thrmpln))))

;; Like queryToPLN but takes a proof (or part thereof) in argument
;; alongside a list of variables so far encountered.  It outputs a
;; pair of variables encountered so far and a PLN term.
(: proofToPLN (-> (List Variable)       ; Variables encountered so far
                  $a                    ; Proof
                  (Pair (List Variable PLN.Term)))) ; Variables and PLN
                                                    ; term
(= (proofToPLN $vars $prf)
   (case (get-metatype $prf)
     (;; If the proof is a variable, return the corresponding DeBruijn
      ;; index and update the list variables if necessary.
      (Variable (variableToPLN $vars $prf))
      ;; If the proof is a symbol, return its corresponding PLN object
      (Symbol (MkPair $vars (symbolToPLN $prf)))
      ;; If the proof is an expression, recurse
      (Expression (if-decons-expr $prf $hdprf $tlprf
                                  ;; Non-empty expression
                                  (let* (;; Call proofToPLN on head
                                         ((MkPair $nvars $hdpln)
                                          (proofToPLN $vars $hdprf))
                                         ;; Call proofToPLN on tail
                                         ((MkPair $nnvars $tlpln)
                                          (proofToPLN $nvars $tlprf))
                                         ;; Cons result
                                         ($prfpln (cons-atom $hdpln $tlpln)))
                                    (MkPair $nnvars $prfpln))
                                  ;; Empty expression
                                  (MkPair $vars ()))))))

;; Like proofToPLN but takes a type (or part thereof) in argument
;; alongside a list of variables so far encountered.
(: typeToPLN (-> (List Variable)       ; Variables encountered so far
                  $a                   ; Type
                  (Pair (List Variable) PLN.Term)))  ; Variables and
                                                     ; PLN term
(= (typeToPLN $vars $type)
   (case (get-metatype $type)
     (;; If the type is a variable, check if it is in $vars, if it is
      ;; then return its corresponding De Bruijn index, otherwise,
      ;; append it first, then return its De Bruijn index.
      (Variable (variableToPLN $vars $type))
      ;; If the type is a symbol, return its corresponding PLN object
      (Symbol (MkPair $vars (symbolToPLN $type)))
      ;; If the type is an expression, recurse
      (Expression (if-decons-expr $type $hdty $tlty
                                  ;; Non-empty expression
                                  (let* (;; Call typeToPLN on head
                                         ((MkPair $nvars $hdpln)
                                          (typeToPLN $vars $hdty))
                                         ;; Call typeToPLN on tail
                                         ((MkPair $nnvars $tlpln)
                                          (typeToPLN $nvars $tlty))
                                         ;; Cons result
                                         ($typln (cons-atom $hdpln $tlpln)))
                                    (MkPair $nnvars $typln))
                                  ;; Empty expression
                                  (MkPair $vars ()))))))

;; Turn a variable into its corresponding DeBruijn index and update
;; the list of encountered variables if necessary.
(: variableToPLN (-> (List Variable)    ; Variables encountered so far
                     Variable           ; Variable
                     (Pair (List Variable) PLN.Term)))
(= (variableToPLN $vars $var)
   (case (List.elemIndex $var $vars)
     (((Just $idx) (MkPair $vars (toDeBruijn $idx)))
      (Nothing (MkPair (List.appendElem $vars $var)
                       (toDeBruijn (List.length $vars)))))))

;; Turn a symbol, proof or type into its corresponding PLN term.  It
;; could probably be simplified by automatically adding underscored
;; around any symbol, but I feel it's better for now to exhaustively
;; enumerate all supported symbols for the sake of clarity.
(: symbolToPLN (-> Symbol PLN.Term))
;; Place holder for propositional calculus
(= (symbolToPLN PC) _PC_)
;; Typing relationship
(= (symbolToPLN :) _:_)
;; Axioms
(= (symbolToPLN ax-1) _ax-1_)
(= (symbolToPLN ax-2) _ax-2_)
(= (symbolToPLN ax-3) _ax-3_)
;; Inference rules
(= (symbolToPLN ax-mp) _ax-mp_)
;; Hypothesis
(= (symbolToPLN mp2.1) _mp2.1_)
(= (symbolToPLN mp2.2) _mp2.2_)
(= (symbolToPLN mp2.3) _mp2.3_)
(= (symbolToPLN mp2b.1) _mp2b.1_)
(= (symbolToPLN mp2b.2) _mp2b.2_)
(= (symbolToPLN mp2b.3) _mp2b.3_)
(= (symbolToPLN a1i.1) _a1i.1_)
;; Connectors
(= (symbolToPLN →) _→_)
(= (symbolToPLN ¬) _¬_)
;; Formula
(= (symbolToPLN 𝜑) _𝜑_)
(= (symbolToPLN 𝜓) _𝜓_)
(= (symbolToPLN 𝜒) _𝜒_)

;; Test typingToPLN
!(assertEqual
  (typingToPLN (: a1i.1 𝜑))
  (_:_ _a1i.1_ _𝜑_))
!(assertEqual
  (typingToPLN PC)
  _PC_)

;; Test theoryToPLN
!(assertEqual
  (theoryToPLN Nil)
  Nil)
!(assertEqual
  (theoryToPLN (Cons PC Nil))
  (Cons _PC_ Nil))
!(assertEqual
  (theoryToPLN (Cons (: a1i.1 𝜑) Nil))
  (Cons (_:_ _a1i.1_ _𝜑_) Nil))
!(assertEqual
  (theoryToPLN (Cons (: a1i.1 𝜑) (Cons PC Nil)))
  (Cons (_:_ _a1i.1_ _𝜑_) (Cons _PC_ Nil)))

;; Test variableToPLN
!(assertEqual
  (variableToPLN Nil $prf)
  (MkPair (Cons $prf Nil) z))
!(assertEqual
  (variableToPLN (Cons $prf Nil) $prf)
  (MkPair (Cons $prf Nil) z))

;; Test proofToPLN
!(assertEqual
  (proofToPLN Nil $prf)
  (MkPair (Cons $prf Nil) z))

;; Test queryToPLN
!(assertEqual
  (queryToPLN Nil Nil (: $prf (→ 𝜓 𝜑)))
  (MkPair (Cons $prf Nil) (Θ Nil z (_→_ _𝜓_ _𝜑_))))

;; Test toPLN
!(assertEqual
  (toPLN (Cons (: a1i.1 𝜑) (Cons PC Nil)) Nil (S Z) (: $prf (→ 𝜓 𝜑)))
  (∃ z (Θ (Cons (_:_ _a1i.1_ _𝜑_) (Cons _PC_ Nil)) z (_→_ _𝜓_ _𝜑_))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;;;;;;;;;;;;;;;;;;;;; ;;
;; ;; Backward chainer ;; ;;
;; ;;;;;;;;;;;;;;;;;;;;;; ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; For now we write a backward chainer that is specialized for the
;; propositional calculus of MetaMath.  The inference control turns
;; the query and other surrounding premises into a PLN statement that,
;; once evaluated, provides an estimate as to whether the recursive
;; backward chainer call is likely to be fruitful.  Since this
;; estimate is a Truth Value with an underlying second order
;; distribution, Thompson sampling can be used to balance exploration
;; and exploitation.  Specifically, a first order probability is
;; sampled for each branch, and the branch with the maximum
;; probability is selected.
;;
;; NEXT: detail exactly inputs and output.
(: bc (-> (List $a)                     ; Environment
          (List $a)                     ; Surrounding premises
          Nat                           ; Maximum depth
          $a                            ; Query
          $a))                          ; Result

;;;;;;;;;;;;;;;;
;; Base cases ;;
;;;;;;;;;;;;;;;;

;; Match the environment
(: bc-env (-> (List $a) (List $a) Nat $a $a))
(= (bc-env $env $ctx $depth (: $prf $thrm))
   (trace! (® bc-env $ctx $depth (: $prf $thrm))
   (match' $env (: $prf $thrm) (: $prf $thrm))))

;; Axiom Simp. Axiom A1 of [Margaris] p. 49.
;; https://us.metamath.org/mpeuni/ax-1.html
(: bc-ax-1 (-> (List $a) (List $a) Nat $a $a))
(= (bc-ax-1 $env $ctx $depth (: ax-1 (→ $𝜑 (→ $𝜓 $𝜑))))
   (trace! (® bc-ax-1 $ctx $depth (: ax-1 (→ $𝜑 (→ $𝜓 $𝜑))))
   (: ax-1 (→ $𝜑 (→ $𝜓 $𝜑)))))

;; Axiom Frege. Axiom A2 of [Margaris] p. 49.
;; https://us.metamath.org/mpeuni/ax-2.html
(: bc-ax-2 (-> (List $a) (List $a) Nat $a $a))
(= (bc-ax-2 $env $ctx $depth
            (: ax-2 (→ (→ $𝜑 (→ $𝜓 $𝜒)) (→ (→ $𝜑 $𝜓) (→ $𝜑 $𝜒)))))
   (trace! (® bc-ax-2 $ctx $depth (: ax-2 (→ (→ $𝜑 (→ $𝜓 $𝜒)) (→ (→ $𝜑 $𝜓) (→ $𝜑 $𝜒)))))
   (: ax-2 (→ (→ $𝜑 (→ $𝜓 $𝜒)) (→ (→ $𝜑 $𝜓) (→ $𝜑 $𝜒))))))

;; Axiom Transp. Axiom A3 of [Margaris] p. 49.
;; https://us.metamath.org/mpeuni/ax-3.html
(: bc-ax-3 (-> (List $a) (List $a) Nat $a $a))
(= (bc-ax-3 $env $depth $ctx
            (: ax-3 (→ (→ (¬ $𝜑) (¬ $𝜓)) (→ $𝜓 $𝜑))))
   (trace! (® bc-ax-3 $ctx $depth (: ax-3 (→ (→ (¬ $𝜑) (¬ $𝜓)) (→ $𝜓 $𝜑))))
   (: ax-3 (→ (→ (¬ $𝜑) (¬ $𝜓)) (→ $𝜓 $𝜑)))))

;;;;;;;;;;;;;;;;;;;;
;; Recursive step ;;
;;;;;;;;;;;;;;;;;;;;

;; Rule 1 of [Hamilton] p. 73.
;; https://us.metamath.org/mpeuni/ax-mp.html
(: bc-ax-mp (-> (List $a) (List $a) Nat $a $a))
(= (bc-ax-mp $env $ctx (S $k) (: (ax-mp $prfarg1 $prfarg2) $𝜓))
   (trace! (® bc-ax-mp $ctx (S $k) (: (ax-mp $prfarg1 $prfarg2) $𝜓))
   (let* (;; Recurse on premise 1
          ((: $prfarg1 $𝜑)
           (bc $env
               ;; Add premise 2 in context
               (Cons (: $prfarg2 (→ $𝜑 $𝜓)) $ctx)
               $k (: $prfarg1 $𝜑)))
          ;; Recurse on premise 2
          ((: $prfarg2 (→ $𝜑 $𝜓))
           (bc $env
               ;; Add premise 1 in context
               (Cons (: $prfarg1 $𝜑) $ctx)
               $k (: $prfarg2 (→ $𝜑 $𝜓)))))
     (: (ax-mp $prfarg1 $prfarg2) $𝜓))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Backward Chainer Estimate ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Define backward chainer estimate.  It mirrors the backward chainer
;; code, but outputs an EDCall, meaning a branch and its estimate of
;; success, instead of directly taking the branch.
(: bce (-> (List $a)                      ; Environment
           (List $a)                      ; Surrounding premises
           Nat                            ; Depth
           $a                             ; Query
           (EDCall (List $a) (List $a) Nat $a $a))) ; EDCall

;; Estimate of matching the environment.  NEXT: the estimate should
;; probably be calculated for each matching result.
(= (bce $env $ctx $depth (: $prf $thrm))
   (MkEDCall (random-float &rng 0 1)    ; NEXT: replace by PLN
             (MkDCall bc-env $env $ctx $depth (: $prf $thrm))))

;; Estimate of Axiom A1
(= (bce $env $ctx $depth (: ax-1 (→ $𝜑 (→ $𝜓 $𝜑))))
   (MkEDCall (random-float &rng 0 1)    ; NEXT: replace by PLN
             (MkDCall bc-ax-1 $env $ctx $depth (: ax-1 (→ $𝜑 (→ $𝜓 $𝜑))))))

;; Estimate of Axiom A2
(= (bce $env $ctx $depth
        (: ax-2 (→ (→ $𝜑 (→ $𝜓 $𝜒)) (→ (→ $𝜑 $𝜓) (→ $𝜑 $𝜒)))))
   (MkEDCall (random-float &rng 0 1)    ; NEXT: replace by PLN
             (MkDCall bc-ax-2 $env $ctx $depth
                      (: ax-2 (→ (→ $𝜑 (→ $𝜓 $𝜒)) (→ (→ $𝜑 $𝜓) (→ $𝜑 $𝜒)))))))

;; Estimate of Axiom A3
(= (bce $env $ctx $depth
        (: ax-3 (→ (→ (¬ $𝜑) (¬ $𝜓)) (→ $𝜓 $𝜑))))
   (MkEDCall (random-float &rng 0 1)    ; NEXT: replace by PLN
             (MkDCall bc-ax-3 $env $ctx $depth
                      (: ax-3 (→ (→ (¬ $𝜑) (¬ $𝜓)) (→ $𝜓 $𝜑))))))

;; Estimate of Rule 1 (modus ponens)
(= (bce $env $ctx (S $k)
        (: (ax-mp $prfarg1 $prfarg2) $𝜓))
   (MkEDCall (random-float &rng 0 1)    ; NEXT: replace by PLN
             (MkDCall bc-ax-mp $env $ctx (S $k)
                      (: (ax-mp $prfarg1 $prfarg2) $𝜓))))

;;;;;;;;;;;;;;
;; Monolith ;;
;;;;;;;;;;;;;;

;; See above for its type signature and comment
(= (bc $env $ctx $depth (: $prf $thrm))
   (trace! (® bc $ctx $depth (: $prf $thrm))
   (let* (($edcalls (collapse (bce $env $ctx $depth (: $prf $thrm))))
          ($edcall_seq (List.fromExpression $edcalls))
          ($best_edcall (List.maxElementWith EDCall.lt4 $edcall_seq)))
     (EDCall.run4 $best_edcall))))

;;;;;;;;;;;;;;;;
;; ;;;;;;;;;; ;;
;; ;; Test ;; ;;
;; ;;;;;;;;;; ;;
;;;;;;;;;;;;;;;;

;; In order to reproduce the tests, the random seed needs to be set
;; just right, and it becomes harder and harder to find a seed that
;; works as the inference path becomes longer and longer.  For that we
;; systematically search for a random seed with the following code
;; (this is an example to discover the seed of test mp2).
;;
;; (: (bc.test.mp2.p (-> Number Bool)))
;; (= (bc.test.mp2.p $n)
;;    (trace! (® bc.test.mp2.p $n)
;;    (let () (set-random-seed &rng $n)
;;         (case (bc (Cons (: mp2.1 𝜑)
;;                         (Cons (: mp2.2 𝜓)
;;                               (Cons (: mp2.3 (→ 𝜑 (→ 𝜓 𝜒)))
;;                                     Nil)))
;;                   (fromNumber 2)
;;                   (: $prf 𝜒))
;;                   ;; (: (ax-mp mp2.2 (ax-mp mp2.1 mp2.3)) 𝜒))
;;           ((Empty False)
;;            ($else True))))))
;; !(until bc.test.mp2.p succ 0)
;;
;; At the end of the loop, it outputs the seed.

;; Test ax-3
!(set-random-seed &rng 1)
!(assertEqual
  (bc Nil Nil (fromNumber 0) (: $prf (→ (→ (¬ 𝜑) (¬ 𝜓)) (→ 𝜓 𝜑))))
  (: ax-3 (→ (→ (¬ 𝜑) (¬ 𝜓)) (→ 𝜓 𝜑))))

;; Test subgoal of https://us.metamath.org/mpeuni/mp2.html
;;
;; Note that variables have been replaced by symbols to force them to
;; be different which considerably prunes the search space.
!(set-random-seed &rng 0)
!(assertEqual
  (bc (Cons (: mp2.1 𝜑)
            (Cons (: mp2.2 𝜓)
                  (Cons (: mp2.3 (→ 𝜑 (→ 𝜓 𝜒)))
                        Nil)))
      Nil
      (fromNumber 1)
      (: $prf (→ 𝜓 𝜒)))
  (: (ax-mp mp2.1 mp2.3) (→ 𝜓 𝜒)))

;; Test https://us.metamath.org/mpeuni/mp2.html
;;
;; Note that variables have been replaced by symbols to force them to
;; be different which considerably prunes the search space.
!(set-random-seed &rng 84)
!(assertEqual
  (bc (Cons (: mp2.1 𝜑)
            (Cons (: mp2.2 𝜓)
                  (Cons (: mp2.3 (→ 𝜑 (→ 𝜓 𝜒)))
                        Nil)))
      Nil
      (fromNumber 2)
      (: $prf 𝜒))
  (: (ax-mp mp2.2 (ax-mp mp2.1 mp2.3)) 𝜒))

;; Test https://us.metamath.org/mpeuni/mp2b.html
!(set-random-seed &rng 363)
!(assertEqual
  (bc (Cons (: mp2b.1 𝜑)
            (Cons (: mp2b.2 (→ 𝜑 𝜓))
                  (Cons (: mp2b.3 (→ 𝜓 𝜒))
                        Nil)))
      Nil
      (fromNumber 2)
      (: $prf 𝜒))
  (: (ax-mp (ax-mp mp2b.1 mp2b.2) mp2b.3) 𝜒))

;; Test https://us.metamath.org/mpeuni/a1i.html
;;
;; Note that variables have been replaced by symbols to force them to
;; be different which considerably prunes the search space.
!(set-random-seed &rng 4)
!(assertEqual
  (bc (Cons (: a1i.1 𝜑) Nil)
      Nil
      (fromNumber 1)
      (: $prf (→ 𝜓 𝜑)))
  (: (ax-mp a1i.1 ax-1) (→ 𝜓 𝜑)))


Alexey Potapov
3 months ago




Hmm....
This is the root cause:

! (== (quote ((println! "Test"))) (quote ()))
This code panics.
The following lines don't panic:

!(== (quote (println! "Test")) (quote ()))
!(== (quote (_ (println! "Test"))) (quote ()))
!(quote ((println! "Test")))
This one produces the type error (incorrect number of arguments):

!((println! "Test"))
There seems to be an issue with == when it get ((println! "smth")) even being quoted.

2 replies

Douglas Miles
3 months ago
Yeah this panics:  ! (== ((println! "Test")) ()) 


Alexey Potapov
3 months ago
Yeah, but it panics even with quote, which is strangier


The next issue is that !(decons-atom ((println! "hello2") (println! "world2"))) works, but

!(let ($h $t) (decons-atom ((println! "hello2") (println! "world2")))
 OK)
panics. So, this is not the problem only for ==

I found workaround for ==:

(: eqt (-> Atom Atom Atom))
(= (eqt $x $x) True)
(= (eqt $x $y) Empty)
(: eq (-> Atom Atom Bool))
(= (eq $x $y)
   (case (eqt $x $y)
    ((True True)
     ($_ False))))
!(eq (quote ((println! "Test"))) (quote ()))
works well

But I'm not sure how to extract atoms from this tuple...

!(car-atom ((println! "hello") (println! "world"))) works
but
!(let $x (car-atom ((println! "hello") (println! "world"))) OK)
doesn't work


Alexey Potapov
2:22 PM
A workaround for you seems to add

(= (print! $x) (println! $x))
and use print! in place of println!


Alexey Potapov
3:18 PM
I raised an issue


Maybe, superpose-atom could be introduced...

12 replies

Douglas Miles
last month
that might work.. 

but we need to ask ourselves what was missing that is preventing a programmer from writing this function for themselves?

or if metta had superpose-atom instead of superpose  then a programmer could define superpose themselves if they needed it for anyhting but not the other way arround 


Douglas Miles
last month
every function that automatically does reduction/evaluation seems to have this exact opportunity..   

probably should code only the non eval version in rust.. then allow users to define eager eval versions only when they want them 


Douglas Miles
last month
we also have a problem where 

 !(let $x (superpose-atom (1 (+ 1 1) 3))
         (println! (format-args "{}" $x)))) 
wouldn't work because let calls eval 

last mo.
how do we work around this? 

last mo.
unify wont work cuz superpose-atom wont be evaluated

!(unify $x (superpose-atom (1 (+ 1 1) 3))
      (println! (format-args "{}" $x)))) 
I guess case is the only option

 !(case (superpose-atom (1 (+ 1 1) 3)) 
     (($x (println!  (format-args "{}" $x))))))

Douglas Miles
last month
though there are some answers to most of these basic issues in 5th generation languages (because there were languages designed to self modify, run partial code, do chaining control etc) 


Alexey Potapov
last month
I agree that superpose-atom could be a more basic one, but superpose is used more frequently, so both can be in stdlib (and if one wishes, superpose can be implemented as a simple wrapper over superpose-atom). Actually, we discussed at the very beginning whether atoms should be evaluated by default or not, and decided that not evaluating them by default would be quite annoying for many non-meta-programming cases.


Douglas Miles
3 weeks ago
Hrrm, here is a case i guess i need superpose-atom:

(= (union-atom $L1 $L2)
    (collapse (union (superpose $L1) (superpose $L2))))
thus:

(= (union-atom $L1 $L2)
    (collapse (union (superpose-atom $L1) (superpose-atom $L2))))

Douglas Miles
3 weeks ago
writting this reminds me we need a println-atom!  as well

3w ago
(iz superpose-atom MeTTa)
(@doc superpose-atom
  (@desc "Function take a tuple and returns each element E.g. !(format-args "{}" ((superpose-atom (1 (+ 1 1) 3)))) -> [\"1\" \"(+ 1 1)\" \"3\"])")
  (@params (
    (@param "List of values")))
  (@return "Each element non-deterministically"))
(: superpose-atom (-> Expression Atom))

Douglas Miles
3 weeks ago
(iz println-atom! MeTTa)
(@doc println-atom!
  (@desc "Prints an Atom it without evaluation")
  (@params (
    (@param "Anything")))
  (@return "Unit atom"))
(: println-atom! (-> Atom (->)))
3w ago
(iz println! MeTTa)
(@doc println!
  (@desc "Prints a line of text to the console")
  (@params (
    (@param "Expression/atom to be printed out afer evaluation")))
  (@return "Unit atom"))
(: println! (-> %Undefined% (->)))
(= (println! $term) (println-atom! (eval $term)))



Nil Geisweiller
11:25 AM
I'd like to call the Python string split method from MeTTa, I'm almost there

!((py-dot "abc:,def" split (-> String String Expression)) ":,")
but I'm getting something that looks like a Python list, and I'm not sure how to deal with it

[['abc', 'def']]
Any idea? 


Nil Geisweiller
12:07 PM
I have found a solution

!(let $s (String.append (repr "abc:,def") ".split(\":,\")[0]") (py-atom $s))
It's not pretty but it works.  If you know something nicer I'm still interested.

Let me provide String.append for the sake of completion

(= (String.append $x $y) ((py-dot $x __add__ (-> String String String)) $y))

Douglas Miles
12:18 PM
It would still be good if we could go from python  list ['abc', 'def'] to metta expression ("abc" "def") easier.      .. in your call you got an non-expression Atom back ( python grounded atom) instead of an atom specialized into Expression like you asked for in !((py-dot "abc:,def" split (-> String String Expression)) ":,") 


Alexey Potapov
1:49 PM
I'd like to call the Python string split method from MeTTa, I'm almost there

to get what?

but I'm getting something that looks like a Python list

What do you want to get?

 If you know something nicer I'm still interested.

If you want to get the first element of the list, then you can use __getitem__, e.g.

!((py-dot ((py-dot "abc:,def" split) ":,")
    __getitem__) 0)
@Douglas Miles 

It would still be good if we could go from python  list ['abc', 'def'] to metta expression ("abc" "def") easier. 

Yes, it could be a useful function in Python stdlib. However, if Nils needs only the first element, then it would look not nicer with such a function and car-atom than __getitem__


Nil Geisweiller
2:37 PM
That's what I was looking for, thanks @Alexey Potapov.


Nil Geisweiller
3:20 PM
Here's some code to convert Python list to List

3:20 PM







;; Convert Python list into List
(: pylistToList (-> $a (List $b)))
(= (pylistToList $pylst)
   (pylistToList_ $pylst 0 ((py-dot $pylst __len__))))
(: pylistToList_ (-> $a Number Number (List $b)))
(= (pylistToList_ $pylst $from $to)
   (if (< $from $to)
       (Cons ((py-dot $pylst __getitem__) $from)
             (pylistToList_ $pylst (+ $from 1) $to))
       Nil))

;; Test pylistToList
!(pylistToList ((py-dot "abc,def" split) ","))


Robert Wuensche
3 weeks ago




how to load a python module?

!(bind! mypymodule (py-atom mypymodule))
doesnt seem to work to load the module mypymodule.py in the same folder as the folder in which mettalog was started

39 replies

Douglas Miles
3 weeks ago
can you give me the src to the sample module you trying to load? .. it aloso can depend on if there are imoport errors while loading the module 


Robert Wuensche
3 weeks ago
it was a empty python file


Douglas Miles
3 weeks ago
as well as making sur ethe path is registered.. that is whaty i am goign to try to troubleshoot is if i shall need to supprt $PWD or '.' etc


Robert Wuensche
3 weeks ago
how to register the path? from where is it loaded in the current version?


Douglas Miles
3 weeks ago
i will try that as well as a file with at lest one def in it

3w ago
its kind foi funky and has to do with  https://www.swi-prolog.org/pldoc/doc_for?object=janus%3Apy_lib_dirs/1


Robert Wuensche
3 weeks ago
 !(bind! mypymodule (py-atom mypymodule))
still doesn't work with a empty def function in the python file


Douglas Miles
3 weeks ago
can you add an error to the file to make sure its actually  hitting the file? 


Robert Wuensche
3 weeks ago
then

Exception: (260) [janus] janus:py_call(metta_python_builtin:make_py_atom(mypymodule), _124176364, [py_object(true), py_string_as(string)]) ?


Douglas Miles
3 weeks ago
(a sybtax error that is)

3w ago
its problabny not importaing the module .. 

3w ago
unless you see the syntax error

3w ago
!(py-atom sys.path) 

3w ago
will list the directories it will search 


Robert Wuensche
3 weeks ago
it did print Exception: (260) [janus] janus:py_call(metta_python_builtin:make_py_atom(mypymodule), _124176364, [py_object(true), py_string_as(string)]) ? when there was a syntax error in python.

if there is no syntax error and a python function def I get a exception in the terminal.

$ mettalog   --no-html  a.metta --repl
============================================================
EXCEPTION TRACEBACK (explicit1):
============================================================
Traceback (most recent call last):
  File "<string>", line 75, in with_explicit_trace
  File "<string>", line 1, in <module>
NameError: name 'mypymodule' is not defined
============================================================
--- Diagnostic Info ---
Function: <built-in function eval>
Type: builtin_function_or_method
Bound to: <module 'builtins' (built-in)> (type: module)
Positional Args:
  [Arg 0] Type: str -- Value: 'mypymodule'
  [Arg 1] Type: dict -- Value: {'module_sys': <module 'sys' (built-in)>, 'sys': <module 'sys' (built-in)>, 'module_builtins': <module 'builtins' (built-in)>, 'builtins': <module 'builtins' (built-in)>, 'module__frozen_importlib': <
  [Arg 2] Type: dict -- Value: {'s': 'mypymodule', 'global_vars': {'module_sys': <module 'sys' (built-in)>, 'sys': <module 'sys' (built-in)>, 'module_builtins': <module 'builtins' (built-in)>, 'builtins': <module 'builtins' (built-
============================================================

[()]
metta+>
Show more

Douglas Miles
3 weeks ago
you will need to force a syntax error in order to confirtm its even botheing to load the file


Robert Wuensche
3 weeks ago
it does

3w ago
metta+>!(py-atom sys.path)
[['',
'/usr/local/lib/swipl/library/ext/swipy/python',
'/home/r0b3/filesystemRoot/TYPE_coding/mixedPython/plnSamplingA',
'/home/r0b3/filesystemRoot/TYPE_coding/github__trueagiio__metta-wam/metta-wam/python',
'/usr/lib/python312.zip',
'/usr/lib/python3.12',
'/usr/lib/python3.12/lib-dynload',
'/home/r0b3/my-venv/lib/python3.12/site-packages']]
metta+>

Douglas Miles
3 weeks ago
ah .. ok ogood

3w ago
try accecting a function with py-dot

3w ago
!(py-dot mymodule myfun) 

3w ago
the problem is py-atom may not be groveling as hard as py-dot's first argument 


Douglas Miles
3 weeks ago
what does  

!mypymodule   return ?

3w ago
ok i see that a first chance exception that it handles

3w ago
============================================================
EXCEPTION TRACEBACK (explicit1):
============================================================
Traceback (most recent call last):
  File "<string>", line 75, in with_explicit_trace
  File "<string>", line 1, in <module>
NameError: name 'mymod' is not defined
============================================================
--- Diagnostic Info ---
Function: <built-in function eval>
Type: builtin_function_or_method
Bound to: <module 'builtins' (built-in)> (type: module)
Positional Args:
  [Arg 0] Type: str -- Value: 'mymod'
  [Arg 1] Type: dict -- Value: {'module_sys': <module 'sys' (built-in)>, 'sys': <module 'sys' (built-in)>, 'module_builtins': <module 'builtins' (built-in)>, 'builtins': <module 'builtins' (built-in)>, 'module__frozen_importlib': <
  [Arg 2] Type: dict -- Value: {'s': 'mymod', 'global_vars': {'module_sys': <module 'sys' (built-in)>, 'sys': <module 'sys' (built-in)>, 'module_builtins': <module 'builtins' (built-in)>, 'builtins': <module 'builtins' (built-in)>,
============================================================



N(1): <module 'mymod' from '/home/deb12user/metta-wam/mymod.py'>
3w ago
you'll want o check the value of the the binding 

3w ago
!(println! mypymodule ) 


Robert Wuensche
3 weeks ago
!(py-dot mypymodule fn0)
gives

[<function fn0 at 0x7e125e1149a0>]
3w ago
but the import on metta is still bugged because it imports fine and still shows the exception


Robert Wuensche
3 weeks ago
now I have a question about metta: There is a function which takes two Float numbers as arguments and returns a float number.

!(bind! mypymodule (py-atom mypymodule))

!(println! ((py-dot mypymodule fn0 (-> Number Number Number)) 0.1 0.2))
doesn't work

all: (240) [user] py_obi(py_call_method_and_args([<py_function>(0x73ce679189a0), 0.1, 0.2]), _124269510)
^  Unify: (240) [user] py_obi(py_call_method_and_args([<py_function>(0x73ce679189a0), 0.1, 0.2]), _124269510)
   Call: (243) [janus] janus:py_call(metta_python_builtin:py_call_method_and_args([<py_function>(0x73ce679189a0), 0.1, 0.2]), _124338886, [py_object(true), py_string_as(string)])
   Exception: (243) [janus] janus:py_call(metta_python_builtin:py_call_method_and_args([<py_function>(0x73ce679189a0), 0.1, 0.2]), _124338886, [py_object(true), py_string_as(string)]) ?

Douglas Miles
3 weeks ago
is the function like ?

def fn0(a, b):
  return a+b 

Robert Wuensche
3 weeks ago
yes


Robert Wuensche
3 weeks ago
is this another bug?


Douglas Miles
3 weeks ago
100% yes

3w ago
btw thank you so much for bringing these up..  i will get to fixing it!

3w ago
if the number/number/number is left off, does it work?


Douglas Miles
3 weeks ago
i am hoping this is fixed in trueagi-io/master now


Douglas Miles
3 weeks ago
(both bugs)  


Robert Wuensche
3 weeks ago
yes both bugs are fixed. thx! No thank you for building this great technology

For MeTTaLog py-exec! is built-in but for H-E i needed it convenient so here is how i call exec  in  H-E https://github.com/logicmoo/metta-testsuite/blob/development/tests/direct_comp/simple_import/py_eval_05.metta#L1-L18 



1 reply
Follow
Last reply last week
when you want an py-eval vs a py-exec you can sometimes use py-atom

problem with py-atom though is it cant see symbols you are building up

you can define a python variable/symbol during a py-exec .. to see it later you have to use py-eval   

py-exec was usefull for defining modules here 
; Define py-exec to execute Python statements programmatically
(= (py-exec $code)
  (let $exec_fn (py-atom exec)                  ; Bind Python's exec function
    (let $globals (py-atom globals)            ; Bind Python's globals function
      (let $global_ctx ($globals)              ; Retrieve the global context
        (let $_1 ((py-dot $global_ctx __setitem__) "sys" (py-atom "sys")) ; Inject sys into the global context
          ($exec_fn $code $global_ctx))))))  ; Execute the code with the updated global context

; Define py-eval to evaluate Python expressions programmatically
(= (py-eval $code)
  (let $eval_fn (py-atom eval)                  ; Bind Python's eval function
    (let $globals (py-atom globals)            ; Bind Python's globals function
      (let $global_ctx ($globals)              ; Retrieve the global context
        (let $_1 ((py-dot $global_ctx __setitem__) "sys" (py-atom "sys")) ; Inject sys into the global context
          (let $result ($eval_fn $code $global_ctx)  ; Evaluate the code
            (if (== $result ())                    ; Check if the result is empty
              (py-atom "None")                     ; Return Python None
              $result)))))))                       ; Otherwise, return the result

; Define py-leval to evaluate expressions using the local context
(= (py-leval $code)
  (let $eval_fn (py-atom eval)                  ; Bind Python's eval function
    (let $locals_fn (py-atom locals)           ; Bind Python's locals function
      (let $local_ctx ($locals_fn)             ; Retrieve the local context
        (let $_1 ((py-dot $local_ctx __setitem__) "sys" (py-atom "sys")) ; Inject sys into the local context
          (let $result ($eval_fn $code $local_ctx)  ; Evaluate the code with the updated local context
            (if (== $result ())                    ; Check if the result is empty
              (py-atom "None")                     ; Return Python None
              $result)))))))                      ; Otherwise, return the result

; Assertions for py-eval, py-atom, and py-exec
; py-atom might seem prefered
!(test (assertEqual (py-atom "print('hello from py-atom')") (py-atom "None")))
!(test (assertEqual (py-eval "print('hello from py-eval')") (py-eval "None")))
!(test (assertEqual (py-leval "print('hello from py-leval')") (py-leval "None")))
!(test (assertEqual (py-exec "print('hello from py-exec')") ()))

; Test arithmetic operations
!(test (assertEqualToResult (py-atom "1+1") (2)))
!(test (assertEqualToResult (py-eval "1+1") (2)))

!(py-exec "global result_sum; result_sum = 2 + 3")
!(test (assertEqualToResult (py-eval "result_sum") (5)))

; Test string operations
!(py-exec "global result_string; result_string = 'Hello ' + 'World'")
!(test (assertEqualToResult (py-eval "result_string") ("Hello World")))

; Test list operations
!(py-exec "global result_list; result_list = (1, 2, 3) + (4, 5)")
!(test (assertEqual (py-eval "result_list") (py-tuple (1 2 3 4 5))))

; Test dictionary operations
!(py-exec "
global result_dict
result_dict = {'a': 1, 'b': 2}
result_dict['c'] = 3
")
!(test (assertEqual (py-eval "result_dict") (py-dict (("a" 1) ("b" 2) ("c" 3)))))

; Test Python function definition and execution
!(py-exec "
global counter
counter = 0

def increment_counter():
    global counter
    counter += 1
    return counter
")
!(test (assertEqual (py-eval "increment_counter()") 1))
!(test (assertEqual (py-eval "increment_counter()") 2))
!(test (assertEqual (py-eval "counter") 2))

; !(test (assertEqual (py-leval "increment_counter()")  (Error (py-atom "counter") "Exception caught:
; RuntimeError: Failed to find \"counter\"")))


;; py-atom does not see the global scope like this
;!(test (assertEqual (py-atom "increment_counter()")  (Error (py-atom "counter") "Exception caught:
; RuntimeError: Failed to find \"counter\"")))


; Test nested function calls
!(py-exec "
def multiply_and_add(x, y, z):
    return (x * y) + z
")
!(test (assertEqualToResult (py-eval "multiply_and_add(2, 3, 4)") (10)))
