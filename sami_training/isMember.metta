
; (= (isMember $target $list)
;     (if (== (collapse 
;             (intersection (superpose ($target)) (superpose $list))
;             ) ()
;         )
;         False
;         True
;     )
; )


(= (isMember $target $list)
    (not (== (collapse 
            (intersection (superpose ($target)) (superpose $list))
            ) ()
        )
    )
)

!(isMember 4 (1 2 3 4 5 6 6 7 7 9 3 2 ))
!(isMember 20 (74 2 3 34 2 1 13 43 35 54 34 1 21))
