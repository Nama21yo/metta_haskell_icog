! (register-module! ../../metta-moses) 
! (import! &self metta-moses:feature-selection:feature-selection-helpers)
! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:utilities:tree)
! (import! &self metta-moses:utilities:general-helpers)



; Helper function of List

;; List.init - return all elements except last
(: List.init (-> (List $a) (List $a)))
(= (List.init $list)
   (unify $list Nil Nil
     (unify $list (Cons $x Nil) Nil
       (unify $list (Cons $x $xs)
        ;  (chain (() (println! (debug inside init $x with $xs))) $jfndsfs 
         (Cons $x (List.init $xs))
        ;  )
       )
     )
   )
)

;;;;;

;; Helper function to extract argument features from a tree
;; This is equivalent to get_argument_abs_idx_from_zero_set in C++
;; Traverses the tree and collects all leaf nodes that are arguments (not operators)
;; Params:
;;   $tree: The tree to extract features from
;; Returns: 
;;   List of feature names found in the tree
;; Example:
;;   ! (getArgumentFeatures (buildTree (AND A (OR B C))))  
;;   ;; Returns: (Cons A (Cons B (Cons C Nil)))
(: getArgumentFeatures (-> (Tree $a) (List $a)))
(= (getArgumentFeatures $tree) (getArgumentFeaturesHelper $tree Nil))

;; Helper function for getArgumentFeatures - accumulates features in a list
;; Params:
;;   $tree: Current tree node to process
;;   $acc: Accumulator list of features found so far
;; Returns:
;;   List of all argument features found in tree
(: getArgumentFeaturesHelper (-> (Tree $a) (List $a) (List $a)))
(= (getArgumentFeaturesHelper (mkNullVex $children) $acc) 
   (List.foldr collectFromChildren $acc $children))
(= (getArgumentFeaturesHelper (mkTree (mkNode $node) $children) $acc)
   (if (isArgument (mkTree (mkNode $node) $children))
       ;; If it's an argument (leaf node that's not AND/OR/NOT), add to accumulator
       (if (List.isMember $node $acc)
           $acc  ;; Don't add duplicates
           (Cons $node $acc))
       ;; If it's an operator, recursively process children
       (List.foldr collectFromChildren $acc $children)))

;; Helper to collect features from children nodes
;; Params:
;;   $child: Child tree node to process
;;   $acc: Current accumulator of features
;; Returns:
;;   Updated accumulator with features from child
(: collectFromChildren (-> (Tree $a) (List $a) (List $a)))
(= (collectFromChildren $child $acc) 
   (getArgumentFeaturesHelper $child $acc))


; ! (getArgumentFeatures (buildTree (AND A (OR B C)))) 
;;   ;; Returns: (Cons A (Cons B (Cons C Nil)))

; ! (getArgumentFeatures (mkTree (mkNode A) Nil))	
; ! (getArgumentFeatures (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) Nil)))	
; ! (getArgumentFeatures (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) Nil)))))	


;; Get input labels from ITable
;; Extracts the feature names from the ITable labels (excluding output label)
;; Params:
;;   $itable: Input table containing data and labels
;; Returns:
;;   List of input feature labels (excludes the last label which is output)
;; Example:
;;   ! (getInputLabels (mkITable $rows (Cons A (Cons B (Cons Output Nil)))))
;;   ;; Returns: (Cons A (Cons B Nil))
(: getInputLabels (-> (ITable $a) (List String)))
(= (getInputLabels (mkITable $rows $labels))
   (List.init $labels)
   )  ;; Remove last element (output label)

; ! (getInputLabels (mkITable $rows (Cons A (Cons B (Cons Output Nil)))))



; ;; Check if a feature list contains specific features
; ;; Params:
; ;;   $feature: Feature to check for
; ;;   $featureList: List to search in
; ;; Returns:
; ;;   True if feature is in list, False otherwise
; (: containsFeature (-> $a (List $a) Bool))
; (= (containsFeature $feature $featureList) 
;    (List.isMember $feature $featureList))

;; Add features to list if not already present
;; Params:
;;   $newFeatures: Features to add
;;   $existingFeatures: Current feature list
;; Returns:
;;   Updated feature list with new features added
(: addUniqueFeatures (-> (List $a) (List $a) (List $a)))
(= (addUniqueFeatures Nil $existing) $existing)
(= (addUniqueFeatures (Cons $feature $rest) $existing)
   (let $updated (if (List.isMember $feature $existing) 
                     $existing 
                     (List.append $feature $existing))
     (addUniqueFeatures $rest $updated)
   )
)

;; Constants
! (bind! EXEMPLAR_FEATURE_NAME "__exemplar_feature__") ;; is it needec

