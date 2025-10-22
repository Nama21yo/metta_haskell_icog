(: findReplace (-> $a $b Expression Expression))
(= (findReplace $target $elem $list)
    (let $current (superpose $list)
        (if (== $current $target)
            $elem
            $current
        )
    )
    
)


! (collapse (findReplace 6 10 (1 2 3 4 4 5 6 6 7 7 8)))
! (collapse (findReplace 7 2 (7 7 7 7 7 7 7 7 7 7 8)))
; 
