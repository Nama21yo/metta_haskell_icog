;; =============================================================================
;; MATRIX MULTIPLICATION IN METTA - CORRECTED IMPLEMENTATION
;; =============================================================================
(= (range $start $end $inc)
   (if (>= $start $end)
       ()  ;; stop when we've reached/exceeded end
       (let $nextEl  (range (+ $start $inc) $end $inc)
            (cons-atom $start $nextEl)
       )
   )
)
;; Helper functions for matrix operations
; (: getRows (-> $a Nat))
(= (getRows $matrix) (size-atom $matrix))
(= (getCols $matrix) 
   (if (> (size-atom $matrix) 0)
        (let $firstRow (car-atom $matrix) 
            
                    (size-atom $firstRow)
        )
    ;  (size-atom (car-atom $matrix))
     0))
(= (getElement $matrix $row $col)
    (let $lenRow (index-atom $matrix $row)  
        (index-atom $lenRow $col)
    )
;    (index-atom (index-atom $matrix $row) $col)
   )
; (: getRow (-> $a Nat $a))
(= (getRow $matrix $i) (index-atom $matrix $i))

; (: getCol (-> $a Nat $a))
(= (getCol $matrix $j)
   (map-atom $matrix $row (index-atom $row $j)))


;; =============================================================================
;; MATRIX MULTIPLICATION - CORRECTED VERSION
;; =============================================================================

;; Calculate dot product of two vectors using foldl-atom
; (: dotProduct (-> $a $a $a))
(= (dotProduct $vec1 $vec2)
   (let $products (map-atom $vec1 $x (let $idx (indexOf $vec1 $x)
                                       (* $x (index-atom $vec2 $idx))))
     (foldl-atom $products 0 $acc $val (+ $acc $val))))

;; Better dot product implementation using zip and fold
; (: dotProductZip (-> $a $a $a))
(= (dotProductZip $vec1 $vec2)
   (let* (($pairs (zipWith * $vec1 $vec2)))
     (foldl-atom $pairs 0 $acc $val (+ $acc $val))))

;; Calculate single element of matrix multiplication (row i, col j)
; (: matrixMultiplyElement (-> $a $a Nat Nat $a))
(= (matrixMultiplyElement $A $B $i $j)
   (let* (($rowA (getRow $A $i))
          ($colB (getCol $B $j)))
     (dotProductZip $rowA $colB)))

;; Calculate entire row of result matrix
; (: matrixMultiplyRow (-> $a $a Nat $a))
(= (matrixMultiplyRow $A $B $i)
   (let* (($colsB (getCols $B))
          ($colRange (range 0 $colsB 1)))
     (map-atom $colRange $j (matrixMultiplyElement $A $B $i $j))))

;; Main matrix multiplication function - CORRECTED
; (: matrixMultiply (-> $a $a $a))
(= (matrixMultiply $A $B)
   (let* (($rowsA (getRows $A))
          ($rowRange (range 0 $rowsA 1)))
     (map-atom $rowRange $i (matrixMultiplyRow $A $B $i))))

;; =============================================================================
;; NON-DETERMINISTIC VERSION (Original approach, but fixed)
;; =============================================================================

;; Non-deterministic matrix multiplication that explores all element calculations
; (: matrixMultiplyNonDet (-> $a $a $a))
(= (matrixMultiplyNonDet $A $B)
   (let* (($rowsA (getRows $A))
          ($colsB (getCols $B))
          ($result (matrixMultiply $A $B)))
     $result))

;; Element-wise non-deterministic calculation (for educational purposes)
; (: matrixMultiplyElementNonDet (-> $a $a $a))
(= (matrixMultiplyElementNonDet $A $B)
   (let* (($rowsA (getRows $A))
          ($colsB (getCols $B))
          ($rowIndexes (range 0 $rowsA 1))
          ($colIndexes (range 0 $colsB 1))
          ($i (superpose $rowIndexes))
          ($j (superpose $colIndexes))
          ($element (matrixMultiplyElement $A $B $i $j)))
     ($i $j $element)))