;; PREPROCESSING PARAMETERS FUNCTION

;;
;; This implementation follows the C++ preprocess_params function:
;; 1. Extract features from exemplar tree using getArgumentFeatures
;; 2. Get input labels from ITable (excluding output column)
;; 3. Convert exemplar feature symbols to string names
;; 4. Conditionally seed initial feature pool with exemplar features
;; 5. Adjust target size to accommodate existing exemplar features
;; 6. Set ignored features list if exemplar features should be excluded
;; 7. Add exemplar output as additional feature if requested
;; 8. Return updated parameters with all modifications applied
;;
;; Uses proper debugging output and follows incremental selection style.

;; Purpose: Main preprocessing function equivalent to C++ preprocess_params
;; Performs comprehensive parameter adjustment based on exemplar analysis
;; This mirrors the C++ logic: sanity checking and parameter mangling
;; Parameters:
;;   $itable (ITable) → Input table containing training data and feature labels
;;   $exemplar (Tree) → Current exemplar tree to analyze for features
;;   $params (FeatureSelectorParameters) → Original parameters to be modified
;; Returns: (FeatureSelectorParameters) → Updated parameters ready for feature selection
;; Example: (preprocessParams xorTable andExemplar defaultParams) → modified parameters
(: preprocessParams (-> (ITable $a) (Tree $a) Bool Bool Bool Bool Number (List $a) Expression))
(= (preprocessParams $itable $exemplar  $initXmplr $increaseTarget $ignoreXmplr $xmplrAsFeature $targetSize $initialFeatures)
   (chain (() (println! (=== STARTING PREPROCESS_PARAMS ===))) $debug1
   (chain (() (println! (DEBUG preprocessParams exemplar: (preOrder $exemplar)))) $debug2
   (chain (() (println! (DEBUG preprocessParams original params - target_size: $targetSize init_features_count: (List.length $initialFeatures)))) $debug3
   
   ;; Step 1: Get the set of features of the exemplar (equivalent to C++ get_argument_abs_idx_from_zero_set)
   (chain (getArgumentFeatures $exemplar) $xmplrFeatures
   (chain (() (println! (DEBUG Step 1 - exemplar features extracted: $xmplrFeatures count: (List.length $xmplrFeatures)))) $debug4
   
   ;; Step 2: Get labels corresponding to all the features (equivalent to C++ _ctable.get_input_labels())
   (chain (getInputLabels $itable) $inputLabels  
   (chain (() (println! (DEBUG Step 2 - input labels retrieved: $inputLabels count: (List.length $inputLabels)))) $debug5
   
   ;; Step 3: Names of the exemplar features (equivalent to C++ for loop converting indices to names)
   ;; todo featureToNames

   ;; Step 4: Conditional feature pool seeding (equivalent to C++ init_xmplr_features block)
   ;; Some feature-selection algos work best when seeded with exemplar features
   ;; This ensures new features will combine well with existing exemplar
   (
    let $updatedInitialFeatures 
     (if $initXmplr
         (chain (() (println! (DEBUG Step 4a - seeding initial features with exemplar features))) $debug7
            (chain (addUniqueFeatures $xmplrFeatures $initialFeatures) $seeded
                (chain (() (println! (DEBUG Step 4a - seeded initial features: $seeded))) $debug8
                    $seeded
                )
            )
        )
         (chain (() (println! (DEBUG Step 4b - skipping exemplar feature seeding))) $debug9
             $initialFeatures
         )
    )
   
   ;; Step 5: Target size adjustment (equivalent to C++ increase_target_size block)
   ;; If exemplar uses N features, we want M additional features to avoid returning same N
   (let $newTargetSize 
     (if (or $initXmplr $increaseTarget)
         (let $xmplrSize (List.length $xmplrFeatures)
         (chain (() (println! (DEBUG Step 5a - increasing target size by: $xmplrSize))) $debug10
         (chain (+ $targetSize $xmplrSize) $increased
         (chain (() (println! (DEBUG Step 5a - new target size: $increased))) $debug11
             $increased))))
         (chain (() (println! (DEBUG Step 5b - keeping original target size: $targetSize))) $debug12
             $targetSize)
    )
   
   ;; Step 6: Ignored features setup (equivalent to C++ ternary operator for ignored_features)
   ;; Alternative strategy: ignore exemplar features to force discovery of novel features
   (let $ignoredFeatures 
     (if $ignoreXmplr
         (chain (() (println! (DEBUG Step 6a - setting exemplar features as ignored: $xmplrFeatures))) $debug13
             $xmplrFeatures)
         (chain (() (println! (DEBUG Step 6b - no features will be ignored))) $debug14
             Nil))
   
   ;; Step 7: Exemplar as feature handling (equivalent to C++ xmplr_as_feature block)
   ;; Use output of exemplar as additional input feature for hierarchical learning
   (let $finalInitialFeatures
     (if $xmplrAsFeature
         (chain (() (println! (DEBUG Step 7a - adding exemplar output as feature: EXEMPLAR_FEATURE_NAME))) $debug15
         (chain (Cons EXEMPLAR_FEATURE_NAME $updatedInitialFeatures) $withExemplarFeature
         (chain (() (println! (DEBUG Step 7a - final initial features with exemplar: $withExemplarFeature))) $debug16
             $withExemplarFeature)))
         (chain (() (println! (DEBUG Step 7b - no't using exemplar as feature))) $debug17
             $updatedInitialFeatures))
   
   ;; Final target size adjustment for exemplar feature
   (let $finalTargetSize
     (if $xmplrAsFeature
         (chain (() (println! (DEBUG Step 7c - incrementing target size for exemplar feature))) $debug18
         (chain (+ $newTargetSize 1) $finalSize
         (chain (() (println! (DEBUG Step 7c - final target size: $finalSize))) $debug19
             $finalSize)))
         (chain (() (println! (DEBUG Step 7d - final target size unchanged: $newTargetSize))) $debug20
             $newTargetSize))
   
   ;; Create and return updated parameters
   (chain ($initXmplr $increaseTarget $ignoreXmplr $xmplrAsFeature $finalTargetSize $finalInitialFeatures) $result
   (chain (() (println! (DEBUG PREPROCESSING COMPLETE - returning updated parameters))) $debug21
   (chain (() (println! (DEBUG Final params - target_size: $finalTargetSize init_features_count: (List.length $finalInitialFeatures)))) $debug22
   (chain (() (println! (=== END PREPROCESS_PARAMS ===))) $debug23
       $result)))))))))))))))))

!(bind! xorTable (mkITable
    (Cons (Cons True  (Cons True  (Cons False Nil)))
    (Cons (Cons True  (Cons False (Cons True  Nil)))
    (Cons (Cons False (Cons True  (Cons True  Nil)))
    (Cons (Cons False (Cons False (Cons False Nil))) Nil))))
    (Cons A (Cons B (Cons Output Nil)))))


;; $initXmplr $increaseTarget $ignoreXmplr $xmplrAsFeature 
;; False        False           True        False   --->>> Seed None
;; False        True            False       False   ---->>> Seed Add
;; True         False           False       False   ---->>> Seed init
;; False        False           False       True    ---->>> Seed Exemplar
;  moses/moses/main/problem-params.cc line 1295 

;  if (fs_seed == seed_none) {
;         festor_params.increase_target_size = false;
;         festor_params.ignore_xmplr_features = true;
;         festor_params.init_xmplr_features = false;
;         festor_params.xmplr_as_feature = false;
;     } else if (fs_seed == seed_add) {
;         festor_params.increase_target_size = true;
;         festor_params.ignore_xmplr_features = false;
;         festor_params.init_xmplr_features = false;
;         festor_params.xmplr_as_feature = false;
;     } else if (fs_seed == seed_init) {
;         festor_params.increase_target_size = false;
;         festor_params.ignore_xmplr_features = false;
;         festor_params.init_xmplr_features = true;
;         festor_params.xmplr_as_feature = false;
;     } else if (fs_seed == seed_xmplr) {
;         festor_params.increase_target_size = false;
;         festor_params.ignore_xmplr_features = false;
;         festor_params.init_xmplr_features = false;
;         festor_params.xmplr_as_feature = true;
;     }

!  (preprocessParams xorTable (buildTree (AND A (OR B C))) False False True False 2 (Cons A Nil)) 
!  (preprocessParams xorTable (buildTree (AND A (OR B C))) False True False False 2 (Cons A Nil)) 
!  (preprocessParams xorTable (buildTree (AND A (OR B C))) True False False False 2 (Cons A Nil)) 
!  (preprocessParams xorTable (buildTree (AND A (OR B C))) False False False True 2 (Cons A Nil)) 

;;If all are true Output: (mkFSParams True True True True 6 (Cons "__exemplar_feature__" (Cons A (Cons B (Cons C Nil)))))
;None [(mkFSParams False False True False 2 (Cons A Nil))]
;Add [(mkFSParams False True False False 5 (Cons A Nil))]
;Init [(mkFSParams True False False False 5 (Cons A (Cons B (Cons C Nil))))]
;Exemplar [(mkFSParams False False False True 3 (Cons "__exemplar_feature__" (Cons A Nil)))] 
; 
