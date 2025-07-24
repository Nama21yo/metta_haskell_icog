
(AddisAbaba 135 Adama)
(AddisAbaba 275 Hawassa)
(AddisAbaba 565 BahirDar)
(Adama 350 DireDawa)
(DireDawa 75 Harar)
(Harar 480 Dessie)
(Dessie 380 Mekelle)
(Mekelle 440 Gonder)


(= (isMember $target $list)
   (if (== (collapse (intersection (superpose ($target))
                                   (superpose $list)))
           ())
       False
       True))

(: dfs (-> Expression Expression Expression Expression))
(= (dfs $current $goal $visited)
   (if (== $current $goal)
       (cons-atom $current ())
       (let $next  (match &self ($current $_ $next) $next) 
         (if (isMember $next $visited)
             ()
             (let $subpath (dfs $next $goal (cons-atom $current $visited))
               (cons-atom $current $subpath))
            )
        )
    )
)
               
(= (findPath $start $goal)
   (dfs $start $goal ()))

!(findPath AddisAbaba Mekelle)
!(findPath AddisAbaba Harar)
; 
