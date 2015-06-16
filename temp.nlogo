;-----------------------------------
;---     GLOBAL DEFINITIONS      ---
;-----------------------------------

directed-link-breed [influence-links influence-link]

turtles-own [
  
  ; value representing an agents opinion
  self-val
  
  ; sum of in values
  in-vals
  
  ; sum of out values
  out-val
  
  ; social capital
  self-weight 
  soc-capital
  
  ; a number representing the group this turtle is a member of, or -1 if this turtle is not in a group.
  my-group
  group
  group-size

] ; a node's self value, aggregate in value, out value and social capital value 

;; only use self-val in-vals self-weight
;; where is my-out-influence-links (builtin macro!) --> directed-link-bread
links-own [ weight ]  ; the strength of the influence of the from (out) agent on the to (in) agent -- future: can be calculated as a difference between the strengths of the respective agents

patches-own [ belongs-to ]

globals [
  p
  new-node  ;; the last node we created
  degrees   ;; this is an array that contains each node in
            ;; proportion to its degree
  group-ids 
  total-agents
] ; global variables
 


;-----------------------------------
;---            SETUP            ---
;-----------------------------------

to create-edit-topology [group-id]
  if (group-id = 0) [user-message "ERROR: Please choose a group number differs than 0" stop]
  
  if (not is-list? group-ids) [ set group-ids [] setup-region ]
  
  ifelse (not member? group-id group-ids) [
    
    set total-agents total-agents + number-of-agents
    
    ifelse network-type? = "Scale-free Network" [
      ifelse (num-edges >= number-of-agents or num-edges = 0)
        [user-message "Number of edges must be less than total-agents" stop]
        [
          type "Scale-free group: " print group-id 
          setup-custom-scale-free-network group-id 
          type "g-list: " print group-ids
        ]
    ]
    [
      create-turtles number-of-agents [ set my-group group-id ]
      if network-type? = "Radial Network" [
        type "Radial group: " print group-id
        let radialSet turtles with [my-group = group-id]
        setup-custom-radial-network radialSet
      ]
      if network-type? = "Random Network" [
        type "Random group: " print group-id
        let randomSet turtles with [my-group = group-id]
        setup-custom-random-network randomSet
      ]
      if network-type? = "Full Network" [
        type "Full group: " print group-id
        let fullSet turtles with [my-group = group-id]
        setup-custom-full-network fullSet
      ]
      if network-type? = "Ring Network" [
        type "Ring Network group: " print group-id
        let ringSet turtles with [my-group = group-id]
        setup-custom-ring-network ringSet 
      ]
      if network-type? = "Ring Network Less Spokes" [
        type "Ring Network Less Spokes group: " print group-id
        let spokesSet turtles with [my-group = group-id]
        setup-custom-ring-less-spokes-network spokesSet 
      ]
    ]
  
    set p 2
    
    display-labels
    reset-ticks
    set group-ids lput group-id group-ids
    setup-weight-net
    check-weights
  ]
  [user-message "ERROR: Group ID has already existed!" stop]
  
end


to setup
  clear-all
  
  ifelse network-type? = "Scale-free Network" [
    ifelse (num-edges >= number-of-agents or num-edges = 0)
       [user-message "Number of edges must be less than total-agents" stop]
       [
         setup-scale-free-network
         check-weights
       ]
  ]
  [
    ;; set shapes
    set-default-shape turtles "circle"
  
    ;; setup agents
    setup-agents
  
    ;; setup network
    setup-network
  ]
  
  set p 2
  
  display-labels
  reset-ticks
end

to setup-agents
  ; create agents
  create-turtles number-of-agents [ set color blue ]
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
    ifelse (total-spokes >= number-of-agents)
       [user-message "Number of spokes must be less than total-agents" stop]
       [setup-ring-network-less-spokes]
  ]
  if network-type? = "Random Network" [
    setup-random-network
  ]
  ;;check in-weights
  check-weights
end

