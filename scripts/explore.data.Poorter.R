rm(list = ls())

library(ggplot2)
library(dplyr)
library(tidyr)

data <- read.csv("./data/Poorter2016/Aboveground biomass 2ndFOR database.csv",
                stringsAsFactors = FALSE)

Age.OG <- 100


data.form <- data %>%
  mutate(Age.num = case_when(Age == "OG" ~ Age.OG,
                             TRUE ~ as.numeric(Age)))

data.form.av <- data.form %>%
  group_by(Chronosequence,Age.num) %>%
  summarise(AGB.m = mean(AGB,na.rm = TRUE),
            AGB.median = median(AGB,na.rm = TRUE),
            .groups = "keep")

data2plot <- data.form.av %>%
  filter(Age.num <= 100,Age.num > 0,
         AGB.m <= 500)

selected.plot <- "Bolpebra"

ggplot(data = data2plot,
       aes(x = Age.num, y = AGB.m, group = Chronosequence)) +
  geom_point(color = "grey") +
  # geom_line() +

  # scale_x_log10() +
  # scale_y_log10() +
  stat_smooth(method = "lm",formula = y ~ log(x),se = FALSE,color = "black") +

  geom_point(data = data2plot %>% filter(Chronosequence == selected.plot),
             color = "red") +
  stat_smooth(data = data2plot %>% filter(Chronosequence == selected.plot),
              method = "lm",formula = y ~ log(x),se = FALSE,color = "red") +

  scale_y_continuous(limits = c(0,500)) +
  theme_bw()


data.form.av.rel <- data.form.av %>% filter(Chronosequence %in% (data.form.av %>% filter(Age.num == Age.OG) %>% pull(Chronosequence) %>% unique())) %>%
  ungroup() %>%
  mutate(AGB.m.rel = 100*AGB.m/median(AGB.m[Age.num == Age.OG],na.rm = TRUE))

data2plot.B <- data.form.av.rel %>%
  filter(Age.num <= 100,Age.num > 0,
         AGB.m <= 500)

ggplot(data = data2plot.B,
       aes(x = Age.num, y = AGB.m.rel, group = Chronosequence)) +
  geom_point(color = "grey") +
  # stat_smooth(method = "lm",formula = y ~ log(x),se = FALSE,color = "black") +

  geom_point(data = data2plot.B %>% filter(Chronosequence == selected.plot),
             color = "red") +
  stat_smooth(data = data2plot.B %>% filter(Chronosequence == selected.plot),
              method = "lm",formula = y ~ log(x),se = FALSE,color = "red") +

  scale_y_continuous(limits = c(0,350)) +
  theme_bw()


