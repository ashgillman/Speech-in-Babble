library(reshape2)
library(ggplot2)

assessmentMethods <- data.frame(
  Paper = c("Wilson, Raj, Smaragdis, Divakaran",
            "Schmidt, Olsson",
            "Raj, Singh, Smaragdis",
            "Raj, Smaragdis",
            "Raj, Singh, Virtanen",
            "Mohammadiha, Leijon",
            "Févotte",
            "Mohammadiha, Smaragdis, Leijon",
            "Weninger, Lehmann, Schuller",
            "Williamson, Wang, Wang",
            "Paliwal, Lyons, So, Stark, Wojcicki",
            "Plourde, Champagne"),
  PESQ =          c(T,F,F,F,F,T,F,T,T,T,T,T),
  MOS =           c(F,F,F,F,F,T,F,F,F,F,F,T),
  WRR =           c(F,T,T,F,F,F,F,F,F,F,F,F),
  PRR =           c(F,F,F,F,F,F,F,F,F,F,T,F),
  Segmental.SNR = c(T,F,F,F,F,T,F,T,F,F,F,F),
  Long.SNR =      c(F,F,F,T,F,T,F,F,F,F,F,F),
  SDR =           c(F,F,F,F,F,T,F,F,F,F,F,F),
  SIR =           c(F,F,F,F,F,F,F,T,F,F,F,F),
  SAR =           c(F,F,F,F,F,F,F,T,F,F,F,F),
  SD =            c(F,F,F,F,F,T,F,F,F,F,F,F),
  Spectrogram  =  c(F,F,F,F,T,F,T,F,F,F,F,F))

humanMethods <- c("MOS", "PESQ")
machineMethods <- c("WRR", "PRR")

usesHuman <- apply(assessmentMethods[, humanMethods], 1,
                   function(x) any(x))
usesMachine <- apply(assessmentMethods[, machineMethods], 1,
                     function(x) any(x))

assessmentMethods$Paper.Uses <- "Neither"
assessmentMethods$Paper.Uses[usesHuman] <- "Human Only"
assessmentMethods$Paper.Uses[usesMachine] <- "Machine Only"
assessmentMethods$Paper.Uses[usesHuman & usesMachine] <- "Both"

assessmentMethods.tall <- melt(assessmentMethods, id=c("Paper", "Paper.Uses"))
assessmentMethods.tall <- assessmentMethods.tall[assessmentMethods.tall$value==T, -4]
colnames(assessmentMethods.tall)[3] <- "Assessment.Method"

assessmentMethods.tall$Type <- "Statistical / Other"
assessmentMethods.tall$Type[assessmentMethods.tall$Assessment.Method %in%
                         humanMethods] <- "Human Recognition"
assessmentMethods.tall$Type[assessmentMethods.tall$Assessment.Method %in%
                         machineMethods] <- "Machine Recognition"

p <- ggplot() +
  #geom_bar(data=assessmentMethods, aes(x=Paper, fill=Paper.Uses,
  #                                     y=rep(13, nrow(assessmentMethods))),
  #         stat="identity", alpha=0.5) +
  geom_point(data=assessmentMethods.tall, aes(x=Paper, y=Assessment.Method,
                                              color=Type), size=6) +
  theme_bw() + theme(axis.text.x = element_text(angle = 30, hjust = 1)) +
  ggtitle("Assessment Methods used in Literature") + ylab("Assessment Method") +
  scale_color_discrete(guide=guide_legend(keyheight=2, keywidth=2))
print(p)
pdf("fig/assessmentMethods.pdf",width=10,height=6)
print(p)
dev.off()