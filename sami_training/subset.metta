
(= (isMember $target $list)
    (not (== (collapse 
            (intersection (superpose ($target)) (superpose $list))
            ) ()
        )
    )
)


(: subSet (-> Expression Number Expression))
(= (subSet $set $n)
    (if (== $n 0)
        (())
        (let* 
            (
                ($currentSub (subSet $set (- $n 1))) ;; using head recursion
                ($newSubset (collapse
                            (let $subset (superpose $currentSub)
                                (let $elem (superpose $set)
                                    (if (not (isMember $elem $subset))
                                        (cons-atom $elem $subset)
                                        (empty)
                                    )
                                )
                            )
                    )
                )

                ($res (union-atom $newSubset $currentSub))
                ($uniqueOne (unique-atom $res))
            )
            $uniqueOne
        )
    )
)

!(subSet (0 1 2) 2)
!(subSet (1 2 3) 1)
!(subSet (A B C D) 3)

; 
