(EvaluationLink
  (PredicateNode "eats")
  (ListLink
     (ConceptNode "Sam")
     (ConceptNode "flies")))

(EvaluationLink
  (PredicateNode "eats")
  (ListLink
     (ConceptNode "Bill")
     (ConceptNode "pizza")))

(EvaluationLink
  (PredicateNode "eats")
  (ListLink
     (ConceptNode "Fritz")
     (ConceptNode "flies")))

!(assertEqualToResult
  (match &self
    (EvaluationLink
      (PredicateNode "eats")
        (ListLink
          $x
          (ConceptNode "flies")))
     $x)
  ((ConceptNode "Sam")
   (ConceptNode "Fritz")))
