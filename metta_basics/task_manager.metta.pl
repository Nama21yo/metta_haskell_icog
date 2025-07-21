%% Generated from /mnt/desktop/metta_haskell_icog/metta_basics/task_manager.metta at 2025-07-14T15:54:12+00:00
:- style_check(-discontiguous).
:- style_check(-singleton).
:- include(library(metta_lang/metta_transpiled_header)).



top_call_5:- do_metta_runtime(ExecRes,u_assign('bind!'('&tasks',['new-space']),ExecRes)).




top_call :-
    time(top_call_5).


%  ; Define urgent Tasks
%  ; Infer Urgent tasks and store in &tasks


top_call_6:- do_metta_runtime( ExecRes, 
               ( A=ift  ,
                 mi(urgent,_task,B) , 
                 B=C , 
                 as_tf('add-atom'('&tasks',[urgent,_task]),D) , 
                 D=E , 
                 u_assign([A,C,E],ExecRes))).




top_call :-
    time(top_call_6).


arg_type_n(ift,2,2,non_eval('Atom')).


top_call_7:- do_metta_runtime( ExecRes, 
               ( A='&tasks'  ,
                 metta_atom_iter(A,['Urgent',_task]) , 
                 e_assign(_task,ExecRes))).




top_call :-
    time(top_call_7).


%  ; Track task status with state atoms


top_call_8:- do_metta_runtime(ExecRes,mi('set-task-status!','Task1',todo,ExecRes)).




top_call :-
    time(top_call_8).




top_call_9:- do_metta_runtime( ExecRes, 
               ( A='get-state'  ,
                 B=status , 
                 mi('Task','Task1',C) , 
                 C=D , 
                 u_assign([B,D],E) , 
                 E=F , 
                 u_assign([A,F],ExecRes))).




top_call :-
    time(top_call_9).




top_call_10:- do_metta_runtime( ExecRes, 
                ( A=nop  ,
                  B='change-state!' , 
                  C=status , 
                  mi('Task','Task1',D) , 
                  D=E , 
                  u_assign([C,E],F) , 
                  F=G , 
                  H=done , 
                  u_assign([B,G,H],I) , 
                  I=J , 
                  u_assign([A,J],ExecRes))).




top_call :-
    time(top_call_10).




top_call_11:- do_metta_runtime( ExecRes, 
                ( A='get-state'  ,
                  B=status , 
                  mi('Task','Task1',C) , 
                  C=D , 
                  u_assign([B,D],E) , 
                  E=F , 
                  u_assign([A,F],ExecRes))).




top_call :-
    time(top_call_11).


%  ;; Import a utility module (assume it defines `log`)


top_call_12:- eval_H(['import!','&self',util_module],ExecRes).




top_call :-
    time(top_call_12).


%  ;; Simulated utility function


top_call_13:- do_metta_runtime(ExecRes,mi(log,"Task1 is done",ExecRes)).




top_call :-
    time(top_call_13).


%  ;; Document the urgent function


top_call_14:- do_metta_runtime(ExecRes,mi('help!',urgent,ExecRes)).




top_call :-
    time(top_call_14).


arg_type_n('help!',1,1,non_eval('Atom')).
arg_type_n('get-doc',1,1,non_eval('Atom')).
arg_type_n('get-doc-single-atom',1,1,non_eval('Atom')).
arg_type_n('mod-space!',1,1,non_eval('Atom')).
arg_type_n(==,2,1,var).
arg_type_n(==,2,2,var).
arg_type_n('get-doc-function',2,1,non_eval('Atom')).
arg_type_n('get-doc-params',3,1,non_eval('Expression')).
arg_type_n('get-doc-params',3,2,non_eval('Atom')).
arg_type_n('get-doc-params',3,3,non_eval('Expression')).
arg_type_n('@item',1,1,non_eval('Atom')).
arg_type_n('@params',1,1,non_eval('Expression')).
arg_type_n('for-each-in-atom',2,1,non_eval('Expression')).
arg_type_n('for-each-in-atom',2,2,non_eval('Atom')).
arg_type_n('noreduce-eq',2,1,non_eval('Atom')).
arg_type_n('noreduce-eq',2,2,non_eval('Atom')).
arg_type_n('help-param!',1,1,non_eval('Atom')).
%  ; 
%% Finished generating /mnt/desktop/metta_haskell_icog/metta_basics/task_manager.metta at 2025-07-14T15:54:12+00:00

:- normal_IO.
:- initialization(transpiled_main, program).
