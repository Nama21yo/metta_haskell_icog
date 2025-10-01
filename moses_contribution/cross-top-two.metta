; (Cons 1 (Cons 2 (Cons 3 Nil))) ; Top/Best Exemplar
; (Cons 0 (Cons 1 (Cons 2 Nil))) ; Base
; (Cons 3 (Cons 2 (Cons 1 Nil))) ;; target

;; Key Points
;; - The `crossTopTwo` function in MOSES's hill-climbing combines pairs of top-scoring instances to create new ones, using a base instance.
;; - The MeTTa implementation mirrors the C++ version, using functional list operations instead of imperative loops.
;; - It seems likely that both produce equivalent results, though MeTTa is less efficient but more declarative.

;; Overview
;; The `crossTopTwo` function is part of the hill-climbing algorithm in OpenCog's MOSES system, used to optimize program settings. It takes the best solutions (instances) from a group (deme), pairs them up, and mixes each pair with a previous solution (base instance) to create new candidates. In C++, it uses loops to process bit-strings, while in MeTTa, it uses lists and functional programming to achieve the same goal. Both versions combine pairs of high-scoring instances in a specific order to explore new solutions.

;; How It Works
;; - **Input**: A deme (collection of scored instances), the number of new instances to make (`nToMake`), a sample range (`sampleStart`, `sampleSize`), and a base instance.
;; - **Process**: 
;;   - Extracts a sample of instances from the deme.
;;   - Sorts them by score (highest first).
;;   - Generates pairs of indices (j, i) where j < i, up to the desired number of new instances.
;;   - For each pair, merges the j-th best instance with the i-th best, using the base instance to decide which settings to copy.
;;   - Adds new instances to the deme with a default low score.
;; - **Output**: A new deme with the original and new instances.

;; Example
;; Imagine optimizing a program with one setting (e.g., a number). If the deme has instances [(5,1), (3,3), (2,4)] (lower scores are better), base is (2), and you want 2 new instances:
;; - Sort by score: [(2,4), (3,3), (5,1)].
;; - Pairs: (0,1) → merge (2) with (3) using base (2) → new instance (3).
;; - (0,2) → merge (2) with (5) using base (2) → new instance (5).
;; - Result: New deme with [(2,4), (3,3), (5,1), (3,low_score), (5,low_score)].

;; MeTTa Implementation
;; Below is the MeTTa code for `crossTopTwo`, designed to match the C++ version.

;; generatePairs -- Generates pairs (j, i) for j < i, up to sample size n
;;   - Generates pairs (j, i) for i from 1 to n-1, j from 0 to i-1. (The c++ nested for loop)
;;   - Example: For n=4, returns [(0,1), (0,2), (1,2), (0,3), (1,3), (2,3)]. ;; the arrangment is non-deterministic
; Helper to append a pair (as expression) to the list
; !(register-module! ../../../metta-moses)

; !(import! &self metta-moses:representation:instance)
; !(import! &self metta-moses:representation:representation)
; !(import! &self metta-moses:representation:create-representation)
; !(import! &self metta-moses:utilities:tree)
; !(import! &self metta-moses:utilities:list-methods)
; !(import! &self metta-moses:utilities:python-helpers)
; !(import! &self metta-moses:utilities:general-helpers)
; !(import! &self metta-moses:scoring:cscore)
; !(import! &self metta-moses:deme:create-deme)
; !(import! &self metta-moses:optimization:hillclimbing:cross-top-one)
; !(import! &self metta-moses:optimization:hillclimbing:test:cross-top-one-test)


; (= (pyExprToList $expr) (py_exprToList $expr))


;; Main generator: outputs list of pairs (each pair is (Cons $j (Cons $i Nil)))
; (: generatePairs (-> Number Number Number (List (List Number)) (List (List Number))))
; (= (generatePairs $n $i $j $acc)
;     (if (>= $i $n)
;         $acc
;         (if (< $j $i)
;             (generatePairs $n $i (+ $j 1) (List.appendPair (Cons $j (Cons $i Nil)) $acc))
;             (generatePairs $n (+ $i 1) 0 $acc)
;         )
;     )
; )

