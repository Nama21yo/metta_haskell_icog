(= (chromosomes)
  (Cons (1 (AND (NOT A) (OR C D)))
  (Cons (3 (AND (OR (NOT A) C) (NOT (AND B D))))
  (Cons (7 (OR (AND (NOT A) C) (NOT (AND B D))))
  (Cons (10 (OR (AND A B) (NOT D)))
  (Cons (5 (AND (OR B C) (NOT A)))
  (Cons (8 (OR (NOT A) (AND B D)))
  (Cons (4 (AND (NOT C) (NOT D)))
  (Cons (6 (OR (AND A C) (OR B D)))
  (Cons (11 (AND (NOT (OR A B)) C))
  (Cons (9 (OR A (AND (NOT B) D)))
  (Cons (2 (AND (NOT A) (OR C D)))
  (Cons (13 (OR (NOT C) (AND B D)))
  (Cons (12 (AND (OR A D) (NOT B)))
  (Cons (15 (OR (AND (NOT A) C) (NOT D)))
  (Cons (14 (AND (NOT B) (OR C D)))
  (Cons (17 (OR (NOT (AND A B)) C))
  (
    Cons (19 (AND (OR A B) (OR C D)))
    Nil)
  ))))))))))
  )))))
  ))

(= (get_score $expr) 
   (car-atom $expr))

(= (insertion_sort $chrom Nil) (Cons $chrom Nil))
(= (insertion_sort $chrom (Cons $head $tail))
   (if (<= (get_score $chrom) (get_score $head))
       (Cons $chrom (Cons $head $tail))
       (Cons $head (insertion_sort $chrom $tail))))

(= (sort_by_score Nil) Nil)
(= (sort_by_score (Cons $head $tail))
   (insertion_sort $head (sort_by_score $tail)))

; ! (chromosomes)
(= (sorted_list) (sort_by_score (chromosomes)))
; ! (sorted_list)

; based on ranking selection assign ranks
(= (append $elem Nil) (Cons $elem Nil))
(= (append $elem (Cons $x $xs)) (Cons $x (append $elem $xs)))


(= (assign_ranks $sorted-list)
   (assign_ranks_helper $sorted-list 1 Nil))

(= (assign_ranks_helper Nil $rank $result) $result)
(= (assign_ranks_helper (Cons $chrom $tail) $rank $result)
   (let* (
         ($score (car-atom $chrom))
         ($expr (cdr-atom $chrom))
         ($ranked-chrom ($rank $score (car-atom $expr)))
        )
        (assign_ranks_helper $tail (+ $rank 1) (append $ranked-chrom $result))
    )
)

; !((assign_ranks (sorted_list)))
(= (ranked_list) (assign_ranks (sorted_list)))
; !(ranked_list)

; calculate the sum

(= (length Nil) 0) 
(= (length (Cons $x $xs))
    (+ 1 (length $xs)))

(= (size_chrom) (length (sorted_list)))

(= (sum_ranks $n)
    (/ (* $n (+ $n 1)) 2) ; n (n + 1) // 2 will be arthimetic sum
)


;  assign pointers for SUS

; ! (sum_ranks (size_chrom))

(= (generate_pointers $total-rank $num-to-select $start-point)
   (generate_pointers_helper $total-rank $num-to-select $start-point 0 Nil))

(= (generate_pointers_helper $total-rank $num-to-select $start-point $current-index $result)
   (if (== $current-index $num-to-select)
       $result
       (let* (
            ($step (/ $total-rank $num-to-select)) 
            ($pointer (+ $start-point (* $current-index $step)))
            )
            (generate_pointers_helper $total-rank $num-to-select $start-point (+ $current-index 1) (append $pointer $result))
    )))
; ! (random-float &rng 0 1)
; ! (generate_pointers (sum_ranks (size_chrom)) 3 (random-float &rng 0 1))

; sus selection

; access for a  list
(= (access 0 Nil) Nil)
(= (access $idx (Cons $elem $list)) 
    (if (> $idx 0)
        (access (- $idx 1) $list)
        $elem
    )
)

; access for an expression
 (= (index $idx $expr)
    (if (== $expr ())
        "Index out of bound error"
        (if (== $idx 0)
            (car-atom $expr)
            (index (- $idx 1) (cdr-atom $expr))
        )
    )
)

(= (select_sus $ranked_chrom $pointers)
    (select_sus_helper $ranked_chrom $pointers Nil)
)

(= (select_sus_helper $ranked_chrom Nil $selected) 
    $selected
)
(= (select_sus_helper $ranked_chrom (Cons $pointer $tail) $selected)
    (let* (
            ($selected_chrom (find_chromosome $ranked_chrom $pointer 0))
         )
         (if (== $selected_chrom Nil)
            $selected
            (select_sus_helper $ranked_chrom $tail (append $selected_chrom $selected))
         )
    )
)

(= (delete 0 Nil) Nil)
(= (delete $idx (Cons $elem $list))
    (if (> $idx 0)
    (Cons $elem (delete (- $idx 1) $list))
    $list
    )
)
(= (find_chromosome $ranked_chrom $pointer $rank_sum)
    (if (== $ranked_chrom Nil)
        Nil
        (let* (
            ($chrom (access 0 $ranked_chrom))           
            ($rank (index 0 $chrom))           
            ($score (index 1 $chrom))
            ($expr (index 2 $chrom))
            ($new_rank_sum (+ $rank_sum $rank))
        )
        (if (>= $new_rank_sum $pointer)
            ($score $expr)
            (find_chromosome (delete 0 $ranked_chrom) $pointer $new_rank_sum)  ; force Nil to end recursion
        ))
    )
)


; Main SUS function with ranking
(= (sus $chromosomes $num_select $random_start)
    (let* (
        ($sorted_chrom (sort_by_score $chromosomes))
        ($ranked_chrom (assign_ranks $sorted_chrom))
        ($total_rank (sum_ranks (length $sorted_chrom)))
        ($pointers (generate_pointers $total_rank $num_select $random_start))
    )
        (select_sus $ranked_chrom $pointers)
    )
)
; select 3 chromosomes
(= (selected_chromosomes) (sus (chromosomes) 3 (random-float &rng 0 1)))

; ! "Selected Chromosomes"
; ! (selected_chromosomes)
