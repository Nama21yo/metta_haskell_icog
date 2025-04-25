; list common methods
(= (example_list) (Cons 1 (Cons 2 (Cons 3 Nil))))
; ! (example_list)
; prepend
(= (prepend Nil) Nil)
(= (prepend $elem $list) (Cons $elem $list))

; ! (prepend Nil)
; ! (prepend 3 Nil)
; ! (prepend  2 (Cons 1 Nil))
; ! (prepend 1 (Cons 2 (Cons 3 Nil)))  
; ! (prepend 0 (example_list))

; append element in a list
(= (append $elem Nil) (Cons $elem Nil))
(= (append $elem (Cons $x $xs)) (Cons $x (append $elem $xs)))

; ! (append 1 Nil)
; !(append 2 (Cons 1 Nil))
; !(append 3 (Cons 2 (Cons 1 Nil)))
; !(append 5 (example_list))

; accessing element by index
(= (access 0 Nil) Nil)
(= (access $idx (Cons $elem $list)) 
    (if (> $idx 0)
        (access (- $idx 1) $list)
        $elem
    )
)
; !(access 2 (Cons A (Cons B (Cons C Nil))))
; !(access 3 (example_list))

; insert element at an index
; ; ( = (factorial $x)
; ;     (if (> $x 0)
; ;         (* $x (factorial (- $x 1)))
; ;         1  
; ;     )
; ; )
; length of a list
(= (length ()) 0) ; base case
(= (length (:: $x $xs))
    (+ 1 (length $xs)))
; ! (length (:: A (:: B (:: C ()))))


; insert item in specfic index
(= (insert 0 $item Nil)  (Cons $item Nil))
(= (insert $idx $item (Cons $elem $list))
    (if (> $idx 0)
        (Cons $elem (insert (- $idx 1) $item $list)) ;swap each of them starting from the back
        (Cons $item (Cons $elem $list))
    )
)

; ! (insert 0 1 Nil)
; ! (insert 1 9 (example_list))


(= (delete 0 Nil) "It is Empty")
(= (delete $idx (Cons $elem $list))
    (if (> $idx 0)
    (Cons $elem (delete (- $idx 1) $list))
    $list
    )
)
; ! (delete 0 Nil)
; ! (delete 1 (Cons C (Cons B (Cons A Nil))))
; ! (delete 2 (example_list))



;? prepend
; ? append
;? accessing elements by index
;? insert by index
;? delete  by index
; ? replace by index
; ? filter
;? max
;? min
; sort
;? foldr
;? foldl
;? map

; replace by index
( = (replace 0 $item Nil) "list is Empty can't be replaced")
(= (replace $idx $item (Cons $elem $list))
    (if (> $idx 0)
    (Cons $elem (replace (- $idx 1) $item $list))
    (Cons $item $list)
    )
)

; ! (replace 1 8 (example_list))

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

; !(filter is_odd (example_list))

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

; ! (max (example_list))
; ! (max (Cons 21 Nil))

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


; ! (min (example_list))
; ! (min (Cons 21 (Cons 19 Nil)))

; fold right in metta
(= ($foldr $func $init Nil) $init)
(= ($foldr $func $init (Cons $elem $list))
    ($func $elem ($foldr $func $init $list))
)

(= (square_sum $acc $x) (+ (* $x $x) $acc))

; ! (foldr + 0 (example_list))
; ! (foldr - 0 (Cons 10 (Cons 5 (Cons 2 Nil))))
; ! (foldr square_sum 0 (example_list))

; fold left in metta
(= (foldl $func $init Nil) $init)
(= (foldl $func $init (Cons $elem $list))
 (foldl $func ($func $init $elem) $list)
)

; ! (foldl - 0 (example_list))
; ! (foldl - 0 (Cons 10 (Cons 5 (Cons 2 Nil))))
; ! (foldl square_sum 0 (example_list))

; sort in metta using Insertion Sort
(= (sort Nil) Nil)
(= (sort (Cons $elem $list))
    (insertion_sort $elem (sort $list))
)

(= (insertion_sort $item Nil) (Cons $item Nil))
(= (insertion_sort $item (Cons $elem $list))
    (if (<= $item $elem)
    (Cons $item (Cons $elem $list))
    (Cons $elem (sort $item $list))
    )
)

!(sort (Cons 1 (Cons 14 (Cons 2 Nil))) )
; map in metta

(= (map $f Nil) Nil)
(= (map $f  (Cons $elem $list))
    (Cons ($f $elem) (map $f $list))
)

(= (square $x) (* $x $x))

; !(map square (example_list))

