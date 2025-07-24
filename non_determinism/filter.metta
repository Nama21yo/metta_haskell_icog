
(: filter (-> (-> $a Bool) Expression Expression))
; (= (filter $func $list)
;     (collapse 
;         (chain (superpose $list) $el
;             (chain ($func $el) $filtered
;                     (if $filtered $el (empty))
;             )
;         )
;     )
; )
(= (filter $func $list)
    (collapse 
        (chain (eval (superpose $list)) $el
                (if ($func $el) $el (empty))
        )
    )
)

(= (isEven $x) (== (% $x 2) 0))
; !(isEven 5)
!(filter isEven (1 2 3 4 5 5 6 7 7 8 8 9))
; 
