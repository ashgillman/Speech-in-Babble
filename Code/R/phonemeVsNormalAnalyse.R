library(ggplot2)
library(corrgram)

rm(list=ls());

figdir <- "fig/phn/compare with normal/"
dir.create(file.path(figdir),recursive=T,showWarnings=F)

d <- read.csv("dat/testResults.csv",header=T)

xp <- "Input.SNR";
yps <- c("pesq","pesqImp","segSNR","segSNRImp");
cp <- "algorithm";
gp <- "phonemes";

testNames <- as.list(unique(d$testName))

d <- d[d[,"utterances"] %in% c(3,5,NA),]
d <- d[d[,"testNo"] %in% c(7,8,9,10),]
#d <- d[d[,"algorithm"]==algorithm,]

test_labeller <- function(variable,value){
  return(testNames[value])
}

for (yp in yps) {
  p <- ggplot(d,aes(x=d[,xp], y=d[,yp],
                    color=d[,cp],shape="Enhanced")) +
    geom_point() +
    scale_colour_brewer(name="Algorithm", type="div", palette="Set1") +
    facet_grid(~testNo,labeller=test_labeller) +
    scale_shape(guide=F) +
    theme_bw() + theme(legend.position="bottom") + xlab(xp) + ylab(yp)
  if (paste0(yp,"Imp") %in% colnames(d)) { # if improvement exists
    p <- p + 
      geom_point(aes(x=d[,xp],y=d[,yp]-d[,paste0(yp,"Imp")],shape="Before Enhancement"),colour="black") +
      geom_line(aes(x=d[,xp],y=d[,yp]-d[,paste0(yp,"Imp")]),linetype=2,colour="black") +
      scale_shape_manual(name="",values=c(4,20))
  }
  print(p)
  pdf(paste0(figdir,yp,".pdf"),width=12,height=6)
  print(p)
  dev.off()
}