; ;; Non-Deterministic DFS Pathfinding in MeTTa
; ;; ============================================

; ; ;; Graph Knowledge Base
; ; (connected AddisAbaba Adama 135)
; ; (connected AddisAbaba Hawassa 275)
; ; (connected AddisAbaba BahirDar 565)
; ; (connected Adama DireDawa 350)
; ; (connected DireDawa Harar 75)
; ; (connected Harar Dessie 480)
; ; (connected Dessie Mekelle 380)
; ; (connected Mekelle Gonder 440)
; ; (connected BahirDar Gonder 180)
; ; (connected Gonder AddisAbaba 250)

; ; ;; Bidirectional connections
; ; (connected Adama AddisAbaba 135)
; ; (connected Hawassa AddisAbaba 275)
; ; (connected BahirDar AddisAbaba 565)
; ; (connected DireDawa Adama 350)
; ; (connected Harar DireDawa 75)
; ; (connected Dessie Harar 480)
; ; (connected Mekelle Dessie 380)
; ; (connected Gonder Mekelle 440)
; ; (connected Gonder BahirDar 180)
; ; (connected AddisAbaba Gonder 250)

; ; ;; Helper Functions
; ; ;; ================

; ;; Check if element is in list
; ; (= (isMember $target $list)
; ;    (if (== (collapse  (intersection (superpose ($target)) (superpose $list)))  ()) 
; ;       False
; ;       True
; ;    )
; ; )

; ; ;; Non-Deterministic DFS Implementation
; ; ;; ====================================

; ; (= (dfs $current $goal $visited)
; ;    (if (== $current $goal)
; ;        ;; Found goal - return single element list
; ;        (cons-atom $goal ())
; ;        ;; Continue search
; ;        (let* (
; ;                ;; Get next city non-deterministically using match
; ;                ($next (match &self (connected $current $neighbor $weight) $neighbor))
; ;                (() (println! (next $next)))
; ;                ;; Add current to visited list
; ;                ($newVisited (cons-atom $current $visited))
; ;                (() (println! (new-visited $newVisited)))
; ;              )
; ;              ;; Only proceed if next city not visited
; ;              (if (isMember $next $newVisited)
; ;                  (empty)
; ;                  ;; Recursive call and build path
; ;                  (let* (
; ;                          ($restPath (dfs $next $goal $newVisited))
; ;                          (() (println! (restPath $restPath)))
; ;                        )
; ;                        (if (== $restPath (empty))
; ;                            (empty)
; ;                            (cons-atom $current $restPath)))))))

; ; ;; Main pathfinding function
; ; (= (findPath $start $goal)
; ;    (dfs $start $goal ()))

; ; ;; Find all paths
; ; (= (findAllPaths $start $goal)
; ;    (collapse (findPath $start $goal)))

; ; ;; Test Examples
; ; ;; =============

; ; ;; Find one path
; ; !(findPath AddisAbaba Mekelle)

; ;; Find all paths  
; ; !(findAllPaths AddisAbaba Harar)

; ;; Test direct connections
; ;; !(collapse (match &self (connected AddisAbaba $neighbor $weight) $neighbor))

; ;; More examples
; ;; !(findPath BahirDar DireDawa)
; ;; !(findAllPaths AddisAbaba Gonder)



; ;; Non-Deterministic DFS Pathfinding in MeTTa
; ;; ============================================

; ;; Graph Knowledge Base
; (connected AddisAbaba Adama 135)
; (connected AddisAbaba Hawassa 275)
; (connected AddisAbaba BahirDar 565)
; (connected Adama DireDawa 350)
; (connected DireDawa Harar 75)
; (connected Harar Dessie 480)
; (connected Dessie Mekelle 380)
; (connected Mekelle Gonder 440)
; (connected BahirDar Gonder 180)
; (connected Gonder AddisAbaba 250)

; ;; Bidirectional connections
; (connected Adama AddisAbaba 135)
; (connected Hawassa AddisAbaba 275)
; (connected BahirDar AddisAbaba 565)
; (connected DireDawa Adama 350)
; (connected Harar DireDawa 75)
; (connected Dessie Harar 480)
; (connected Mekelle Dessie 380)
; (connected Gonder Mekelle 440)
; (connected Gonder BahirDar 180)
; (connected AddisAbaba Gonder 250)

; ;; Helper Functions
; ;; ================

; ;; Check if element is in list
; (= (contains $x ()) False)
; (= (contains $x (cons-atom $head $tail))
;    (if (== $x $head) True (contains $x $tail)))

; ;; Non-Deterministic DFS Implementation
; ;; ====================================