; Previous error Code
; (: List.appendPair (-> Expression (List Expression) (List Expression)))
; (= (List.appendPair $pair $list)
;    (Cons $pair $list))

; ; ;; Main generator: outputs list of flat pairs (j i)
; (: generatePairs (-> Number Number Number (List Expression) (List Expression)))
; (= (generatePairs $n $i $j $acc)
;     (if (>= $i $n)
;         $acc
;         (if (< $j $i)
;             (generatePairs $n $i (+ $j 1) (List.appendPair  (Cons $j $i) $acc))
;             (generatePairs $n (+ $i 1) 0 $acc)
;         )
;     )
; )
; ! (generatePairs 2 1 0 Nil)
; ! (assertEqual (generatePairs 2 1 0 Nil) (Cons (Cons 0 1) Nil)) ;; (Cons (Cons 0 1) Nil)
; ! (assertEqual (generatePairs 3 1 0 Nil) (Cons (Cons 0 1) (Cons (Cons 0 2) (Cons (Cons 1 2) Nil))))


; !(List.sort (generatePairs 3 1 0 Nil))
;; crossTopTwo -- Combines pairs of top-scoring instances to create new ones
; (: crossTopTwo (-> Deme Number Number Number Instance Deme))
; (= (crossTopTwo $deme $nToMake $sampleStart $sampleSize $baseInstance)
;     (let* (
;         ((mkDeme $rep (mkSInstSet $instSet) $demeId) $deme)
;         ($sample (List.takeNFrom $sampleStart $sampleSize $instSet))
;         ($sortedSample (List.partialSort instance>= $sample $sampleSize Nil))
;         ($maxPairs (/ (* $sampleSize (- $sampleSize 1)) 2))
;         ($nToMakeNew (if (< $maxPairs $nToMake) $maxPairs $nToMake))
;         ($pairs (generatePairs $sampleSize 1 0 Nil))
;         ($selectedPairs (List.takeN $nToMakeNew $pairs))
;         ($newInstancesList
;             (List.map
;                 (fn ($pair)
;                     (let* (
;                         ((Cons $a (Cons $b Nil)) $pair)
;                         ($target (List.getByIdx $sortedSample $a))
;                         ($reference (List.getByIdx $sortedSample $b))
;                         ($newInst (mergeInstance
;                             (.first (.pair $target))
;                             $baseInstance
;                             (.first (.pair $reference))))
;                         )
;                         (mkSInst
;                             (mkPair
;                                 $newInst
;                                 worstCscore))))
;                 $selectedPairs))
;         ($newInstSet
;             (List.appendList $newInstancesList $instSet))
;         )
;         (mkDeme
;             $rep
;             (mkSInstSet $newInstSet)
;             $demeId)))

