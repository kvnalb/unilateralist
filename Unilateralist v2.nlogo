globals [
  true-box             ; which box actually has the prize this round ("A" or "B")
  imposed?             ; whether any agent chose to impose (open box "B")
  correct?             ; whether the imposed box was the correct one
  num-imposers         ; how many agents imposed
  nash-eqb             ; nash equilibrium confidence threshold for given group size
  rounds-won           ; count of rounds won in current iteration
  bad-impositions      ; count of bad impositions in current iteration
  good-impositions     ; count of good impositions in current iteration
  good-abstentions     ; count of good abstentions in current iteration
  missed-opportunities ; count of missed opportunities in current iteration
]

turtles-own [
  signal-strength      ; The power of the signal (always 51-100)
  signal-direction     ; Which box the signal points to ("A" or "B")
  threshold            ; confidence threshold of signal beyond which the turtle will impose
  imposer?             ; whether or not the particular agent chooses to impose
]

;;;;;;;;;;;;;;;;;;;;;;; Helper Procedures ;;;;;;;;;;;;;;;;;;;;;

; Procedure to base confidence threshold for deciding-as-usual scenario
to-report confidence-threshold [group stakes]
  let base-threshold 75.8
  let stakes-effect ifelse-value (stakes = 1.00) [4.4] [0]
  let group-effect 0.025 * (group - 3)
  report base-threshold + stakes-effect + group-effect
end

; Procerdure to report which box was chosen
to-report box-chosen [did-they-impose?]
  ifelse did-they-impose? [report "B"][report "A"]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  create-turtles group-size [
    setxy random-xcor random-ycor
    set color blue
    set imposer? false
    set shape "person"
    set size 1.5
  ]
  layout-circle turtles 15
  reset-ticks
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  ; Step 1: Reset globals and set true-box for the round

  set imposed? false
  set correct? false
  set num-imposers 0
  set nash-eqb min (list 100 (max (list 51 round (100 - (55.96 / (group-size ^ 0.73)))))) ; Power law approximation using data from Lewis et. al.
  set true-box one-of ["A" "B"]


  ; Step 2: Assign agents a threshold and private signal.

  ask turtles [

    ifelse decision-scenario != "nash-equilibrium" [
      let raw-threshold (confidence-threshold group-size reward-amount) + random-normal 0 13.5
      set threshold min (list 100 (max (list 51 round (raw-threshold)))) ; Bell curve approximation using empirical data from Lewis et. al.
    ] [
      set threshold nash-eqb
    ]

    set signal-strength (random 50) + 51
    let is-signal-correct? (random 100 < signal-strength)
    ifelse (is-signal-correct?) [
      ; The signal is truthful and points to the true box.
      set signal-direction true-box
    ] [
      ; The signal is misleading and points to the wrong box.
      ifelse (true-box = "A")
        [ set signal-direction "B" ]
        [ set signal-direction "A" ]
    ]

  ]

 ;; SCENARIO: deference-leader
  if (decision-scenario = "deference-leader") [
    ask turtles [ set imposer? false ] ; Everyone defaults to abstaining.
    ask one-of turtles [ ; One random agent is chosen as the leader.
      if (signal-direction = "B" and signal-strength >= threshold) [
        set imposer? true
      ]
    ]
  ]

  ;; SCENARIO: deference-vote
  if (decision-scenario = "deference-vote") [
    let votes-for-b count turtles with [signal-direction = "B"]
    ; The group imposes if and only if there's a majority vote.
    set imposed? (votes-for-b > (group-size / 2))
    ; For visualization, we can mark the turtles who voted for B as "imposers", even if the group choses not to impose.
    ask turtles [ set imposer? false ]
    if (imposed?) [ set num-imposers votes-for-b ]
  ]

  ;; SCENARIO: limited-imposers
  if (decision-scenario = "limited-imposers") [
    ask turtles [ set imposer? false ] ; Everyone defaults to abstaining.
    ask n-of round (fraction-active-imposers * group-size / 100) turtles [ ; A subset is chosen to be active.
      if (signal-direction = "B" and signal-strength >= threshold) [
        set imposer? true
      ]
    ]
  ]
  ; -----------------------------------------------------------------

  ; Step 4: Update globals based on turtles' choices
  ; This logic works for all scenarios except the vote, which sets 'imposed?' directly.
  if (decision-scenario != "deference-vote") [
    set imposed? any? turtles with [imposer?]
    set num-imposers count turtles with [imposer?]
  ]

  ; For visualization: Update agent colors based on their final 'imposer?' state
  ask turtles with [imposer?] [ set color orange ]
  ask turtles with [not imposer?] [ set color blue ]

  ; Step 5: Determine if correct box was chosen
  ifelse imposed? [
    if true-box = "B" [ set correct? true ]
    ] [
    if true-box = "A" [ set correct? true ]
    ]



  ;Step 6: Set result square color and update global trackers
  ask patches with [pxcor > -5 and pxcor < 5 and pycor > -5 and pycor < 5 ] [
    ifelse correct?
    [
      set pcolor green
      set rounds-won rounds-won + 1
      ifelse imposed? [set good-impositions good-impositions + 1] [set good-abstentions good-abstentions + 1]
    ] [
      set pcolor red
      ifelse imposed?[ set bad-impositions bad-impositions + 1 ] [set missed-opportunities missed-opportunities + 1]
    ]
  ]

  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
