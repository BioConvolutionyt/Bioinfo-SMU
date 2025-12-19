## ggplot test
## This file is for basic test for ggplot2
## Author: Nan He 2025.12.19

library(ggplot2)
data("iris")

## simple point plot
p1 <- ggplot(data = iris, aes(x = Sepal.Width, y = Sepal.Length)) +
  geom_point(aes(colour = Species))

p1

## add linear regression for each species
p2 <- ggplot(iris, aes(Sepal.Width, Sepal.Length)) +
  geom_point(aes(colour = Species)) +
  geom_smooth(aes(group = Species, colour = Species), method = "lm")

p2

## add customized colours
p3 <- ggplot(iris, aes(Sepal.Width, Sepal.Length)) +
  geom_point(aes(colour = Species)) +
  geom_smooth(aes(group = Species, colour = Species), method = "lm") +
  scale_color_brewer(palette = "Dark2")

p3

## add theme
p4 <- ggplot(iris, aes(Sepal.Width, Sepal.Length)) +
  geom_point(aes(colour = Species)) +
  geom_smooth(aes(group = Species, colour = Species), method = "lm") +
  scale_color_brewer(palette = "Dark2") +
  theme_classic()

p4

## add text colour
p5 <- ggplot(iris, aes(Sepal.Width, Sepal.Length)) +
  geom_point(aes(colour = Species)) +
  geom_smooth(aes(group = Species, colour = Species), method = "lm") +
  scale_color_brewer(palette = "Dark2") +
  theme_classic() + 
  theme(axis.text = element_text(colour = "firebrick", size = 15))

p5

## facet according to species
p6 <- ggplot(iris, aes(Sepal.Width, Sepal.Length)) +
  geom_point(aes(colour = Species)) +
  geom_smooth(aes(group = Species, colour = Species), method = "lm") +
  scale_color_brewer(palette = "Dark2") +
  theme_minimal() +
  facet_grid(.~Species)

p6

## subset plot-data
p7 <- ggplot(iris, aes(Sepal.Width, Sepal.Length)) +
  geom_point(data = iris[, -5], colour = "grey") +
  geom_point(aes(colour = Species)) +
  geom_smooth(aes(group = Species, colour = Species), method = "lm") +
  scale_color_brewer(palette = "Dark2") +
  theme_minimal() +
  facet_grid(.~Species)

p7

## complex-plot
p8 <- ggplot(iris, aes(Species, Petal.Length, fill = Species)) +
  geom_violin(alpha = .5) +
  geom_boxplot(width = .1) +
  geom_jitter()

p8




