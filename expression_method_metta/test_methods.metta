! (register-module! ../expression_method_metta)

! (import! &self expression_method_metta:methods)


! ("Length of Expression")
! (length (1 2 3 4 5))

! ("prepend in expression")
! (prepend 1 ())
! (prepend 0 (1 2 3 4 5))

! ("append in expression")
? ! (append 1 ())
? ! (append 6 (1 2 3 4 5))

! ("access in metta")
! (access 6 (1 2 3 4 5))
! (access 2 (1 2 3 4 5))

! ("insert in metta")
! (insert (0 1 2 3 4) 2)

! ("delete in metta")
! (delete 2 (1 2 3 4 5)) 
! (delete 0 (1 2 3 4 5)) 

! ("replace in metta")
! (replace 2 10 (1 2 3 4 5)) 

! ("filter in metta")
! (filter is_even (1 2 3 4 5))
! (filter is_odd (1 2 3 4 5))

! ("maximum in expression")
! (max (1 5 3 2 4))

! ("minimum in expression")
! (min (1 5 3 2 4))


! ("fold right in expression")
! (foldr square_sum 0 (1 2 3 4 5))

! ("fold left in expression")
! (foldl square_sum 0 (1 2 3 4 5))

! ("Sorting in expression using Insertion Sort")
! (sort (5 2 8 1 9))

! ("map in expression")
! (map square (1 2 3 4 5))
