!(bind! &tasks (new-space))

; Define urgent Tasks
(= (urgent $task) (and (due_soon $task) (high_priority $task)))
(= (due_soon Task1) True)
(= (high_priority Task1) True)
(= (due_soon Task2) True)
(= (high_priority Task2) True)

; Infer Urgent tasks and store in &tasks
(: ift (-> Bool Atom %Undefined%))
(= (ift True $then) $then)
!(ift (urgent $task) (add-atom &tasks (urgent $task)))

!(match &tasks (Urgent $task) $task)


; Track task status with state atoms
(= (set-task-status! $task $status)
    (let $new-state (new-state $status)
        (add-atom &self (= (status (Task $task)) $new-state))
    )
)

!(set-task-status! Task1 todo)
!(get-state (status (Task Task1)))
!(nop (change-state! (status (Task Task1)) done))
!(get-state (status (Task Task1)))

;; Import a utility module (assume it defines `log`)
; !(import! &self util_module)
; (= (log $msg) (print $msg))  ;; Simulated utility function
; !(log "Task1 is done")

;; Document the urgent function
(@doc urgent 
     (@desc "Identifies if a task is urgent") 
     (@params ((@param "Task name"))) 
     (@return "True if urgent"))
(: urgent (-> Symbol Bool))
!(help! urgent)
; 
