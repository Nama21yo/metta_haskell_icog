((3 (AND A (NOT B) C (OR D))) (2 (AND A (NOT B) C (OR D))))


(Cons (3 (AND A (NOT B) C (OR D))) (Cons (2 (AND A (NOT B) C (OR D))) Nil))

(Cons 1 (Cons 2 (Cons 3 Nil)))
(Cons 2 (Cons 3 Nil))
; ! (bind! rd (py-atom round))
; !
; ! (rd 3.4434332 2)

! (random-int &rng 1 6)
! (random-float &rng 1 6)
; How to pick the last element in a list 

; (= (lastEl Nil) Nil)
(= (lastEl (Cons $x $xs))
    (if (== $xs Nil)
        $x
        (lastEl $xs)
    ))

; ! (lastEl (Cons 1 (Cons 2 (Cons 3 Nil))))
(1 2 3)

! (index-atom (D A B) 0)
(OR a B) C
()
(= (lastEl $expr)
    (let*
        (
            ($h (car-atom $expr))
            ($t (cdr-atom $expr))
        )
    (if (== $t ())
        $h
        (lastEl $t)
    )))

; ! (lastEl (1 2 3))
; ! (index-atom (0 1 2 3 4) 2)

(Cons (s ex) (Cons (s ex) (Cons (s ex) Nil)))

;; genetic programming task description
;; Genetic programming involves various opertions to get to a solution that is fitter than the rest
;; these pertions include
;; 1. selection -- selecting promising candidates from host of options == there are host of selection algorithms 
;; that can be applied here. It's upto the reader to choose and implement in MeTTa the algorithm of his/her choice. 
;; two of the most common selection alogorithms are tournament selection and roulette selection ... the reader is advised to
;; explore other approaches as well.

;; 2. recombination/crossover -- using genetic material from two parents and swapping them to create 
;;      new offsprings which are just potentail solutions that could give us even better performace 
;;      in relation  to the problem at hand
;; e.g., in the particular case of generating boolean expressions let's take two parents
;; (AND A B (OR B C))  and (OR B (AND D B) C) if we swapp elements of the two expressions at index postion 
;; of 2 whicha re B and (AND D B), respecively, we will end up with two more expressions which are
;; (AND A (AND D C) (OR B C)) and (OR B B)

;; 3. Muitation -- this operation involves selecting a gene in a parent by pure chance and changing its value
;; once again to try and produce an indivual which is fitter than the parent.
;; taking the first of the above examples, (AND A B (OR B C)), pick a node at random and change its value taking
;; from all possible values that can be replaced at that position.

;; So the task is to write simple implementation of the above operations in MeTTa
