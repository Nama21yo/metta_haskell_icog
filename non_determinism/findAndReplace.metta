(: findAndReplace (-> $a $b Expression Expression))
(= (findAndReplace $old $new $list)
   (collapse 
        ; let $current (superpose $list)
        (chain (eval (superpose $list)) $current
            (if (== $old $current) $new $current)
        )
   )
)

!(findAndReplace 5 99 (1 2 3 5 6 5 7 5 8 5))
