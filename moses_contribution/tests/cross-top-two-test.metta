
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
!(import! &self metta-moses:optimization:hillclimbing:cross-top-two)


; Utility function to convert Python expressions to lists
(= (pyExprToList $expr) (py_exprToList $expr))

(: merger (-> Expression Instance Instance Expression))
(= (merger $targetInstances $baseInst $referenceInst)
    (collapse (let (mkSInst (mkPair $targetInst $score)) (superpose $targetInstances)
        (mkSInst (mkPair (mergeInstance $targetInst $baseInst $referenceInst) (worstCscore))))))



;; Check the actual output structure, if it correct
! ( crossTopTwo 
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
        (mkDemeId "1")) 3 0 4 (mkInst (Cons 2 Nil)))

; ;; Define a sample deme for testing
; ! (bind! deme1 
;     (mkDeme 
;         (mkRep 
;             (mkKbMap 
;                 (mkDscKbMp (ConsMap NilMap)) 
;                 (mkDscMp NilMMap)) 
;             (mkTree (mkNode A) Nil))
;         (mkSInstSet 
;             (Cons (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 1 2 3 4 1))) 
;             (Cons (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 2 3 4 3))) 
;             (Cons (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 1 2 3 4 4))) 
;             (Cons (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore 1 2 3 4 2))) 
;             (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore 1 2 3 4 5))) 
;             Nil))))))
;         (mkDemeId "1")))

; ;; Test cases for generatePairs
; ;; Verifies correct pair generation for different sample sizes
; ; ! (assertEqual (generatePairs 1 1 0 Nil) Nil)
; ; ! (assertEqual (generatePairs 2 1 0 Nil) (Cons (Cons 0 1) Nil)) ;; (Cons (Cons 0 1) Nil)
; ; ! (assertEqual (generatePairs 3 1 0 Nil) (Cons (Cons 0 1) (Cons (Cons 0 2) (Cons (Cons 1 2) Nil))))
; ; ! (assertEqual (generatePairs 4 1 0 Nil) 
; ;     (Cons (Cons 0 1) 
; ;     (Cons (Cons 0 2) 
; ;     (Cons (Cons 1 2) 
; ;     (Cons (Cons 0 3) 
; ;     (Cons (Cons 1 3) 
; ;     (Cons (Cons 2 3) Nil)))))))

; ;; Test cases for swapValue (reused from cross-top-one)
; ; ! (assertEqual (swapValue 1 2 2) 1)
; ; ! (assertEqual (swapValue 1 2 3) 3)
; ; ! (assertEqual (swapValue a b b) a)
; ; ! (assertEqual (swapValue x y z) z)

; ; ;; Test cases for compareAndSwap (reused from cross-top-one)
; ; ! (assertEqual 
; ;     (compareAndSwap (Cons 0 Nil) (Cons 1 Nil) (Cons 1 Nil) Nil) 
; ;     (Cons 0 Nil))
; ; ! (assertEqual 
; ;     (compareAndSwap (Cons 0 (Cons 3 Nil)) (Cons 1 (Cons 1 Nil)) (Cons 2 (Cons 1 Nil)) Nil) 
; ;     (Cons 2 (Cons 3 Nil)))
; ; ! (assertEqual 
; ;     (compareAndSwap (Cons a (Cons b (Cons c Nil))) 
; ;                     (Cons 1 (Cons 2 (Cons 3 Nil))) 
; ;                     (Cons 1 (Cons 4 (Cons 5 Nil))) Nil)
; ;     (Cons a (Cons 4 (Cons 5 Nil))))