; (= (dfs $current $goal $visited)
;    (if (== $current $goal)
;        ;; Found goal - return single element list
;        (cons-atom $goal ())
;        ;; Continue search - avoid cycles first
;        (if (isMember $current $visited)
;            (empty)
;            ;; Get next city non-deterministically and continue
;            (let* (
;                    ($next (match &self (connected $current $neighbor $weight) $neighbor))
;                     (() (println! (next $next)))
;                    ($newVisited (cons-atom $current $visited))
;                     (() (println! (newVisited $newVisited)))
;                    ($restPath (dfs $next $goal $newVisited))
;                     (() (println! (restPath $restPath)))
;                  )
;                  (if (== $restPath (empty))
;                      (empty)
;                      (cons-atom $current $restPath))))))

; ;; Main pathfinding function
; (= (findPath $start $goal)
;    (dfs $start $goal ()))

; ;; Find all paths
; (= (findAllPaths $start $goal)
;    (collapse (findPath $start $goal)))

; ;; Test Examples
; ;; =============

; ;; Find one path
; !(findPath AddisAbaba Mekelle)

;; Find all paths  
;; !(findAllPaths AddisAbaba Harar)

;; Test direct connections
;; !(collapse (match &self (connected AddisAbaba $neighbor $weight) $neighbor))

;; More examples
;; !(findPath BahirDar DireDawa)
;; !(findAllPaths AddisAbaba Gonder)

;; Non-Deterministic DFS Pathfinding in MeTTa
;; ============================================

; ;; Graph Knowledge Base
; (connected AddisAbaba Adama 135)
; (connected AddisAbaba Hawassa 275)
; (connected AddisAbaba BahirDar 565)
; (connected Adama DireDawa 350)
; (connected DireDawa Harar 75)
; (connected Harar Dessie 480)
; (connected Dessie Mekelle 380)
; (connected Mekelle Gonder 440)
; (connected BahirDar Gonder 180)
; (connected Gonder AddisAbaba 250)

; ;; Bidirectional connections
; (connected Adama AddisAbaba 135)
; (connected Hawassa AddisAbaba 275)
; (connected BahirDar AddisAbaba 565)
; (connected DireDawa Adama 350)
; (connected Harar DireDawa 75)
; (connected Dessie Harar 480)
; (connected Mekelle Dessie 380)
; (connected Gonder Mekelle 440)
; (connected Gonder BahirDar 180)
; (connected AddisAbaba Gonder 250)

; ;; Helper Functions
; ;; ================

; ;; Check if element is in list (using your improved version)
; (= (isMember $target $list)
;    (if (== (collapse (intersection (superpose ($target)) (superpose $list))) ()) 
;       False
;       True))

; ;; Non-Deterministic DFS Implementation
; ;; ====================================

; (= (dfs $current $goal $visited)
;    (if (== $current $goal)
;        ;; Found goal - return single element list
;        (cons-atom $goal ())
;        ;; Continue search - check if current already visited first
;        (if (isMember $current $visited)
;            (empty)
;            ;; Add current to visited and explore neighbors
;            (let* (
;                    ($newVisited (cons-atom $current $visited))
;                     (() (println! (newVisited $newVisited)))
;                    ;; Get next city non-deterministically using match
;                    ($next (match &self (connected $current $neighbor $weight) $neighbor))
;                     (() (println! (next $next)))
;                    ;; Recursive call
;                    ($restPath (dfs $next $goal $newVisited))
;                     (() (println! (restPath $restPath)))
;                  )
;                  ;; Build path if we found one
;                  (if (== $restPath (empty))
;                      (empty)
;                      (cons-atom $current $restPath))))))

; ;; Main pathfinding function
; (= (findPath $start $goal)
;    (dfs $start $goal ()))

; ;; Find all paths
; (= (findAllPaths $start $goal)
;    (collapse (findPath $start $goal)))

;; Test Examples
;; =============

;; Find one path
; !(findPath AddisAbaba Mekelle)

;; Find all paths  
;; !(findAllPaths AddisAbaba Harar)

;; Test direct connections
;; !(collapse (match &self (connected AddisAbaba $neighbor $weight) $neighbor))

;; More examples
;; !(findPath BahirDar DireDawa)
;; !(findAllPaths AddisAbaba Gonder)

;; Non-Deterministic DFS Pathfinding in MeTTa
;; ============================================

; ;; Graph Knowledge Base
; (connected AddisAbaba Adama 135)
; (connected AddisAbaba Hawassa 275)
; (connected AddisAbaba BahirDar 565)
; (connected Adama DireDawa 350)
; (connected DireDawa Harar 75)
; (connected Harar Dessie 480)
; (connected Dessie Mekelle 380)
; (connected Mekelle Gonder 440)
; (connected BahirDar Gonder 180)
; (connected Gonder AddisAbaba 250)

