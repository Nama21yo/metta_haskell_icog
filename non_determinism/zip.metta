(= (zip $list1 $list2)
     (if (and (> (size-atom $list1) 0) (> (size-atom $list2) 0))
       (let* (
                    (($first1 $rest1) (decons-atom $list1))
                    (($first2 $rest2) (decons-atom $list2))
                    ($pair ($first1 $first2))
                    ($restZipped (zip $rest1 $rest2))
               )
           (cons-atom $pair $restZipped))
       ()))
    
; (: zipNonDet (-> Expression Expression Expression))
; (= (zipNonDet $list1 $list2)
;    (let* (($elem1 (superpose $list1))
;           ($elem2 (superpose $list2)))
;      ($elem1 $elem2)))

!  (zip (1 2) (a b))
; !(collapse (zipNonDet (1 2) (a b)))


(= (zipWith $func $list1 $list2)
     (if (and (> (size-atom $list1) 0) (> (size-atom $list2) 0))
       (let* (
                     (($first1 $rest1) (decons-atom $list1))
                     (($first2 $rest2) (decons-atom $list2))
                     ($result ($func $first1 $first2))
                     ($restResults (zipWith $func $rest1 $rest2))
                 )
           (cons-atom $result $restResults))
       ()))

(= (add $x $y) (+ $x $y))
!(zipWith add (1 2 3) (10 20 30))
;;  (11 22 33)


; 
