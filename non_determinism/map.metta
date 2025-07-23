(= (double $x) (* 2 $x))

(= (map $func $list)
    (collapse (chain (superpose $list) $el
        (chain ($func $el) $res $res)
    ))
)
; !(double 5)
; !(map double (1 2 3 4 5 5 6 7 7 8 8 9))
; 
