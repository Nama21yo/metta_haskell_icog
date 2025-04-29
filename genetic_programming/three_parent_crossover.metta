; Three parent cross over
! (register-module! ../genetic_programming)
! (import! &self genetic_programming:stochastic_ranking)


(= (parents) (sus (chromosomes) 3 (random-float &rng 0 1)))
(= (parent1)  (access 0 (parents)))
(= (parent2)  (access 1 (parents)))
(= (parent3)  (access 2 (parents)))
! "Selected Chromosomes"
! (parents)

; append for expression
(= (append_expr $item ()) (cons-atom $item ()))
(= (append_expr $item $expr) 
   (let* (
     ($head (car-atom $expr))
     ($tail (cdr-atom $expr))
     ($appended-tail (append_expr $item $tail))
   )
   (cons-atom $head $appended-tail)))

(= (crossover $p1 $p2 $p3 $offspring)  
  (if (== $p1 ())
      $offspring
      (let* (
          ($p1_element (index 0 $p1))
          ($p2_element (if (== $p2 ()) Nil (index 0 $p2)))
          ($p3_element (if (== $p3 ()) Nil (index 0 $p3)))
          ($tail1 (if (== $p1 ()) () (cdr-atom $p1)))
          ($tail2 (if (== $p2 ()) () (cdr-atom $p2)))
          ($tail3 (if (== $p3 ()) () (cdr-atom $p3)))
          ($new_offspring
            (if (== $p1_element $p2_element)
                (append_expr $p1_element $offspring)
                (append_expr $p3_element $offspring)
            )
          )
      )
      (crossover $tail1 $tail2 $tail3 $new_offspring)
  )
)
)

; do for the combinations
(= (offspring1) (crossover (parent1) (parent2) (parent3) ())) ; offspring 1
(= (offspring2) (crossover (parent1) (parent3) (parent2) ()) ); offspring 2
(= (offspring3) (crossover (parent2) (parent3) (parent1) ())) ; offspring 3

(= (Crossover_result) (Cons (offspring1) (Cons (offspring2) (Cons (offspring3) Nil)) ))
! "CrossOvered Chromosomes"
!(Crossover_result)


