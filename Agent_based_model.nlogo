globals [
  A                      ;; technology
  A-old                  ;; technology in the last period for calculating technological progress
  A-growth               ;; technological progress
  N                      ;; population
  average-delta          ;; average innovative potential of the population
  average-delta-old      ;; innovative potential in the last period for calculating growth rate
  average-delta-growth   ;; innovative potential growth rate
  w                      ;; wage
  Y                      ;; total income
  Y-old                  ;; total income in the last period for calculating growth rate
  Y-growth               ;; total income growth rate
  average-z              ;; average income
  malthusian-limit       ;; population at equilibrium for a given level of technology
  subsistence            ;; subsistence income at the Malthusian limit
  c                      ;; proportion of subsistence income that must be used on self (rest available for children)
  alpha                  ;; labour share
  v                      ;; mutation rate - set by slider mutation-rate
  m                      ;; mutation increment - set by slider mutation-increment
  pheta                  ;; parameter for fishing out mutations
  phi                    ;; parameter for fishing out ideas
  lambda                 ;; parameter for network effects
  ]

turtles-own [
  delta                  ;; innovative potential
  z                      ;; turtle income
  children               ;; expected number of children for a turtle
  age                    ;; use for mechanism to kill off turtles after one generation
  ]

to setup
   clear-all
   setup-turtles
   set alpha labour-share
   set v mutation-rate
   set m mutation-increment
   set pheta fishing-out-mutations
   set phi fishing-out-A
   set lambda network-effects
   set A 1                                                                 ;; set technology to 1
   set average-delta initial-innovative-potential                          ;; to give non-zero initial value for plot
   set average-z A * number ^ (alpha - 1) * average-delta ^ alpha          ;; to give non-zero initial value for plot of logarithms equal to subsistence
   set Y average-z * number
   set subsistence A * (number ^ (alpha - 1)) * (average-delta ^ alpha)    ;; to set subsistence such that users can select any initial number of turtles
   set c subsistence-self                                                  ;; use slider to set proportion of income that must be used on self (rest available for children)
   reset-ticks
end

to setup-turtles
  create-turtles number
  ask turtles [
    setxy random-xcor random-ycor
    set delta initial-innovative-potential
  ]
end

to go
  if N >= 100000 [
    stop                       ;; stop population getting too large and hanging simulation
    ]
  if ticks >= number-of-ticks [
    stop                       ;; stop after a certain number of ticks
    ]
  work
  innovate
  reproduce
  tick
end

to work
  set average-delta-old average-delta
  set average-delta mean [delta] of turtles
  set average-delta-growth average-delta / average-delta-old - 1
  set N count turtles
  ifelse productivity?
  [set w A * ((average-delta * N) ^ (alpha - 1))
    set malthusian-limit (subsistence / (A * average-delta ^ alpha)) ^ (1 / (alpha - 1))]
  [set w A * (N ^ (alpha - 1))
    set malthusian-limit (subsistence / A) ^ (1 / (alpha - 1))]
  ask turtles [
    ifelse productivity?
    [set z delta * w]
    [set z w]
    set age 1                                                 ;; age turtles so can kill off at end of generation
  ]
  set Y-old Y
  set Y sum [z] of turtles
  set Y-growth Y / Y-old - 1
  set average-z Y / N
end

to innovate
    set A-old A
    set A A + (A ^ phi) * ((average-delta * N) ^ lambda)
    set A-growth A / A-old - 1
end