; (: crossTopTwo (-> Deme Number Number Number Instance Deme))
; (= (crossTopTwo $deme $nToMake $sampleStart $sampleSize $baseInstance)
;    (trace! (Inside crossTopTwo: $nToMake $sampleStart $sampleSize) 
;             (let* (
;                     ((mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $instSet) $demeId) $deme)
;                     (() (println! (Inside crossTopTwo)))
;                     ; ($nToMakeNew (if (< (- $sampleSize 1) $nToMake) (- $sampleSize 1) $nToMake)) ;;

;                     ($max (/ (* $sampleSize (- $sampleSize 1)) 2))
;                     ($nToMakeNewer (if (< $max $nToMake) $max $nToMake))
                    
;                     (() (println! (NToMake & Max: $nToMakeNewer $max)))

;                      ;; Calculate how many to sort: sqrt(2*nToMake) + 3, but not more than sample_size
;                     ($numToSortRaw (+ (sqrt-math (* 2 $nToMakeNewer)) 3))
;                     ($numToSort (if (< $sampleSize $numToSortRaw) $sampleSize $numToSortRaw))
                    
;                     (() (println! (Nums to Sort: $numToSortRaw $numToSort)))

;                     ;; Partially sort the instances to get the best `numToSort` out of the sample
;                     ($partialSorted (List.partialSort instance>= $instSet $numToSort Nil))
;                     ($sampled (List.takeNFrom $sampleStart $sampleSize $partialSorted))

;                     (() (println! (PartialSort: $partialSorted )))

;                     ;; Generate all (j,i) pairs in the upper triangle (excluding diagonal)
;                     ($pairs (generatePairs $sampleSize 1 0 Nil))

;                     (() (println! (nested loop Pairs: $pairs )))

;                     ;; Only keep the number of pairs needed
;                     ($pairsToMake (List.takeN $nToMakeNewer $pairs))

;                     (() (println! (Pairs to make from the current: $pairsToMake)))
                    
;                      ;; For each (j,i) in pairsToMake, perform crossover between reference at i and target at j
;                     ; to be corrected
;                     ($newInstances
;                       (List.map
;                         (fn ($pair)
;                           (let* (
;                             ($j (List.getByIdx $pair 0))
;                             ($i (List.getByIdx $pair 1))
;                             ((mkSInst (mkPair $referenceInst $referenceScore)) (List.getByIdx $sampled $i))
;                             ($target (List.getByIdx $sampled $j))
;                             ;; Perform merge (merger) as in crossTopOne
;                             ($result (merger $target $baseInstance $referenceInst))
;                           ) $result))
;                         $pairsToMake
;                       )
;                     )

;                     (() (println! (New instances After merging: $newInstances)))
;                     ;; Append new instances to deme
;                     ($newInstList (pyExprToList (List.listToExpr $newInstances)))
;                     ($finalInstSet (List.appendList $newInstList $instSet))
;                     (() (println! (AppendList Set $finalInstSet))))
;                 (mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $finalInstSet) $demeId)
;               )
;       )
; )



; (: crossTopTwo (-> Deme Number Number Number Instance Deme))
; (= (crossTopTwo $deme $demeSize $nToMake $sampleStart $sampleSize $baseInstance)
;   (!trace (let* (
;     ;; Deconstruct deme to get instance set and other fields (adjust as per your Deme structure)
;     ((mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $instSet) $demeId) $deme)

;     ;; Calculate maximum number of pairs (sample_size choose 2)
;     ($max (/ (* $sampleSize (- $sampleSize 1)) 2))
;     ($nToMakeNew (if (< $max $nToMake) $max $nToMake))

;     ;; Calculate how many to sort: sqrt(2*nToMake) + 3, but not more than sample_size
;     ($numToSortRaw (+ (sqrt (* 2 $nToMakeNew)) 3))
;     ; ($numToSort (if (< $sampleSize $numToSortRaw) $sampleSize $numToSortRaw))

;     ;; Partially sort the instances to get the best `numToSort` out of the sample
;     ; ($partialSorted (List.partialSort instance>= $instSet $numToSort Nil))
;     ; ($sampled (List.takeNFrom $sampleStart $sampleSize $partialSorted))

;     ;; Generate all (j,i) pairs in the upper triangle (excluding diagonal)
;     ($pairs (generatePairs $sampleSize 1 0 Nil))

;     ;; Only keep the number of pairs needed
;     ; ($pairsToMake (List.takeN $nToMakeNew $pairs))

;     ;; For each (j,i) in pairsToMake, perform crossover between reference at i and target at j
;     ; ($newInstances
;     ;   (List.map
;     ;     (fn ($pair)
;     ;       (let* (
;     ;         ($j (List.getByIdx $pair 0))
;     ;         ($i (List.getByIdx $pair 1))
;     ;         ((mkSInst (mkPair $referenceInst $referenceScore)) (List.getByIdx $sampled $i))
;     ;         ($target (List.getByIdx $sampled $j))
;     ;         ;; Perform merge (merger) as in crossTopOne
;     ;         ($result (merger $target $baseInstance $referenceInst))
;     ;       ) $result))
;     ;     $pairsToMake
;     ;   )
;     ; )
;     (() (println! (make instances After merging: $nToMakeNew)))
;     (() (println! (sort instances After merging: $numToSortRaw)))
;     (() (println! (pair instances After merging: $pairs)))

    
;     ;; Append new instances to deme
;     ($newInstList (0 1 2 4))
;     ; ($finalInstSet (List.appendList $newInstList $instSet))
;   )
;     (mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet (List.appendList (pyExprToList $newInstances) $instSet)) $demeId)
;   ))
; )

