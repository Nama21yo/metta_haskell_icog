%% Generated from /mnt/desktop/metta_haskell_icog/non_determinism/generate.metta at 2025-07-24T06:09:47+00:00
:- style_check(-discontiguous).
:- style_check(-singleton).
:- include(library(metta_lang/metta_transpiled_header)).

%  ;; Basic generate sequence


top_call_5:- do_metta_runtime(ExecRes,mi(generate,increment,1,5,ExecRes)).




top_call :-
    time(top_call_5).


%  ;; Expected: (1 2 3 4 5)
%  ;; Expected: (1 2 4 8)
%% Finished generating /mnt/desktop/metta_haskell_icog/non_determinism/generate.metta at 2025-07-24T06:09:47+00:00

:- normal_IO.
:- initialization(transpiled_main, program).
