library(ggplot2)
library(gridExtra)
library(corrgram)

rm(list=ls());

figdir <- "fig/dir/myTests/"
dir.create(file.path(figdir),recursive=T,showWarnings=F)

testDesc <- c("c3c ~ c3f",
              "c3l ~ c31",
              "c3s ~ c31",
              "c3s ~ c31+c34+c35",
              "c3s ~ c3f+c3c+c35",
              "c3s ~ c3f+c3c",
              "c3s ~ c3f",
              "c3s ~ NOIZEUS car",
              "c3s ~ NOIZEUS babble",
              "c3s ~ NOIZEUS street")

test <- c(8,9,10,7,6,5); # tests to use
algorithm <- "mohammadiaOnline"
#algorithm <- "mohammadiaSupervised"

# load data
file <- paste0("dat/PESQ-SegSNR",test[1],".csv")
d <- read.csv(file,header=T);
d$testNo <- rep(test[1],nrow(d))
d$testName <- rep(testDesc[test[1]],nrow(d))
if (length(test) > 1) {
  for (i in 2:length(test)) {
    file <- paste0("dat/PESQ-SegSNR", test[i], ".csv")
    dnew <- read.csv(file,header=T);
    dnew$testNo <- rep(test[i],nrow(dnew))
    dnew$testName <- rep(testDesc[test[i]],nrow(dnew))
    d <- rbind(d,dnew)
  }
}

d <- d[d[,"utterances"] %in% c(3,5),]
d <- d[d[,"algorithm"]==algorithm,]
d$testNo <- factor(d$testNo)

# correlogram
corrgram(d[-c(1,2,4,9,10)],upper.panel=panel.pts)
d.corr <- cor(d[-c(1,2,4,9,10)])
heatmap(d.corr)

# PLOT UNGROUPED #
# set plot params:
yps <- c("pesq","pesqImp","segSNR","segSNRImp") # y parameter
xp <- "Input.SNR" # x parameter
cp <- "testName" # colour parameter

for (i in 1:length(yps)) {
  yp <- yps[i]
  p <- (ggplot(d,aes(x=d[,xp], y=d[,yp],
                     color=d[,cp])) +
          geom_point() +
          scale_colour_brewer(name="Test Data", type="div", palette="Set1") +
          theme_bw() + xlab(xp) + ylab(yp))
  if (paste0(yp,"Imp") %in% yps) { # if improvement exists
    p <- p + 
      geom_point(aes(x=d[,xp],y=d[,yp]-d[,paste0(yp,"Imp")]),shape=4) +
      geom_line(aes(x=d[,xp],y=d[,yp]-d[,paste0(yp,"Imp")]),linetype=2)
  }
  # LOESS
  p1 <- p + stat_smooth(method=loess, se=F, level=0.5) +
    ggtitle(paste(algorithm,"Performance (LOESS fit)"));
  # LM
  p2 <- p + stat_smooth(method=lm, se=F, level=0.5) +
    ggtitle(paste(algorithm,"Performance (LM fit)"));
  print(grid.arrange(p1, p2))
  
  pdf(paste(figdir,paste0(algorithm,yp,"LOESS.pdf")),width=9,height=5)
  print(p1)
  dev.off()
  pdf(paste(figdir,paste0(algorithm,yp,"LM.pdf")),width=9,height=5)
  print(p2)
  dev.off()
  pdf(paste(figdir,paste0(algorithm,yp,".pdf")),width=9,height=10)
  print(grid.arrange(p1, p2))
  dev.off()
}