; !(crossTopTwo (mkDeme 
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

; ! (get-atoms &self)
;; Helper function to generate pairs (j,i) where j < i
; (: generatePairs (-> Number Number Number (List (List Number)) (List (List Number))))
; (= (generatePairs $n $i $j $acc)
;     (if (>= $i $n)
;         $acc
;         (if (< $j $i)
;             (generatePairs $n $i (+ $j 1) (Cons (Cons $j (Cons $i Nil)) $acc))
;             (generatePairs $n (+ $i 1) 0 $acc)
;         )
;     )
; )

; (: crossTopTwo (-> Deme Number Number Number Instance Deme))
; (= (crossTopTwo $deme $nToMake $sampleStart $sampleSize $baseInstance)
;    (trace! (Inside crossTopTwo: $nToMake $sampleStart $sampleSize) 
;             (let* (
;                     ((mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $instSet) $demeId) $deme)
;                     (() (println! (Inside crossTopTwo)))

;                     ;; Calculate maximum possible pairs (sample_size choose 2)
;                     ($max (/ (* $sampleSize (- $sampleSize 1)) 2))
;                     ($nToMakeNew (if (< $max $nToMake) $max $nToMake))
                    
;                     (() (println! (NToMake & Max: $nToMakeNew $max)))

;                     ;; Calculate how many to sort: sqrt(2*nToMake) + 3, but not more than sample_size
;                     ($numToSortRaw (+ (sqrt-math (* 2 $nToMakeNew)) 3))
;                     ($numToSort (if (< $sampleSize $numToSortRaw) $sampleSize $numToSortRaw))
                    
;                     (() (println! (Nums to Sort: $numToSortRaw $numToSort)))

;                     ;; Get the sample from instSet
;                     ($sample (List.takeNFrom $sampleStart $sampleSize $instSet))
                    
;                     ;; Partially sort the sample to get top numToSort instances
;                     ($sortedSample (List.partialSort instance>= $sample $numToSort Nil))

;                     (() (println! (PartialSort: $sortedSample )))

;                     ;; Generate all possible pairs (j,i) where j < i
;                     ($pairs (generatePairs $numToSort 1 0 Nil))

;                     (() (println! (nested loop Pairs: $pairs )))

;                     ;; Take only the number of pairs we need
;                     ($pairsToMake (List.takeN $nToMakeNew $pairs))

;                     (() (println! (Pairs to make: $pairsToMake)))
                    
;                     ;; For each pair, merge the instances
;                     ($newInstances
;                       (List.map
;                         (fn ($pair)
;                           (let* (
;                             ;; Get j and i from the pair (Cons j (Cons i Nil))
;                             ($j (List.head $pair))
;                             (() (println! (Pairs of i & j: $j $pair)))

;                             ($i (List.head (List.tail $pair)))

;                             (() (println! (Pairs of i & j: $i $j $pair)))
                            
;                             ;; Get the reference instance (i-th best)
;                             ((mkSInst (mkPair $referenceInst $referenceScore)) (List.getByIdx $sortedSample $i))
                            
;                             ;; Get the target instance (j-th best)
;                             ((mkSInst (mkPair $targetInst $targetScore)) (List.getByIdx $sortedSample $j))
                            
;                             ;; Perform merge (using merger from crossTopOne)
;                             ($mergedInst (merger $targetInst $baseInstance $referenceInst))
                            
;                             ;; Create new scored instance with worst score
;                             ($newSInst (mkSInst (mkPair $mergedInst worstCscore)))
;                           ) 
;                           $newSInst))
;                         $pairsToMake
;                       )
;                     )

;                     (() (println! (New instances: $newInstances)))
                    
;                     ;; Append new instances to the original instSet
;                     ($finalInstSet (List.appendList $newInstances $instSet))
                    
;                     (() (println! (Final instance set: $finalInstSet))))
;                 ;; Return new deme with updated instances
;                 (mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $finalInstSet) $demeId)
;               )
;       )
; )


