; swap mutation - we select two positions of a single gene at random, and interchange the values
! (register-module! ../genetic_programming)
! (import! &self genetic_programming:stochastic_ranking)

(= (parents) (sus (chromosomes) 1 (random-float &rng 0 5)))
! "Original Selected Chromosome"
! (parents)

(= (length_exp $list)
    (if (== $list ())
        0
        (let $rest (cdr-atom $list)
            (+ 1 (length_exp $rest))
        )
    )
)

(= (first) (access 0 (parents)))

; !(first)
(= (score (index 0 (first))))
(= (expression) (index 1 (first)))
; !(expression)

(= (size_chromosome) (length_exp (expression)))
; ! (size_chromosome)
(= (random_number) (random-int &rng 0 (size_chromosome)))
; !(random_number)
(= (swap1) (index (random_number) (expression)))
; (= (swap2) (index (random_number) (expression)))
; ! (swap1)
; !(swap2)

(= (replace $idx $item $expr)
    (if (== $expr ())
        (error "Index out of bounds")
        (if (== $idx 0)
            (let* (
                    ($rest (cdr-atom $expr))
                  )
                  (cons-atom $item $rest)
            )
            (let*
                (
                    ($head (car-atom $expr))
                    ($tail (cdr-atom $expr))
                    ($c (replace (- $idx 1) $item $tail))
                )
                (cons-atom $head $c)
            )
        )
    )
)

(= (mutated_expr) (replace (random_number) (swap1) (expression)))
! "Mutated Chromosome"
!(mutated_expr)
(= (mutated_list) (Cons (mutated_expr) Nil))
!(mutated_list)

