; length of an expression
(= (length $list)
    (if (== $list ())
        0
        (let $rest (cdr-atom $list)
            (+ 1 (length $rest))
        )
    )
)

; car-atom: gets the first element of an expression
; cdr-atom: gets all elements except the first
; cons-atom: combines an element with a list to create a new list

; prepend in metta
(= (prepend $item $expr) (cons-atom $item $expr))

; append element in a list
(= (append $item ()) 
   (cons-atom $item ()))
(= (append $item $expr)
   (cons-atom (car-atom $expr) 
              (append $item (cdr-atom $expr))))


; accessing element by index
(= (access $idx $expr)
    (if (== $expr ())
        "Index out of bound error"
        (if (== $idx 0)
            (car-atom $expr)
            (access (- $idx 1) (cdr-atom $expr))
        )
    )
)

! ()

; insert item in specfic index

(= (insert 0 $item ()) (cons-atom $item ()))
(= (insert $idx $item $expr)
    (let*
        (
            ($head (car-atom $expr))
            ($tail (cdr-atom $expr))
        )
    (if (== $idx 0)
        (cons-atom $item $expr)
        (cons-atom $head (insert (- $idx 1) $item $tail))
    ))
)
;; the problem with the above implementation has sth to do with how cons-atom works
;; if you are looking to concatenate an atom and an expression the second argument must be an actual argument or a reference to an argument
;; not a function call that returns an expression
;; so bind the recursive call (insert (- $idx 1) $item $tail) in a variable and call that variable in cons-atom
;; like this
(= (insert 0 $item ()) (cons-atom $item ()))
(= (insert $idx $item $expr)
    (let*
        (
            ($head (car-atom $expr))
            ($tail (cdr-atom $expr))
        )
    (if (== $idx 0)
        (cons-atom $item $expr)
        (let  $c (insert (- $idx 1) $item $tail)
             (cons-atom $head $c)))))

; ! (insert 2 20 (1 2 3))


; delete item in specific index
(= (delete $idx $expr)
    (if (== $expr ())
        (error "Index out of bounds")
        (if (== $idx 0)
            (cdr-atom $expr)
            (let* 
                (
                    ($head (car-atom $expr))
                    ($tail (cdr-atom $expr))
                )
                (cons-atom $head (delete (- $idx 1) $tail))
            )
        )
    )
)
;; the commnet for insert function applies for delete and replace also
; ! (delete 2 (0 1 2 3))

; replace by index
(= (replace $idx $item $expr)
    (if (== $expr ())
        (error "Index out of bounds")
        (if (== $idx 0)
            (cons-atom $item (cdr-atom $expr))
            (let* 
                (
                    ($head (car-atom $expr))
                    ($tail (cdr-atom $expr))
                )
                (cons-atom $head (replace (- $idx 1) $item $tail))
            )
        )
    )
)

; ! (replace 2 20 (0 1 2 3))
; filter in metta
(= (is_even $x ) (== (% $x 2) 0))
( = (is_odd $x) (not (is_even $x)))

(= (filter $pred $list)
    (if (== $list ())
        ()
        (let* 
            (
                ($head (car-atom $list))
                ($tail (cdr-atom $list))
                ($filtered-tail (filter $pred $tail))
            )
            (if ($pred $head)
                (cons-atom $head $filtered-tail)
                $filtered-tail
            )
        )
    )
)
; ! (filter is_even (1 2 3 4 5))

; max element in a lsit
(= (max $expr)
    (let* 
        (
            ($head (car-atom $expr))
            ($tail (cdr-atom $expr))
        )
        (if (== $tail ())
            $head
            (let $max-tail (max $tail)
                (if (> $head $max-tail)
                    $head
                    $max-tail
                )
            )
        )
    )
)

! (max (1 2 5 23 1 6 7 ))
; min element in a list
(= (min $expr)
    (let*
        (
            ($head (car-atom $expr))
            ($tail (cdr-atom $expr))
        )
        (if (== $tail ())
            $head
            (let $min-tail (min $tail)
                (if (< $head $min-tail)
                    $head
                    $min-tail
                )
            )
        )
    )
)
! (min (1 2 5 23 1 6 7 ))

; fold right in metta
(= (foldr $func $init $expr)
    (if (== $expr ())
        $init
        (let*
            (
                ($head (car-atom $expr))
                ($tail (cdr-atom $expr))
            )
            ($func $head (foldr $func $init $tail))
        )
    )
)
(= (square_sum $acc $x) (+ (* $x $x) $acc))

; fold left in metta
; ! (foldr square_sum 0 (1 2 5 1)) ;; results in 1445 but is should be 31 not 1445

(= (foldl $func $init $expr)
    (if (== $expr ())
        $init
        (let*
            (
                ($head (car-atom $expr))
                ($tail (cdr-atom $expr))
                ($new-acc ($func $init $head))
            )
            (foldl $func $new-acc $tail)
        )
    )
)

! (foldl square_sum 0 (1 2 5 1)) ;; this appears to work well

; sort in metta using Insertion Sort
(= (insertion_sort $item $sorted_expr)
    (if (== $sorted_expr ())
        (cons-atom $item ())
        (let* 
            (
                ($head (car-atom $sorted_expr))
                ($tail (cdr-atom $sorted_expr))
            )
            (if (<= $item $head)
                (cons-atom $item $sorted_expr)
                (cons-atom $head (insertion_sort $item $tail))
            )
        )

    )
)
(= (sort $expr)
    (if (== $expr ())
        ()
        (let* 
            (
                ($head (car-atom $expr))
                ($tail (cdr-atom $expr))
                ($sorted-tail (sort $tail))
            )
            (insertion_sort $head $sorted-tail)
        )
    )
)

(= (compare $a $b) (< $a $b))

! (sort (7 1 4 2 -2))
; map in metta
(= (map $func $expr)
     (if (== $expr ())
        ()
        (let*
            (
                ($head (car-atom $expr))
                ($tail (cdr-atom $expr))
            )
            (cons-atom ($func $head) (map $func $tail))
        )
     )
)
(= (square $x) (* $x $x))