to setup-scale-free-network
  ca
  set degrees []   ;; initialize the array to be empty
  ;; make the initial network of two nodes and an edge
  set-default-shape turtles "circle"
  ;; make the initial network of two nodes and an edge
  make-node -1 ;; first node, group 0
  let first-node new-node
  let prev-node new-node
  repeat num-edges [
    make-node -1 ;; second node
    make-edge new-node prev-node ;; make the edge
    set degrees lput prev-node degrees
    set degrees lput new-node degrees
    set prev-node new-node
  ]
  make-edge new-node first-node
  ask first-node [
    set self-val head's-value
    set color red
  ]

  while [count turtles < total-agents] [
    make-node -1 ;; add one new node
    
    ;; it's going to have m edges
    repeat num-edges [
      let partner find-partner new-node -1     ;; find a partner for the new node
      ;ask partner [set color blue]    ;; set color of partner to gray
      make-edge new-node partner     ;; connect it to the partner we picked before
    ]
  ]

  setup-weight-net
end

to setup-random-network
  ;setup layout
  layout-circle (sort turtles) max-pxcor - 1
  
  ;; Simple random network
;  while [(2 * count links ) <= ( (count turtles) * (count turtles - 1) )] [
;    ;; Note that if the link already exists, nothing happens
;    ask one-of turtles [ create-influence-link-to one-of other turtles ]
;  ]
   
   ;; Create a random network with a probability p of creating edges
   ask turtles [
      ;; we use "self > myself" here so that each pair of turtles
      ;; is only considered once and to avoid link to itself
      create-influence-links-to turtles with [self > myself and
        random-float 1.0 < random-probability]
      create-influence-links-from turtles with [self > myself and
        random-float 1.0 < random-probability]
   ]
   
   ;;set weight values
   setup-weight-net
end
  
to setup-radial-network
  ; create links in both directions between turtle 0 and all other turtles
  ask turtle 0 [ create-influence-links-to other turtles ]
  ask turtle 0 [ create-influence-links-from other turtles ]
  ;type "created " type count influence-links print " influence-links"
  ; do a radial tree layout, centered on turtle 0
  layout-radial turtles influence-links (turtle 0)
  
  ; set weight values
  setup-weight-net
end

to setup-full-network
  ; create links in both directions between all pairs of turtles
  foreach sort turtles[
    ask ? [ create-influence-links-to other turtles ]
  ]
  
  ;set weights
  setup-weight-net
  
  ;;set layout
  layout-circle turtles with [who > 0 ] 8 ;layout-circle agentset radius ;; layout-circle list-of-turtles radius
  ask turtle 0[ set xcor 0 set ycor 0]
end

to setup-ring-network
  
  if (number-of-neighbors > number-of-agents - 2) or (number-of-neighbors mod 2 != 0) or (number-of-neighbors <= 0)  [ user-message "ERROR: Number of neighbors must be less than number of agents or number of agent must be divisible by 2" stop]
  
  ; create links in both directions between all neighbours of turtles => ring; except turtle 0 (the control agent)
  setup-ring-no-spokes

  ask turtle 0 [
    create-influence-links-to other turtles
    create-influence-links-from other turtles
  ]
  
  ;set layout
  layout-circle sort turtles with [who > 0 ] 8 ;layout-circle agentset radius ;; layout-circle list-of-turtles radius
  ask turtle 0[ set xcor 0 set ycor 0]
  
  ;set weights
  setup-weight-net  
end

to setup-ring-network-less-spokes
  ; create links in both directions between all neighbours of turtles => ring; except turtle 0 (the control agent)
  setup-ring-no-spokes
  
  ; set links
  let nmbr-spokes total-spokes
  let other-who 1
  let delta round(number-of-agents / nmbr-spokes)
  if(delta = 0)[set delta 1]
  let counter 1 
  while [other-who < number-of-agents and counter <= total-spokes][
    ask turtle 0[
      create-influence-link-to turtle other-who
      create-influence-link-from turtle other-who
      set other-who (other-who + delta)
      set counter (counter + 1)
    ]
  ]

 ; set links   
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
        if (left-agent-who = 0)[set left-agent-who (number-of-agents - 1)]
        if(right-agent-who = number-of-agents)[set right-agent-who 1]
        create-influence-link-to turtle right-agent-who 
        create-influence-link-to turtle left-agent-who
      ]
    ]
  ]
  
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


