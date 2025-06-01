; ; check if a nuber is even
; ; (= (is_even 0) True)
; ; (= (is_even 1) False)
; ; (= (is_even $n) (is_even (- $n 2)))
; ; %
; ; operation 
; (= (is_even $x ) (== (% $x 2) 0))
; ( = (isodd $x) (not (is_even $x)))

; (= (is_even $n))
;     (if (== $n 0)
;         True
;         (if (== $n 1)
;             False
;             (is_even (- $n 2))
;         )

;     )

(= (length Nil) 0)
(= (length (Cons $x $xs)) (+ 1 (length $xs)))
!(length (Cons r (Cons r Nil)))

; all list methods
; haskell pattern matching
; ()
; (= (prepend ()))
; ; ! (is_even 4)

; ; ( = (factorial $x)
; ;     (if (> $x 0)
; ;         (* $x (factorial (- $x 1)))
; ;         1  
; ;     )
; ; )

; (= (even-if? $n)
;    (if (== $n 0)
;        True
;        (if (== $n 1)
;            False
;            (if (< $n 0)  ;; Added case for negative numbers
;                False     ;; Or handle negative numbers differently if needed
;                (even-if? (- $n 2))))))
; ! (even-if? 5) 