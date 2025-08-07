(= (range $start $end $inc)
   (if (>= $start $end)
       ()  
       (let $nextEl  (range (+ $start $inc) $end $inc)
            (cons-atom $start $nextEl)
       )
   )
)
(= (getCols $matrix) 
   (if (> (size-atom $matrix) 0)
        (let $firstRow (car-atom $matrix) 
                    (size-atom $firstRow)
        )
     0))
(= (getElement $matrix $row $col)
     (let $lenRow (index-atom $matrix $row)  
          (index-atom $lenRow $col)
     )
   )
(= (parallelSum $list)
   (foldl-atom $list 0 $acc $x (+ $acc $x)))

(= (matrixMultiply $A $B)
   (let* (($rowsA (size-atom $A))
          ($colsB (getCols $B))
          ($rowIndexes (range 0 $rowsA 1))
          ($colIndexes (range 0 $colsB 1)))
     (map-atom $rowIndexes $i
       (map-atom $colIndexes $j
         (parallelSum (collapse (matrixMultiplyElement $A $B $i $j)))))))

;; Calculate single element of matrix multiplication
; (: matrixMultiplyElement (-> $a $a Nat Nat $a))
(= (matrixMultiplyElement $A $B $i $j)
   (let* (($rowA (index-atom $A $i))
          ($colsA (size-atom $rowA))
          ($colRange (range 0 $colsA 1))
          ($k (superpose $colRange))
          ($aik (index-atom $rowA $k))
          ($bkj (getElement $B $k $j))
          ($product (* $aik $bkj))
          
          )
     $product))


; !(parallelSum (collapse (matrixMultiplyElement ((1 2) (2 1)) ((1 2) (2 1)) 0 0)))
; !(matrixMultiply ((1 2) (2 1)) ((1 2) (2 1)))
;; Helper: sum elements in parallel
; (: parallelSum (-> $a $a))


;; Matrix power using repeated multiplication
; (: matrixPower (-> $a Nat $a))
; (= (matrixPower $matrix 0) 
;    ;; Return identity matrix (simplified - assumes square matrix)
;    (let* (($n (getRows $matrix))
;           ($ranges (range 0 $n 1))
;           ($i (superpose $ranges))
;           ($j (superpose $ranges)))
;      (if (== $i $j) 1 0)))

; (= (matrixPower $matrix 1) $matrix)
(= (matrixPower $matrix $k)
   (if (> $k 1)
     (matrixMultiply $matrix (matrixPower $matrix (- $k 1)))
     $matrix))

;; Extract diagonal elements in parallel
(= (getDiagonal $matrix)
   (let* (
            ($numRows (size-atom $matrix))
            ($numCols (getCols $matrix))
            ($minExpr  ($numRows $numCols))
            ($n (min-atom $minExpr))
            ($ranges (range 0 $n 1))
          ($i (superpose $ranges)))
     (getElement $matrix $i $i)))

;; Calculate trace (sum of diagonal elements)
; (: trace (-> $a $a))
(= (trace $matrix)
   (let $diagonals (collapse (getDiagonal $matrix))
     (parallelSum $diagonals)))

;; Main function: Trace of matrix to the k-th power
(= (traceOfPower $matrix $k)
   (let $matrixPowerK  (matrixPower $matrix $k)
     (trace $matrixPowerK)))
;; Parallel computation of multiple traces (for different powers)
; (: parallelTraces (-> $a Nat $a))
(= (parallelTraces $matrix $maxK)
   (let* (
            ($ranges (range 1 (+ $maxK 1) 1))
            ($k  (superpose $ranges))
   )
     (traceOfPower $matrix $k)))



;; Example 2x2 matrix: ((2 1) (1 2))
;; A^1 = ((2 1) (1 2)) -> trace = 2+2 = 4
;; A^2 = ((5 4) (4 5)) -> trace = 5+5 = 10  
;; A^3 = ((14 13) (13 14)) -> trace = 14+14 = 28

;; Single trace computation
; !(trace ((2 1) (1 2)))
;; Expected: 4

; !(traceOfPower ((2 1) (1 2)) 2)
;; Expected: 10

!(traceOfPower ((1 2 3 4 5) (4 5 6 7 8 ) (7 8 9 10 11) (12 13 14 15 16) (17 18 17 17 17)) 3)  
;; Expected: 28

;; Parallel traces for multiple powers
; !(collapse (parallelTraces ((2 1) (1 2)) 3))
;; Expected: (4 10 28)

;; Batch trace computation
; !(batchTracePowers ((1 2) (3 4)) 2)
;; Expected: (5 14)  ; trace(A^1)=1+4=5, trace(A^2)=7+7=14

;; =============================================================================
;; 3x3 MATRIX EXAMPLES
;; =============================================================================

;; Identity matrix examples
; !(trace ((1 0 0) (0 1 0) (0 0 1)))
;; Expected: 3

; !(traceOfPower ((1 0 0) (0 1 0) (0 0 1)) 5)
;; Expected: 3  ; Identity raised to any power is still identity

;; Complex 3x3 matrix
; !(collapse (parallelTraces ((1 2 3) (0 1 4) (5 6 0)) 2))
;; Expected: (2 80)  ; trace(A^1)=1+1+0=2, trace(A^2) n