;-----------------------------------
;---         SIMULATION          ---
;-----------------------------------

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
  ifelse network-type? = "Random Network" [
    print-results-for-random
  ]
  [ print-results ]
  type "end of test for epsilon: " print epsilon
  stop 
end

to go
  ;;select to go-for-once-eps or go-vary-eps
  ifelse (is-vary-eps?)
       [go-varyEpsilon]
       [go-for-one-epsilon]
  stop
end

;-----------------------------------
;---     SIMULATION RESULTS      ---
;-----------------------------------

to print-results-for-random
  let convergence-val (precision ([self-val] of turtle 1) p)
  let influence-report precision ((convergence-val / (head's-value - other's-value))) p
  
  type "convergence value: " print convergence-val
  type "self-weight of agent 0: " print precision ([self-weight] of turtle 0) p
  type "influence-report: " print influence-report
  type "ticks: " print ticks
  
  ; print in a log file
  file-open log-file-path ; open the log file for writing (file path indicated as input)
  if print-log-header[
    file-type "number of agents: " file-type (count turtles)   
    file-print ""
    file-type "epsilon, ticks, convergence-value, influence-report"
    file-print ""
  ]
  file-type epsilon file-type ", "
  file-type ticks file-type ", " 
  file-type convergence-val file-type ", "
  file-type influence-report file-type ", " 
  file-print ""
  file-close
end

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

;-----------------------------------
;---    AUXILIARY PROCEDURES     ---
;-----------------------------------

to setup-region
 ask patches [set belongs-to nobody]
 ;ask patches [ set pcolor 3 ]
end

to setup-custom-agents [nbOfAgents]
  ;; set shapes
  set-default-shape turtles "circle"
  ;; create agents
  create-turtles nbOfAgents [ set color blue ]
  ;; all turtles are initially ungrouped
  ask turtles [ set my-group -1 ]
end

to setup-central-agent [ setOfAgents centralAgent ]
  ask centralAgent [ set color red set group-size count setOfAgents]
  ask centralAgent [ 
    move-to one-of patches with [not any? other patches in-radius 5 with [belongs-to != nobody]] 
    set group patches in-radius group-size
    ask group [set belongs-to myself]
  ]
  ;move-to-agent setOfAgents centralAgent
  ; init self values
  init-custom-agent-values setOfAgents centralAgent
end

to move-central-agent [centralAgent]
  ask centralAgent [ 
    move-to one-of patches with [not any? other patches in-radius 5 with [belongs-to != nobody or belongs-to = centralAgent]] 
    set group patches in-radius group-size
    ask group [set belongs-to myself]
  ]
end

to move-to-agent [setOfAgents centralAgent]
  type "center node: " print centralAgent
  let delta 1
  foreach sort setOfAgents [
    if ( ? != centralAgent ) [
      type "move..." print ?
      ask ? [
        let x-cor xcor + [xcor] of centralAgent
        let y-cor ycor + [ycor] of centralAgent
        while [x-cor > max-pxcor] [set x-cor x-cor - delta]
        while [x-cor < min-pxcor] [set x-cor x-cor + delta]
        while [y-cor > max-pycor] [set y-cor y-cor - delta]
        while [y-cor < min-pycor] [set y-cor y-cor + delta]
        setxy x-cor y-cor
        ;setxy (xcor + [xcor] of centralAgent) (ycor + [ycor] of centralAgent)
      ]
      ;move-to centralAgent
      ;move-to one-of patches with [not any? turtles-here and belongs-to = centralAgent]
    ]
  ]
end

