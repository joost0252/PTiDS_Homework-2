#############################################
## The following loads the needed packages ##
#############################################

packages <- c(
  "knitr", "readr", "dplyr",
  "here", # for the project's organization
  "tidyverse", "kableExtra", "microbenchmark",
  "ggplot2", "plot.matrix", "rstan", "quanteda",
  "quanteda.textstats", "lexicon", "tidytext", "reshape2"
)

purrr::walk(packages, library, character.only = TRUE)
library(boot)

######################################################
## The following sets a few option for nice reports ##
######################################################

# general options
options(
  digits = 3,
  str = strOptions(strict.width = "cut"),
  width = 69,
  tibble.width = 69,
  cli.unicode = FALSE
)

# ggplot options
theme_set(theme_light())

# knitr options
opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  cache = TRUE,
  fig.retina = 0.8, # figures are either vectors or 300 dpi diagrams
  dpi = 300,
  out.width = "70%",
  fig.align = "center",
  fig.width = 6,
  fig.asp = 0.618,
  fig.show = "hold",
  message = FALSE,
  echo = FALSE
)