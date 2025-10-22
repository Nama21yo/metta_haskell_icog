
(= (findRemove $target $list)
    (let $current (superpose $list)
        (if (== $current $target)
            (empty)
            $current
        )
    )
)

! (collapse (findRemove 6 (1 2 3 4 4 5 6 6 7 7 8)))
! (collapse (findRemove 7 (7 7 7 7 7 7 7 7 7 7 8)))
; 