; ;; Alternative implementation using direct nested loops (closer to C++ version)
; (: crossTopTwoAlternative (-> Deme Number Number Number Instance Deme))
; (= (crossTopTwoAlternative $deme $nToMake $sampleStart $sampleSize $baseInstance)
;    (let* (
;            ((mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $instSet) $demeId) $deme)
           
;            ;; Calculate maximum possible pairs
;            ($max (/ (* $sampleSize (- $sampleSize 1)) 2))
;            ($nToMakeNew (if (< $max $nToMake) $max $nToMake))
           
;            ;; Calculate how many to sort
;            ($numToSortRaw (+ (sqrt-math (* 2 $nToMakeNew)) 3))
;            ($numToSort (if (< $sampleSize $numToSortRaw) $sampleSize $numToSortRaw))
           
;            ;; Get and sort the sample
;            ($sample (List.takeNFrom $sampleStart $sampleSize $instSet))
;            ($sortedSample (List.partialSort instance>= $sample $numToSort Nil))
           
;            ;; Generate new instances using nested processing
;            ($newInstances (processNestedPairs $sortedSample $numToSort $nToMakeNew $baseInstance 1 Nil))
           
;            ;; Append to original instSet
;            ($finalInstSet (List.appendList $newInstances $instSet))
;          )
;          ;; Return new deme
;          (mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $finalInstSet) $demeId)
;    )
; )

; ;; Helper function for nested pair processing (mimics C++ nested loops)
; (: processNestedPairs (-> (List $a) Number Number Instance Number (List $a) (List $a)))
; (= (processNestedPairs $sortedSample $numToSort $nToMake $baseInstance $i $acc)
;    (if (>= $i $numToSort)
;        $acc
;        (let (($newAcc (processInnerLoop $sortedSample $baseInstance $i 0 $nToMake $acc)))
;             (processNestedPairs $sortedSample $numToSort $nToMake $baseInstance (+ $i 1) $newAcc)
;        )
;    )
; )

; ;; Helper function for inner loop processing
; (: processInnerLoop (-> (List $a) Instance Number Number Number (List $a) (List $a)))
; (= (processInnerLoop $sortedSample $baseInstance $i $j $nToMake $acc)
;    (if (>= $j $i)
;        $acc
;        (let* (
;                ;; Calculate position n = i*(i-1)/2 + j
;                ($n (+ (/ (* $i (- $i 1)) 2) $j))
               
;                ;; Check if we've made enough instances
;                ($shouldContinue (< $n $nToMake))
;              )
;              (if $shouldContinue
;                  (let* (
;                          ;; Get reference instance (i-th best)
;                          ($referenceElement (List.getByIdx $sortedSample $i))
;                          ((mkSInst (mkPair $referenceInst $referenceScore)) $referenceElement)
                         
;                          ;; Get target instance (j-th best)
;                          ($targetElement (List.getByIdx $sortedSample $j))
;                          ((mkSInst (mkPair $targetInst $targetScore)) $targetElement)
                         
;                          ;; Merge instances
;                          ($mergedInst (merger $targetInst $baseInstance $referenceInst))
                         
;                          ;; Create new scored instance
;                          ($newSInst (mkSInst (mkPair $mergedInst worstCscore)))
                         
;                          ;; Add to accumulator
;                          ($newAcc (Cons $newSInst $acc))
;                        )
;                        (processInnerLoop $sortedSample $baseInstance $i (+ $j 1) $nToMake $newAcc)
;                  )
;                  $acc
;              )
;        )
;    )
; )