453
15
885
448
-1
-1
12.85
1
10
1
1
1
0
0
0
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

SLIDER
18
26
183
59
group-size
group-size
1
50
20.0
1
1
NIL
HORIZONTAL

CHOOSER
18
65
182
110
reward-amount
reward-amount
"0.01" "1.00"
1

BUTTON
18
208
183
241
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

BUTTON
107
251
184
284
go x100
repeat 100 [go]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
17
251
93
284
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
18
114
182
159
decision-scenario
decision-scenario
"deciding-as-usual" "nash-equilibrium" "deference-leader" "deference-vote" "limited-imposers"
3

MONITOR
234
28
323
73
True Box
true-box
17
1
11

MONITOR
343
27
437
72
Box Chosen
box-chosen imposed?
17
1
11

MONITOR
236
187
437
232
Overconfidence Rate
(count turtles with [threshold < nash-eqb] / count turtles) * 100
2
1
11

PLOT
10
299
210
449
Threshold Distribution
Threshold
Agents
50.0
100.0
0.0
5.0
true
false
"plot-pen-up" "plot-pen-down"
PENS
"default" 1.0 1 -16777216 true "" "histogram [threshold] of turtles"

PLOT
909
18
1317
212
% of Rounds Won
Ticks
% Rounds Won
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plotxy ticks rounds-won / max list 1 ticks"

PLOT
909
243
1319
448
Bad Imposition Rate
Ticks
% Bad Imposition
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plotxy ticks bad-impositions / max list 1 ticks"

PLOT
234
298
434
448
Signal Distribution
Signal
Agents
50.0
100.0
0.0
5.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [signal-strength] of turtles"

MONITOR
236
239
438
284
Average Signal of Imposers
mean [signal-strength] of turtles with [imposer?]
2
1
11

MONITOR
234
79
437
124
Nash Equilibrium Threshold
nash-eqb
2
1
11

MONITOR
235
133
437
178
Average Threshold of Agents
(precision (mean [threshold] of turtles) 1)
17
1
11

SLIDER
17
164
183
197
fraction-active-imposers
fraction-active-imposers
1
100
50.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?
This model is a high-fidelity replication of the economic game in Experiment 5 from the 2024 preprint "It Only Takes One: The Psychology of Unilateral Decisions" by Lewis et al. It demonstrates the "Unilateralist's Curse," a concept from a 2016 paper by Nick Bostrom, Thomas Douglas, and Anders Sandberg.

