

! (register-module! ../../../metta-moses)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:representation:instance)
! (import! &self metta-moses:feature-selection:feature-selection-helpers)
   
;; Purpose: Score a feature set using the specified scorer type
;; Parameters:
;;   $scorer (FSScorer) → Scorer containing ITable and scorer type
;;   $featureSet (Expression) → Set of feature indices to score
;; Returns: (Composite Score) → Score with complexity penalty
;; todo It might take more parameters
(= (featureSetScorer (mkITable $rows $labels) $scorerType $miConf $featureSet)
    (chain (() (println! (DEBUG scoring feature set: $featureSet with scorer: $scorerType))) $debug
           (case $scorerType
               (
                ; correct the implementation and make it as applyMutualInformation but including confidence
                (mi
                    (if (== $featureSet ())
                        0.0
                            (chain (zipColumn $featureSet $rows) $inputIndices
                                (chain (- (List.length $labels) 1) $columnIndex 
                                    (chain (() (println! (debug itable $itable rows $rows inside feature Scorer $featureSet $inputIndices))) $uhsdf
                                        (chain (Table.getColumn $columnIndex $rows) $outputColumn
                                            (chain (() (println! (debug isdei mutualInformation  $inputIndices expected $outputColumn))))
                                            (chain (mutualInformation $inputIndices $outputColumn) $miScore
                                                (chain (() (println! (debug After mutual Information $miScore))) $kfdssgd
                                                    ; (let (mkITable $rows $labels ) $itable
                                                        (chain (List.length $rows) $size 
                                                        ; todo this size is the size of featureSet 
                                                            (chain (/ $size (+ $size (pow-math 2.718 (* -1 (* $size $miConf))))) $confidence
                                                                (* $miScore $confidence)
                                                            )
                                                        )
                                                    ; )
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        )
                )
                (pre (chain (precisionScore $featureSet $itable) $score ;;todo
                    ; todo   To be implemented
                ))
                ($else (0.0)) ;; correct it
                )
            )
    )
)


(= (demeBasedScorer $itable  $scorer $intialIndices $miConf) 
    (chain (featureSetScorer $itable $scorer $miConf $intialIndices) $scoredValue
        (let (mkITable $rows $labels) $itable 
            (chain (List.length $labels) $complexity 
                (mkCscore $scoredValue $complexity 0.0 0.0 $scoredValue) ; todo
            )
        )
    )
)
;Binary fieldset implementation 
(= (cartesianProduct $set $n)
  (if (== $n 1)
      ;; base case: singleton tuples
      (chain  (superpose $set) $x
        (cons-atom $x ())
      )
      (chain  (superpose $set) $first
        (chain   (collapse (cartesianProduct $set (- $n 1))) $collapsed
            (chain (superpose $collapsed) $rest
                (cons-atom $first $rest)
            )
        )
      )
  )
)

(= (initialInstance  $intialFeatures $arity)
    (chain (repeat 0 $arity) $dummyStarter
         ; !(map-atom (1 2 3) $x (+ $x 1)) ; Returns (2 3 4)
        (chain (map-atom $dummyStarter $each (if (isMember $each $intialFeatures) 1 0))  $finalInstance
            $finalInstance
        )
    )
)

(= (optimizeDeme $fields $itable $actualInstance) 
    (
        ;todo make optimize function to work on with other otpimizers too
        (let ($instance (mkSInstSet $instSet) $state) (hillClimbingFS (mkSInstSet Nil) $itable $actualInstance)
        
            ("My Instance" $instance "My Instset" $instSet "My state" $state)
        )

    )
)
;; Purpose: Main entry point for MOSES-style feature selection with hill climbing
;; Parameters:
;;   $itable (ITable) → Input table containing features and target
;;   $fsParams (FSParams) → Feature selection parameters
;; Returns: (Expression) → Selected feature set
; (: mosesSelectFeatureSets (-> ITable FSParams Expression))
(= (mosesSelectFeatureSets $itable $algo $scorerType $intialFeatures $miConf)
;    (let (FSParams $algo $threshold $targetSize $maxEvals $maxTime $scorerType) $fsParams
       (chain (() (println! (INFO Starting MOSES feature selection with algo: $algo scorer: $scorerType))) $debug

            ; (chain (featureSetScorer $itable $scorerType) $fsScorer ;;todo featureSet is needed as a parameter
                ; get input features
                (let (mkITable $rows $labels) $itable
                    ;; I will get the input features
                    (chain  (- (List.length $labels) 1) $arity ; it is the size of the input features
                        ; binary fields set for features
                        (chain (() (println! (info itable $itable rows $rows inside cartesian $labels arity found $arity))) $sdfhusfdiu
                            (chain (collapse (cartesianProduct (0 1) $arity)) $fields
                                    ; create an intail Instance
                                    ; get input feature by idices
                                    (chain (() (println! (debug after caresian the field sets $fields $labels $intialFeatures))) $uihsg
                                        ; (((1 0)) ((1 0)) ((1 0)) ((1 0)) ((1 0)) ((1 0)) ((1 0)) ((1 0)))

                                        ; ! (map-atom (A) $each (List.index (Cons A (Cons B (Cons Output Nil))) $each))

                                        (chain (map-atom $intialFeatures $each (List.index $labels $each)) $intialIndices
                                            (chain (() (println! (debug after map atom $intialIndices))) $dsjkfsdn
                                                (chain (initialInstance $intialIndices $arity) $initInstance 
                                                    (chain (exprToInst $initInstance) $actualInstance 
                                                        ; the c++ also includes deme based scorer db_sc
                                                        (chain (demeBasedScorer $itable $scorerType $intialIndices $miConf ) $score 
                                                            ("Actual Instance" $actualInstance  "fields" $fields "scored Value" $score)
                                                        )
                                                        ;todo (chain (optimizeDeme $fields $itable $actualInstance $algo) $optimizedDeme
                                                        ;     $optimizedDeme
                                                        ; )
                                                    )
                                                )
                                            )
                                        )
                                    )
                            )
                        )
                    )
                )
              
            ; )
        )
    ; )
)
! (bind! andTable 
   (mkITable
     (Cons (Cons True (Cons True (Cons True Nil)))
     (Cons (Cons True (Cons False (Cons False Nil)))
     (Cons (Cons False (Cons True (Cons False Nil)))
     (Cons (Cons False (Cons False (Cons False Nil))) Nil))))
     (Cons A (Cons B (Cons Output Nil)))))

! (mosesSelectFeatureSets andTable hc mi (A) -1)
; 
