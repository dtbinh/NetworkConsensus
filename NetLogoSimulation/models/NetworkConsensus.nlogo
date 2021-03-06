directed-link-breed [influence-links influence-link]

turtles-own [ self-val in-vals out-val self-weight soc-capital ] ; a node's self value, aggregate in value, out value and social capital value 
links-own [ weight ]  ; the strength of the influence of the from (out) agent on the to (in) agent -- future: can be calculated as a difference between the strengths of the respective agents

globals [p] ; global variables

;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  
  ;; set shapes
  set-default-shape turtles "circle"
  ;; setup agents
  setup-agents
  ;; setup network
  setup-network
  
  set p 2 ;;what is p?
  
  display-labels
  reset-ticks
end

to setup-agents
  ; create agents
  create-turtles total-agents [ set color blue ]
  ask turtle 0 [ set color red ]
  type "created " type count turtles print " agents"
  ;init self values
  init-agent-values
end

to init-agent-values
  ; init self values
  ask turtle 0 [ set self-val head's-value ]
  type "--> set self-val of turtle 0 to: " type [self-val] of turtle 0 print ""
  ask turtles with [ who > 0 ] [ set self-val other's-value  ]
  type "--> set self-val of turtle 1..N to: " type [self-val] of turtle 1 print ""
end

to setup-network
  ;; setup network
  if network-type? = "Radial Network" [
    setup-radial-network
  ]
  if network-type? = "Full Network" [
    setup-full-network
  ]
  if network-type? = "Ring Network" [
    setup-ring-network
  ]
  if network-type? = "Ring Network Less Spokes" [
    ifelse (total-spokes >= total-agents)
       [type "Number of spokes cannot exceed number of agent " print total-agents stop]
       [setup-ring-network-less-spokes]
  ]
  ;;check in-weights
  check-weights
end

  
to setup-radial-network
  ; create links in both directions between turtle 0 and all other turtles
  ask turtle 0 [ create-influence-links-to other turtles ]
  ask turtle 0 [ create-influence-links-from other turtles ]
  ;type "created " type count influence-links print " influence-links"
  ; do a radial tree layout, centered on turtle 0
  layout-radial turtles influence-links (turtle 0)
  
  ; set weight values
;  ask turtle 0 [ foreach sort my-out-influence-links [ ask ? [set weight (1 - epsilon)] ] ]
;  ask turtle 0 [ foreach sort my-in-influence-links [ ask ? [set weight precision (epsilon / (total-agents - 1)) 5] ] ]
;  ;ask turtles  [ set self-weight epsilon ]
;  ;ask turtle 0 [ set self-weight (1 - epsilon) ]
;  ask turtles  [ set self-weight (1 - get-in-neighbour-weights) ]
  setup-weight-net
end

to setup-full-network
  ; create links in both directions between all pairs of turtles
  foreach sort turtles[
    ask ? [ create-influence-links-to other turtles ]
  ]
  
  ;set weights
  ;setup-absolute-weight-for-full-net
  ;setup-normalised-weights-for-full-net
  setup-weight-net
  ;;set layout
  ;;radial
  ;layout-radial turtles influence-links (turtle 0)
  ;;spring
  ;repeat 30 [ layout-spring turtles influence-links 0.2 10 1 ] ;;layout-spring turtle-set link-set spring-constant spring-length repulsion-constant
  ;;circle
  layout-circle turtles with [who > 0 ] 8 ;layout-circle agentset radius ;; layout-circle list-of-turtles radius
  ask turtle 0[ set xcor 0 set ycor 0]
end

to setup-ring-network
  
  if (number-of-neighbors > total-agents - 2) or (number-of-neighbors mod 2 != 0) or (number-of-neighbors <= 0)  [ print "ERROR" ]
  
  ; create links in both directions between all neighbours of turtles => ring; except turtle 0 (the control agent)
  foreach sort turtles[
    let agent-who ([who] of ?)
    let pair-of-neighbors 1
;    let left-agent-who (agent-who - 1)
;    let right-agent-who (agent-who + 1)
;    ask ?[  
;      ifelse (agent-who != 0)[
;        if (left-agent-who = 0)[set left-agent-who (total-agents - 1)]
;        if(right-agent-who = total-agents)[set right-agent-who 1]
;        create-influence-link-to turtle right-agent-who 
;        create-influence-link-to turtle left-agent-who
;      ]
;      [ ; for agent 0
;        create-influence-links-to other turtles
;        create-influence-links-from other turtles
;      ]
;    ]
    repeat number-of-neighbors / 2 [
      let left-agent-who ifelse-value (agent-who - pair-of-neighbors > 0) [agent-who - pair-of-neighbors] [ agent-who - pair-of-neighbors + total-agents - 1 ]
      let right-agent-who ifelse-value (agent-who + pair-of-neighbors < total-agents) [agent-who + pair-of-neighbors] [ agent-who + pair-of-neighbors - total-agents + 1 ]
      ifelse (agent-who != 0)
      [
        ask ? [
          create-influence-link-to turtle right-agent-who
          create-influence-link-to turtle left-agent-who
        ]  
      ]
      [
        ask ? [
          create-influence-links-to other turtles
          create-influence-links-from other turtles
        ]  
      ]
      set pair-of-neighbors (pair-of-neighbors + 1)
    ]
  ]
  
  ;set layout
  layout-circle sort turtles with [who > 0 ] 8 ;layout-circle agentset radius ;; layout-circle list-of-turtles radius
  ask turtle 0[ set xcor 0 set ycor 0]
  
  ;set weights
  ;setup-normalised-weights-for-ring-net 
  setup-weight-net  
end

to setup-ring-network-less-spokes
  ; create links in both directions between all neighbours of turtles => ring; except turtle 0 (the control agent)
  setup-ring-no-spokes
  
  ;let nmbr-spokes 1
  let nmbr-spokes total-spokes
  let other-who 1
  let delta round(total-agents / nmbr-spokes)
  if(delta = 0)[set delta 1]
  let counter 1 
  while [other-who < total-agents and counter <= total-spokes][
    ask turtle 0[
      create-influence-link-to turtle other-who
      create-influence-link-from turtle other-who
      set other-who (other-who + delta)
      set counter (counter + 1)
    ]
  ]

    
 set counter count([my-out-influence-links] of turtle 0)
  while [counter < total-spokes][
    let agent-who random (total-agents)
    type "agent-who " print agent-who
    if (agent-who != 0)[
      ask turtle 0[
        create-influence-link-to turtle agent-who
        create-influence-link-from turtle agent-who
      ]
      set counter count([my-out-influence-links] of turtle 0)
    ]
  ]
  
  ;set layout
  layout-circle sort turtles with [who > 0 ] 8 ;layout-circle agentset radius ;; layout-circle list-of-turtles radius
  ask turtle 0[ set xcor 0 set ycor 0]
  
  ;set weights
  ;setup-normalised-weights-for-ring-net-with-less-spokes nmbr-spokes ; call with parameter
  setup-weight-net
  
end

to check-weights
  ask turtles[
    let in-weight-sum get-in-neighbour-weights
    set in-weight-sum (in-weight-sum + self-weight)
    ;type "check-weights: agent " type [who] of self type ": " type in-weight-sum print ""  
    if in-weight-sum != 1[
      type "Warning --> check-weights: agent " type [who] of self type ": " type in-weight-sum type ". should be 1." print "" 
    ]
    
    ;type "sum-in-weights: agent " type [who] of self type ": " type get-in-neighbour-weights print ""
    ;type "self-weight: agent " type [who] of self type ": " type self-weight print "" 
  ]
end

to setup-ring-no-spokes
   ; create links in both directions between all neighbours of turtles => ring; except turtle 0 (the control agent)
  foreach sort turtles[
    let agent-who ([who] of ?)
    let left-agent-who (agent-who - 1)
    let right-agent-who (agent-who + 1)
    ask ?[  
      if(agent-who != 0)[
        if (left-agent-who = 0)[set left-agent-who (total-agents - 1)]
        if(right-agent-who = total-agents)[set right-agent-who 1]
        create-influence-link-to turtle right-agent-who 
        create-influence-link-to turtle left-agent-who
      ]
    ]
  ]
;  foreach sort turtles[
;    let agent-who ([who] of ?)
;    let pair-of-neighbors 1
;    repeat number-of-neighbors / 2 [
;      let left-agent-who ifelse-value (agent-who - pair-of-neighbors > 0) [agent-who - pair-of-neighbors] [ agent-who - pair-of-neighbors + total-agents - 1 ]
;      let right-agent-who ifelse-value (agent-who + pair-of-neighbors < total-agents) [agent-who + pair-of-neighbors] [ agent-who + pair-of-neighbors - total-agents + 1 ]
;      if (agent-who != 0)
;      [
;        ask ? [
;          create-influence-link-to turtle right-agent-who
;          create-influence-link-to turtle left-agent-who
;        ]  
;      ]
;      set pair-of-neighbors (pair-of-neighbors + 1)
;    ]
;  ]
  ;ask turtle 0[; for agent 0
  ;    create-influence-links-to turtles
  ;    create-influence-links-from other turtles
  ;]
  
end

to-report get-in-neighbour-weights
  let in-weight-sum 0
  foreach sort my-in-influence-links[
       set in-weight-sum (in-weight-sum + [weight] of ?)  
  ]
  report in-weight-sum 
end

; turtle 0: 0.9 self; 0.1 influence from all others
; others: 0.9 from turtle0; 0.1/neighbours from neighbours; ~0.1 self 
to setup-absolute-weight-for-full-net
  let neigh-influence (epsilon / (total-agents - 1))
  ask turtles [ foreach sort my-out-influence-links [ ask ? [set weight neigh-influence] ]]
  ;ask turtles [show get-in-neighbour-weights]

  ;turtle 0 --> out
  ask turtle 0 [ foreach sort my-out-influence-links [ ask ? [set weight (1 - epsilon)] ] ]
  ;turtle 0 --> in
  ask turtle 0 [ foreach sort my-in-influence-links [ ask ? [set weight precision (epsilon / (total-agents - 1)) 100] ] ]
  ask turtle 0 [ set self-weight (1 - epsilon)]

  ask turtles  [ set self-weight (1 - get-in-neighbour-weights) ]
  
  ;print weights
  print-weights
  
   
end

;;sets weights with respect to epislon, then normalises them wrt to 1
;to setup-normalised-weights-for-full-net
;  let head-weight (1 - epsilon)
;  let own-weight (1 * epsilon)
;  let neighbour-weight (1 * epsilon)
;  ;normalise wrt 1
;  let norm (head-weight + own-weight + (neighbour-weight * (total-agents - 2))) 
;  ;let head-weight-norm (head-weight / norm)
;  let head-weight-norm 0
;  let own-weight-norm (own-weight / norm)
;  let neighbour-weight-norm (neighbour-weight / norm)
;  
;  ask turtles [ 
;    foreach sort my-out-influence-links [ ask ? [set weight neighbour-weight-norm ] ] 
;    set self-weight own-weight-norm
;    set head-weight-norm (1 - self-weight - (neighbour-weight-norm * (total-agents - 2)))
;  ]
;  
;  ask turtle 0 [ foreach sort my-out-influence-links [ ask ? [set weight head-weight-norm] ] ]
;  ask turtle 0 [ foreach sort my-in-influence-links [ ask ? [set weight precision (epsilon / (total-agents - 1)) 100] ] ]
;  ask turtle 0  [ set self-weight (1 - get-in-neighbour-weights) ]
;  
;  ask turtles [ 
;    set self-weight (1 - get-in-neighbour-weights)
;    ]
;  
;  ;print weights
;  print-weights
;
;end

;prints weights of turtle 0 and turtle 1 (from neighbour 2)
to print-weights
  
  ask turtle 1 [
    let neigh-weight [weight] of in-influence-link-from turtle 2
    ;type "all in weights: " show get-in-neighbour-weights
    type "agent 1: weight from agent 0: " show  [weight] of in-influence-link-from turtle 0
    ;type "agent 1: total weight from in neighbours: " show ((count neighbors) * neigh-weight)
    type "agent 1: total weight from in neighbours: " show (get-in-neighbour-weights - ([weight] of in-influence-link-from turtle 0))
    type "agent 1: self weight: " show self-weight
  ]
  ask turtle 0 [
    type "agent 0: all in neighs weights: " show get-in-neighbour-weights
    type "agent 0: self-weight: " show self-weight
  ]
end

to setup-normalised-weights-for-ring-net
  ;let number-of-neighbours 2
  let head-weight (1 - epsilon)
  let own-weight epsilon
  let neighbour-weight 1 * epsilon
  ;normalise wrt 1
  let norm (head-weight + own-weight + (neighbour-weight * number-of-neighbors)) 
  ;let head-weight-norm (head-weight / norm)
  let head-weight-norm 0
  let own-weight-norm (own-weight / norm)
  let neighbour-weight-norm (neighbour-weight / norm)
  
  ask turtles [ 
    foreach sort my-out-influence-links [ ask ? [set weight neighbour-weight-norm ] ] 
    set self-weight own-weight-norm
    set head-weight-norm (1 - self-weight - (neighbour-weight-norm * number-of-neighbors))
  ]
  
  ask turtle 0 [ foreach sort my-out-influence-links [ ask ? [set weight head-weight-norm] ] ]
  ask turtle 0 [ foreach sort my-in-influence-links [ ask ? [set weight precision (epsilon / (total-agents - 1)) 100] ] ]
  ask turtle 0  [ set self-weight (1 - get-in-neighbour-weights) ]
  
  ask turtles [ 
    set self-weight (1 - get-in-neighbour-weights)
    ]
  
  ;print weights
  print-weights
end

to setup-normalised-weights-for-ring-net-with-less-spokes [nmbr-spokes]
  let number-of-neighbours 2
  let head-weight (1 - epsilon)
  let own-weight epsilon
  let neighbour-weight epsilon
  ;normalise wrt 1
  let norm 0 
  ;let head-weight-norm (head-weight / norm)
  let head-weight-norm 0
  
  ask turtles [ 
    ifelse (in-influence-link-neighbor? turtle 0)
       [set norm (head-weight + own-weight + (neighbour-weight * number-of-neighbours))]
       [set norm (own-weight + (neighbour-weight * number-of-neighbours))]
    let own-weight-norm (own-weight / norm)
    let neighbour-weight-norm (neighbour-weight / norm)
    ;show neighbour-weight-norm
    
    foreach sort my-in-influence-links [ ask ? [set weight neighbour-weight-norm ] ] ; overwritten for out link to agent 0
    set self-weight own-weight-norm
    
    if (who = 1)[
      set head-weight-norm (1 - self-weight - (neighbour-weight-norm * number-of-neighbours))
      ]
  ]
 
  ask turtle 0 [ foreach sort my-out-influence-links [ ask ? [set weight head-weight-norm] ] ]
  ask turtle 0 [ foreach sort my-in-influence-links [ ask ? [set weight precision (epsilon / nmbr-spokes) 100] ] ]
  ask turtle 0  [ set self-weight (1 - get-in-neighbour-weights) ]

  
  ;print weights
  print-weights
end

;to setup-normalised-weights-for-ring-net
;  let number-of-neighbours 2
;  let head-weight (1 - epsilon)
;  let own-weight epsilon
;  let neighbour-weight 1 * epsilon
;  ;normalise wrt 1
;  let norm (head-weight + own-weight + (neighbour-weight * number-of-neighbours)) 
;  ;let head-weight-norm (head-weight / norm)
;  let head-weight-norm 0
;  let own-weight-norm (own-weight / norm)
;  let neighbour-weight-norm (neighbour-weight / norm)
;  
;  ask turtles [ 
;    foreach sort my-out-influence-links [ ask ? [set weight neighbour-weight-norm ] ] 
;    set self-weight own-weight-norm
;    set head-weight-norm (1 - self-weight - (neighbour-weight-norm * number-of-neighbours))
;  ]
;  
;  ask turtle 0 [ foreach sort my-out-influence-links [ ask ? [set weight head-weight-norm] ] ]
;  ask turtle 0 [ foreach sort my-in-influence-links [ ask ? [set weight precision (epsilon / (total-agents - 1)) 100] ] ]
;  ask turtle 0  [ set self-weight (1 - get-in-neighbour-weights) ]
;  
;  ask turtles [ 
;    set self-weight (1 - get-in-neighbour-weights)
;    ]
;  
;  ;print weights
;  print-weights
;end

;to setup-normalised-weights-for-ring-net-with-less-spokes [nmbr-spokes]
;  let number-of-neighbours 2
;  let head-weight (1 - epsilon)
;  let own-weight epsilon
;  let neighbour-weight epsilon
;  ;normalise wrt 1
;  let norm 0 
;  ;let head-weight-norm (head-weight / norm)
;  let head-weight-norm 0
;  
;  ask turtles [ 
;    ifelse (in-influence-link-neighbor? turtle 0)
;       [set norm (head-weight + own-weight + (neighbour-weight * number-of-neighbours))]
;       [set norm (own-weight + (neighbour-weight * number-of-neighbours))]
;    let own-weight-norm (own-weight / norm)
;    let neighbour-weight-norm (neighbour-weight / norm)
;    ;show neighbour-weight-norm
;    
;    foreach sort my-in-influence-links [ ask ? [set weight neighbour-weight-norm ] ] ; overwritten for out link to agent 0
;    set self-weight own-weight-norm
;    
;    if (who = 1)[
;      set head-weight-norm (1 - self-weight - (neighbour-weight-norm * number-of-neighbours))
;      ]
;  ]
; 
;  ask turtle 0 [ foreach sort my-out-influence-links [ ask ? [set weight head-weight-norm] ] ]
;  ask turtle 0 [ foreach sort my-in-influence-links [ ask ? [set weight precision (epsilon / nmbr-spokes) 100] ] ]
;  ask turtle 0  [ set self-weight (1 - get-in-neighbour-weights) ]
;
;  
;  ;print weights
;  print-weights
;end


;;;;;;;;;;;;;;;;;;;;;;;
;;; Main Procedure  ;;;
;;;;;;;;;;;;;;;;;;;;;;;

to go-varyAgents
  let nbAgents 0
  let increment 10
  let max-agents 100
  
  while[nbAgents < max-agents][
    set nbAgents (nbAgents + increment)
    set total-agents nbAgents
    type "nombre d'agents: " print nbAgents
    ;;call to setup network and agents
    setup
    reset-ticks
    ;;select to go-for-once-eps or go-vary-eps
    ifelse (is-vary-eps?)
       [go-varyEpsilon]
       [go-for-one-epsilon]
  ]
  stop
end

to go-varyEpsilon
  let eps 0
  let delta 0.1
  let max-epsilon 1.0;;epsilon
  while[eps < max-epsilon][
    set eps precision (eps + delta) p
    set epsilon eps
    init-agent-values
    ;setup network and weights
    setup-network
    reset-ticks
    go-for-one-epsilon
  ]
  stop
end

to go-for-one-epsilon
  
  let convergence-factor 0.00001 ; determines when to stop
  let convergence 1 ; any value bigger than the onvergence-factor
  
  while[convergence >= convergence-factor][
    type "at ticks: " type ticks print ": " ask turtle 0 [type "self-val of a0: " show self-val] ask turtle 1 [type "self-val of a1: " show self-val]
    
    ask turtles [ 
      update-in-vals  
    ]
    ask turtles[
      update-self-val
    ]
    display-labels
    
    ;eval convergence and decide whether or not to go on
    set convergence (([self-val] of turtle 0) - ([self-val] of turtle 1))
    tick
  ]
  print-results 
  type "end of test for epsilon: " print epsilon
  stop
  
    ;ifelse (convergence >= convergence-factor)
    ;  [tick]
    ; [print-results type "end :)" stop]  
end

to go
  ;;select to go-for-once-eps or go-vary-eps
  ifelse (is-vary-eps?)
       [go-varyEpsilon]
       [go-for-one-epsilon]
  stop
end

;deprecated?:
to go-once
  ;setup network and weights
  setup-network
  
  ;go
  ask turtles [
    update-in-vals 
  ]
  ask turtles[
    update-self-val
  ]
  display-labels
  show ticks ask turtle 0 [show self-val] show ticks ask turtle 1 [show self-val]
 
  ;eval convergence and decide whether or not to go on
  let convergence-factor 0.1
  let convergence (([self-val] of turtle 0) - ([self-val] of turtle 1))
  ifelse (convergence >= convergence-factor)
     [tick]
     [print-results type "end :)" stop]  
end

;;;;;;;;;;;;;;;;;;;
;;; Procedures  ;;;
;;;;;;;;;;;;;;;;;;;

; prints the final results after convergence is reached
to print-results
  ;let p 3 ; precision  --> global var
  let convergence-val (precision ([self-val] of turtle 1) p)
  let influence-report precision ((convergence-val / (head's-value - other's-value))) p
  let weight-of-ctrl-agent precision (([[weight] of in-influence-link-from turtle 0] of turtle 1)) p  ; weight of agent 0 on agent 1
  let weight-of-neighs-with-ctrl precision ([get-in-neighbour-weights] of turtle 1) p
  let weight-of-neighs-without-ctrl precision (weight-of-neighs-with-ctrl - weight-of-ctrl-agent) p
  let weight-of-neigh-and-self precision (([self-weight] of turtle 1) + weight-of-neighs-without-ctrl) p
  let weight-report-of-other precision (weight-of-ctrl-agent / weight-of-neigh-and-self) p
  let weight-of-neighs-of-ctrl precision ([get-in-neighbour-weights] of turtle 0) p ; weight of other agents on agent 0 (cotnroller)
  let weight-report-of-ctrl precision (weight-of-neighs-of-ctrl / ([self-weight] of turtle 0)) p
  
  ; print at the output console
  type "convergence value: " print convergence-val
  type "weight of agent 0 on agent 1: " print weight-of-ctrl-agent 
  type "weight of neighbours and self on agent 1: " print weight-of-neigh-and-self
  type "weight of others on agent 0: " print weight-of-neighs-of-ctrl
  type "self-weight of agent 0: " print precision ([self-weight] of turtle 0) p
  type "influence-report: " print influence-report
  type "weight-report of agent 1: " print weight-report-of-other
  type "weight-report of agent 0: " print weight-report-of-ctrl
  type "ticks: " print ticks
  
  ; print in a log file
  file-open log-file-path ; open the log file for writing (file path indicated as input)
  if print-log-header[
    file-type "number of agents: " file-type (count turtles)   
    file-print ""
    file-type "epsilon, ticks, convergence-value, weight-of-a0-on-a1, weight-of-neighs-&-self-on-a1, weight-of-others-on-a0, self-weight-of-a0, influence-report, weight-report-of-a1, weight-report-of-a0"
    file-print ""
  ]
  file-type epsilon file-type ", "
  file-type ticks file-type ", " 
  file-type convergence-val file-type ", " 
  file-type weight-of-ctrl-agent file-type ", "  
  file-type weight-of-neigh-and-self file-type ", " 
  file-type weight-of-neighs-of-ctrl file-type ", " 
  file-type precision ([self-weight] of turtle 0) p file-type ", " 
  file-type influence-report file-type ", " 
  file-type weight-report-of-other file-type ", " 
  file-type weight-report-of-ctrl file-type ", " 
  file-print ""
  file-close
end

to update-in-vals 
  ;set in-vals sum [self-val] of in-influence-link-neighbors ; my-in-influence-links 
  set in-vals 0
  let neighbor-impact 0 
  let neighbour-weight 0
  let neighbour-self-val 0
  foreach sort in-influence-link-neighbors [ 
    set neighbour-weight [weight] of (in-influence-link-from ?)
    set neighbour-self-val [self-val] of ? 
    set neighbor-impact (neighbour-self-val * neighbour-weight)
    set in-vals (in-vals + neighbor-impact) 
  ]
  ;type "agent " type [who] of self type " has in-vals: " type [in-vals] of self print ""
end

to update-self-val
  let old-self-val self-val
  set self-val (in-vals + (old-self-val * self-weight)) 
  ;type "agent " type [who] of self type " has self-val: " type [self-val] of self print ""
end

to display-labels
  ask turtles [ set label "" ]
  if show-self-value [
    ask turtles [ set label round self-val ]
  ]
end

;----------------------------------------------------------------------------------------------------------------
to setup-weight-net
  let head-weight (1 - epsilon)
  let own-weight (1 * epsilon)
  let neighbour-weight (1 * epsilon)
  let norm 0
  let number-of-neighbours 0
  ask turtles[
    set number-of-neighbours count(my-in-influence-links) 
    ifelse (in-influence-link-neighbor? turtle 0)
       [
         set norm (head-weight + own-weight + (neighbour-weight * (number-of-neighbours - 1 )))
         foreach sort my-in-influence-links [ ask ? [set weight precision (neighbour-weight / norm) 100 ] ]
         ask  turtle who [ ask in-influence-link-from turtle 0 [set weight precision (head-weight / norm) 100 ] ]                
       ]
       [
         set norm (own-weight + (neighbour-weight * number-of-neighbours))
         foreach sort my-in-influence-links [ ask ? [set weight precision (neighbour-weight / norm) 100] ]
       ]
       
  ]
  ask turtle 0 [ 
    set number-of-neighbours count(my-in-influence-links)
    foreach sort my-in-influence-links [ ask ? [set weight precision (epsilon / number-of-neighbours ) 100] ] 
  ]
  
  ask turtles [ 
    set self-weight (1 - get-in-neighbour-weights)
    show self-weight
    ]
end

;add a single edge from a node to another
to add-edge [t_from t_to]
  ask turtle t_from [ create-influence-link-to turtle t_to ]
  ask turtle t_to [ create-influence-link-to  turtle t_from ]
end 
;add multiples edges from list of nodes to another list of nodes
to add-edges [T_from T_to]
  (foreach T_from T_to
    [ add-edge ?1 ?2 ])
end

; add edges from one to multiple
to add-edges-from [t_from T_to]
  foreach T_to [add-edge t_from ?]
end 

;delete a single edge
to delete-edge [t_from t_to]
  ask turtle t_from [ ask out-influence-link-to turtle t_to [die]]
  ask turtle t_to [ ask out-influence-link-to turtle t_from [die]]
end 
;delete multiples edges from list of nodes to another list of nodes
to delete-edges [T_from T_to]
  (foreach T_from T_to
    [ delete-edge ?1 ?2 ])
end
;delete edges from one to multiple
to delete-edges-from [t_from T_to]
  foreach T_to [delete-edge t_from ?]
end
@#$#@#$#@
GRAPHICS-WINDOW
201
17
663
500
16
16
13.7
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
13
16
80
49
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
12
149
182
182
show-self-value
show-self-value
0
1
-1000

INPUTBOX
14
259
183
319
epsilon
0.9
1
0
Number

INPUTBOX
15
336
94
396
head's-value
100
1
0
Number

INPUTBOX
104
337
184
397
other's-value
0
1
0
Number

PLOT
679
17
1647
432
self values
tick
self-value
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"head agent (a0)" 1.0 0 -2674135 true "" "plot [self-val] of turtle 0"
"other agent (a1)" 1.0 0 -13345367 true "" "plot [self-val] of turtle 1"
"mid agent" 1.0 0 -7500403 true "" "let mid (total-agents / 2)\nplot [self-val] of turtle mid"

INPUTBOX
13
188
182
248
total-agents
10
1
0
Number

INPUTBOX
851
440
1424
500
log-file-path
log.txt
1
0
String

SWITCH
677
466
841
499
print-log-header
print-log-header
0
1
-1000

BUTTON
98
18
161
51
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
15
105
140
138
NIL
go-varyAgents
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
19
63
154
96
is-vary-eps?
is-vary-eps?
1
1
-1000

CHOOSER
2
408
211
453
network-type?
network-type?
"Radial Network" "Full Network" "Ring Network" "Ring Network Less Spokes"
2

INPUTBOX
10
468
165
528
total-spokes
1
1
0
Number

INPUTBOX
10
540
162
600
number-of-neighbors
0
1
0
Number

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
1
@#$#@#$#@
