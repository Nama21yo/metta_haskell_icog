%% Generated from /mnt/desktop/metta_haskell_icog/metta_basics/difference.metta at 2025-07-16T10:52:15+00:00
:- style_check(-discontiguous).
:- style_check(-singleton).
:- include(library(metta_lang/metta_transpiled_header)).

%  ; ; Term registration whether it is an operation or not
%  ; (= (isop opleft) True)
%  ; (= (isop opright) True)
%  ; (= (isop opnop) True)
%  ; (= (isop ballleft) False)
%  ; (= (isop ballhit) False)
%  ; (= (isop ballright) False)
%  ; ; induce implications from event stream
%  ; (= (induce $Memory Nil) $Memory)
%  ; (= (induce $Memory (Cons $Event Nil)) $Memory)
%  ; (= (induce $Memory (Cons $Event (Cons $Op Nil))) $Memory)
%  ; (= (induce $Memory (Cons $Event (Cons $Op (Cons $LastEvent $FIFO))))
%  ;    (if (and (and (not (isop $Event)) (not (isop $LastEvent))) (isop $Op))
%  ;        (induce (Cons (Sentence (Implication $LastEvent $Op $Event) (Truth 1 0)) $Memory) (Cons $LastEvent $FIFO))
%  ;        (induce $Memory (Cons $LastEvent $FIFO))))
%  ; ;  evidence from anticipation failure
%  ; (= (reviseNeg (Sentence $Implication $Truth) Nil) $Truth)
%  ; (= (reviseNeg (Sentence $Implication $Truth) (Cons $Event Nil)) $Truth)
%  ; (= (reviseNeg (Sentence $Implication $Truth) (Cons $Event (Cons $Op Nil))) $Truth)
%  ; (= (reviseNeg (Sentence (Implication $S $A $P) (Truth $WP $WN)) (Cons $Event (Cons $Op (Cons $LastEvent $FIFO))))
%  ;    (if (and (and (not (== $P $Event)) (== $S $LastEvent)) (== $A $Op))
%  ;        (reviseNeg (Sentence (Implication $S $Op $P) (Truth $WP (+ 1 $WN))) (Cons $LastEvent $FIFO))
%  ;        (reviseNeg (Sentence (Implication $S $Op $P) (Truth $WP $WN)) (Cons $LastEvent $FIFO))))
%  ; ;  revise all items when existing multiple times
%  ; (= (revisePos $SearchTerm $Truth Nil) $Truth)
%  ; (= (revisePos $SearchTerm (Truth $WP $WN) (Cons (Sentence $Term $Truth) $MemoryTail))
%  ;     (if (== $SearchTerm $Term)
%  ;         (revisePos $SearchTerm (Truth (+ 1 $WP) $WN) $MemoryTail)
%  ;         (revisePos $SearchTerm (Truth $WP $WN) $MemoryTail)))
%  ; ;  Whether the term is included in the list of terms (should be a hashmap lookup ideally)
%  ; (= (included $SearchTerm Nil) False)
%  ; (= (included $SearchTerm (Cons $Term $TermListTail))
%  ;    (if (== $SearchTerm $Term)
%  ;        True
%  ;        (included $SearchTerm $TermListTail)))
%  ; ;  Revise the procedureal implications
%  ; (= (revise $FIFO $AlreadyHAndledTerms Nil) Nil)
%  ; (= (revise $FIFO $AlreadyHAndledTerms (Cons (Sentence $Term $Truth) $MemoryTail))
%  ;    (if (included $Term $AlreadyHAndledTerms)
%  ;        (revise $FIFO (Cons $Term $AlreadyHAndledTerms) $MemoryTail)
%  ;        (Cons (Sentence $Term (revisePos $Term (reviseNeg (Sentence $Term $Truth) $FIFO) $MemoryTail)) (revise $FIFO (Cons $Term $AlreadyHAndledTerms) $MemoryTail))))
%  ; ;  process events by doing induction + revision on the events
%  ; (= (processEvents $FIFO) (revise $FIFO Nil (induce Nil $FIFO)))
%  ; !(processEvents (Cons ballhit (Cons opleft (Cons ballleft (Cons opleft (Cons ballleft (Cons opnop (Cons ballhit (Cons opleft (Cons ballleft Nil))))))))))
%  ; (= (bin) 0)
%  ; (= (bin) 1)
%  ; (= (pair $x $y) ($x $y))
%  ; ! (pair (bin) (bin))
%  ; !(assertEqualToResult (+ 2 (* 3 5.5)) (18.5))
%  ; !(assertEqualToResult (- 8 (/ 4 6.4)) (7.375))
%  ; !(assertEqualToResult (% 21 17) (4))
%  ; !(assertEqualToResult (< 4 (+ 2 (* 3 5))) (True))
%  ; !(assertEqualToResult (and (> 4 2) (< 4 3)) (False))
%  ; !(assertEqualToResult (* (+ 5 3) (- 10 4)) (48))  ; (5 + 3) * (10 - 4) = 8 * 6 = 48
%  ; ! (+ 2 "String")
%  ; !(assertEqualToResult (+ 2 "String") ((Error "String" BadType)))
%  ; gen 3 generates all 3-bit binary lists (e.g., [0,0,0], [1,0,1]).
%  ; (= (gen $n) (if (> $n 0) (Cons (bin) (gen (- $n 1))) Nil))
%  ; (= (bin) 0)
%  ; (= (bin) 1)
%  ; ; subsum computes the sum of products: 3*1 + 7*0 + 5*1 = 8.
%  ; (= (subsum Nil Nil) 0)
%  ; (= (subsum (Cons $x $xs) (Cons $b $bs)) (+ (* $x $b) (subsum $xs $bs)))
%  ; (let $t (gen 3)
%  ;     (if (== (subsum (Cons 3 (Cons 7 (Cons 5 Nil))) $t) 8) $t (superpose ())))
%  ; (= (choice) "A")
%  ; (= (choice) "B")
%  ; ! (choice)
%  ; Queries the &kb space for planets with colors, finding Mars is Red.
%  ; !(import! &kb c2_spaces_kb)
%  ; ! (match &kb
%  ;     (, ($obj is $prop)
%  ;        ($prop is-a Color)
%  ;        ($obj is-a Planet))
%  ;     (Color of Planet $obj is $prop))
%  ; list all planets inside the knowledge base
%  ; ! (match &kb ($obj is-a Planet) $obj)
%  ; !(assertEqualToResult
%  ;   (match &kb
%  ;     (, ($obj is $prop)
%  ;        ($prop is-a Color)
%  ;        ($obj is-a Planet))
%  ;     (Color of Planet $obj is $prop))
%  ;   ((Color of Planet Mars is Red)))
%  ; Probabilistic Logic Networks for reasoning
%  ; todo This isn't working
%  ; (= (s-tv (stv $s $c)) $s) ;; added this but still need to know min
%  ; (= (c-tv (stv $s $c)) $c)
%  ; (= (TV $x) (match &self (.tv $x $stv) $stv))
%  ; (= (TV (And $a $b)) (stv (min (s-tv (TV $a)) (s-tv (TV $b))) (min (c-tv (TV $a)) (c-tv (TV $b)))))
%  ; (.tv (Evaluation (Predicate P) (Concept A)) (stv 0.5 0.8))
%  ; (.tv (Evaluation (Predicate P) (Concept B)) (stv 0.3 0.9))
%  ; ! (TV (And (Evaluation (Predicate P) (Concept A)) (Evaluation (Predicate P) (Concept B))))
%  ; ; !(assertEqual (TV (And (Evaluation (Predicate P) (Concept A)) (Evaluation (Predicate P) (Concept B)))) (stv 0.3 0.8))
%  ; (.tv (Rain) (stv 0.7 0.9))
%  ; (.tv (Wet) (stv 0.8 0.95))
%  ; ; todo ! (TV (And Rain Wet))
%  ; ! (get-type +)
%  ; ! (get-metatype +)
%  ; ! (get-type (+ -))
%  ; Box wraps any type
%  ; (: Box (-> $t Type))
%  ; (: box (-> $t (Box $t)))
%  ; ! (get-type (box 10))
%  ; ! (get-metatype (box 10))
%  ; (: curry (-> (-> $a $b $c) (-> $a (-> $b $c))))
%  ; (= (((curry $f) $x) $y) ($f $x $y))
%  ; ; !(assertEqual (get-type (curry +)) (-> Number (-> Number Number)))
%  ; ; !(assertEqual (((curry +) 2) 3) 5)
%  ; (= (add10) (curry + 10))
%  ; ! ((add10) 5)
%  ; !(bind! &pets (new-space))
%  ; (= (pet $x) (and (friendly $x) (lives_with_humans $x)))
%  ; (= (friendly Max) True)
%  ; (= (lives_with_humans Max) True)
%  ; (= (friendly Luna) True)
%  ; (= (lives_with_humans Luna) True)
%  ; (: ift (-> Bool Atom %Undefined%))
%  ; (= (ift True $then) $then)
%  ; !(ift (pet $x) (add-atom &pets (Pet $x)))
%  ; !(assertEqualToResult (match &pets (Pet $x) $x) (Max Luna))
%  ; State atoms in metta allow you to create utable containers whose contents can change without
%  ; altering their identity. They are ideal tfo tracking dynamic values
%  ; !(bind! &balance (new-state 100))
%  ; (= (deposit $amount) (change-state! &balance (+ (get-state &balance) $amount )))
%  ; (= (withdraw $amount) (change-state! &balance (- (get-state &balance) $amount)))
%  ; ! (deposit 50)
%  ; !(get-state &balance) ; 150
%  ; ! (withdraw 30)
%  ; !(get-state &balance) ; 120
%  ; ; task’s status changes from pending to done.
%  ; (= (set-task-status! $task $status)
%  ;   (let $new-state (new-state $status)
%  ;         (add-atom &self (= (status (Task $task)) $new-state))
%  ;   )
%  ; )
%  ; !(set-task-status! coding pending)
%  ; !(get-state (status (Task coding))) ; pending
%  ; !(nop (change-state! (status (Task coding)) done))
%  ; !(get-state (status (Task coding))) ; done
%  ; (@doc multiply
%  ;     (@desc "Multiplies two numbers")
%  ;     (@params ((@param "First number") (@param "Second number")))
%  ;     (@return "Product")
%  ; )
%  ; (: multiply (-> Number Number Number))
%  ; (= (multiply $x $y) (* $x $y))
%  ; !(help! multiply)
%  ; (function (if True (return "Success") (return "Failure")))
%  ; !(function)
%  ; (= (double $x) (* 2 $x))
%  ; !(double 3)
%  ; !(eval (double 3))
%  ; !(unify 5 5 "Equal" "Not Equal")
%  ; !(cons-atom A (B C))
%  ; ! (decons-atom (A B C))
%  ; ! (context-space)
%  ; !(min-atom (3 1 4 2))  ; Returns 1
%  ; !(max-atom (3 1 4 2))  ; Returns 4
%  ; ! (size-atom (A B C))
%  ; Facts
%  ; (= (Frog kermit) true)
%  ; (= (Frog $x) $x)
%  ; ! (match &self (Frog $x) $x)
%  ; !(collapse-bind (match &self (Frog $x) $x))
%  ; !(superpose-bind (collapse-bind (match &self (Frog $x) $x)))
%  ; !(superpose (1 (+ 1 1) ))
%  ; (A B C)
%  ; ! (match &self (A $x) $x)
%  ; Avoiding tokens
%  ; (= (new-state-var! $var $val)
%  ;     (let $new-state (new-state $val)
%  ;          (add-atom &self (= (status $var) $new-state))))
%  ; ! (new-state-var! user guest)
%  ; ! (get-state (status user))      ; Returns guest
%  ; ! (change-state! (status user) admin)
%  ; ! (get-state (status user))      ; Returns admin
%  ; !(bind! &token (new-state (A B)))
%  ; !(get-state &token)          ; Returns (A B)
%  ; !(change-state! &token (C D))
%  ; !(get-state &token)          ; Returns (C D)
%  ; !(bind! &state (new-state 0))
%  ; !(superpose ((change-state! &state 1) (change-state! &state 2)))
%  ; !(get-state &state)  ; Returns 2 (currently sequential, but order not guaranteed)
%  ; (: unified (-> Atom $a $a $a))
%  ; (= (unified $lterm $rterm $rewrite)
%  ;    (case $rterm (($lterm $rewrite))))
%  ; !(unified A A B)  ; Returns B (since A unifies with A)
%  ; !(bind! &tempcount (new-state 0))
%  ; (= (TupleCount $x)
%  ;    (superpose ((case (change-state! &tempcount 0) ())
%  ;                (case (let $y (superpose $x)
%  ;                      (superpose ((change-state! &tempcount (+ 1 (get-state &tempcount)))))) ())
%  ;                (get-state &tempcount))))
%  ; !(TupleCount (1 2 3))  ; Returns 3
%  ; !(bind! &tempbest (new-state Nil))
%  ; !(bind! &tempbestscore (new-state 0))
%  ; (= (BestCandidate $tuple $evaluateCandidateFunction $t)
%  ;    (superpose ((case (change-state! &tempbestscore 0) ())
%  ;                (case (change-state! &tempbest Nil) ())
%  ;                (case (let* (($x (superpose $tuple))
%  ;                             ($fx ($evaluateCandidateFunction $x $t)))
%  ;                            (superpose ((if (> $fx (get-state &tempbestscore))
%  ;                                            (superpose ((change-state! &tempbest $x)
%  ;                                                        (change-state! &tempbestscore $fx))) nop)))) ())
%  ;                (get-state &tempbest))))
%  ; (= (score $x $t) (+ $x $t))  ; Example evaluation function
%  ; !(BestCandidate (1 2 3) score 5)  ; Returns 3 (highest score: 3 + 5 = 8)
%  ; (: for (-> %Undefined% (Number Atom Number) Atom %Undefined%))
%  ; (= (for $I ($Start ... $End) $Body)
%  ;    (If (< $Start $End)
%  ;        (sequential ((let $I $Start $Body)
%  ;                     (for $I ((+ 1 $Start) ... $End) $Body)))))
%  ; !(bind! &sum (new-state 0))
%  ; !(for $x (1 ... 4) (change-state! &sum (+ $x (get-state &sum))))
%  ; !(get-state &sum)  ; Returns 6 (1 + 2 + 3)
%  ; !(get-type 5)       ; Returns Number
%  ; !(get-type Number)  ; Returns %Undefined%
%  ; (= (test 2) 2)
%  ; (: f (-> Atom Atom))
%  ; (= (f $a) $a)  ; Prevents evaluation
%  ; !(let $W (test $X) (f (= (test $X) $W)))  ; Returns (= 2 2)
%  ; !(add-atom &self (A B))
%  ; !(add-atom &self (C D))
%  ; !(match &self $x $x)  ; Returns [(A B), (C D)] no deterministic
%  ; (= (foo) (trace! msg (empty)))
%  ; !(foo)
%  ; !(println! (match &self (@doc $fname $1 $2 $3) $fname))
%  ; !(get-doc map-atom)
%  ; !(help!) 
%  ;  !(let $localvar  (collapse-bind (match &self (Frog $x) $x))  $localvar)
%  ; /[((a {  })), ((b {  })), ((c {  })), ((d {  }))]
%  ;  !(collapse-bind (match &self (Frog $x) $x))
%  ; [((d {  })), ((c {  })), ((b {  })), ((a {  }))]
%  ; >
%  ; !(eval (baz))  ; Might return NotReducible if baz is undefined
%  ; !(subtraction-atom (a b b c) (b c c d))  ; Returns (a b)
%  ; !(intersection-atom (a b c c) (b c c d))  ; Returns (b c c)
%  ; !(union-atom (a b b c) (b c c d))  ; Returns (a b b c b c c d)
%  ; !(unique-atom (a b c d d))  ; Returns (a b c d)
%  ; !(xor True False)  ; Returns True
%  ; !(xor True True)   ; Returns False
%  ; !(format-args ("Hello, {}!") ("world"))  ; Returns "Hello, world!"
%  ; !(trace! "Debug" (+ 2 3))  ; Prints "Debug" and returns 5
%  ; !(case $value
%  ;   (
%  ;     (1 "One")
%  ;    (2 "Two")
%  ;    ($x "Other")))
%  ; !(collapse (superpose (1 2 3)))  ; Returns (1 2 3)
%  ; !(assertAlphaEqualToResult (foo) (bar))
%  ; !(assertEqualToResult (+ 1 1) (2))
%  ; !(=alpha (lambda $x $x) (lambda $y $y))  ; Returns True
%  ; !(if-equal 5 5 (println! "Equal") (println! "Not equal"))
%  ; !(noreduce-eq (foo) (foo))
%  ; !(help-param! $param)
%  ; !(subtraction (superpose (a b c)) (superpose (b c)))  ; Returns [a]
%  ; !(intersection (superpose (a b c)) (superpose (b c d)))  ; Returns [b c]
%  ; !(union (superpose (a b)) (superpose (b c)))  ; Returns [a b c]
%  ; !(nop)
%  ; !(let* (($x 1) ($y (+ $x 1))) $y)  ; Returns 2
%  ; !(foldl-atom (1 2 3) 0 $a $b (+ $a $b))  ; Returns 6
%  ; !(map-atom (1 2 3) $v (* $v 2))  ; Returns (2 4 6)
%  ; !(filter-atom (1 2 3 4) $v (> $v 2))  ; Returns (3 4)
%  ; !(first-from-pair (a b))  ; Returns a
%  ; !(switch $value ((1 "One") (2 "Two") ($x "Other")))
%  ; ; !(if-error (foo) "Error" "No error")
%  ; ; !(atom-subst 5 $x (* $x $x))  ; Returns (* 5 5)
%  ; ; !(noeval (+ 1 2))  ; Returns (+ 1 2)
%  ; ; !(id 5)  ; Returns 5
%  ; ; !(isinf-math (/ 1 0))  ; Returns True
%  ; ; !(round-math 3.7)  ; Returns 4
%  ; ; !(ceil-math 3.2)  ; Returns 4
%  ; ; !(trunc-math 3.7)  ; Returns 3
%  ; ; !(log-math 2 8)  ; Returns 3
%  ; ; !(abs-math -5)  ; Returns 5
%  ; ; !(pow-math 2 3)  ; Returns 8
%  ; ; !(sqrt-math 16)  ; Returns 4
%  ; ; !(index-atom (a b c) 1)  ; Returns b
%  ; ; !(unify $x 5 "Five" "Not five")
%  ; ; !(chain (+ 1 2) $x (* $x $x))  ; Returns 9
%  ; ; !(function (if True (return "Yes") (return "No")))  ; Returns "Yes"
%  ; ; (: List (-> $a Type))
%  ; ; (: Nil (List $a))
%  ; ; (: Cons (-> $a (List $a) (List $a)))
%  ; ; !(get-type (List 5) ) ; ouput is [Type]
%  ; ; !(get-type (Lisr A)) ; output is []
%  ; ; (: ITable (-> $a Type))
%  ; ; (: mkITable (-> (List (List $a)) (List Type) (ITable $a) ))
%  ; ; ; (: ITable (-> Type Type))
%  ; ; !(get-type (ITable 263785946635))
%  ; ; (: some_type (-> $a (List $a)))
%  ; ; ; (: Symbol Type)
%  ; ; ; !(get-type (some_type 5))
%  ; ; !(get-type (Cons A (Cons B (Cons C Nil))))
%  ; ; !(get-type (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil)))) )
%  ; ; !(get-metatype (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil)))) )
%  ; ;  ! (let $a (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil)))) (get-type $a))
%  ; ; !(assertEqual
%  ; ;    (let $a (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil)))) (get-type $a))
%  ; ;    (ITable $a))
%  ; ; (: T Type)
%  ; ; (: tt (-> $a T))
%  ; ; !(get-type (tt A))  ;; Returns T and its correct
%  ; ; !(get-type A) ;; Returns [] but in MeTTa interpreter I got %Undefined%
%  ; ; ! (format-args "{} {}" (2 abc))
%  ; (: List (-> $a Type))
%  ; (: Nil (List $a))
%  ; (: Cons (-> $a (List $a) (List $a)))
%  ; ; Conditional Definition
%  ; (= (if True $x $y) $x)
%  ; (= (if False $x $y) $y)
%  ; ; Insert an element to presumably sorted list
%  ; (= (insert $x Nil) (Cons $x Nil))
%  ; (= (insert $x (Cons $head $tail))
%  ;     (if (< $x $head)
%  ;         (Cons $x (Cons $head $tail))
%  ;         (Cons $head (insert $x $tail))
%  ;     )
%  ; )
%  ; ! (insert 1 Nil)
%  ; ! (insert 2 (insert 1 Nil))
%  ; ! (insert 3 (insert 2 (insert 1 Nil)))
%  ; ! (+ 2 "S") -> doesn't show error
%  ; !(unify 5 5 "Equal" "Not Equal")
%  ; !(unify $x (5 gas) "Five" "Not five")
%  ; ! (unify (1 2 $x) (1 2 4) $x NotFound)
%  ; (= (double $x) (* 2 $x))
%  ; !(double 3)
%  ; ; It is different in metta and mettalog
%  ; !(quote (double 3))
%  ; !(case $v
%  ;   (
%  ;     (1 "One")
%  ;    (2 "Two")
%  ;    ($x "Other")))
%  ; !(isinf-math (/ 1 0))
%  ; gen 3 generates all 3-bit binary lists (e.g., [0,0,0], [1,0,1]).
%  ; (= (gen $n) (if (> $n 0) (Cons (bin) (gen (- $n 1))) Nil))
%  ; (= (bin) 0)
%  ; (= (bin) 1)
%  ; ; subsum computes the sum of products: 3*1 + 7*0 + 5*1 = 8.
%  ; !(gen 3)
%  ; (= (subsum Nil Nil) 0)
%  ; (= (subsum (Cons $x $xs) (Cons $b $bs)) (+ (* $x $b) (subsum $xs $bs)))
%  ; !   (let $t (gen 3)
%  ;     (if (== (subsum (Cons 3 (Cons 7 (Cons 5 Nil))) $t) 8) $t (superpose ())))


top_call_5:- do_metta_runtime(ExecRes,mi('min-atom',[3,1,4,2],ExecRes)).




top_call :-
    time(top_call_5).


arg_type_n('min-atom',1,1,non_eval('Expression')).
%  ; Returns 1


top_call_6:- do_metta_runtime(ExecRes,mi('max-atom',[3,1,4,2],ExecRes)).




top_call :-
    time(top_call_6).


arg_type_n('max-atom',1,1,non_eval('Expression')).
%  ; Returns 4
%  ; ; ; ; ; 
%% Finished generating /mnt/desktop/metta_haskell_icog/metta_basics/difference.metta at 2025-07-16T10:52:15+00:00

:- normal_IO.
:- initialization(transpiled_main, program).
