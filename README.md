![](cover_image.png)

To try out the model, download the code file and run using the NetLogo Desktop App or [NetLogo Web](https://netlogoweb.org/launch#Load)

----
# Unilateralist

A NetLogo Model of the Unilateralist's Curse

## WHAT IS IT?
This model is a high-fidelity replication of the economic game in Experiment 5 from the 2024 preprint "It Only Takes One: The Psychology of Unilateral Decisions" by Lewis et al. It demonstrates the "Unilateralist's Curse," a concept from a 2016 paper by Nick Bostrom, Thomas Douglas, and Anders Sandberg.

The curse describes a situation where a group of well-intentioned agents, each able to unilaterally trigger a significant event, will cause that event to occur more often than is optimal. This model allows users to explore this phenomenon by simulating the decisions of agents under two different behavioral strategies: a psychologically realistic one and a game-theoretically optimal one. The scope of this model is to demonstrate how the Unilateralist's Curse emerges from individual decisions and to compare the effectiveness of different decision strategies in mitigating it.
## HOW IT WORKS
The model's environment is an abstract representation of a group decision problem. There are two boxes, "A" and "B." In each round, one box is designated as the "true box" containing a reward. The group opens Box A, the default outcome, if none of the agents in the group choose to "impose" (open box B). If even one of the agents chooses to impose, the group must open box B, regardless of the decisions of the other agents. Each agent privately decides whether or not to impose based on a signal and confidence threshold.

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

This NetLogo model was created by Kunal Baldava in July 2025, as part of the Introduction to Agent Based Modeling Course by The SantaFe Institute.
