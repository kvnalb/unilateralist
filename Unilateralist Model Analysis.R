# --- Unilateralist Netlogo model - Comprehensive Two-Experiment Analysis ---

# This script loads and analyzes data from two BehaviorSpace experiments
# conducted on the Unilateralist NetLogo Model

# 1. Load necessary libraries
# --------------------------------------------------------------------------
# install.packages("tidyverse")
library(tidyverse)

# 2. Data Loading and Cleaning (IMPORTANT: Replace file paths with paths on your computer)
# --------------------------------------------------------------------------
# --- Load Data from Experiment 1: Core Strategies ---
file_core <- "/Users/kunalb/Desktop/Archive/Summer25/Unilateralist/Unilateralist Comprehensive Sweep-table.csv"
raw_core <- read.csv(file_core, skip = 6, check.names = FALSE)

results_core <- raw_core %>%
  rename(
    decision_scenario = `decision-scenario`,
    group_size = `group-size`,
    win_count = `rounds-won`,
    bad_imposition_count = `bad-impositions`
  ) %>%
  mutate(
    win_rate = win_count / 100,
    bad_imposition_rate = bad_imposition_count / 100
  ) %>%
  mutate(
    Scenario = factor(case_when(
      decision_scenario == "deciding-as-usual" ~ "Deciding as Usual",
      decision_scenario == "nash-equilibrium" ~ "Nash Equilibrium",
      decision_scenario == "deference-leader" ~ "Deference - Leader",
      decision_scenario == "deference-vote" ~ "Deference - Majority Vote",
      decision_scenario == "deference-weighted-vote" ~ "Deference - Weighted Vote",
      TRUE ~ decision_scenario
    ), levels = c("Deciding as Usual", "Nash Equilibrium", 
                  "Deference - Leader", "Deference - Majority Vote", "Deference - Weighted Vote"))
  ) %>%
  select(Scenario, group_size, win_rate, bad_imposition_rate)

# --- Load Data from Experiment 2: Limited Imposers ---
file_limited <- "/Users/kunalb/Desktop/Archive/Summer25/Unilateralist/Unilateralist Limited Imposers-table.csv"
raw_limited <- read.csv(file_limited, skip = 6, check.names = FALSE)

results_limited <- raw_limited %>%
  rename(
    group_size = `group-size`,
    percent_active = `percent-active-imposers`,
    win_count = `rounds-won`,
    bad_imposition_count = `bad-impositions`
  ) %>%
  mutate(
    win_rate = win_count / 100,
    bad_imposition_rate = bad_imposition_count / 100
  ) %>%
  select(group_size, percent_active, win_rate, bad_imposition_rate)

results_limited_with_absolute_n <- results_limited %>%
  mutate(
    absolute_n_active = round(group_size * (percent_active / 100))
  ) %>%
  filter(absolute_n_active > 0)


# 3. Aggregate Results
# --------------------------------------------------------------------------
summary_core <- results_core %>%
  group_by(Scenario, group_size) %>%
  summarise(
    avg_win_rate = mean(win_rate),
    lower_ci_win = avg_win_rate - 1.96 * (sd(win_rate) / sqrt(n())),
    upper_ci_win = avg_win_rate + 1.96 * (sd(win_rate) / sqrt(n())),
    avg_bad_imposition_rate = mean(bad_imposition_rate),
    lower_ci_bad = avg_bad_imposition_rate - 1.96 * (sd(bad_imposition_rate) / sqrt(n())),
    upper_ci_bad = avg_bad_imposition_rate + 1.96 * (sd(bad_imposition_rate) / sqrt(n())),
    .groups = 'drop'
  )

summary_limited <- results_limited %>%
  group_by(group_size, percent_active) %>%
  summarise(
    avg_win_rate = mean(win_rate),
    avg_bad_imposition_rate = mean(bad_imposition_rate),
    .groups = 'drop'
  )


# 4. Visualization: Core Strategies
# --------------------------------------------------------------------------
plot_core_strategies <- ggplot(summary_core, aes(x = group_size, y = avg_win_rate, color = Scenario)) +
  geom_line(linewidth = 1.2) +
  geom_ribbon(aes(ymin = lower_ci_win, ymax = upper_ci_win, fill = Scenario), alpha = 0.15, linetype = 0) +
  scale_y_continuous(labels = scales::percent_format(), limits = c(0, 1)) +
  labs(title = "Performance of Core Decision Strategies vs. Group Size", x = "Group Size", y = "Average Win Rate") +
  theme_minimal(base_size = 15) + theme(legend.position = "bottom") + guides(fill = "none")
print(plot_core_strategies)

plot_core_errors <- ggplot(summary_core, aes(x = group_size, y = avg_bad_imposition_rate, color = Scenario)) +
  geom_line(linewidth = 1.2) +
  geom_ribbon(aes(ymin = lower_ci_bad, ymax = upper_ci_bad, fill = Scenario), alpha = 0.15, linetype = 0) +
  scale_y_continuous(labels = scales::percent_format()) + coord_cartesian(ylim = c(0, 0.5)) +
  labs(title = "Visualizing the Unilateralist's Curse: Error Rates", subtitle = "The 'Naive' strategy's error rate explodes, while solutions keep it near zero.", x = "Group Size", y = "Average Bad Imposition Rate") +
  theme_minimal(base_size = 15) + theme(legend.position = "bottom") + guides(fill = "none")
print(plot_core_errors)


# 5. Visualization: Limited Imposers
# --------------------------------------------------------------------------
plot_limited_heatmap <- ggplot(summary_limited, aes(x = group_size, y = percent_active, fill = avg_bad_imposition_rate)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(low = "darkgreen", mid = "yellow", high = "red", midpoint = 0.1, labels = scales::percent, name = "Avg. Bad Imposition Rate") +
  labs(title = "Error Rate of the 'Limited Imposers' Strategy", subtitle = "Risk is highest with large groups and many active agents (top-right)", x = "Total Group Size", y = "% of Agents Allowed to Impose") +
  theme_minimal(base_size = 15)
print(plot_limited_heatmap)


plot_collapse <- ggplot(results_limited_with_absolute_n, aes(x = absolute_n_active, y = bad_imposition_rate)) +
  geom_point(alpha = 0.05, color = "gray") + # The raw data cloud
  geom_smooth(method = "gam", formula = y ~ s(x), color = "firebrick", se = TRUE) +
  scale_y_continuous(labels = scales::percent_format()) + 
  coord_cartesian(ylim = c(0, 0.75)) +
  labs(
    title = "Absolute Number of Active Agents as Independent Variable",
    x = "Absolute Number of Active Agents",
    y = "Average Bad Imposition Rate"
  ) +
  theme_minimal(base_size = 15) +
  theme(
    plot.margin = unit(c(1, 1, 1, 1), "cm") # Adds 1cm of padding on all sides
  )

print(plot_collapse)

