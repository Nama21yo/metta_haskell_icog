(translates_to (transcript ENST00000353703) (protein P31946))
(translates_to (transcript ENST00000372839) (protein P31946))
(translates_to (transcript ENST00000264335) (protein P62258))
(translates_to (transcript ENST00000571732) (protein P62258))
(translates_to (transcript ENST00000616643) (protein P62258))
(translates_to (transcript ENST00000627231) (protein P62258))
(translates_to (transcript ENST00000248975) (protein Q04917))
(translates_to (transcript ENST00000307630) (protein P61981))
(translates_to (transcript ENST00000339276) (protein P31947))
(translates_to (transcript ENST00000238081) (protein P27348))


; !(let $transcript (match &space (transcribed_to  ({node[0]}) (transcript $result)) $result)  (match &space (translates_to (transcript $transcript) (protein $myprotein)) (translates_to (transcript $transcript) (protein $myprotein))))

(= (mettaParser $input)
    (let*
        (
            ($each (superpose $input))
            (($head $tail) (decons-atom $each))
            (($gene $rest) (decons-atom $tail))
        )
        (
            {"edge" : $head , "source" : $gene , "target" : $rest }
        )
    )
)


!(mettaParser ((transcribed_to (gene ENSG00000166913)(transcript ENST00000372839)) (transcribed_to (gene ENSG00000166913) (transcript ENST00000353703))))
