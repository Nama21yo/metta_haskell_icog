
! (register-module! ../list_methods_metta)
! (import! &self list_methods_metta:methods)

(= (example_list) (Cons 1 (Cons 2 (Cons 3 Nil))))

! ( "prepend in a list")
! (prepend Nil)
! (prepend 3 Nil)
! (prepend  2 (Cons 1 Nil))
! (prepend 1 (Cons 2 (Cons 3 Nil))) 

! ( "append in a list")
!(append 1 Nil)
!(append 2 (Cons 1 Nil))
!(append 3 (Cons 2 (Cons 1 Nil)))
!(append 5 (example_list))

! ( "access element by Index")

! (access 2 (Cons A (Cons B (Cons C Nil))))
! (access 3 (example_list))

! ( "insert item at specific index")

! (insert 0 1 Nil)
! (insert 1 9 (example_list))

! ( "Delete by index")

! (delete 0 Nil)
! (delete 1 (Cons C (Cons B (Cons A Nil))))
! (delete 2 (example_list))

! ( "replace by index")
! (replace 1 8 (example_list))

! ( "filter in a list")
! (filter is_odd (example_list))

! ( "maximum in a list")
! (max (example_list))
! (max (Cons 21 Nil))

! ( "minimum in a list")
! (min (example_list))
! (min (Cons 21 (Cons 19 Nil)))

! ( "fold right in metta")
! (foldr + 0 (example_list))
! (foldr - 0 (Cons 10 (Cons 5 (Cons 2 Nil))))
! (foldr square_sum 0 (example_list))

! ( "fold left in metta")
! (foldl - 0 (example_list))
! (foldl - 0 (Cons 10 (Cons 5 (Cons 2 Nil))))
! (foldl square_sum 0 (example_list))

! ( "Sorting using Insertion sort")
!(sort (Cons 1 (Cons 14 (Cons 2 Nil))) )

! ( "map in list")
! (map square (example_list))
