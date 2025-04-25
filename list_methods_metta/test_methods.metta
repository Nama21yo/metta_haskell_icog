
!(import! &self methods.metta)

; (= (example_list) (Cons 1 (Cons 2 (Cons 3 Nil))))

! (prepend Nil)
! (prepend 3 Nil)
! (prepend  2 (Cons 1 Nil))
! (prepend 1 (Cons 2 (Cons 3 Nil))) 

! (min (example_list))
! (min (Cons 21 (Cons 19 Nil)))