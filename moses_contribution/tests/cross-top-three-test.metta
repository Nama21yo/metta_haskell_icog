
!(register-module! ../../../../metta-moses)

!(import! &self metta-moses:representation:instance)
!(import! &self metta-moses:representation:representation)
!(import! &self metta-moses:representation:create-representation)
!(import! &self metta-moses:utilities:tree)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:utilities:python-helpers)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:scoring:cscore)
!(import! &self metta-moses:deme:create-deme)
!(import! &self metta-moses:optimization:hillclimbing:cross-top-three)


; Utility function to convert Python expressions to lists
(= (pyExprToList $expr) (py_exprToList $expr))

(: merger (-> Expression Instance Instance Expression))
(= (merger $targetInstances $baseInst $referenceInst)
    (collapse (let (mkSInst (mkPair $targetInst $score)) (superpose $targetInstances)
        (mkSInst (mkPair (mergeInstance $targetInst $baseInst $referenceInst) (worstCscore))))))



;; Check the actual output structure, if it correct
! (crossTopThree
    (mkDeme 
        (mkRep 
          (mkKbMap (mkDscKbMp (ConsMap NilMap)) (mkDscMp NilMMap)) 
          (mkTree (mkNode A) Nil))
        (mkSInstSet 
          (Cons 
            (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 1 2 3 4 1)))
            (Cons 
              (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 2 3 4 3)))
              (Cons 
                (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 1 2 3 4 4)))
                (Cons 
                  (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore 1 2 3 4 2)))
                  (Cons 
                    (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore 1 2 3 4 5)))
                    Nil))))))
        (mkDemeId "1")) 
    3 0 5 (mkInst (Cons 2 Nil)))
