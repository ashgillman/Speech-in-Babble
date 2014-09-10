library(ggplot2)

rm(list=ls());

figdir <- "fig/train/mohSup/"
dir.create(file.path(figdir),recursive=T,showWarnings=F)

file <- "dat/Moh_PESQ-SegSNR1.csv"
d1 <- read.csv(file,header=T);
d1$testNo <- rep(1,nrow(d1))
file <- "dat/Moh_PESQ-SegSNR2.csv"
d2 <- read.csv(file,header=T);
d2$testNo <- rep(2,nrow(d2))
file <- "dat/Moh_PESQ-SegSNR3.csv"
d3 <- read.csv(file,header=T);
d3$testNo <- rep(3,nrow(d3))

d <- rbind(d1,d2)
d <- rbind(d,d3)
d$Input.SNR <- factor(d$Input.SNR)

## PESQ

p <- ggplot(d,aes(x=utterances,y=pesq,group=Input.SNR,colour=Input.SNR,
                  linetype="enhanced")) +
  geom_line(aes(linetype="enhanced")) +
  geom_line(aes(x=utterances,y=pesq-pesqImp,linetype="dirty")) +
  scale_color_discrete("Input SNR") +
  scale_linetype_manual("Enhanced?",
                        values=c("enhanced"="solid","dirty"="dashed")) +
  facet_wrap(~testNo) +
  theme_bw() + ggtitle("PESQ Score") + xlab("Utterances") + ylab("PESQ Score")
print(p)
pdf(paste(figdir,"pesq.pdf",sep=""),width=7,height=5)
print(p)
dev.off()

p <- ggplot(d,aes(x=utterances,y=pesqImp,group=Input.SNR,colour=Input.SNR,
                  group=testNo)) +
  geom_line() +
  scale_color_discrete("Input SNR") +
  facet_wrap(~testNo) +
  theme_bw() + ggtitle("PESQ Improvement") + xlab("Utterances") +
  ylab("PESQ Improvement")
print(p)
pdf(paste(figdir,"pesqImp.pdf",sep=""),width=7,height=5)
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
  facet_wrap(~testNo) +
  theme_bw() + ggtitle("Segmental SNR Score") + xlab("Utterances") +
  ylab("SegSNR Score")
print(p)
pdf(paste(figdir,"segSNR.pdf",sep=""),width=7,height=5)
print(p)
dev.off()


p <- ggplot(d,aes(x=utterances,y=segSNRImp,group=Input.SNR,colour=Input.SNR)) +
  geom_line() +
  scale_color_discrete("Input SNR") +
  facet_wrap(~testNo) +
  theme_bw() + ggtitle("Segmental SNR Improvement") + xlab("Utterances") +
  ylab("SegSNR Improvement")
print(p)
pdf(paste(figdir,"segSNRImp.pdf",sep=""),width=7,height=5)
print(p)
dev.off()