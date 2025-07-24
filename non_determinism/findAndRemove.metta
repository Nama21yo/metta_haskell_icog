; (: findAndRemove (-> $a Expression Expression))
(= (findAndRemove $target $list)
   (collapse
      ; let $current (superpose $list) 
      (chain (eval (superpose $list)) $current
           (if (== $current $target) (empty) $current)
      )
    )
)

!(findAndRemove 3 (1 2 3 4 3 5))
; 
