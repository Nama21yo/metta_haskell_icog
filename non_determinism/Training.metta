;; Introduction
;; Graph Representation
(Male Solomon)
(Male Dawit)
(Male Eyosiyas)

(Female Helen)
(Female Rahel)

(Parent Solomon)
(Parent Helen)

(Child Bereket Solomon)
(Child Rahel Solomon)

(AddisAbaba 135 Adama)
(AddisAbaba 275 Hawassa)
(AddisAbaba 565 BahirDar)
(Adama 350 DireDawa)
(DireDawa 75 Harar)
(Harar 480 Dessie)
(Dessie 380 Mekelle)
(Mekelle 440 Gonder)

;; Pattern Matching

;; !(match &self (Male $x) (match &self (Parent $x) $x))
;; !(let $x (match &self (Male $x) $x) (match &self (Parent $x) $x))
;; !(match &self (AddisAbaba $w $d) (AddisAbaba to $d is $w Kms))
;; !(let $x (match &self (AddisAbaba $w $d) $d) $d)

;; Std lib
;; let
;; let*
;; cons-atom
;; decons-atom
;; if

;; Functional Programming
;; Function Definition

(= (cat) (Cat Name Age Weight))
(= (getName (Cat $name $age $w)) $name)
;; !(foo 1)

(= (isEven $x) (== (% $x 2) 0))
;; !(isEven 0)
;; !(isEven 1)
;; !(isEven 2)

(= (double $x) (* 2 $x))

(= (applyTwice $f $x) ($f ($f $x)))
;; !(applyTwice double 5)

(= (map $f $list)
   (if (== $list ())
     ()
     (let*
        (
          (($h $t) (decons-atom $list))
          ($h' ($f $h))
          ($t' (map $f $t))
        )
        (cons-atom $h' $t')
     )
   )
)

;; !(map double (1 2 3 4 5))


;; Non Determinism
;; collapse
;; !(match &self (Male $x) $x)
;; !(collapse (match &self (Male $x) $x))
;; !(let $a (match &self (AddisAbaba $w $d) $w) (double $a))
;; !(collapse (match &self (AddisAbaba $w $d) (AddisAbaba is $w Kms from $d)))

;; superpose
;; !(superpose (A B C D E))
;; !((superpose (A B C D E)) (superpose (A B C D E)))
;; !(+ (superpose (A B C)) (superpose (A B C)))
;; !(+ (superpose (1 2 3)) (superpose (1 2 3)))
;; !((superpose (1 2 3)) (superpose (1 2 3)))

;; empty
;; !(empty)

(= (pickEven $x) (if (isEven $x) $x (empty)))
;; !(pickEven 10)
;; !(pickEven 1)
;; !(collapse (pickEven 10))
;; !(collapse (pickEven 1))
;; !(collapse (pickEven (superpose (1 2 3 4 5))))

;; Unification with let*
;; (Male $x) (match &people (Male $x) $x)
;; !(let (A $b) (superpose ((A $x) (A F E) (B F))) $b)

!(let*
    (
      (($a $a) ((superpose (A B C D E)) (superpose (F G H I J )))) ;; (A F E)
    )
    ($a $a))

;; !(let*
;;     (
;;       ($a (superpose (A B C D E)))
;;       ;; ($a (superpose (A)))
;;       ;; (($a $b) (superpose ((A C) (E A) (F A) (G A) (G A) (I H))))
;;     )
;;     ($a $a))

!(let*
    (
      (($a $b) (superpose (
                            (AddisAbaba Adama)
                            (Adama AddisAbaba)
                            (Adama BahirDar)
                            (BahirDar AddisAbaba)
                            (DireDawa AddisAbaba)
                            (Adama DireDawa)
                            (Ambo Mekelle)
                            (Gonder Hawassa))))
      (($b $c) (superpose (
                            (AddisAbaba Adama)
                            (Adama AddisAbaba)
                            (Adama BahirDar)
                            (Adama DireDawa)
                            (BahirDar AddisAbaba)
                            (DireDawa AddisAbaba)
                            (Ambo Mekelle)
                            (Gonder Hawassa))))
      (($c $a) (superpose (
                            (AddisAbaba Adama)
                            (Adama AddisAbaba)
                            (Adama BahirDar)
                            (BahirDar AddisAbaba)
                            (DireDawa AddisAbaba)
                            (Adama DireDawa)
                            (Ambo Mekelle)
                            (Gonder Hawassa))))
    )
    ($a $b $c $a))

;; addOne
(= (addOne $lists) (collapse (+ 1 (superpose $lists))))
;; !(addOne (1 2 3 4 5))

;; map
;; filter
;; findAndReplace
;; findAndRemove
;; isMember

;; repeat
;; zip
;; zipWith
;; generate


;; PathFinding Function
;; Cartesian product
