(: cartesianProduct (-> Expression Number Expression))
(= (cartesianProduct $set $n)
  (if (== $n 1)
      ;; base case: singleton tuples
      (chain (eval (superpose $set)) $x
        (cons-atom $x ())
      )
      (chain (eval (superpose $set)) $first
        (chain (eval (superpose (collapse (cartesianProduct $set (- $n 1))))) $rest
          (cons-atom $first $rest)
        )
      )
  )
)



! (cartesianProduct (a b) 2) ; (a a), (a b), (b a), (b b)

!(cartesianProduct (1 2) 3)

!(cartesianProduct (1 2) 4)
