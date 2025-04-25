; list common methods

; prepend in metta
(= (prepend Nil) Nil)
(= (prepend $elem $list) (Cons $elem $list))


; append element in a list
(= (append $elem Nil) (Cons $elem Nil))
(= (append $elem (Cons $x $xs)) (Cons $x (append $elem $xs)))

; accessing element by index
(= (access 0 Nil) Nil)
(= (access $idx (Cons $elem $list)) 
    (if (> $idx 0)
        (access (- $idx 1) $list)
        $elem
    )
)

; insert item in specfic index
(= (insert 0 $item Nil)  (Cons $item Nil))
(= (insert $idx $item (Cons $elem $list))
    (if (> $idx 0)
        (Cons $elem (insert (- $idx 1) $item $list)) ;swap each of them starting from the back
        (Cons $item (Cons $elem $list))
    )
)

; delete item in specific index
(= (delete 0 Nil) "It is Empty")
(= (delete $idx (Cons $elem $list))
    (if (> $idx 0)
    (Cons $elem (delete (- $idx 1) $list))
    $list
    )
)

; replace by index
( = (replace 0 $item Nil) "list is Empty can't be replaced")
(= (replace $idx $item (Cons $elem $list))
    (if (> $idx 0)
    (Cons $elem (replace (- $idx 1) $item $list))
    (Cons $item $list)
    )
)

; filter in metta
(= (is_even $x ) (== (% $x 2) 0))
( = (is_odd $x) (not (is_even $x)))

(= (filter $func Nil) Nil)
(= (filter $func (Cons $elem $list))
 (if ($func $elem)
    (Cons $elem (filter $func $list))
    (filter $func $list)
 )
)

; max element in a lsit
(= (max Nil) "Empty List")
(= (max (Cons $elem $list))
    (max_helper $list $elem)
)
(= (max_helper Nil $current_max) $current_max)
(= (max_helper (Cons $elem $list) $current_max)
    (if (> $elem $current_max)
        (max_helper $list $elem) ; if the element is larger update current max
        (max_helper $list $current_max) 
    )
)

; min element in a list
(= (min Nil) "Empty List")
(= (min (Cons $elem $list)) 
    (min_helper $list $elem)
)
(= (min_helper Nil $current_min) $current_min)
(= (min_helper (Cons $elem $list) $current_min)
    (if (< $elem $current_min)
    (min_helper $list $elem)
    (min_helper $list $current_min)
    )
)

; fold right in metta
(= ($foldr $func $init Nil) $init)
(= ($foldr $func $init (Cons $elem $list))
    ($func $elem ($foldr $func $init $list))
)

(= (square_sum $acc $x) (+ (* $x $x) $acc))

; fold left in metta
(= (foldl $func $init Nil) $init)
(= (foldl $func $init (Cons $elem $list))
 (foldl $func ($func $init $elem) $list)
)

; sort in metta using Insertion Sort
(= (sort Nil) Nil)
(= (sort (Cons $elem $list))
    (insertion_sort $elem (sort $list))
)
(= (insertion_sort $item Nil) (Cons $item Nil))
(= (insertion_sort $item (Cons $elem $list))
    (if (<= $item $elem)
    (Cons $item (Cons $elem $list))
    (Cons $elem (insertion_sort $item $list))
    )
)

; map in metta
(= (map $f Nil) Nil)
(= (map $f  (Cons $elem $list))
    (Cons ($f $elem) (map $f $list))
)
(= (square $x) (* $x $x))