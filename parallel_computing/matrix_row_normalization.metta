
;; matrix representation: ((row1) (row2) (row3) ...)
; Matrix Row Normalization

;; calculate L2 norm (length) of a row vector
(= (rowL2Norm $row)
   (let* (($squared (map-atom $row $x (* $x $x)))
          ($sum (foldl-atom $squared 0 $acc $x (+ $acc $x))))
     (sqrt-math $sum)))

(= (normalizeRow $row)
   (let* (($norm (rowL2Norm $row))
          ($elem (superpose $row)))
     (if (> $norm 0)
       (/ $elem $norm)
       $elem)))

(= (normalizeMatrixL2 $matrix)
   (collapse (let $row (superpose $matrix)
     (collapse (normalizeRow $row)))))

! (normalizeMatrixL2 ((3 4 4 5 6) (0 5 5 6 7) (6 8 7 6 6) (1 2 3 4 5) (1 2 3 4 5)))


;; Example matrix: ((3 4) (0 5) (6 8))
;; Row 1: (3 4) -> L2 norm = sqrt(9+16) = 5 -> normalized: (0.6 0.8)
;; Row 2: (0 5) -> L2 norm = sqrt(0+25) = 5 -> normalized: (0 1)  
;; Row 3: (6 8) -> L2 norm = sqrt(36+64) = 10 -> normalized: (0.6 0.8)

; !(collapse (normalizeMatrixL2 ((3 4) (0 5) (6 8))))
;; Expected: ((0.6 0.8) (0 1) (0.6 0.8))

; !(normalizeMatrixL2((1 0) (0 1)))
;; Expected: ((1 0) (0 1))  ; Already normalized