to reproduce
  ask turtles [
    set children malthusian-limit * (z - c * subsistence) / (Y - c * subsistence * N)
    hatch random-poisson children [                           ;; number of children of each turtle is given by a Poisson distribution
      set age 0
      setxy random-xcor random-ycor
      if evolution? [                                         ;; ability to turn off evolution to allow simulation of Kremer model
        if (2 * v * 1000000000) > random 1000000000 [         ;; set innovative potential of turtles of next generation - mutation rate of 2v
          ifelse 1 = random 2                                 ;; one in two chance that mutation is either positive or negative
          [set delta delta + (m * delta ^ pheta)]                         ;; positive mutation if random 2 = 1
          [set delta delta - (m * delta ^ pheta)]                         ;; negative mutation if random 2 = 0
        ]   
      ]
    ]
    if age = 1 [die]                                          ;; kills off turtles from the last generation
    if delta <= 0 [die]                                       ;; kills of turtles where innovative potential has mutated to zero or below in no productivity simulation
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
209
12
454
216
16
16
5.242424242424242
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
0
0
1
ticks
30.0

BUTTON
27
11
82
44
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
87
11
142
44
NIL
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
27
59
107
104
population
count turtles
17
1
11

PLOT
404
12
809
325
Totals
time
totals (log)
0.0
10.0
0.0
3.0
true
true
"" ";; plots are normalised to an initial value of one"
PENS
"N" 1.0 0 -16777216 true "" "plot log (count turtles / number) 10"
"A" 1.0 0 -7500403 true "" "plot log (A) 10"
"Average z" 1.0 0 -2674135 true "" "plot log (average-z / subsistence) 10"
"Y" 1.0 0 -955883 true "" "plot log (Y / (number * subsistence)) 10"

SLIDER
18
149
207
182
number-of-ticks
number-of-ticks
0
1000000
40000
1000
1
NIL
HORIZONTAL

SLIDER
18
222
298
255
initial-innovative-potential
initial-innovative-potential
0
1.0E-7
1.0E-8
1.0E-9
1
NIL
HORIZONTAL

SLIDER
18
113
207
146
number
number
0
1000
1000
50
1
NIL
HORIZONTAL

SLIDER
18
260
207
293
mutation-rate
mutation-rate
0
1.0E-5
1.0E-6
1.0E-7
1
NIL
HORIZONTAL

PLOT
824
337
1191
584
Histogram of innovative potential
q
number
0.0
20.0
0.0
1000.0
true
false
"set-plot-y-range 0 count turtles\nset-histogram-num-bars 50\nset-plot-pen-interval 0.1" ""
PENS
"quality" 1.0 1 -16777216 true "" "histogram [delta / initial-innovative-potential] of turtles"

PLOT
407
337
809
582
Average innovative potential
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot (average-delta / initial-innovative-potential)"

SLIDER
18
296
206
329
mutation-increment
mutation-increment
0
1
0.1
0.1
1
NIL
HORIZONTAL

SLIDER
18
331
206
364
fishing-out-mutations
fishing-out-mutations
0
1
1
0.1
1
NIL
HORIZONTAL

SLIDER
19
366
207
399
fishing-out-A
fishing-out-A
0
1
1
0.1
1
NIL
HORIZONTAL

SLIDER
19
402
207
435
network-effects
network-effects
0
2
1
0.1
1
NIL
HORIZONTAL

SLIDER
19
439
208
472
subsistence-self
subsistence-self
0
1
0
0.1
1
NIL
HORIZONTAL

PLOT
823
14
1191
326
Growth rates
time
growth rate
0.0
10.0
0.0
0.01
true
true
"" ""
PENS
"g(y)" 1.0 0 -2674135 true "" "plot Y-growth"
"g(A)" 1.0 0 -7500403 true "" "plot A-growth"

SWITCH
19
479
139
512
evolution?
evolution?
0
1
-1000

SWITCH
142
479
280
512
productivity?
productivity?
0
1
-1000

SLIDER
18
186
206
219
labour-share
labour-share
0
1
0.5
0.1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This model is the agent-based model reported in Section 8 of Collins, Baer and Weber (2013) Population, Technological Progress and the Evolution of Innovative Potential, UWA Economics Discussion Paper No. 13.21. Available at SSRN: http://ssrn.com/abstract=2284456 or http://dx.doi.org/10.2139/ssrn.2284456

## HOW IT WORKS

This evolutionary growth model follows the following basic steps:

1. Each agent i works and generates income.
2. The agent activity generates technological progress, which sets the level of technology available to the agents in the next generation.
3. Each agent i has children.
4. The innovative potential of each child j is determined.
5. The agents from generation t die.

## HOW TO USE IT

"Number" sets the initial number of agents in the model.

"Number-of-ticks" is a number of ticks after which the model run will stop.

"Labour-share" sets the parameter alpha in the production function.

"Innovation-rate" sets the paramater gamma in the technology growth function.

"Mutation-rate" sets the parameter v, which is the probability of an agent experiencing a mutation in each generation.

"Mutation-increment" is the percentage increase or decrease in innovative potential that an agent may obtain through a single mutation.

"Fishing-our-mutations" sets the parameter pheta which is the degree to which there are increasing returns to further mutations.

"Fishing-out-A" sets the parameter phi for the more general form of the technological progress function.

"Network-effects" allows for network effects in the technological progress function.

The "subsistence-self" slider allows for an alternative specification of reproductive success to be trailed. When set to zero, all income is allocated to reproduction. If set higher, that percentage of the subsistence income in that Malthusian state is required by the agent, with only the surplus available for reproduction.

The "evolution" switch allows you to simulate a version of Kremer's (1993) model without human evolution.

The "productivity?" switch allows you to explore a version of the model where there is no productivity component to output. When set to off, there is no fitness advantage to mutations and evolution must occur by drift.

## THINGS TO NOTICE

When the model is running fast, you may not notice the change in population composition in the histogram, which can occur very quickly. At early stages of the model, it can be worth running it more slowly to observe the evolution process.

## THINGS TO TRY

The opening parameters result in quite slow evolution, with an intention of observing the process over 10s of thousands of generations. It may be worth setting the innovation-rate and mutation-rate to higher levels when playing with the model to obtain faster results. Setting the starting number of agents to a lower number may also be useful on slow computers.

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

Collins, Baer and Weber (2013) Population, Technological Progress and the Evolution of Innovative Potential, UWA Economics Discussion Paper No. 13.21. Available at SSRN: http://ssrn.com/abstract=2284456 or http://dx.doi.org/10.2139/ssrn.2284456
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
NetLogo 5.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <metric>average-quality</metric>
    <enumeratedValueSet variable="subsistence-self">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="export-chart-output?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fishing-out-mutations">
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-increment">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="productivity?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-innovative-potential">
      <value value="1.0E-8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-ticks">
      <value value="1000000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-effects">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fishing-out-technology">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-rate">
      <value value="1.0E-6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evolution?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="labour-share">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="1000"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
