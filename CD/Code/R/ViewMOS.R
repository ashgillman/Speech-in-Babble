library(ggplot2)
library(corrgram)
library(plyr)
rm(list=ls());
source("statFunctions.R") # summarySE

# output location
figdir <- "fig/mos/"
dir.create(file.path(figdir),recursive=T,showWarnings=F)

# data retrieval
d <- read.csv("/Users/Ash/Documents/ThesisData/testdat/MOSScores.csv",header=T,
              na.strings="45")

# data reduction
d <- d[d$Input.SNR == 0,]
d <- d[d$ID != "test",]

# data cleaning
d$training <- ifelse(grepl("phoneme",d$algorithm),
                     "Phoneme-dependent Training","Normal Training")
d$algorithm <- sub("phoneme","",d$algorithm)
testDesc <- c("SoI = c3c(f)\nNoise = c3f(m)",
              "SoI = c3l(f)\nNoise = c31(m)",
              "SoI = c3s(m)\nNoise = c31(m)",
              "SoI = c3s(m)\nNoise = c31(m)+c34(m)+c35(m)",
              "SoI = c3s(m)\nNoise = c3f(m)+c3c(f)+c35(m)",
              "SoI = c3s(m)\nNoise = c3f(m)+c3c(f)",
              "SoI = c3s(m)\nNoise = c3f(m)",
              "SoI = c3s(m)\nNoise = NOIZEUS car",
              "SoI = c3s(m)\nNoise = NOIZEUS babble",
              "SoI = c3s(m)\nNoise = NOIZEUS street")
d$testName <- testDesc[d$testNo]
d$algorithm <- factor(d$algorithm)
d$testNo <- factor(d$testNo)
d$Input.SNR <- factor(d$Input.SNR)
d$utterances.phns <- factor(d$utterances.phns)


# plotting results
for (meas in c("MOS","MOSle","CCR")) {
  d$y <- d[,meas]
  d <- d[!is.na(d$y),]
  
  # data tranform for freq
  d.freq <- ddply(d, c("testName","algorithm","training","utterances.phns","y"),
             "nrow", .drop = T)
  p <- ggplot(d.freq,aes(x=algorithm,y=y,
                    color=utterances.phns,size=nrow)) +
    geom_point(position = position_jitter(width = .15,height=0.1)) +
    scale_colour_brewer(name="Algorithm", type="seq", palette="Spectral") +
    scale_size("Count",range=c(2,5)) +
    facet_grid(testName~training) +
    #scale_x_log10() +
    theme_bw() + theme(axis.text.x=element_text(angle=15,hjust=0.8)) +
    xlab("Phonemes") + ylab(meas)
  print(p)
  pdf(paste0(figdir,meas,".pdf"),width=14,height=12)
  print(p)
  dev.off()
  
  p <- ggplot(d,aes(x=algorithm,y=y,
                         color=utterances.phns)) +
    geom_boxplot(aes(fill=algorithm)) +
    scale_colour_brewer(name="Algorithm", type="seq", palette="Spectral") +
    scale_fill_manual(values=c("white","white","white","white","white","white"),guide=F) +
    facet_grid(testName~training) +
    #scale_x_log10() +
    theme_bw() + theme(axis.text.x=element_text(angle=15,hjust=0.8)) +
    xlab("Phonemes") + ylab(meas)
  print(p)
  pdf(paste0(figdir,meas,"box.pdf"),width=14,height=12)
  print(p)
  dev.off()
  
  # data transform for conidence interval (t dist.)
  d.stat <- summarySE(d, measurevar="y",
                      groupvars=c("testName","algorithm","training",
                                  "utterances.phns"))
  pd <- position_dodge(.5) # move them .25 to the left and right
  p <- ggplot(d.stat, aes(x=algorithm,y=y,
                     color=utterances.phns, group=utterances.phns)) + 
    geom_errorbar(aes(ymin=y-ci, ymax=y+ci), colour="black", width=.1, position=pd) +
    facet_grid(testName~training) +
    #geom_line(position=pd) +
    geom_point(position=pd, size=3) +
    scale_colour_brewer(name="Algorithm", type="seq", palette="Spectral") +
    theme_bw() + theme(axis.text.x=element_text(angle=15,hjust=0.8)) +
    xlab("Phonemes") + ylab(meas)
  print(p)
  pdf(paste0(figdir,meas,"conf95.pdf"),width=14,height=12)
  print(p)
  dev.off()
}
