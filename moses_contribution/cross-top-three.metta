
; Since there isn't cube root in metta we will use pow-math and cast it into Integer
! (bind! int (py-atom "int"))


;; Helper function to generate triples (k,j,i) where k < j < i (matching C++ triple nested loop logic)
(: generateTriples (-> Number Number Number Number (List (List Number)) (List (List Number))))
(= (generateTriples $n $i $j $k $acc)
    (if (>= $i $n)
        $acc
        (if (>= $j $i)
            (generateTriples $n (+ $i 1) 1 0 $acc)
            (if (>= $k $j)
                (generateTriples $n $i (+ $j 1) 0 $acc)
                (let* (
                        ;; Calculate position index: i*(i-1)*(i-2)/6 + j*(j-1)/2 + k
                        ($iContrib (/ (* $i (* (- $i 1) (- $i 2))) 6))
                        ; (() (println! $i ))
                        ($jContrib (/ (* $j (- $j 1)) 2))
                        ; (() (println! $j))
                        ($position (+ $iContrib (+ $jContrib $k)))
                        ; (() (println $position))
                        ($triple (Cons $k (Cons $j (Cons $i Nil))))
                        ($newAcc (Cons (Cons $position $triple) $acc))
                      )
                      (generateTriples $n $i $j (+ $k 1) $newAcc)
                )
            )
        )
    )
)

; ! (generateTriples 4 2 1 0 Nil)

;; Helper function to process a single triple and create merged instance
(: processTriple (-> (List Number) (List $a) Instance $a))
(= (processTriple (Cons $position (Cons $k (Cons $j (Cons $i Nil)))) $sortedSample $baseInstance)
   (let* (
           (() (println! (DEBUG: Processing triple $k $j $i at position $position)))
           
           ;; Get the i-th reference instance (best from sorted sample)
           ($iElement (List.getByIdx $sortedSample $i))
           (() (println! (DEBUG: Got i-th element: $iElement)))

           ; Pattern match to extract reference instance
           ((mkSInst (mkPair $ithinstance $ithscore)) $iElement)
           (() (println! (DEBUG: Extracted reference inst of i: $ithinstance)))
           
          ;  ($iExpr ($iElement))
          ;   (() (println! (DEBUG: Extracted instances -  i: $iExpr)))

           ;; Get the j-th reference instance
           ($jElement (List.getByIdx $sortedSample $j))
           (() (println! (DEBUG: Got j-th element: $jElement)))

             ; Pattern match to extract reference instance
           ((mkSInst (mkPair $jthinstance $jthscore)) $jElement)
           (() (println! (DEBUG: Extracted reference inst of i: $jthinstance)))

          
          ;  ($jExpr ($jElement))
          ;  (() (println! (DEBUG: Extracted instances - j: $jExpr i: $iExpr)))

           ;; Get the k-th target instance (to be modified)
           ($kElement (List.getByIdx $sortedSample $k))
           (() (println! (DEBUG: Got k-th element: $kElement)))
           
           ;; Extract the instances from the scored instances
           ($kExpr ($kElement))

;            (DEBUG: Processing pair 2 4)
; (DEBUG: Got reference element: (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 1 2 3 4 1))))
; (DEBUG: Extracted reference inst: (mkInst (Cons 5 Nil)))
; (DEBUG: Got target element: (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 2 3 4 3))))
; (DEBUG: Changed target inst: ((mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 2 3 4 3)))))
; (DEBUG: Created new scored instance: ((mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore -1.0000000000000006e308 0.0 0.0 0.0 -1.0000000000000006e308)))))
; ($newSInst (merger $targetExpr $baseInstance $referenceInst))
            (() (println!  (DEBUG: kth-instance changed to Expression: $kExpr)))
          ;  (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 1 2 3 4 4)))
           
          ;  (() (println! (DEBUG: Extracted instances - k $kExpr, j $jExpr, i $iElement)))
           
           ;; Perform first merge: merge k-th instance with base and i-th reference
           ($firstMerge (merger $kExpr $baseInstance $ithinstance))
           (() (println! (DEBUG: First merge result: $firstMerge)))
           
           ;; Perform second merge: merge result with base and j-th reference
           ($finalMerge (merger $firstMerge $baseInstance $jthinstance))
           (() (println! (DEBUG: Final merge result: $finalMerge)))
         ) 
         $finalMerge))

