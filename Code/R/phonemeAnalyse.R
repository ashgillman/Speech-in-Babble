library(ggplot2)
library(corrgram)

source("gatherData.R") # update data file

rm(list=ls());

figdir <- "fig/phn/numDrawn/"
dir.create(file.path(figdir),recursive=T,showWarnings=F)

d <- read.csv("dat/testResults.csv",header=T)
d <- d[d[,"utterances"] %in% c(NA),]
d <- d[d[,"testNo"] %in% c(5,7,8,9,10),]
d <- d[,c("testName","algorithm","phonemes","Input.SNR","pesq","pesqImp","segSNR","segSNRImp","testNo")]

d$algorithm <- factor(d$algorithm)
d$testNo <- factor(d$testNo)
d$Input.SNR <- factor(d$Input.SNR)

testNames <- as.list(unique(d$testName))
algorithms <- as.list(unique(d$algorithm))

test_labeller <- function(variable,value){
  if (variable == "testNo") {
    return(testNames[value])
  } else {
    return(algorithms[value])
  }
}

p <- ggplot(d,aes(x=phonemes, y=pesq,
                  color=Input.SNR)) +
  geom_line() +
  scale_colour_brewer(name="Algorithm", type="div", palette="Set1") +
  facet_grid(algorithm~testNo,labeller=test_labeller) +
  scale_shape(guide=F) +
  scale_x_log10() +
  theme_bw() + theme(legend.position="bottom") +
  xlab("Phonemes") + ylab("PESQ") + 
  geom_point(aes(x=phonemes,y=pesq-pesqImp,
                 shape="Before Enhancement"),colour="black") +
  geom_line(aes(x=phonemes,y=pesq-pesqImp,color=Input.SNR),
            linetype=2) +
  scale_shape_manual(name="",values=c(4,20))
print(p)
pdf(paste0(figdir,"pesq",".pdf"),width=12,height=6)
print(p)
dev.off()

p <- ggplot(d,aes(x=phonemes, y=segSNR,
                  color=Input.SNR)) +
  geom_line() +
  scale_colour_brewer(name="Algorithm", type="div", palette="Set1") +
  facet_grid(algorithm~testNo,labeller=test_labeller) +
  scale_shape(guide=F) +
  scale_x_log10() +
  theme_bw() + theme(legend.position="bottom") +
  xlab("Phonemes") + ylab("Segmental SNR") + 
  geom_point(aes(x=phonemes,y=segSNR-segSNRImp,
                 shape="Before Enhancement"),colour="black") +
  geom_line(aes(x=phonemes,y=segSNR-segSNRImp,color=Input.SNR),
            linetype=2) +
  scale_shape_manual(name="",values=c(4,20))
print(p)
pdf(paste0(figdir,"segSNR",".pdf"),width=10,height=7)
print(p)
dev.off()