; ; ;; Example usage
; !(crossTopTwoAlternative 
;     (mkDeme 
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
;         (mkDemeId "1")) 
;     3 0 4 (mkInst (Cons 2 Nil)))


; (DEBUG: Extracted target inst: (Cons (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 1 2 3 4 4))) (Cons (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 2 3 4 3))) Nil)))
; (DEBUG: Changed target inst: ((mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 1 2 3 4 4))) (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 2 3 4 3)))))
; (Destructured Reference Instance: (mkInst (Cons 1 Nil)))
; (New instances After merging: ((mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -1.0000000000000006e308 0.0 0.0 0.0 -1.0000000000000006e308))) (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -1.0000000000000006e308 0.0 0.0 0.0 -1.0000000000000006e308)))))


; ;; Helper function to create a closure for processPair
; (: makeProcessPairFunction (-> (List $a) Instance (-> (List Number) $a)))
; (= (makeProcessPairFunction $sortedSample $baseInstance)
;    (lambda $pair (processPair $pair $sortedSample $baseInstance)))

; ;; Alternative implementation using direct nested loops (closer to C++ version)
; (: crossTopTwoAlternative (-> Deme Number Number Number Instance Deme))
; (= (crossTopTwoAlternative $deme $nToMake $sampleStart $sampleSize $baseInstance)
;    (trace! (Alternative crossTopTwo implementation)
;    (let* (
;            ((mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $instSet) $demeId) $deme)
;            (() (println! (ALT DEBUG: Extracted deme components)))
           
;            ;; Calculate maximum possible pairs
;            ($max (/ (* $sampleSize (- $sampleSize 1)) 2))
;            ($nToMakeNew (if (< $max $nToMake) $max $nToMake))
;            (() (println! (ALT DEBUG: Max pairs and nToMake: $max $nToMakeNew)))
           
;            ;; Calculate how many to sort
;            ($numToSortRaw (+ (sqrt-math (* 2 $nToMakeNew)) 3))
;            ($numToSort (if (< $sampleSize $numToSortRaw) $sampleSize $numToSortRaw))
;            (() (println! (ALT DEBUG: Num to sort: $numToSort)))
           
;            ;; Get and sort the sample
;            ($sample (List.takeNFrom $sampleStart $sampleSize $instSet))
;            (() (println! (ALT DEBUG: Sample: $sample)))
;            ($sortedSample (List.partialSort instance>= $sample $numToSort Nil))
;            (() (println! (ALT DEBUG: Sorted sample: $sortedSample)))
           
;            ;; Generate new instances using iterative processing
;            ($newInstances (processAllPairs $sortedSample $numToSort $nToMakeNew $baseInstance))
;            (() (println! (ALT DEBUG: Generated instances: $newInstances)))
           
;            ;; Append to original instSet
;            ($finalInstSet (List.appendList $newInstances $instSet))
;            (() (println! (ALT DEBUG: Final instSet: $finalInstSet)))
;          )
;          ;; Return new deme
;          (mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $finalInstSet) $demeId)
;    ))
; )

; ;; Simplified pair processing that generates all pairs and processes them
; (: processAllPairs (-> (List $a) Number Number Instance (List $a)))
; (= (processAllPairs $sortedSample $numToSort $nToMake $baseInstance)
;    (let* (
;            ;; Generate all pairs like the main function
;            ($allPairs (generatePairs $numToSort 1 0 Nil))
;            (() (println! (ALT DEBUG: All pairs generated: $allPairs)))
           
;            ;; Take only what we need
;            ($pairsToProcess (List.takeN $nToMake $allPairs))
;            (() (println! (ALT DEBUG: Pairs to process: $pairsToProcess)))
           
;            ;; Process each pair using iterative function
;            ($processedInstances (processPairList $pairsToProcess $sortedSample $baseInstance Nil))
;            (() (println! (ALT DEBUG: Processed instances: $processedInstances)))
;          )
;          $processedInstances
;    )
; )