;; Process a list of triples iteratively
(: processTripleList (-> (List (List Number)) (List $a) Instance Number (List $a) (List $a)))
(= (processTripleList Nil $sortedSample $baseInstance $nToMake $acc) $acc)
(= (processTripleList (Cons $triple $restTriples) $sortedSample $baseInstance $nToMake $acc)
   (let* (
           ;; Extract position from triple
           ((Cons $position $actualTriple) $triple)
           (() (println! (DEBUG: Processing triple at position $position)))
           
           ;; Check if we've made enough instances
           ($continue (<= $position $nToMake))
           (() (println! (DEBUG: Continue processing: $continue (position $position <= nToMake $nToMake))))
         )
         (if $continue
             (let* (

                     ($processedInstance (processTriple $triple $sortedSample $baseInstance))
                     ($newAcc (pyExprToList $processedInstance))
                     ($appendedAcc (List.appendList $acc $newAcc))
                     (() (println! (DEBUG: New accumulator: $appendedAcc)))
                   )
                   (processTripleList $restTriples $sortedSample $baseInstance $nToMake $appendedAcc)
             )
             (() (println! (DEBUG: Reached limit, stopping at position $position))
                  $acc)
         )
   ))

(: crossTopThree (-> Deme Number Number Number Instance Deme))
(= (crossTopThree $deme $nToMake $sampleStart $sampleSize $baseInstance)
   (trace! (Inside crossTopThree: $nToMake $sampleStart $sampleSize) 
            (let* (
                    ((mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $instSet) $demeId) $deme)
                    (() (println! (DEBUG: Extracted deme components)))
                    (() (println! (DEBUG: instSet: $instSet)))

                    ;; Calculate maximum possible triples (sample_size choose 3)
                    ;; Formula: sample_size * (sample_size-1) * (sample_size-2) / 6
                    ($max (/ (* $sampleSize (* (- $sampleSize 1) (- $sampleSize 2))) 6))
                    ($nToMakeNew (if (< $max $nToMake) $max $nToMake))
                    
                    (() (println! (DEBUG: NToMake & Max: $nToMakeNew $max)))

                    ;; Calculate how many to sort: cbrt(6*nToMake) + 3, but not more than sample_size
                    ($numToSortRaw (+ (pow-math (* 6 $nToMakeNew) (/ 1.0 3)) 3)) ;; Implementing cube root using power root since there isn't cube root in metta
                    ($numToSort (if (< $sampleSize $numToSortRaw) (int $sampleSize) (int $numToSortRaw)))
                    
                    (() (println! (DEBUG: Nums to Sort: $numToSortRaw $numToSort)))

                    ;; Get the sample from instSet
                    ($sample (List.takeNFrom $sampleStart $sampleSize $instSet))
                    (() (println! (DEBUG: Sample taken: $sample)))
                    
                    ;; Partially sort the sample to get top numToSort instances
                    ($sortedSample (List.partialSort instance>= $sample $numToSort Nil))
                    (() (println! (DEBUG: PartialSort: $sortedSample)))

                    ;; Generate all possible triples (k,j,i) where k < j < i
                    ($triples (generateTriples $numToSort 2 1 0 Nil))
                    (() (println! (DEBUG: Generated triples: $triples)))
                    
                    ;; Process each triple using the iterative function
                    ($newInstances (processTripleList $triples $sortedSample $baseInstance $nToMakeNew Nil))
                    (() (println! (DEBUG: New instances created: $newInstances)))
                    
                    ;; Append new instances to the original instSet
                    ; ($finalInstSet (List.appendList $newInstances $instSet))
                    ($finalInstSet (if (==  (() () Nil) $newInstances)
                                      $instSet
                                      (List.appendList $newInstances $instSet)))
                    (() (println! (DEBUG: Final instance set: $finalInstSet))))
                ;; Return new deme with updated instances
                (mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $finalInstSet) $demeId)
              )
      )
)


