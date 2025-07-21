(gene "A")
(chr (gene "A") "chr16")
(start (gene "A") 1000)
(end (gene "A") 1200)

(gene "B")
(chr (gene "B") "chr2")
(start (gene "B") 1000)
(end (gene "B") 1200)

(gene "C")
(chr (gene "C") "chr16")
(start (gene "C") 9000)
(end (gene "C") 9400)

(gene "D")
(chr (gene "D") "chr16")
(start (gene "D") 1600)
(end (gene "D") 1900)

; "find all genes on chr16
;  whose start base is greater than 500 and end base is less than 2000"
!(match &self (, (chr $g "chr16")
    (start $g $start)
    (end $g $end))
(if (and (> $start 500) (< $end 2000)) $g ()))


!(match &self (, (chr $g "chr16")
            (start $g $start)
            (end $g $end))
    (if (and (> $start 500) (< $end 2000)) $g (empty)))

; shouldn't be reduced
!((py-atom str (-> Atom Atom )) (+ 1 1))

; Should get-atoms and match  see the same atoms?

; Not really. get-atoms simply retrieves atoms in the given atomspace. match delegates matching to the atoms, which support this operation (in particular, 
; atoms representing other spaces). Atoms from stdlib (or other imported spaces) 
; are not directly inserted into &self. Earlier, imported spaces were inserted as atoms. Now, it seems, that modules are not even inserted as atoms (get-atoms doesn't retrieve them), but handled separately (you still can put one space inside another space, and match will peek into the inserted space). In any case, match goes through the imported modules, which atoms are not really inserted into &self.

; There is a function now print-mods!, which prints the imported modules. 

(= (sum $l) (foldl-atom $l 0 $x $y (+ $x $y)))

!(sum (3.0 4.0 5.0 5.0 5.0 5.0 4.0 5.0 4.0 4.0 4.0 5.0 5.0 4.0 5.0 5.0 5.0 4.0 5.0 5.0 5.0 5.0 5.0 4.0 5.0 4.0))

;; Declaration of List data type and constructors
(: List (-> $a Type))
(: Nil (List $a))
(: Cons (-> $a (List $a) (List $a)))

;; Define List.foldr
;; Fold a tuple from right to left
(: List.foldr (-> (-> $a $b $b) $b (List $a) $b))
(= (List.foldr $f $i Nil) $i)
(= (List.foldr $f $i (Cons $h $t)) ($f $h (List.foldr $f $i $t)))

;; Define List.sum
(: List.sum (-> (List Number) Number))
(= (List.sum $xs) (List.foldr + 0 $xs))

;; Define sum
(= (sum $l) (foldl-atom $l 0 $x $y (+ $x $y)))

;; ;; Test sum
;; !(sum (3.0 4.0 5.0 5.0 5.0 5.0 4.0 5.0 4.0 4.0 4.0 5.0 5.0 4.0 5.0 5.0 5.0 4.0 5.0 5.0 5.0 5.0 5.0 4.0 5.0 4.0))

;; Test List.sum
!(List.sum (Cons 3.0
                 (Cons 4.0
                       (Cons 5.0
                             (Cons 5.0
                                   (Cons 5.0
                                         (Cons 5.0
                                               (Cons 4.0
                                                     (Cons 5.0
                                                           (Cons 4.0
                                                                 (Cons 4.0
                                                                       (Cons 4.0
                                                                             (Cons 5.0
                                                                                   (Cons 5.0
                                                                                         (Cons 4.0
                                                                                               (Cons 5.0
                                                                                                     (Cons 5.0
                                                                                                           (Cons 5.0
                                                                                                                 (Cons 4.0
                                                                                                                       (Cons 5.0
                                                                                                                             (Cons 5.0
                                                                                                                                   (Cons 5.0
                                                                                                                                         (Cons 5.0
                                                                                                                                               (Cons 5.0
                                                                                                                                                     (Cons 4.0
                                                                                                                                                           (Cons 5.0
                                                                                                                                                                 (Cons 4.0 Nil)))))))))))))))))))))))))))


!((py-atom sum)
  (py-list (3.0 4.0 5.0 5.0 5.0 5.0 4.0 5.0 4.0 4.0 4.0 5.0 5.0 4.0 5.0 5.0 5.0 4.0 5.0 5.0 5.0 5.0 5.0 4.0 5.0 4.0)))


!(max-atom (1 2 3))


(number 1)
(number 2)
(number 3)
! (match &self (number $x) $x)
! (collapse (match &self (number $x) $x))
! (max-atom (collapse (match &self (number $x) $x)))


! (println "Variables in Knowledge Base")
(implies (Frog $x) (Green $x))
(implies (Frog $x) (Eats-flies $x))

; The first match is like asking, "What can I conclude if Sam is a Frog?" The answer is "Sam is Green" and "Sam Eats-flies".
! (match &self (implies (Frog Sam) $what) $what)

; The second match is like asking, "What condition would make Sam Green?" The answer is "If Sam is a Frog".
! (match &self (implies ($P $x) (Green Sam)) ($x might be $P))

; Composite Queries with Conjunction
(Frog Sam)
(Robot Sophia)

; use , to form a conjunction of two conditions
; fact and implication together
; think of it as join
; You’re joining the table of frogs with the table of implications about frogs, then selecting the conclusions for each frog
; useful for combining facts and rules to derive new information
! (match &self (, (Frog $x) (implies (Frog $x) $y)) $y)

; Chaining Concepts with Combinatory Logic and Peano Arithmetic
; Using := for facts like (:= (Green Sam) T)
(:= (I $x) $x)
(:= ((K $x) $y) $x)
(:= (K $x $y) $x)
(:= (S $x $y $z) ($x $z ($y $z)))

!(assertEqualToResult
  (match &self
    (:= (S K K x) $r)
    $r)
  ((K x (K x))))

!(assertEqualToResult
  (match &self
    (:= (S K K x) $r)
    (match &self (:= $r $r2)
      $r2))
  (x))

(:= (Add $x Z) $x)
(:= (Add $x (S $y)) (Add (S $x) $y))

!(assertEqualToResult
  (match &self
    (:= (Add (S Z) (S Z)) $r)
    $r)
  ((Add (S (S Z)) Z)))

!(assertEqualToResult
  (match &self
    (:= (Add (S Z) (S Z)) $r)
    (match &self (:= $r $r2)
      $r2))
  ((S (S Z))))


(= (croaks Fritz) T)
(= (eat_flies Fritz) T)
(= (And T T) T)
(= (frog $x) (And (croaks $x) (eat_flies $x)))
(= (green $x) (frog $x))
!(assertEqual (green Fritz) T)

; Facts: Fritz croaks and eats flies.
; Rules: A frog croaks and eats flies; frogs are green.
; Evaluation: (green Fritz) reduces to (frog Fritz) (T), then (And T T) (T).

(= (color) green)
(= (color) yellow)
(= (color) red)
! (match &self (= (color) $x) $x) 
! (superpose (red yellow green))
; The order doesn't matter in assertEqual
!(assertEqual (match &self (= (color) $x) $x) (superpose (red yellow green)))
!(assertEqual (color) (superpose (red yellow green)))
; 


