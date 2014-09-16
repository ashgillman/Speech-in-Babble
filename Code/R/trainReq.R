library(ggplot2)
library(corrgram)

rm(list=ls());

figdir <- "fig/train/"
dir.create(file.path(figdir),recursive=T,showWarnings=F)

testDesc <- c("SoI = c3c(f)\nNoise = c3f(m)",
              "SoI = c3l(f)\nNoise = c31(m)",
              "SoI = c3s(m)\nNoise = c31(m)",
              "SoI = c3s(m)\nNoise = c31(m)+c34(m)+c35(m)",
              "SoI = c3s(m)\nNoise = c3f(m)+c3c(f)+c35(m)",
              "SoI = c3s(m)\nNoise = c3f(m)+c3c(f)",
              "SoI = c3s(m)\nNoise = c3f(m)")

# tests to use
test <- c(1,2,3,4,5,6,7);

# load data
file <- paste0("dat/PESQ-SegSNR",test[1],".csv")
d <- read.csv(file,header=T);
d$testNo <- rep(1,nrow(d))
d$testName <- rep(testDesc[1],nrow(d))
if (length(test) > 1) {
  for (i in 2:length(test)) {
    file <- paste0("dat/PESQ-SegSNR", i, ".csv")
    dnew <- read.csv(file,header=T);
    dnew$testNo <- rep(i,nrow(dnew))
    dnew$testName <- rep(testDesc[i],nrow(dnew))
    d <- rbind(d,dnew)
  }
}

# correlogram
corrgram(d[-c(1,2,9,10)],upper.panel=panel.pts)
pdf(paste(figdir,"corr.pdf",sep=""),width=15,height=15)
corrgram(d[-c(1,2,9,10)],upper.panel=panel.pts)
dev.off()
d.corr <- cor(d[-c(1,2,9,10)])
heatmap(d.corr)

d$Input.SNR <- factor(d$Input.SNR)
d$testNo <- factor(d$testNo)

## PESQ

p <- ggplot(d,aes(x=utterances,y=pesq,group=Input.SNR,colour=Input.SNR,
                  linetype="enhanced")) +
  geom_line(aes(linetype="enhanced")) +
  geom_line(aes(x=utterances,y=pesq-pesqImp,linetype="dirty")) +
  scale_color_discrete("Input SNR") +
  scale_linetype_manual("Enhanced?",
                        values=c("enhanced"="solid","dirty"="dashed")) +
  facet_grid(algorithm~testName) +
  theme_bw() + ggtitle("PESQ Score") + xlab("Utterances") + ylab("PESQ Score")
print(p)
pdf(paste(figdir,"pesq.pdf",sep=""),width=18,height=10)
print(p)
dev.off()

p <- ggplot(d,aes(x=utterances,y=pesqImp,group=Input.SNR,colour=Input.SNR,
                  group=testNo)) +
  geom_line() +
  scale_color_discrete("Input SNR") +
  facet_grid(algorithm~testName) +
  theme_bw() + ggtitle("PESQ Improvement") + xlab("Utterances") +
  ylab("PESQ Improvement")
print(p)
pdf(paste(figdir,"pesqImp.pdf",sep=""),width=18,height=10)
print(p)
dev.off()

## SegSNR

p <- ggplot(d,aes(x=utterances,y=segSNR,group=Input.SNR,colour=Input.SNR,
                  group=testNo)) +
  geom_line(aes(linetype="enhanced")) +
  geom_line(aes(x=utterances,y=segSNR-segSNRImp,linetype="dirty")) +
  scale_color_discrete("Input SNR") +
  scale_linetype_manual("Enhanced?",
                        values=c("enhanced"="solid","dirty"="dashed")) +
  facet_grid(algorithm~testName) +
  theme_bw() + ggtitle("Segmental SNR Score") + xlab("Utterances") +
  ylab("SegSNR Score")
print(p)
pdf(paste(figdir,"segSNR.pdf",sep=""),width=18,height=10)
print(p)
dev.off()

p <- ggplot(d,aes(x=utterances,y=segSNRImp,group=Input.SNR,colour=Input.SNR)) +
  geom_line() +
  scale_color_discrete("Input SNR") +
  facet_grid(algorithm~testName) +
  theme_bw() + ggtitle("Segmental SNR Improvement") + xlab("Utterances") +
  ylab("SegSNR Improvement")
print(p)
pdf(paste(figdir,"segSNRImp.pdf",sep=""),width=18,height=10)
print(p)
dev.off()