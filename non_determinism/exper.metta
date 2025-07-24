(= (filter $func $list)
    (collapse (chain (eval (superpose $list)) $el
        (if ($func $el) $el (empty))
    ))
)

(= (isEven $x)  (== (% $x 2 ) 0))

!(filter isEven (1 2 3 4))
; 