to init-custom-agent-values [setOfAgents centralAgent]
  ; init self values
  ask setOfAgents with [ who != centralAgent ] [ set self-val other's-value set color blue ]
  ask one-of setOfAgents with [ who != centralAgent ] [type "--> set self-val of turtle 1..N to: " type [self-val] of turtle who print ""]
  ask centralAgent [ set self-val head's-value set color red ]
  type "--> set self-val of turtle " type [who] of centralAgent type " : " type [self-val] of centralAgent print ""
end

;to-report get-home ;; turtle procedure
;  ;; calculate the minimum length of each side of our grid
;  let side ceiling (sqrt (max [my-group] of turtles + 1))
;
;  report patch
;           ;; compute the x coordinate
;           (round ((world-width / side) * (my-group mod side)
;             + min-pxcor + int (world-width / (side * 2))))
;           ;; compute the y coordinate
;           (round ((world-height / side) * int (my-group / side)
;             + min-pycor + int (world-height / (side * 2))))
;end

to setup-multiple-networks
  let counter 1
;  if Radial-Network? [set counter counter + 1 ]
;  if Random-Network? [set counter counter + 1 ]
;  if Full-Network? [set counter counter + 1 ]
;  if Ring-Less-Spokes? [set counter counter + 1 ]
  
  ; set total number of agents to create
  let nbOfAgents 10 ;number-of-agents
  set total-agents nbOfAgents * counter
  if total-agents = 0 [
    user-message "Total-agents must be bigger than 0"
    stop
  ]
  type "total-agents: " print total-agents
  
  clear-all
  setup-region
  ;; setup agents
  setup-custom-agents total-agents
  
  let unassigned turtles
  ;; start with group 0 and loop to build each group
  let current 0
  while [any? unassigned and current < counter]
  [
    ;; place a randomly chosen set of group-size turtles into the current
    ;; group. or, if there are less than group-size turtles left, place the
    ;; rest of the turtles in the current group.
    ask n-of (min sort (list nbOfAgents (count unassigned))) unassigned
      [ set my-group current ]
    ;ask n-of (min (list nbOfAgents (count unassigned))) patches [ sprout 1 ]
    ;; consider the next group.
    set current current + 1
    ;; remove grouped turtles from the pool of turtles to assign
    set unassigned unassigned with [my-group = -1]
  ]
  
  ;ask turtles [type "Turtle " type who type ": " print my-group print ""]
  ;; if i'm in a group, move towards "home" for my group
;  ask turtles [
;    if my-group != -1
;      [ face get-home ]
;  ]
  
;  if Radial-Network? [
;    ;set radialSet n-of nbOfAgents turtles
;    set current current - 1
;    let radialGroup current
;    type "Radial group: " print radialGroup
;    let radialSet turtles with [my-group = radialGroup]
;    ;print radialSet
;    setup-custom-radial-network radialSet
;  ]
;  if Random-Network? [
;    ;set randomSet n-of nbOfAgents turtles
;    set current current - 1
;    let randomGroup current
;    type "Random group: " print randomGroup
;    let randomSet turtles with [my-group = randomGroup]
;    ;print randomSet
;    setup-custom-random-network randomSet
;  ]
;  if Full-Network? [
;    set current current - 1
;    let fullGroup current
;    type "Full group: " print fullGroup
;    let fullSet turtles with [my-group = fullGroup]
;    ;print fullSet
;    setup-custom-full-network fullSet
;  ]
  ;if Ring-Less-Spokes? [
    set current current - 1
    let spokesGroup current
    type "RingLessSpokes group: " print spokesGroup
    let spokesSet turtles with [my-group = spokesGroup]
    ;print spokesSet
    setup-custom-ring-less-spokes-network spokesSet 
  ;]
  
  set p 2
  
  display-labels
  reset-ticks
end

to setup-custom-scale-free-network [group-id]
  set degrees []   ;; initialize the array to be empty
  ;; make the initial network of two nodes and an edge
  set-default-shape turtles "circle"
  ;; make the initial network of two nodes and an edge
  make-node group-id ;; first node
  let first-node new-node
  let prev-node new-node
  repeat num-edges [
    make-node group-id ;; second node
    make-edge new-node prev-node ;; make the edge
    set degrees lput prev-node degrees
    set degrees lput new-node degrees
    set prev-node new-node
  ]
  make-edge new-node first-node
  ask first-node [
    set self-val head's-value
    set color red
  ]

  while [count turtles with [my-group = group-id] < number-of-agents] [
    make-node group-id  ;; add one new node
    
    ;; it's going to have m edges
    repeat num-edges [
      let partner find-partner new-node group-id     ;; find a partner for the new node
      ;ask partner [set color blue]    ;; set color of partner to gray
      make-edge new-node partner     ;; connect it to the partner we picked before
    ]
  ]

  let setOfAgents turtles with [my-group = group-id]
  layout-circle (sort setOfAgents) 5
  ;move-to-agent setOfAgents first-node
end

to setup-custom-ring-no-spokes [setOfAgents centralAgent startIndex]

  let maxIndex (startIndex + count setOfAgents)
  ; create links in both directions between all neighbours of turtles => ring; except turtle 0 (the control agent)
  foreach sort setOfAgents[
    let agent-who ([who] of ?)
    let left-agent-who (agent-who - 1)
    let right-agent-who (agent-who + 1)
    ask ?[  
      if(agent-who != ([who] of centralAgent))[
        if (left-agent-who < startIndex) [set left-agent-who startIndex]
        ;if (left-agent-who = startIndex) [set left-agent-who maxIndex - 1]
        if (right-agent-who = maxIndex) [set right-agent-who startIndex]
        if (right-agent-who != agent-who) [ create-influence-link-to turtle right-agent-who ]
        if (left-agent-who != agent-who) [ create-influence-link-to turtle left-agent-who ]
      ]
    ]
  ]
  ; remove redundant links
  let node-left nobody
  let node-right nobody
  ask centralAgent [
    ask my-in-influence-links [
      ifelse (node-left = nobody) [ set node-left [who] of end1 ] [ set node-right [who] of end1 ]
       die
    ]
  ]
  if (node-left != nobody and node-right != nobody) [
    ask turtle node-left[
      create-influence-link-to turtle node-right
      create-influence-link-from turtle node-right
    ]
  ]
end

to setup-custom-ring-network [ringSet]
  let network-size count ringSet
  if (number-of-neighbors > network-size - 2) or (number-of-neighbors mod 2 != 0) or (number-of-neighbors <= 0)  [ user-message "ERROR: Number of neighbors must be less than number of agents or number of agent must be divisible by 2" stop]
  
  ;; choose a random node and set it as central node
  let startIndex (total-agents - network-size)
  let centralAgent turtle startIndex
  setup-central-agent ringSet centralAgent
  
  ; create links in both directions between all neighbours of turtles => ring; except turtle 0 (the control agent)
  setup-custom-ring-no-spokes ringSet centralAgent startIndex
  
  ask centralAgent [
    create-influence-links-to other ringSet
    create-influence-links-from other ringSet
  ]
  
  ;set layout
  layout-circle sort ringSet with [who > startIndex ] 5 ;layout-circle agentset radius ;; layout-circle list-of-turtles radius
  move-to-agent ringSet centralAgent
  
  ;set weights
  setup-weight-net  
  
end

to setup-custom-ring-less-spokes-network [spokesSet]
  let network-size count spokesSet
  let startIndex (total-agents - network-size)
  ;; choose a random node and set it as central node
  let centralAgent turtle startIndex
  setup-central-agent spokesSet centralAgent
  
  ;; create links in both directions between all neighbours of turtles => ring; except turtle 0 (the control agent)
  setup-custom-ring-no-spokes spokesSet centralAgent startIndex
  
;  ; set links
;  let nmbr-spokes total-spokes
;  let nbAgents (count spokesSet)
;  let other-who [who] of (one-of spokesSet with [who != ([who] of centralAgent)])
;  let delta round(nbAgents / nmbr-spokes)
;  if(delta = 0)[set delta 1]
;  let counter 1 
;  while [other-who < maxIndex and counter <= total-spokes][
;    if (other-who != ([who] of centralAgent)) [
;      ask centralAgent[   
;        create-influence-link-to turtle other-who
;        create-influence-link-from turtle other-who
;        set other-who (other-who + delta)
;        set counter (counter + 1)
;      ]
;    ]
;  ]

 ; set links   
 let counter count([my-out-influence-links] of centralAgent)
  while [counter < total-spokes][
    let agent-who [who] of (one-of spokesSet with [who != ([who] of centralAgent)])
    if (agent-who > ([who] of centralAgent))[
      ask centralAgent[
        create-influence-link-to turtle agent-who
        create-influence-link-from turtle agent-who
      ]
      set counter count([my-out-influence-links] of centralAgent)
    ]
  ]
  
  ;set layout
  layout-circle sort spokesSet with [who != ([who] of centralAgent) ] 5 ;layout-circle agentset radius ;; layout-circle list-of-turtles radius
  
  ;set weights
  setup-weight-net
  move-to-agent spokesSet centralAgent
end

to setup-custom-full-network [setOfAgents]
  ;; setup layout
  layout-circle (sort setOfAgents) 5
  
  ;; choose a random node and set it as central node
  let agent-who one-of setOfAgents
  setup-central-agent setOfAgents agent-who
  
  ; create links in both directions between all pairs of turtles
  foreach sort setOfAgents[
    ask ? [ create-influence-links-to other setOfAgents ]
  ]
  
  ;set weights
  setup-weight-net
  
  move-to-agent setOfAgents agent-who
end

to setup-custom-random-network [setOfAgents]
  ;; setup layout
  layout-circle (sort setOfAgents) 5
  
  ;; choose a random node and set it as central node
  let agent-who one-of setOfAgents
  setup-central-agent setOfAgents agent-who
   
  ;; Create a random network with a probability p of creating edges
  ask setOfAgents [
      ;; we use "self > myself" here so that each pair of turtles
      ;; is only considered once and to avoid link to itself
      create-influence-links-to setOfAgents with [self > myself and
        random-float 1.0 < random-probability]
      create-influence-links-from setOfAgents with [self > myself and
        random-float 1.0 < random-probability]
   ]
  move-to-agent setOfAgents agent-who
end

to setup-custom-radial-network [setOfAgents]
  ;; setup layout
  layout-circle (sort setOfAgents) 5
  
  ;; choose a random node and set it as central node
  let agent-who one-of setOfAgents
  setup-central-agent setOfAgents agent-who 
 
  ;; create links in both directions between turtle 0 and all other turtles
  ask agent-who [ create-influence-links-to other setOfAgents ]
  ask agent-who [ create-influence-links-from other setOfAgents ]
  ;type "created " type count influence-links print " influence-links"
  ;; do a radial tree layout, centered on turtle 0
  ask agent-who [ 
    move-to one-of group
  ]
  ;; setup layout
  ;layout-radial setOfAgents influence-links (agent-who)
  move-to-agent setOfAgents agent-who
end

to-report find-partner [node1 group-id]
  ;; set a local variable called ispref that
  ;; determines if this link is going to be
  ;; preferential of not
  let ispref (random-float 1 >= gamma)
  
  ;; initialize partner to be the node itself
  ;; this will have to be changed
  let partner node1
  
  ;; if preferential attachment then choose
  ;; from our degrees array
  ;; otherwise chose one of the turtles at random

  ifelse ispref 
  [ set partner one-of degrees ]
  [ set partner one-of turtles with [my-group = group-id] ]
     
   ;; but need to check that partner chosen isn't
   ;; the node itself and also isn't a node that
   ;; our node is already connected to
   ;; if this is the case, it will try another
   ;; partner and try again
  let checkit true
  while [checkit] [
    ask partner [
      ifelse ((link-neighbor? node1) or (partner = node1))
        [
          ifelse ispref 
          [
            set partner one-of degrees
           ]
           [
             set partner one-of turtles with [my-group = group-id]
           ]
            set checkit true
         ]
         [
           set checkit false
         ]
       ] 
    ]
  report partner
end

;; used for creating a new node
to make-node [group-id]
  crt 1
  [
    set color blue
    set self-val other's-value
    set my-group group-id
    set new-node self ;; set the new-node global    
  ]
end

;; create link between two node
;; input by turle id
to create-edge [id1 id2]
  let node1 turtle id1
  let node2 turtle id2
  ask node1 [
    ifelse (node1 = node2) 
    [
      show "error: self-loop attempted"
    ]
    [
      create-influence-link-to node2
      create-influence-link-from node2
    ]
  ]
end

;; connect two nodes from different networks
to connect-network [id1 id2]
  let node1 turtle id1
  let node2 turtle id2
  ask node1 [
    ifelse (my-group != ([my-group] of node2) and node1 != node2) [
        create-influence-link-to node2
        create-influence-link-from node2
    ]
    [
      show "error: self-loop attempted"
    ]
  ]
end

;; connects the two nodes (turle)
to make-edge [node1 node2]
  ask node1 [
    ifelse (node1 = node2) 
    [
      show "error: self-loop attempted"
    ]
    [
      create-influence-link-to node2
      create-influence-link-from node2
      ;; position the new node near its partner
      ;setxy ([xcor] of node2) ([ycor] of node2)
      move-to node1
      fd 8
      set degrees lput node1 degrees
      set degrees lput node2 degrees
     ]
  ]
end

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

;loads a topology from a file
to load-file [file-name]
  
  file-open file-name
  
  clear-all
 
  ; create agents
  create-turtles total-agents [ set color blue ]
  
  ;; set shapes
  set-default-shape turtles "circle"
  
  set epsilon read-from-string file-read-line
  
  let total-clusters read-from-string file-read-line
  
  let cluster-centers (list turtle 0)
  
  let cluster-size read-from-string file-read-line
  let turtle-index cluster-size
  let cluster-sizes (list cluster-size)
  
  let cluster 1
  
  while [cluster < total-clusters] [
    set cluster-size read-from-string file-read-line
    set cluster-centers lput (turtle turtle-index) cluster-centers
    set cluster-sizes lput cluster-size cluster-sizes
    set turtle-index turtle-index + cluster-size
    set cluster cluster + 1
  ]
    
  set total-agents turtle-index
  set turtle-index 0
  set cluster 0
 
  let i 0
  let j 0
  let link-exists "0"
  
  layout-circle cluster-centers 12
  foreach cluster-centers [ ask ? [ set color red ]]
    
  while [cluster < total-clusters] [
    
    set cluster-size item cluster cluster-sizes
    
    layout-circle sort turtles with [who > turtle-index and who < turtle-index + cluster-size] 4
      
    ask turtles with [who > turtle-index and who < turtle-index + cluster-size] [
      setxy (xcor + [xcor] of turtle turtle-index) (ycor + [ycor] of turtle turtle-index)  
    ]
    
    set i 0
    while [i < cluster-size] [
      set j 0
      while [j < cluster-size] [
        set link-exists file-read-characters 1
        if (link-exists = "1" and i != j) [
          ask turtle (i + turtle-index) [ create-influence-link-to turtle (j + turtle-index) ]
        ]
        if (not file-at-end?) [ set link-exists file-read-characters 1 ]
        set j (j + 1) 
      ]
      set i (i + 1) 
    ]
    set cluster cluster + 1
    set turtle-index turtle-index + cluster-size
  ]
  
  file-close
  
  setup-weight-net
  
  set p 2
  display-labels
  reset-ticks
  
end

to save-file [file-name]
    
  file-open user-new-file
  
  file-print total-agents
  file-print epsilon
  
  let i 0
  let j 0
  
  while [i < total-agents] [
    set j 0
    while [j < total-agents] [
      let node-link [in-influence-link-from turtle j] of turtle i
      file-type ifelse-value (node-link = nobody) [ "0" ] [ "1" ]
      ifelse (j = total-agents - 1) [ file-print "" ] [ file-type " " ]
      set j (j + 1) 
    ]
    set i (i + 1) 
  ]
  
  file-close
  
end