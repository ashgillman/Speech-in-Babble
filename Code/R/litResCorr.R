library(ggplot2)
library(reshape2)

rm(list=ls());
figdir <- "fig/cor/"

# data
data <- read.csv('../RapidMiner/litResCorr.csv',header=T,na.strings="none");
ignore <- c("WRR","STOIimp","SAR","SIR")
data <- data[!data$X %in% ignore,!names(data) %in% ignore]

# row colours
col <- c("darkblue","darkblue","darkred","darkred","darkgreen")
#col <- c("blue","blue","blue","blue","red","red","red","darkgreen","darkgreen")

# get the right format
data.melt <- melt(data)
data.melt$X <- factor(data.melt$X, levels=unique(data.melt$X))
data.melt$Y <- factor(data.melt$variable, levels=rev(unique(data.melt$variable)))

# discretise
data.melt$value<-cut(data.melt$value,breaks=c(-1,-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,
                                              0.6,0.8,1),
                 include.lowest=TRUE,
                 label=c("(-0.8,-1)","(-0.6,-0.8)","(0.6,-0.4)","(-0.4,-0.2)",
                         "(-0.2,0)","(0,0.2)","(0.2,0.4)","(0.4,0.6)",
                         "(0.6,0.8)","(0.8,1)"))

p <- ggplot(data.melt,aes(x=X,y=Y,alpha=abs(as.numeric(data.melt$value)-4.5))) +
  geom_tile(aes(fill=value,na.value=0)) +
  scale_fill_brewer(palette = "RdYlGn",name="Correlation",drop=F) + 
  scale_alpha(na.value=0,range=c(0.5,1),guide=F) +
  theme_bw() + xlab("") + ylab("") +
  theme(axis.text.y = element_text(color=rev(col))) +
  theme(axis.text.x = element_text(color=col)) 

print(p)

# save plot
dir.create(file.path(figdir), showWarnings = FALSE)
pdf(paste(figdir,"litResCorr.pdf",sep=""),width=6,height=4)
print(p)
dev.off()