; ; ;; Test cases for mergeInstance (reused from cross-top-one)
; ; ! (assertEqual 
; ;     (mergeInstance (mkInst (Cons a (Cons b Nil))) 
; ;                    (mkInst (Cons 1 (Cons 2 Nil))) 
; ;                    (mkInst (Cons 1 (Cons 3 Nil)))) 
; ;     (mkInst (Cons a (Cons 3 Nil))))
; ; ! (assertEqual 
; ;     (mergeInstance (mkInst (Cons a (Cons b Nil))) 
; ;                    (mkInst (Cons 1 (Cons 2 Nil))) 
; ;                    (mkInst (Cons 1 (Cons 2 Nil)))) 
; ;     (mkInst (Cons a (Cons b Nil))))
; ; ! (assertEqual 
; ;     (mergeInstance (mkInst (Cons a Nil)) 
; ;                    (mkInst (Cons 1 (Cons 2 Nil))) 
; ;                    (mkInst (Cons 1 (Cons 2 Nil)))) 
; ;     (Error (1 2 2) "Unequal target base and/or reference sizes"))

; ; ;; Test cases for crossTopTwo
; ; ;; Test 1: Generate 2 new instances from sample size 4
; ; ! (let
; ;     (mkDeme 
; ;         (mkRep 
; ;             (mkKbMap 
; ;                 (mkDscKbMp (ConsMap NilMap)) 
; ;                 (mkDscMp NilMMap)) 
; ;             (mkTree (mkNode A) Nil))
; ;         (mkSInstSet $list) 
; ;         $demeId) 
; ;     (crossTopTwo deme1 2 0 4 (mkInst (Cons 2 Nil))) 
; ;     (assertEqual (List.length $list) 7)) ;; Original 5 + 2 new

; ; ;; Test 2: Generate 3 new instances from sample size 4
; ; ! (let
; ;     (mkDeme 
; ;         (mkRep 
; ;             (mkKbMap 
; ;                 (mkDscKbMp (ConsMap NilMap)) 
; ;                 (mkDscMp NilMMap)) 
; ;             (mkTree (mkNode A) Nil))
; ;         (mkSInstSet $list) 
; ;         $demeId) 
; ;     (crossTopTwo deme1 3 0 4 (mkInst (Cons 2 Nil))) 
; ;     (assertEqual (List.length $list) 8)) ;; Original 5 + 3 new

; ; ;; Test 3: Specific output validation for nToMake=2
; ; ! (assertEqual 
; ;     (crossTopTwo 
; ;         (mkDeme 
; ;             (mkRep 
; ;                 (mkKbMap 
; ;                     (mkDscKbMp (ConsMap NilMap)) 
; ;                     (mkDscMp NilMMap)) 
; ;                 (mkTree (mkNode A) Nil))
; ;             (mkSInstSet 
; ;                 (Cons 
; ;                     (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 1 2 3 4 1))) 
; ;                     (Cons 
; ;                         (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 2 3 4 3))) 
; ;                         (Cons 
; ;                             (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 1 2 3 4 4))) 
; ;                             (Cons 
; ;                                 (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore 1 2 3 4 2))) 
; ;                                 Nil)))))
; ;             (mkDemeId "1")) 
; ;         2 0 4 (mkInst (Cons 2 Nil)))
; ;     (mkDeme 
; ;         (mkRep 
; ;             (mkKbMap 
; ;                 (mkDscKbMp (ConsMap NilMap)) 
; ;                 (mkDscMp NilMMap)) 
; ;             (mkTree (mkNode A) Nil))
; ;         (mkSInstSet 
; ;             (Cons 
; ;                 (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 1 2 3 4 1))) 
; ;                 (Cons 
; ;                     (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 2 3 4 3))) 
; ;                     (Cons 
; ;                         (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 1 2 3 4 4))) 
; ;                         (Cons 
; ;                             (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore 1 2 3 4 2))) 
; ;                             (Cons 
; ;                                 (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore -1.0000000000000006e308 0.0 0.0 0.0 -1.0000000000000006e308))) 
; ;                                 (Cons 
; ;                                     (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore -1.0000000000000006e308 0.0 0.0 0.0 -1.0000000000000006e308))) 
; ;                                     Nil)))))))
; ;         (mkDemeId "1")))