The curse describes a situation where a group of well-intentioned agents, each able to unilaterally trigger a significant event, will cause that event to occur more often than is optimal. This model allows users to explore this phenomenon by simulating the decisions of agents under two different behavioral strategies: a psychologically realistic one and a game-theoretically optimal one. The scope of this model is to demonstrate how the Unilateralist's Curse emerges from individual decisions and to compare the effectiveness of different decision strategies in mitigating it.
## HOW IT WORKS
The model's environment is an abstract representation of a group decision problem. There are two boxes, "A" and "B." In each round, one box is designated as the "true box" containing a reward. The group opens Box A, the default outcome, if none of the agents in the group choose to "impose" (open box B). If even one of the agents chooses to impose", the group must open box B, regardless of the decisions of the other agents. Each agent privately decides whether or not to impose based on a signal and confidence threshold.

**Agents:**
The model contains a single population of agents (`turtles`) who represent the participants in the experiment.

**Agent Properties:**
`threshold`: The agent's pre-committed confidence level (from 51-100). The agent will only act if a signal's strength meets or exceeds this value.
`signal-strength`: A value from 51 to 100 representing the strength of an agent's private signal.
`signal-direction`: The box ("A" or "B") that the agent's signal points to.
`imposer?`: A true/false state indicating whether the agent chose to open Box B in the current round.

