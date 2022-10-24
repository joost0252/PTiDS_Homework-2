# load libraries
library(dplyr)
library(plot.matrix)
library(rstan)
library(readr) # to read the data with read_delim
library(quanteda) 
library(quanteda.textstats) 
library(lexicon) # contains hash_lemmas
library(tidytext) # contains stop_words
library(reshape2)
library(ggplot2)

load("maze.rds")


# define as matrix
matmaze = matrix(maze, ncol= sqrt(length(maze)) , byrow = T)
matmaze_plot <- matmaze
matmaze_plot <- +(!matmaze_plot)
matmaze <- matmaze[nrow(matmaze):1, ]
matmaze <- +(!matmaze)
#matmaze <- +(!matmaze) this makes the zeros ones and the ones zeros
matmaze

###############################################
# define starting and final position
starting_pos = c(15,1)
final_pos = c(3,17)

# Solving the maze with right hand wall follower
pos <- starting_pos # start with the starting position
direction <- "right" # initial direction
iteration <- 1
time_delay <- 1
right_vector = c(0,1)
down_vector = c(-1,0) #note that the down_vector and down direction are reversed
left_vector = c(0,-1)
up_vector = c(1,0) #note that the up_vector and up direction are reversed

while(any(pos != final_pos)){
  # 1. Find the direction
  # wall on the right hand?
  wall_right <- switch(direction,
                       right = as.logical(matmaze[as.integer(c(pos[1]+ down_vector[1])), as.integer(c(pos[2]+ down_vector[2]))]),
                       down  = as.logical(matmaze[as.integer(c(pos[1]+ right_vector[1])), as.integer(c(pos[2]+ right_vector[2]))]),
                       left  = as.logical(matmaze[as.integer(c(pos[1]+ up_vector[1])),   as.integer(c(pos[2]+ up_vector[2]))]),
                       up    = as.logical(matmaze[as.integer(c(pos[1]+ left_vector[1])),as.integer(c(pos[2]+ left_vector[2]))]))
  # if not, make a turn right
  if(!wall_right){
    direction <- switch(direction,
                        right = "up",
                        down = "right",
                        left = "down",
                        up = "left")
  }
  
  

  
  # wall in front?
  wall_front <- switch(direction,
                       right = as.logical(matmaze[as.integer(c(pos[1]+right_vector[1])),as.integer(c(pos[2]+right_vector[2]))]),
                       down  = as.logical(matmaze[as.integer(c(pos[1]+up_vector[1])),as.integer(c(pos[2]+up_vector[2]))]),
                       left  = as.logical(matmaze[as.integer(c(pos[1]+left_vector[1])),as.integer(c(pos[2]+left_vector[2]))]),
                       up    = as.logical(matmaze[as.integer(c(pos[1]+down_vector[1])),as.integer(c(pos[2]+down_vector[2]))]))
  
  # if true, make one turn left
  if(wall_front){
    direction <- switch(direction,
                        right = "down",
                        down = "left",
                        left = "up",
                        up = "right")
  }
  
  # wall in front?
  wall_front <- switch(direction,
                       right = as.logical(matmaze[as.integer(c(pos[1]+right_vector[1])),as.integer(c(pos[2]+right_vector[2]))]),
                       down = as.logical(matmaze[as.integer(c(pos[1]+up_vector[1])),as.integer(c(pos[2]+up_vector[2]))]),
                       left = as.logical(matmaze[as.integer(c(pos[1]+left_vector[1])),as.integer(c(pos[2]+left_vector[2]))]),
                       up = as.logical(matmaze[as.integer(c(pos[1]+down_vector[1])),as.integer(c(pos[2]+down_vector[2]))]))
  
  # if true, make one turn left
  if(wall_front){
    direction <- switch(direction,
                        right = "down",
                        down = "left",
                        left = "up",
                        up = "right")
  }

  
  # 2. Move one step in the direction
  pos <- switch(direction,
                right = pos + right_vector,
                down = pos + up_vector, #Again, down and up are switched because of the perspective
                left = pos + left_vector,
                up = pos + down_vector)
  # plot maze and define starting and final position
  plot(matmaze_plot, las=1, col=c("white", "black"), key=NULL, main ="Maze")
  # plot starting and final position
  points(x=starting_pos[2], y=starting_pos[1], col = "darkgreen", pch = 16, cex = 5)
  points(x=final_pos[2], y=final_pos[1], col = "red", pch = 16, cex = 5)
  # Print the iteration in the graph
  text(x = pos[2], y = pos[1], labels = iteration, cex = 1, col ="blue4")
  Sys.sleep(time_delay)
  iteration = iteration+1
}