; ; ;; Test 4: Small sample size (2 instances)
; ! (crossTopTwo 
;         (mkDeme 
;             (mkRep 
;                 (mkKbMap 
;                     (mkDscKbMp (ConsMap NilMap)) 
;                     (mkDscMp NilMMap)) 
;                 (mkTree (mkNode A) Nil))
;             (mkSInstSet 
;                 (Cons 
;                     (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 1 2 3 4 1))) 
;                     (Cons 
;                         (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 2 3 4 3))) 
;                         Nil)))
;             (mkDemeId "1")) 
;         2 0 2 (mkInst (Cons 2 Nil)))
; ; ! (assertEqual 
; ;     (crossTopTwo 
; ;         (mkDeme 
; ;             (mkRep 
; ;                 (mkKbMap 
; ;                     (mkDscKbMp (ConsMap NilMap)) 
; ;                     (mkDscMp NilMMap)) 
; ;                 (mkTree (mkNode A) Nil))
; ;             (mkSInstSet 
; ;                 (Cons 
; ;                     (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 1 2 3 4 1))) 
; ;                     (Cons 
; ;                         (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 2 3 4 3))) 
; ;                         Nil)))
; ;             (mkDemeId "1")) 
; ;         2 0 2 (mkInst (Cons 2 Nil)))
; ;     (mkDeme 
; ;         (mkRep 
; ;             (mkKbMap 
; ;                 (mkDscKbMp (ConsMap NilMap)) 
; ;                 (mkDscMp NilMMap)) 
; ;             (mkTree (mkNode A) Nil))
; ;         (mkSInstSet 
; ;             (Cons 
; ;                 (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 1 2 3 4 1))) 
; ;                 (Cons 
; ;                     (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 2 3 4 3))) 
; ;                     (Cons 
; ;                         (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore -1.0000000000000006e308 0.0 0.0 0.0 -1.0000000000000006e308))) 
; ;                         Nil))))
; ;         (mkDemeId "1")))


    
; ! ( crossTopOne
;       (mkDeme 
;         (mkRep 
;           (mkKbMap (mkDscKbMp (ConsMap NilMap)) (mkDscMp NilMMap)) 
;           (mkTree (mkNode A) Nil))
;         (mkSInstSet 
;           (Cons 
;             (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 1 2 3 4 1)))
;             (Cons 
;               (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 2 3 4 3)))
;               (Cons 
;                 (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 1 2 3 4 4)))
;                 (Cons 
;                   (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore 1 2 3 4 2)))
;                   (Cons 
;                     (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore 1 2 3 4 5)))
;                     Nil))))))
;         (mkDemeId "1")) 3 0 4 (mkInst (Cons 2 Nil)))
; ! (assertEqual 
;     (crossTopTwo 
;       (mkDeme 
;         (mkRep 
;           (mkKbMap (mkDscKbMp (ConsMap NilMap)) (mkDscMp NilMMap)) 
;           (mkTree (mkNode A) Nil))
;         (mkSInstSet 
;           (Cons 
;             (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 1 2 3 4 1)))
;             (Cons 
;               (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 2 3 4 3)))
;               (Cons 
;                 (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 1 2 3 4 4)))
;                 (Cons 
;                   (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore 1 2 3 4 2)))
;                   (Cons 
;                     (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore 1 2 3 4 5)))
;                     Nil))))))
;         (mkDemeId "1")) 3 0 4 (mkInst (Cons 2 Nil)))
;     (mkDeme 
;         (mkRep 
;             (mkKbMap 
;                 (mkDscKbMp 
;                     (ConsMap NilMap)) 
;                     (mkDscMp NilMMap)) 
;                     (mkTree (mkNode A) Nil)) 
;                         (mkSInstSet 
;                             (Cons (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 1 2 3 4 1))) 
;                                 (Cons (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 2 3 4 3))) 
;                                     (Cons (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 1 2 3 4 4))) 
;                                         (Cons (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore 1 2 3 4 2))) 
;                                             (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore 1 2 3 4 5))) 
;                                                 ;; The rest: new mkSInst from all i>j pairs, with merged values
;                                                 (Cons (mkSInst (mkPair (mkInst (...)) (mkCscore ...)))))))))) (mkDemeId "1")))

; ;; You can add more asserts for values, or check content using List.getByIdx, etc.
