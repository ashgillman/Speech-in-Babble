rm(list=ls());
data <- read.csv('litresults.csv',header=T);

hum = c("PESQimp","STOIimp")

(d <- ggplot(data,aes(x=PRRimp,y=PESQimp,color=Class)) +
   geom_point()) + scale_colour_brewer(type="qual",palette="Dark2") + 
   stat_smooth(method=lm,se=F) +
   theme_classic();