; ;; Test the processPair function independently
; (: testProcessPair (-> (List (List Number)) (List $a) Instance (List $a)))
; (= (testProcessPair $pairs $sortedSample $baseInstance)
;    (let* (
;            (() (println! (TEST: Starting processPair test)))
;            (() (println! (TEST: Pairs: $pairs)))
;            (() (println! (TEST: SortedSample: $sortedSample)))
;            ($firstPair (List.head $pairs))
;            (() (println! (TEST: First pair: $firstPair)))
;            ($result (processPair $firstPair $sortedSample $baseInstance))
;            (() (println! (TEST: Result: $result)))
;          )
;          (Cons $result Nil)
;    ))

;; Example usage with debugging
; !(crossTopTwo
;     (mkDeme 
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
;         (mkDemeId "1")) 
;     3 0 4 (mkInst (Cons 2 Nil)))
; [(mkDeme (mkRep (mkKbMap (mkDscKbMp (ConsMap NilMap)) (mkDscMp NilMMap)) (mkTree (mkNode A) Nil)) (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 1 2 3 4 1))) (Cons (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 2 3 4 3))) (Cons (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 1 2 3 4 4))) (Cons (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore 1 2 3 4 2))) (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore 1 2 3 4 5))) (Cons (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore -1.0000000000000006e308 0.0 0.0 0.0 -1.0000000000000006e308))) (Cons (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore -1.0000000000000006e308 0.0 0.0 0.0 -1.0000000000000006e308))) (Cons (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore -1.0000000000000006e308 0.0 0.0 0.0 -1.0000000000000006e308))) Nil))))))))) (mkDemeId "1"))] TopTwo
; [(mkDeme (mkRep (mkKbMap (mkDscKbMp (ConsMap NilMap)) (mkDscMp NilMMap)) (mkTree (mkNode A) Nil)) (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 1 2 3 4 1))) (Cons (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 2 3 4 3))) (Cons (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 1 2 3 4 4))) (Cons (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore 1 2 3 4 2))) (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore 1 2 3 4 5))) (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -1.0000000000000006e308 0.0 0.0 0.0 -1.0000000000000006e308))) (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -1.0000000000000006e308 0.0 0.0 0.0 -1.0000000000000006e308))) Nil)))))))) (mkDemeId "1"))] TopOne




;; Helper function to generate pairs (j,i) where j < i (for the C++ nested loop)
(: generatePairs (-> Number Number Number (List (List Number)) (List (List Number))))
(= (generatePairs $n $i $j $acc)
    (if (>= $i $n)
        $acc
        (if (< $j $i)
            (generatePairs $n $i (+ $j 1) (Cons (Cons $j (Cons $i Nil)) $acc))
            (generatePairs $n (+ $i 1) 0 $acc)
        )
    )
)
;; Helper function to process a single pair and create merged instance
(: processPair (-> (List Number) (List $a) Instance $a))
(= (processPair (Cons $j (Cons $i Nil)) $sortedSample $baseInstance)
   (let* (
           (() (println! (DEBUG: Processing pair $j $i)))
           
           ;; Get the reference instance (i-th best from sorted sample)
           ($referenceElement (List.getByIdx $sortedSample $i))
           (() (println! (DEBUG: Got reference element: $referenceElement)))
           
           ; Pattern match to extract reference instance
           ((mkSInst (mkPair $referenceInst $referenceScore)) $referenceElement)
           (() (println! (DEBUG: Extracted reference inst: $referenceInst)))
           
           ;; Get the target instance (j-th best from sorted sample)  
           ($targetElement (List.getByIdx $sortedSample $j))
           (() (println! (DEBUG: Got target element: $targetElement)))
           
          ;  ;; Pattern match to extract target instance
          ;  ((mkSInst (mkPair $targetInst $targetScore)) $targetElement)
          ;  (() (println! (DEBUG: Extracted target inst: $targetInst)))

          ($targetExpr ($targetElement))
          (() (println! (DEBUG: Changed target inst: $targetExpr)))
           
           ;; Perform merge (using merger from crossTopOne)
           ($newSInst (merger $targetExpr $baseInstance $referenceInst))
          ;  (() (println! (DEBUG: Merged instance: $mergedInst)))
           (() (println! (DEBUG: Created new scored instance: $newSInst)))
           
          ;  ;; Create new scored instance with worst score
          ;  ($newSInst (mkSInst (mkPair $mergedInst worstCscore)))
         ) 
         $newSInst))


