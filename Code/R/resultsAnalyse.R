library(ggplot2)

rm(list=ls());
data <- read.csv('results.csv',header=T);

xp <- "Input.SNR";
yp <- "pesqImp";
cp <- "utterances";
sp <- "algorithm";

p <- ggplot(data,aes(x=data[,xp], y=data[,yp],
                     color=factor(data[,cp])), group=data[,cp]) +
  geom_line() +
  scale_colour_discrete(name=cp) +
  xlab(xp) + ylab(yp)

print(p)

xp <- "utterances";
yp <- "pesqImp";
cp <- "Input.SNR";
sp <- "algorithm";

p <- ggplot(data,aes(x=data[,xp], y=data[,yp],
                     color=factor(data[,cp])), group=data[,cp]) +
  geom_line() +
  scale_colour_discrete(name=cp) +
  xlab(xp) + ylab(yp)

print(p)