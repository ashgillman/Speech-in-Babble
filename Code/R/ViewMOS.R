library(ggplot2)
library(corrgram)
rm(list=ls());

figdir <- "fig/mos/"
dir.create(file.path(figdir),recursive=T,showWarnings=F)

d <- read.csv("/Users/Ash/Documents/ThesisData/testdat/MOSScores.csv",header=T,na.strings="45")
#d <- d[d[,"utterances.phns"] %in% c(NA),]
#d <- d[d[,"testNo"] %in% c(5,7,8,9,10),]
#d <- d[,c("algorithm","Input.SNR","testNo","utterances.phns","MOS","MOSle","CCR")]

d$algorithm <- factor(d$algorithm)
d$testNo <- factor(d$testNo)
d$Input.SNR <- factor(d$Input.SNR)

p <- ggplot(d,aes(x=utterances.phns, y=MOS,
                  color=algorithm,shape=Input.SNR,linetype=Input.SNR)) +
  geom_line() +
  geom_point() +
  scale_colour_brewer(name="Algorithm", type="div", palette="Set1") +
  facet_grid(algorithm~testNo) +
  scale_shape(guide=F) +
  scale_x_log10() +
  theme_bw() + #theme(legend.position="bottom") +
  xlab("Phonemes") + ylab("MOS") + 
  scale_shape_manual(name="",values=c(4,20))
print(p)
pdf(paste0(figdir,"mos",".pdf"),width=12,height=6)
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
pdf(paste0(figdir,"mosle",".pdf"),width=10,height=7)
print(p)
dev.off()