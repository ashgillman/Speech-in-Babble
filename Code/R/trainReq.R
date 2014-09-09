library(ggplot2)

rm(list=ls());

figdir <- "fig/train/mohSup/"
dir.create(file.path(figdir),recursive=T,showWarnings=F)

file1 <- "dat/Moh_PESQ-SegSNR1.csv"
d <- read.csv(file1,header=T);
d$testNo <- rep(1,nrow(d))
d$Input.SNR <- factor(d$Input.SNR)
file1b <- "dat/Moh_PESQ-SegSNR1b.csv"
d1b <- read.csv(file1b,header=T);
d1b$testNo <- rep(1,nrow(d1b))
d1b$Input.SNR <- factor(d1b$Input.SNR)
file1b <- "dat/Moh_PESQ-SegSNR2.csv"
d2 <- read.csv(file1b,header=T);
d2$testNo <- rep(2,nrow(d2))
d2$Input.SNR <- factor(d2$Input.SNR)

d <- rbind(d,d2)

## PESQ

p <- ggplot(d,aes(x=utterances,y=pesq,group=Input.SNR,colour=Input.SNR,
                  linetype="enhanced")) +
  geom_line(aes(linetype="enhanced")) +
  geom_line(data=d1b,aes(linetype="enhanced")) +
  geom_line(aes(x=utterances,y=pesq-pesqImp,linetype="dirty")) +
  geom_line(data=d1b,aes(x=utterances,y=pesq-pesqImp,linetype="dirty")) +
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
  geom_line(data=d1b) +
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
  geom_line(data=d1b,aes(linetype="enhanced")) +
  geom_line(aes(x=utterances,y=segSNR-segSNRImp,linetype="dirty")) +
  geom_line(data=d1b,aes(x=utterances,y=segSNR-segSNRImp,linetype="dirty")) +
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
  geom_line(data=d1b) +
  scale_color_discrete("Input SNR") +
  facet_wrap(~testNo) +
  theme_bw() + ggtitle("Segmental SNR Improvement") + xlab("Utterances") +
  ylab("SegSNR Improvement")
print(p)
pdf(paste(figdir,"segSNRImp.pdf",sep=""),width=7,height=5)
print(p)
dev.off()