;; Process a list of pairs iteratively (alternative to List.map)
(: processPairList (-> (List (List Number)) (List $a) Instance (List $a) (List $a)))
(= (processPairList Nil $sortedSample $baseInstance $acc) $acc)
(= (processPairList (Cons $pair $restPairs) $sortedSample $baseInstance $acc)
   (let* (
           ($processedInstance (processPair $pair $sortedSample $baseInstance))
           ($newAcc (pyExprToList $processedInstance))
           ($appendedAcc (List.appendList $acc $newAcc))
           (() (println! (New accumulator: $appendedAcc)))
         )
         (processPairList $restPairs $sortedSample $baseInstance $appendedAcc)
   ))

(: crossTopTwo (-> Deme Number Number Number Instance Deme))
(= (crossTopTwo $deme $nToMake $sampleStart $sampleSize $baseInstance)
   (trace! (Inside crossTopTwo: $nToMake $sampleStart $sampleSize) 
            (let* (
                    ((mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $instSet) $demeId) $deme)
                    (() (println! (DEBUG: Extracted deme components)))
                    (() (println! (DEBUG: instSet: $instSet)))

                    ;; Calculate maximum possible pairs (sample_size choose 2)
                    ($max (/ (* $sampleSize (- $sampleSize 1)) 2))
                    ($nToMakeNew (if (< $max $nToMake) $max $nToMake))
                    
                    (() (println! (DEBUG: NToMake & Max: $nToMakeNew $max)))

                    ;; Calculate how many to sort: sqrt(2*nToMake) + 3, but not more than sample_size
                    ($numToSortRaw (+ (sqrt-math (* 2 $nToMakeNew)) 3))
                    ($numToSort (if (< $sampleSize $numToSortRaw) $sampleSize $numToSortRaw))
                    
                    (() (println! (DEBUG: Nums to Sort: $numToSortRaw $numToSort)))

                    ;; Get the sample from instSet
                    ($sample (List.takeNFrom $sampleStart $sampleSize $instSet))
                    (() (println! (DEBUG: Sample taken: $sample)))
                    
                    ;; Partially sort the sample to get top numToSort instances
                    ($sortedSample (List.partialSort instance>= $sample $numToSort Nil))
                    (() (println! (DEBUG: PartialSort: $sortedSample)))

                    ;; Generate all possible pairs (j,i) where j < i
                    ($pairs (generatePairs $numToSort 1 0 Nil))
                    (() (println! (DEBUG: Generated pairs: $pairs)))

                    ;; Take only the number of pairs we need
                    ($pairsToMake (List.takeN $nToMakeNew $pairs))
                    (() (println! (DEBUG: Pairs to make: $pairsToMake)))
                    
                    ;; Process each pair using the iterative function instead of List.map
                    ($newInstances (processPairList $pairsToMake $sortedSample $baseInstance Nil))
                    (() (println! (DEBUG: New instances created: $newInstances)))
                    
                    ;; Append new instances to the original instSet
                    ($finalInstSet (List.appendList $newInstances $instSet))
                    (() (println! (DEBUG: Final instance set: $finalInstSet))))
                ;; Return new deme with updated instances
                (mkDeme (mkRep (mkKbMap $dscKbMp (mkDscMp $dscMp)) $tree) (mkSInstSet $finalInstSet) $demeId)
              )
      )
)

