library(tidyverse)
library(tidymodels)

setwd('D:/GIS_Data/DisMap/test')
dat_forest <- read.csv('D:/GIS_Data/DisMap/test/dat_forest.csv')

dat_forest %>%
  ggplot() +
  geom_boxplot(aes(r_SOS, group = SpecName, color = SpecName))

head(dat_forest)

set.seed(123)
trees_split <- initial_split(dat_forest, strata = r_SOS)
trees_train <- training(trees_split)
trees_test <- testing(trees_split)

tree_rec <- recipe(r_SOS ~ ., data = trees_train)

tree_prep <- prep(tree_rec)
juiced <- juice(tree_prep)

tune_spec <- rand_forest(
  mtry = tune(),
  trees = 200,
  min_n = tune()
) %>%
  set_mode("regression") %>%
  set_engine("ranger")

tune_wf <- workflow() %>%
  add_recipe(tree_rec) %>%
  add_model(tune_spec)

set.seed(234)
trees_folds <- vfold_cv(trees_train)

doParallel::registerDoParallel()

set.seed(345)
tune_res <- tune_grid(
  tune_wf,
  resamples = trees_folds,
  grid = 20
)

tune_res

tune_res$.metrics

tune_res %>%
  collect_metrics() %>%
  filter(.metric == "rmse") %>%
  select(mean, min_n, mtry) %>%
  pivot_longer(min_n:mtry,
               values_to = "value",
               names_to = "parameter"
  ) %>%
  ggplot(aes(value, mean, color = parameter)) +
  geom_point(show.legend = FALSE) +
  facet_wrap(~parameter, scales = "free_x") +
  labs(x = NULL, y = "RMSE")


tune_res %>%
  collect_metrics() %>%
  filter(.metric == "rsq") %>%
  select(mean, min_n, mtry) %>%
  pivot_longer(min_n:mtry,
               values_to = "value",
               names_to = "parameter"
  ) %>%
  ggplot(aes(value, mean, color = parameter)) +
  geom_point(show.legend = FALSE) +
  facet_wrap(~parameter, scales = "free_x") +
  labs(x = NULL, y = "R squared")


rf_grid <- grid_regular(
  mtry(range = c(2, 10)),
  min_n(range = c(2, 10)),
  levels = 5
)

rf_grid

set.seed(456)
regular_res <- tune_grid(
  tune_wf,
  resamples = trees_folds,
  grid = rf_grid
)

regular_res

regular_res %>%
  collect_metrics() %>%
  filter(.metric == "rmse") %>%
  mutate(min_n = factor(min_n)) %>%
  ggplot(aes(mtry, mean, color = min_n)) +
  geom_line(alpha = 0.5, size = 1.5) +
  geom_point() +
  labs(y = "RMSE")


best_auc <- select_best(regular_res)

final_rf <- finalize_model(
  tune_spec,
  best_auc
)

final_rf

library(vip)

final_rf %>%
  set_engine("ranger", importance = "permutation") %>%
  fit(r_SOS ~ .,
      data = juice(tree_prep)
  ) %>%
  vip(geom = "point")

final_wf <- workflow() %>%
  add_recipe(tree_rec) %>%
  add_model(final_rf)

final_res <- final_wf %>%
  last_fit(trees_split)

final_res %>%
  collect_metrics()

final_res$.predictions[[1]]

final_res$.predictions[[1]] %>%
  ggplot() +
  geom_point(aes(y = r_SOS, x = .pred))

