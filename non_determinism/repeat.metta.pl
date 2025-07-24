%% Generated from /mnt/desktop/metta_haskell_icog/non_determinism/repeat.metta at 2025-07-24T06:10:11+00:00
:- style_check(-discontiguous).
:- style_check(-singleton).
:- include(library(metta_lang/metta_transpiled_header)).

%  ; (: repeat (-> $a $a))
%  ; (: repeatN (-> $a Nat $a))
%  ; !(repeat x)  


top_call_5:- do_metta_runtime(ExecRes,mi(repeatN,x,5,ExecRes)).




top_call :-
    time(top_call_5).


%  ;;  (x x x x x)
%% Finished generating /mnt/desktop/metta_haskell_icog/non_determinism/repeat.metta at 2025-07-24T06:10:11+00:00

:- normal_IO.
:- initialization(transpiled_main, program).