;; =============================================================================
;; ALTERNATIVE IMPLEMENTATIONS USING MAP AND FOLD
;; =============================================================================

;; Matrix multiplication using more functional style
; (: matrixMultiplyFunctional (-> $a $a $a))
(= (matrixMultiplyFunctional $A $B)
   (map-atom $A $rowA 
     (let $colsB (getCols $B)
       (map-atom (range 0 $colsB 1) $j
         (let $colB (getCol $B $j)
           (foldl-atom $rowA 0 $acc $elem
             (let $idx (indexOf $rowA $elem)
               (+ $acc (* $elem (index-atom $colB $idx))))))))))

;; Cleaner version using zipWith
; (: matrixMultiplyClean (-> $a $a $a))
(= (matrixMultiplyClean $A $B)
   (map-atom $A $rowA
     (let $colsB (getCols $B)
       (map-atom (range 0 $colsB 1) $j
         (let* (($colB (getCol $B $j))
                ($products (zipWith * $rowA $colB)))
           (foldl-atom $products 0 $acc $val (+ $acc $val)))))))

;; =============================================================================
;; UTILITY FUNCTIONS
;; =============================================================================

;; Helper to find index of element in list (needed for some implementations)
; (: indexOf (-> $a $a Nat))
(= (indexOf $list $elem)
   (indexOfHelper $list $elem 0))

; (: indexOfHelper (-> $a $a Nat Nat))
(= (indexOfHelper () $elem $idx) 0)  ; Not found, return 0
(= (indexOfHelper $list $elem $idx)
   (if (> (size-atom $list) 0)
     (if (== (car-atom $list) $elem)
       $idx
       (indexOfHelper (cdr-atom $list) $elem (+ $idx 1)))
     0))

;; Create identity matrix of size n
; (: identityMatrix (-> Nat $a))
(= (identityMatrix $n)
   (let $indices (range 0 $n 1)
     (map-atom $indices $i
       (map-atom $indices $j
         (if (== $i $j) 1 0)))))

;; Matrix transpose
; (: transpose (-> $a $a))
(= (transpose $matrix)
   (let* (($cols (getCols $matrix))
          ($colIndices (range 0 $cols 1)))
     (map-atom $colIndices $j (getCol $matrix $j))))

;; =============================================================================
;; TEST EXAMPLES AND EXPECTED OUTPUTS
;; =============================================================================

;; Test matrices
;; $A = ((1 2) (2 1))
;; $B = ((1 2) (2 1))

;; Manual calculation:
;; Result[0][0] = (1*1 + 2*2) = 5
;; Result[0][1] = (1*2 + 2*1) = 4  
;; Result[1][0] = (2*1 + 1*2) = 4
;; Result[1][1] = (2*2 + 1*1) = 5

;; Expected result: ((5 4) (4 5))

!(matrixMultiply ((1 2) (2 1)) ((1 2) (2 1)))
;; Expected: ((5 4) (4 5))

;; !(matrixMultiplyClean ((1 2) (2 1)) ((1 2) (2 1)))
;; Expected: ((5 4) (4 5))

;; Test with identity matrix
;; !(matrixMultiply ((1 2) (3 4)) (identityMatrix 2))
;; Expected: ((1 2) (3 4))

;; Test with different sized matrices
;; !(matrixMultiply ((1 2 3) (4 5 6)) ((1 0) (0 1) (1 1)))
;; Expected: ((4 5) (10 11))

;; Non-deterministic exploration of elements
;; !(collapse (matrixMultiplyElementNonDet ((1 2) (2 1)) ((1 2) (2 1))))
;; Expected: ((0 0 5) (0 1 4) (1 0 4) (1 1 5))

;; Test helper functions
;; !(dotProductZip (1 2 3) (4 5 6))
;; Expected: 32  ; (1*4 + 2*5 + 3*6)

;; !(getCol ((1 2 3) (4 5 6)) 1)
;; Expected: (2 5)

;; !(transpose ((1 2 3) (4 5 6)))
;; Expected: ((1 4) (2 5) (3 6))
