; (: isMember (-> $a Expression Bool))
; (= (isMember $target $list)
;     (collapse 
;         (chain (eval (superpose $list)) $current
;             (if (== $current $target) True False)
;         )
;     )
; )

(: isMember (-> $a Expression Bool))
(= (isMember $target $list)
   (if (== (collapse  (intersection (superpose ($target)) (superpose $list)))  ()) 
      False
      True
   )
)
; (: isMember (-> $a Expression Bool))
; (= (isMember $target $list)
;    (unify
;       (collapse (intersection (superpose ($target)) (superpose $list)))
;       ()     
;       False  
;       True   
;    )
; )


!(isMember 15 (1 2 3 4 5 5 6 6 6 8))
!(isMember 6 (1 2 3 4 5 5 6 6 6 8))
; ! (== (collapse  (intersection (superpose (4)) (superpose (1 2 3))))  ())
; 