; ;; Bidirectional connections
; (connected Adama AddisAbaba 135)
; (connected Hawassa AddisAbaba 275)
; (connected BahirDar AddisAbaba 565)
; (connected DireDawa Adama 350)
; (connected Harar DireDawa 75)
; (connected Dessie Harar 480)
; (connected Mekelle Dessie 380)
; (connected Gonder Mekelle 440)
; (connected Gonder BahirDar 180)
; (connected AddisAbaba Gonder 250)

; ;; Helper Functions
; ;; ================

; ;; Check if element is in list (using your improved version)
; (= (isMember $target $list)
;    (if (== (collapse (intersection (superpose ($target)) (superpose $list))) ()) 
;       False
;       True))

; ;; Non-Deterministic DFS Implementation using superpose/collapse
; ;; =============================================================
; (= (dfs $current $goal $visited)
;    (if (== $current $goal)
;        ;; Found goal - return single element list
;        (cons-atom $goal ())
;        ;; Continue search - check if current already visited first
;        (if (isMember $current $visited)
;            (empty)
;            ;; Add current to visited and explore all neighbors using superpose/collapse
;            (let* (
;                    ($newVisited (cons-atom $current $visited))
;                     (() (println! (newVisited $newVisited)))
;                    ;; Get all neighbors first
;                    ($allNeighbors (collapse (match &self (connected $current $next $weight) $next)))
;                     (() (println! (allNeighbors $allNeighbors)))
;                    ;; Filter out visited neighbors using collapse and superpose
;                    ($validNexts (collapse 
;                                 (let $neighbor (superpose $allNeighbors)
;                                      (if (isMember $neighbor $newVisited)
;                                          (empty)
;                                          $neighbor))))
;                     (() (println! (validNexts $validNexts)))
;                  )
;                  ;; If no valid neighbors, return empty
;                  (if (== $validNexts ())
;                      (empty)
;                      ;; Otherwise explore each valid neighbor
;                      (let $nextCity (superpose $validNexts)
;                           (let $restPath (dfs $nextCity $goal $newVisited)
;                                (if (== $restPath (empty))
;                                    (empty)
;                                    (cons-atom $current $restPath)))))))))

; ;; Main pathfinding function
; (= (findPath $start $goal)
;    (dfs $start $goal ()))

; ;; Find all paths
; (= (findAllPaths $start $goal)
;    (collapse (findPath $start $goal)))

; ;; Test Examples
; ;; =============

; ;; Find one path
; !(findPath AddisAbaba Mekelle)

;; Find all paths  
;; !(findAllPaths AddisAbaba Harar)

;; Test direct connections
;; !(collapse (match &self (connected AddisAbaba $neighbor $weight) $neighbor))

;; More examples
;; !(findPath BahirDar DireDawa)
;; !(findAllPaths AddisAbaba Gonder)

;; =========================
;; Knowledge base (edges)
; ;; =========================
; (connected AddisAbaba Adama 135)
; (connected AddisAbaba Hawassa 275)
; (connected AddisAbaba BahirDar 565)
; (connected Adama DireDawa 350)
; (connected DireDawa Harar 75)
; (connected Harar Dessie 480)
; (connected Dessie Mekelle 380)
; (connected Mekelle Gonder 440)
; (connected BahirDar Gonder 180)
; (connected Gonder AddisAbaba 250)

; ;; Bidirectional edges
; (connected Adama AddisAbaba 135)
; (connected Hawassa AddisAbaba 275)
; (connected BahirDar AddisAbaba 565)
; (connected DireDawa Adama 350)
; (connected Harar DireDawa 75)
; (connected Dessie Harar 480)
; (connected Mekelle Dessie 380)
; (connected Gonder Mekelle 440)
; (connected Gonder BahirDar 180)
; (connected AddisAbaba Gonder 250)
; ; 

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
       ;; Base case: reached goal
       (cons-atom $current ())
       ;; Else, explore neighbors
       (let $next  (match &self ($current $_ $next) $next) 
         (if (isMember $next $visited)
             ()
             (let $subpath  (dfs $next $goal (cons-atom $current $visited))
               (cons-atom $current $subpath))
            )
        )
    )
)
               
(= (findPath $start $goal)
   (dfs $start $goal ()))


!(findPath AddisAbaba Mekelle)
!(findPath AddisAbaba Harar)

; (AddisAbaba BahirDar Gonder Mekelle)



; 

