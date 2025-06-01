! (and True True)
! (or False False)

(= (croaks Fritz) True)
(= (eats_flies Fritz) True)
(= (croaks Sam) True)
(= (eats_flies Sam) False)

(= (frog $x)
    (and (croaks $x)
    (eats_flies $x))
) ; a frog eats and croaks 

! (if (frog $x) ($x is Frog) ($x isn't Frog))

(= (green $x)
    (if (frog $x) True (empty))
)

!(if (green $x) ($x is Green) ($x isn't Green))

!($x (frog $x))


; generate binary
(= (bin) 0)
(= (bin) 1)

(= (gen_bin $n)
    (if (> $n 0)
        (Cons (bin) (gen_bin (- $n 1)))
        Nil
    )
)

; !(gen_bin 3)

(= (gen_bin_list Nil) Nil)
(= (gen_bin_list (Cons $elem $list))
    (Cons (bin) (gen_bin_list $list))
)


; sum of products of two lists

(= (scalar_product Nil Nil) 0)
(= (scalar_product (Cons $elem1 $list1) (Cons $elem2 $list2))
    (+ (* $elem1 $elem2) (scalar_product $list1 $list2))
)


(= (candidate_sum $numbers $solution $target_sum)
    (if (== (scalar_product $numbers $solution) $target_sum) 
    $solution
    (empty)
    )
)

(= (task) (Cons 8 (Cons 3 (Cons 10 (Cons 17 Nil)))))
! (candidate_sum (task) (gen_bin_list (task)) 20)
! (gen_bin_list (task))
!(scalar_product (task) (gen_bin_list (task)))