**Order of Events and Agent Actions:**
The model follows a strict sequence in each round (`tick`):
- A `true-box is chosen randomly with a 50% chance for the round.
- Each agent independently determines its `threshold` based on the `decision-scenario` chooser.
- Each agent is given a private, independent signal composed of two parts:
A `signal-strength` is randomly drawn from the integers between 51 and 100.
This signal's probability of being correct is equal to its strength. A check is performed to determine if the signal is truthful or misleading.
Based on this accuracy check and the `true-box`, the agent is assigned a `signal-direction` of "A" or "B".
- If signal strength is greater than the threshold AND signal direction points to B, then the agent imposes. Otherwise, the agent abstains.
- If any of the agents imposes, the group outcome is Box B. Otherwise, the outcome is Box A.

## HOW TO USE IT
1.  Press the SETUP button to create the agents and reset all plots and monitors.
2.  Use the sliders and choosers to set the parameters for the simulation (`group-size`, `reward-amount`, `decision-scenario`).
3.  Press GO to run the model one round at a time.
4.  Press GO x100 to run 100 consecutive rounds to observe long-term trends.

**Interface Items:**
**Inputs:**
**`group-size` Slider**: Sets the number of agents in the model (from 2 to 100).
**`reward-amount` Chooser**: Sets the value of the prize ($0.01 or $1.00). In the `deciding-as-usual` scenario, higher stakes slightly increase agent caution.
**`decision-scenario` Chooser**: Selects the rule agents use to set their decision threshold:
deciding-as-usual - A psychologically realistic model based on empirical data from Lewis et. al.
nash-equilibrium - A game-theoretic model where thresholds rise optimally with group size.

**Monitors:**
**`True Box`**: Shows which box ("A" or "B") contains the reward in the current round.
**`Box Chosen`**: Shows which box the group ended up with based on the agents' decisions.
**`Nash Equilibrium Threshold`**: Displays the calculated optimal threshold for the current `group-size`.
**`Overconfidence Rate`**: The percentage of agents in the current round whose decision `threshold` is lower than the optimal `Nash Equilibrium Threshold`.
**`Average Signal of Imposers`**: The average `signal-strength` of only the agents who chose to impose in the current round. Displays "N/A" if no agents imposed.
**`Average Threshold of Imposers`**: The average `threshold` of only the agents who chose to impose in the current round. Displays "N/A" if no agents imposed.

**Plots:**
**`Threshold Distribution`**: A histogram showing the distribution of `threshold` values across all agents.
**`Signal Distribution`**: A histogram showing the distribution of `signal-strength` values for signals that were in favor of Box B.
**`% of Rounds Won` Plot**: A line graph tracking the cumulative percentage of rounds where the group chose the correct box.
**`Bad Imposition Rate` Plot**: A line graph tracking the cumulative percentage of rounds where Box B was imposed, but Box A was the true box.

## THINGS TO NOTICE

1.  Watch the `Bad Imposition Rate` plot when using the `deciding-as-usual` scenario. As you increase the `group-size`, the rate of erroneous impositions will rise significantly.
2.  Switch to the `nash-equilibrium` scenario. Notice how the `Bad Imposition Rate` is much lower and more stable, even at large group sizes. This is because the agents' thresholds adapt to the risk.
3.  In the `deciding-as-usual` scenario, the `Overconfidence Rate` will often be very high, especially at large group sizes, showing how far from optimal the naive strategy is. In the `nash-equilibrium` scenario, this rate is always 0%.

## THINGS TO TRY

1.  Run a controlled experiment. Set the `decision-scenario` to `deciding-as-usual` and `group-size` to 5. Run it for 100+ ticks with `go x100` and note the final `% of Rounds Won`. Now, reset, set `group-size` to 50, and run again. How much does the success rate drop?
2.  Repeat the experiment above, but using the `nash-equilibrium` scenario. Notice how the success rate is much more stable, demonstrating how rational caution lifts the curse.
3.  Set the `group-size` to 40. Switch the `reward-amount` between $0.01 and $1.00. In the `deciding-as-usual` scenario, this has a small effect on behavior. In the `nash-equilibrium` scenario, it has no effect on the threshold, because the optimal strategy depends on probabilities, not the stakes.

## EXTENDING THE MODEL

1.  **Moral Deference by Leader:** Add a third decision scenario. In it, one agent is randomly chosen as the "leader" each round. Only the leader evaluates its signal; all others automatically abstain. This models a solution where the group solves the curse by delegating authority.
2.  **Moral Deference by Vote:** Add a fourth scenario where the group's choice is determined by a majority vote based on each agent's `signal-direction`. This models a procedural solution that leverages the wisdom of the crowd.
3.  **Limit the Number of Imposers:** One of the key interventions suggested in Lewis et al. is to structurally limit the number of potential imposers. Add a slider that controls how many of the agents are randomly selected each round to be "active" (capable of imposing). All others are "inactive" and cannot impose.

## NETLOGO FEATURES

The plotting pen commands use the `max list 1 ticks` structure for denominators to prevent division-by-zero errors at `tick 0`, ensuring a clean user interface.

## RELATED MODELS

Models in the NetLogo Models Library that explore related concepts include:
**Voting:** Explores how different voting procedures aggregate individual preferences.
**El Farol:** Demonstrates how individuals trying to predict group behavior can lead to unexpected emergent dynamics.

## CREDITS AND REFERENCES

This model is a faithful implementation of the economic game described in the following works:
1.  **Source Experiment:** Lewis, J., Allen, C., Winter, C., & Caviola, L. (2024). *It Only Takes One: The Psychology of Unilateral Decisions*. [Preprint].
2.  **Core Concept:** Bostrom, N., Douglas, T., & Sandberg, A. (2016). The Unilateralist's Curse and the Case for a Principle of Conformity. *Social Epistemology*, 30(4), 350-371.

This NetLogo model was created by Kunal Baldava in July 2025, as part of the Introduction to Agent Based Modeling Course by The SantaFe Institute. It is also available at https://github.com/Kunalongithub/unilateralist

MIT License Copyright (c) 2025 Kunal Baldava
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
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Win Rate - All Params" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>repeat 100 [go]</go>
    <exitCondition>ticks = 100</exitCondition>
    <metric>rounds-won / max list 1 ticks</metric>
    <metric>bad-impositions / max list 1 ticks</metric>
    <enumeratedValueSet variable="decision-scenario">
      <value value="&quot;deciding-as-usual&quot;"/>
      <value value="&quot;nash-equilibrium&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="group-size" first="1" step="1" last="50"/>
    <enumeratedValueSet variable="reward-amount">
      <value value="&quot;1.00&quot;"/>
      <value value="&quot;0.01&quot;"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
0
@#$#@#$#@
