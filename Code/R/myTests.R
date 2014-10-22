library(ggplot2)
library(gridExtra)
library(RColorBrewer)
library(corrgram)
library(plyr)

rm(list=ls());
file = "dat/testResults.csv"
d <- read.csv(file, header=T);

figdir <- "fig/dir/my/"
fig <- "fig/my/"
dir.create(file.path(figdir), showWarnings = FALSE)
dir.create(file.path(fig), showWarnings = FALSE)

# Function to Extract Legend 
g_legend<-function(a.gplot){ 
  tmp <- ggplot_gtable(ggplot_build(a.gplot)) 
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box") 
  legend <- tmp$grobs[[leg]] 
  return(legend)}

# plot shapes
shapes <- utf8ToInt("123456789A")
shapes <- 0:9

##### CORRELOGRAM #####

corrField <- c("Input.SNR", "utterances", "phonemes", # test cond.
               "pesq", "pesqImp", "MOS", "MOSle", "CMOS", # human
               "PRRcorr", "PRRcorrImp", "PRRacc", "PRRaccImp", # machine
               "segSNR", "segSNRImp") # stat

source("myCorrgramPanels.R")

# correlogram
corrgram(d[corrField], upper.panel=panel.ptsAlpha, lower.panel=panel.shadeConf)
pdf(paste0(figdir, "corr.pdf"), width=20, height=20)
corrgram(d[corrField], upper.panel=panel.ptsAlpha, lower.panel=panel.shadeConf)
dev.off()

# correlogram where there is improvement (omit terrible algorithms)
d.imp <- d[(d$pesqImp > 0) | (d$CMOS > 0) | (d$PRRaccImp > 0) |
             (d$PRRcorrImp > 0),]
corrgram(d.imp[corrField], upper.panel=panel.ptsAlpha,
         lower.panel=panel.shadeConf)
pdf(paste0(figdir, "impCorr.pdf"), width=20, height=20)
corrgram(d.imp[corrField], upper.panel=panel.ptsAlpha,
         lower.panel=panel.shadeConf)
dev.off()

### PLOT (same as in lit results) ###

# set highlighting ("Name" field), leave blank for no highlighting
highlight <- c()
hname <- paste(highlight, collapse="-")

# set plot params:
xp <- "PRRcorrImp" # x parameter
yp <- "pesqImp" # y parameter
cp <- "algorithm" # colour parameter
sp <- "algorithm" # shape parameter
xwp <- "." # x wrap param
ywp <- "." # y wrap param

# data for plotting
myScatter <- function (d, xp, yp, cp, sp, xwp, ywp, title) {
  # plot colours
  colourCount <- length(unique(d[, cp]))
  getPalette <- colorRampPalette(rainbow(9))
  
  d.plot <- data.frame(x=d[, xp], y=d[, yp], col=factor(d[, cp]),
                       shape=factor(d[, sp]), sv=d[, sp])
  if (xwp != "." & xwp != "") {
    d.plot$xwp <- d[, xwp]
    xwp <- "xwp"
  }
  if (ywp != "." & ywp != "") {
    d.plot$ywp <- d[, ywp]
    ywp <- "ywp"
  }
  d.plot <- d.plot[complete.cases(d.plot[, c("x", "y")]), ]
  
  # highlighting
  if (length(highlight) == 0) {
    d.plot$highlight <- rep(1, nrow(d.plot))
  } else {
    d.plot$highlight <- 1*d.plot[["algorithm"]] %in% highlight
  }
  
  p <- ggplot(d.plot, aes(x=x, y=y, color=col, shape=shape, alpha=highlight)) +
    geom_point(size=3) +
    scale_colour_manual(values=getPalette(colourCount), name=cp) +
    scale_shape_manual(name=sp,
                       values=shapes[as.numeric(unique(d.plot$sv))]) +
    scale_alpha(guide = FALSE, range=c(0.3, 1), limits=c(0, 1)) +
    theme_bw() + xlab(xp) + ylab(yp) +
    ggtitle(title)
  if ((xwp != "." & xwp != "") | (ywp != "." & ywp != "")) {
    p <- p + facet_grid(paste0(ywp,'~',xwp)) # facet if req'd
  }
    
  return(p)
}

p <- myScatter(d, xp, yp, cp, sp, xwp, ywp, "Human vs. Machine Improvement")
print(p)

# Save
dir.create(file.path(figdir, hname), showWarnings=F)
pdf(paste0(figdir, hname, "/HumanMachineAll.pdf", sep=""), width=7, height=10)
print(p)
dev.off()

## again, only actually improved
d.reduct <- d[d$pesqImp > 0 & d$PRRcorrImp > 0, ]
p <- myScatter(d.reduct, xp, yp, cp, sp, xwp, ywp,
               "Human vs. Machine Improvement")
print(p)

## Results, eval method specific
myBoxPlot <- function (d, yParam, yName, savedir, doImprovement=F) {
  p <- ggplot(d, aes_string(x="algorithm", y=yParam, colour="testName")) +
    geom_boxplot() +
    geom_point(position=position_jitter(width=0.1), alpha=0.5) +
    scale_colour_discrete(name="Test", guide=guide_legend(nrow=2)) +
    theme_bw() + xlab("Algorithms") + ylab(paste(yName, "Score")) +
    theme(legend.position="bottom",
          axis.text.x=element_text(angle=15, hjust=0.8)) +
    ggtitle(paste(yName, "Results of Implemented Algorithms"))
  print(p)
  pdf(paste0(savedir, "/", yParam, ".pdf", sep=""), width=15, height=10)
  print(p)
  dev.off()
  if (doImprovement) {
    p <- ggplot(d, aes_string(x="algorithm", y=paste0(yParam, "Imp"),
                              colour="testName")) +
      geom_boxplot() +
      geom_point(position=position_jitter(width=0.1), alpha=0.5) +
      scale_colour_discrete(name="Test", guide=guide_legend(nrow=2)) +
      theme_bw() + xlab("Algorithms") + ylab(paste(yName, "Improvement")) +
      theme(legend.position="bottom",
            axis.text.x=element_text(angle=15, hjust=0.8)) +
      ggtitle(paste("Relative", yName,
                    "Results of Implemented Algorithms"))
    print(p)
    pdf(paste0(savedir, "/", yParam, "Imp.pdf", sep=""), width=15, height=10)
    print(p)
    dev.off()
  }
}

myBoxPlot(d, "pesq", "PESQ", fig, T)
myBoxPlot(d, "segSNR", "Segmental SNR", fig, T)
myBoxPlot(d, "MOS", "MOS", fig)
myBoxPlot(d, "MOSle", "MOS Listening Effort", fig)
myBoxPlot(d, "CMOS", "Comparative MOS", fig)
myBoxPlot(d, "PRRcorr", "ASR Phoneme Correctness", fig, T)
myBoxPlot(d, "PRRacc", "ASR Phoneme Accuracy", fig, T)

##### Some further scatterplots where interesting #####
saveP <- function(dir, name, p, w, h) {
  dir.create(dir, showWarnings=F, recursive=T)
  pdf(paste0(dir, "/", name, ".pdf"), width=w, height=h)
  print(p)
  dev.off()
}
saveLeg <- function(dir, name, p, w, h) {
  dir.create(dir, showWarnings=F, recursive=T)
  pdf(paste0(dir, "/", name, ".pdf"), width=w, height=h)
  grid.draw(p)
  dev.off()
}
algOrder <- unique(d[order(grepl("modified", d$algorithm) +
                             2 * grepl("MMSE", d$algorithm) +
                             3 * grepl("IDBM", d$algorithm)),
                     "algorithm"])
d$algorithm <- factor(d$algorithm, levels=algOrder)

# PESQ vs. MOS, w/ and w/o IDBM
corVal1 <- cor(d[, c("pesq", "MOS")], use="complete.obs")[2]
corVal2 <- cor(d[!grepl("IDBM", d$algorithm), c("pesq", "MOS")],
               use="complete.obs")[2]
p1 <- ggplot(d, aes(x=MOS, y=pesq, color=algorithm)) +
  geom_point() +
  scale_shape_discrete() +
  scale_color_manual(name="Algorithm", values=rainbow(10), drop=F) +
  ggtitle(paste0("With IDBM (correlation = ", as.character(round(corVal1, 3)), ")")) +
  theme_bw() + ylab("PESQ") + theme(legend.position="none")
p2 <- ggplot(d[!grepl("IDBM", d$algorithm),], aes(x=MOS, y=pesq,
                                                  color=factor(algorithm))) +
  geom_point() +
  scale_shape_discrete() +
  scale_color_manual(name="Algorithm", values=rainbow(10), drop=F) +
  ggtitle(paste0("Without IDBM (correlation = ", as.character(round(corVal2, 3)),
                 ")")) +
  theme_bw() + ylab("PESQ") + theme(legend.position="none")
print(p1)
print(p2)
saveLeg("fig/pair/my", "pesq-mos_leg",
        g_legend(p1 +
                   theme(legend.position="bottom") +
                   scale_color_discrete(name="Algorithm",
                                        guide=guide_legend(nrow=2,
                                                           keyheight=1.5,
                                                           keywidth=1.5))),
        w=10, h=1)
saveP("fig/pair/my", "pesq-mos", p1, w=7, h=6)
saveP("fig/pair/my", "pesq-mos_no-IDBM", p2, w=7, h=6)

# PESQimp vs. CMOS, w/ and w/o IDBM
corVal1 <- cor(d[, c("pesqImp", "CMOS")], use="complete.obs")[2]
corVal2 <- cor(d[!grepl("IDBM", d$algorithm), c("pesqImp", "CMOS")],
               use="complete.obs")[2]
p1 <- ggplot(d, aes(x=CMOS, y=pesqImp, color=algorithm)) +
  geom_point() +
  scale_shape_discrete() +
  scale_color_manual(name="Algorithm", values=rainbow(10), drop=F) +
  ggtitle(paste0("With IDBM (correlation = ", as.character(round(corVal1, 3)), ")")) +
  theme_bw() + ylab("PESQ Improvement") + theme(legend.position="none")
p2 <- ggplot(d[!grepl("IDBM", d$algorithm),], aes(x=CMOS, y=pesqImp,
                                                  color=factor(algorithm))) +
  geom_point() +
  scale_shape_discrete() +
  scale_color_manual(name="Algorithm", values=rainbow(10), drop=F) +
  ggtitle(paste0("Without IDBM (correlation = ", as.character(round(corVal2, 3)),
                 ")")) +
  theme_bw() + ylab("PESQ Imporvement") + theme(legend.position="none")
print(p1)
print(p2)
saveLeg("fig/pair/my", "pesqimp-cmos_leg",
        g_legend(p1 +
                   theme(legend.position="bottom") +
                   scale_color_discrete(name="Algorithm",
                                        guide=guide_legend(nrow=2,
                                                           keyheight=1.5,
                                                           keywidth=1.5))),
        w=10, h=1)
saveP("fig/pair/my", "pesqimp-cmos", p1, w=7, h=6)
saveP("fig/pair/my", "pesqimp-cmos_no-IDBM", p2, w=7, h=6)

# PRRacc vs. MOS by Test Cond.
pMosCorr <- ggplot(d[!is.na(d$MOS) & !is.na(d$PRRcorr),],
                   aes(x=PRRcorr, y=MOS, color=testName)) +
  geom_point() + geom_point(color="black", size=0.75) +
  geom_density2d(alpha=0.2, show_guide=F) +
  geom_point(size=50, alpha=0.02, show_guide=F) +
  scale_color_discrete(name="Test Name", drop=T) +
  theme_bw() + xlab("Correctness (PRR)") +
  ggtitle("MOS vs. ASR Correctness by Test Conditions, Grouping Highlighted")
pMosAcc <- ggplot(d[!is.na(d$MOS) & !is.na(d$PRRacc),],
                  aes(x=PRRacc, y=MOS, color=testName)) +
  geom_point() +
  scale_color_discrete(name="Test Name", drop=T) +
  theme_bw() + xlab("Accuracy (PRR)") +
  ggtitle("MOS vs. ASR Accuracy by Test Conditions")
pMosCorrImp <- ggplot(d[!is.na(d$CMOS) & !is.na(d$PRRcorrImp),],
                  aes(x=PRRcorrImp, y=CMOS, color=testName)) +
  geom_point() +
  scale_color_discrete(name="Test Name", drop=T) +
  theme_bw() + xlab("Correctness (PRR) Improvement") + ylab("Comparative MOS") +
  ggtitle("Comparative MOS vs. ASR Correctness Improvement by Test Conditions")
pMosAccImp <- ggplot(d[!is.na(d$CMOS) & !is.na(d$PRRaccImp),],
                  aes(x=PRRaccImp, y=CMOS, color=testName)) +
  geom_point() +
  scale_color_discrete(name="Test Name", drop=T) +
  theme_bw() + xlab("Accuracy (PRR) Improvement") + ylab("Comparative MOS") +
  ggtitle("Comparative MOS vs. ASR Accuracy Improvement by Test Conditions")
print(pMosCorr)
print(pMosAcc)
print(pMosCorrImp)
print(pMosAccImp)
saveP("fig/pair/byTest", "mos-prrcorr",
      pMosCorr + theme(legend.position="none"), w=7, h=6)
saveP("fig/pair/byTest", "mos-prracc",
      pMosAcc + theme(legend.position="none"), w=7, h=6)
saveP("fig/pair/byTest", "cmos-prrcorrimp",
      pMosCorrImp + theme(legend.position="none"), w=7, h=6)
saveP("fig/pair/byTest", "cmos-prraccimp",
      pMosAccImp + theme(legend.position="none"), w=7, h=6)
saveLeg("fig/pair/byTest", "mos-prr-leg",
        g_legend(pMosCorr +
                   geom_point(size=3) +
                   theme(legend.position="bottom") +
                   scale_color_discrete(name="Test Name",
                                        guide=guide_legend(nrow=2,
                                                           keyheight=1.5,
                                                           keywidth=1.5))),
        w=7, h=1)

# PRRacc vs. MOS by Alg.
pMosCorr <- ggplot(d[!is.na(d$MOS) & !is.na(d$PRRcorr),],
                   aes(x=PRRcorr, y=MOS, color=algorithm)) +
  geom_point() + geom_point(color="black", size=0.75) +
  geom_density2d(alpha=0.2, show_guide=F) +
  geom_point(size=50, alpha=0.02, show_guide=F) +
  scale_color_discrete(name="Test Name", drop=T) +
  theme_bw() + xlab("Correctness (PRR)") +
  ggtitle("MOS vs. ASR Correctness by Algorithm")
pMosAcc <- ggplot(d[!is.na(d$MOS) & !is.na(d$PRRacc),],
                  aes(x=PRRacc, y=MOS, color=algorithm)) +
  geom_point() + geom_point(color="black", size=0.75) +
  geom_density2d(alpha=0.2, show_guide=F) +
  geom_point(size=50, alpha=0.02, show_guide=F) +
  scale_color_discrete(name="Test Name", drop=T) +
  theme_bw() + xlab("Accuracy (PRR)") +
  ggtitle("MOS vs. ASR Accuracy by Algorithm")
pMosCorrImp <- ggplot(d[!is.na(d$CMOS) & !is.na(d$PRRcorrImp),],
                      aes(x=PRRcorrImp, y=CMOS, color=algorithm)) +
  geom_point() + geom_point(color="black", size=0.75) +
  geom_density2d(alpha=0.2, show_guide=F) +
  geom_point(size=50, alpha=0.02, show_guide=F) +
  scale_color_discrete(name="Test Name", drop=T) +
  theme_bw() + xlab("Correctness (PRR) Improvement") + ylab("Comparative MOS") +
  ggtitle("Comparative MOS vs. ASR Correctness Improvement by Algorithm")
pMosAccImp <- ggplot(d[!is.na(d$CMOS) & !is.na(d$PRRaccImp),],
                     aes(x=PRRaccImp, y=CMOS, color=algorithm)) +
  geom_point() + geom_point(color="black", size=0.75) +
  geom_density2d(alpha=0.2, show_guide=F) +
  geom_point(size=50, alpha=0.02, show_guide=F) +
  scale_color_discrete(name="Test Name", drop=T) +
  theme_bw() + xlab("Accuracy (PRR) Improvement") + ylab("Comparative MOS") +
  ggtitle("Comparative MOS vs. ASR Accuracy Improvement by Algorithm")
print(pMosCorr)
print(pMosAcc)
print(pMosCorrImp)
print(pMosAccImp)
saveP("fig/pair/byAlg", "mos-prrcorr",
      pMosCorr + theme(legend.position="none"), w=7, h=6)
saveP("fig/pair/byAlg", "mos-prracc",
      pMosAcc + theme(legend.position="none"), w=7, h=6)
saveP("fig/pair/byAlg", "cmos-prrcorrimp",
      pMosCorrImp + theme(legend.position="none"), w=7, h=6)
saveP("fig/pair/byAlg", "cmos-prraccimp",
      pMosAccImp + theme(legend.position="none"), w=7, h=6)
saveLeg("fig/pair/byAlg", "mos-prr-leg",
        g_legend(pMosCorr +
                   geom_point(size=3) +
                   theme(legend.position="bottom") +
                   scale_color_discrete(name="Algorithm",
                                        guide=guide_legend(nrow=2,
                                                           keyheight=1.5,
                                                           keywidth=1.5))),
        w=10, h=1)
saveLeg("fig/pair/byAlg", "mos-prr-legV",
        g_legend(pMosCorr +
                   geom_point(size=3) +
                   theme(legend.position="right") +
                   scale_color_discrete(name="Algorithm",
                                        guide=guide_legend(ncol=1,
                                                           keyheight=1.5,
                                                           keywidth=1.5))),
        w=2.5, h=3.5)

##### Box of moh and mod, phoneme comparison #####
## Results, eval method specific
myBoxPlot <- function (d, yParam, yName, savedir, doImprovement=F) {
  p <- ggplot(d, aes_string(x="algorithm", y=yParam, colour="testName")) +
    geom_boxplot() +
    geom_point(position=position_jitter(width=0.1), alpha=0.5) +
    scale_colour_discrete(name="Test", guide=guide_legend(nrow=2)) +
    theme_bw() + xlab("Algorithms") + ylab(paste(yName, "Score")) +
    theme(legend.position="none",
          axis.text.x=element_text(angle=15, hjust=0.8)) +
    ggtitle(paste(yName, "Results of Implemented Algorithms"))
  print(p)
  pdf(paste0(savedir, "/", yParam, ".pdf", sep=""), width=15, height=10)
  print(p)
  dev.off()
  saveLeg(savedir, paste0(yParam, "_leg.pdf"),
          g_legend(p +
                     theme(legend.position="right") +
                     scale_color_discrete(name="Algorithm",
                                          guide=guide_legend(ncol=1,
                                                             keyheight=1.5,
                                                             keywidth=1.5))),
          w=2.5, h=3.5)
  if (doImprovement) {
    p <- ggplot(d, aes_string(x="algorithm", y=paste0(yParam, "Imp"),
                              colour="testName")) +
      geom_boxplot() +
      geom_point(position=position_jitter(width=0.1), alpha=0.5) +
      scale_colour_discrete(name="Test", guide=guide_legend(nrow=2)) +
      theme_bw() + xlab("Algorithms") + ylab(paste(yName, "Improvement")) +
      theme(legend.position="bottom",
            axis.text.x=element_text(angle=15, hjust=0.8)) +
      ggtitle(paste("Relative", yName,
                    "Results of Implemented Algorithms"))
    print(p)
    pdf(paste0(savedir, "/", yParam, "Imp.pdf", sep=""), width=15, height=10)
    print(p)
    dev.off()
  }
}

algs <- c("mohammadiaOnline", "phonememohammadiaOnline",
          "phonememodifiedOnline",
          "mohammadiaSupervised", "phonememohammadiaSupervised",
          "phonememodifiedSupervised")
newLab <- c("Mohammadia (Online)", "Phn Train Mohammadia (Online)",
          "Phoneme Base (Online)",
          "Mohammadia (Supervised)", "Phn Train Mohammadia (Supervised)",
          "Phoneme Base (Supervised)")
d.plot <- d[(d$algorithm %in% algs) & (d$testNo %in% c(5, 7, 8, 9, 10)), ]
d.plot$algorithm <- factor(d.plot$algorithm, levels=algs)
for (i in 1:length(algs)) {
  d.plot$algLab[d.plot$algorithm == algs[i]] <- newLab[i]
}
d.plot$algLab <- factor(d.plot$algLab, levels=newLab)
d.plot$algorithm <- d.plot$algLab

folder <- paste0(fig, "phnComp")
dir.create(folder, showWarnings=F)
myBoxPlot(d.plot, "pesq", "PESQ", folder, T)
myBoxPlot(d.plot, "segSNR", "Segmental SNR", folder, T)
myBoxPlot(d.plot, "PRRcorr", "ASR Phoneme Correctness", folder, T)
myBoxPlot(d.plot, "PRRacc", "ASR Phoneme Accuracy", folder, T)

myBoxPlot(d.plot, "MOS", "MOS", folder)
myBoxPlot(d.plot, "MOSle", "MOS Listening Effort", folder)
myBoxPlot(d.plot, "CMOS", "Comparative MOS", folder)

##### Phoneme Comparison x-y #####
evalMethods <- list("PRRcorrImp"="Machine Correctness Improvement",
                    "PRRaccImp"="Machine Accuracy Improvement",
                    "PRRcorr"="Machine Correctness",
                    "PRRacc"="Machine Accuracy",
                    "segSNR"="Segmental SNR",
                    "segSNRImp"="Segmental SNR Improvement",
                    "MOS"="MOS", "MOSle"="MOS Listening Effort",
                    "CMOS"="CMOS", "pesq"="PESQ")
by <- c("testName", "algorithm", "Input.SNR")

folder <- paste0(fig, "phnCompXY/")
dir.create(folder, showWarnings=F)

for (evalMethod in names(evalMethods)) {
  d.plot <- d[(d$testNo %in% c(5, 7, 8, 9, 10)) &
                !is.na(d[, evalMethod]),
              c(evalMethod, by)]
  d.plot$val <- d.plot[, evalMethod]
  
  # before phn mod
  d.bef <- d.plot[!grepl("phoneme", d.plot$algorithm), ]
  #d.bef$algorithm <- sub("mohammadia", "", d.bef$algorithm)
  d.bef <- ddply(d.bef, by, summarise, val=mean(val))
  
  # train phn mod
  d.trn <- d.plot[grepl("phoneme", d.plot$algorithm) &
                    !grepl("modified", d.plot$algorithm), ]
  d.trn$algorithm <- sub("phoneme", "", d.trn$algorithm)
  d.trn <- ddply(d.trn, by, summarise, val=mean(val))
  d.trn$Type <- "Phoneme Trained"
  
  # base phn mod
  d.bas <- d.plot[grepl("modified", d.plot$algorithm), ]
  d.bas$algorithm <- sub("phonememodified", "mohammadia", d.bas$algorithm)
  d.bas <- ddply(d.bas, by, summarise, val=mean(val))
  d.bas$Type <- "Phoneme Dictionary (Modified)"
  
  d.trn <- merge(d.bef, d.trn, by=by)
  d.bas <- merge(d.bef, d.bas, by=by)

  d.plot <- rbind(d.trn,d.bas)
  d.plot$Type <- factor(d.plot$Type,
                        levels=c(unique(d.trn$Type), unique(d.bas$Type)))
  d.min <- min(d.plot$val.x, d.plot$val.y)
  d.max <- max(d.plot$val.x, d.plot$val.y)
  d.minmax <- c(d.min, d.max)
  
  p <- ggplot(data=d.plot) +
    geom_ribbon(data=data.frame(x=d.minmax, y=d.minmax),
                aes(x=x, ymax=y), ymin=d.min, fill="red", alpha=0.05) +
    geom_ribbon(data=data.frame(x=d.minmax, y=d.minmax),
                aes(x=x, ymin=y), ymax=d.max, fill="green", alpha=0.05) +
    geom_ribbon(data=data.frame(x=c(0, d.max), y=d.minmax),
                aes(x=x), ymin=d.min, ymax=0, fill="red", alpha=0.05) +
    geom_ribbon(data=data.frame(x=c(d.min, 0), y=d.minmax),
                aes(x=x), ymin=0, ymax=d.max, fill="green", alpha=0.05) +
    geom_point(aes(x=val.x, y=val.y, color=algorithm,
                   shape=factor(testName), linetype=factor(testName))) +
    stat_smooth(aes(x=val.x, y=val.y, color=algorithm,
                    shape=factor(testName), linetype=factor(testName)), method=lm, se=F) +
    geom_abline(intercept=0,slope=1) +
    facet_grid(~Type) +
    scale_x_continuous(limits=d.minmax) +
    scale_y_continuous(limits=d.minmax) +
    scale_linetype_discrete(name="Noise Type",
                            guide=guide_legend(keyheight=2,
                                               keywidth=2)) +
    scale_color_discrete(name="Algorithm",
                         guide=guide_legend(keyheight=2,
                                            keywidth=2)) +
    scale_shape(name="Noise Type",
                guide=guide_legend(keyheight=2,
                                   keywidth=2)) +
    theme_bw() + xlab("Score Before Modifications") +
    ylab("Score With Phoneme Modifications") + ggtitle(evalMethods[[evalMethod]])
  print(p)
  pdf(paste0(folder, evalMethod, ".pdf", sep=""), width=12.5, height=5)
  print(p)
  dev.off()
}

##### For Presentation #####

evalMethods <- list("PRRcorrImp"="Machine Correctness Improvement",
                    "PRRaccImp"="Machine Accuracy Improvement",
                    "CMOS"="CMOS", "pesq"="PESQ")

ignorealgs <- c("IDBM", "MMSE")

folder <- paste0(fig, "phnCompXY/poster/")
dir.create(folder, showWarnings=F)

for (evalMethod in names(evalMethods)) {
  d.plot <- d[(d$testNo %in% c(5, 7, 8, 9, 10)) &
                !is.na(d[, evalMethod]) & 
                !d$algorithm %in% ignorealgs,
              c(evalMethod, by)]
  d.plot$val <- d.plot[, evalMethod]
  
  # before phn mod
  d.bef <- d.plot[!grepl("phoneme", d.plot$algorithm), ]
  #d.bef$algorithm <- sub("mohammadia", "", d.bef$algorithm)
  d.bef <- ddply(d.bef, by, summarise, val=mean(val))
  
  # train phn mod
  d.trn <- d.plot[grepl("phoneme", d.plot$algorithm) &
                    !grepl("modified", d.plot$algorithm), ]
  d.trn$algorithm <- sub("phoneme", "", d.trn$algorithm)
  d.trn <- ddply(d.trn, by, summarise, val=mean(val))
  d.trn$Type <- "Phoneme Trained"
  
  d.plot <- merge(d.bef, d.trn, by=by)
  
  d.plot$Type <- factor(d.plot$Type,
                        levels=c(unique(d.trn$Type), unique(d.bas$Type)))
  d.min <- min(d.plot$val.x, d.plot$val.y)
  d.max <- max(d.plot$val.x, d.plot$val.y)
  d.minmax <- c(d.min, d.max)
  
  p <- ggplot(data=d.plot) +
    geom_ribbon(data=data.frame(x=d.minmax, y=d.minmax),
                aes(x=x, ymax=y), ymin=d.min, fill="red", alpha=0.05) +
    geom_ribbon(data=data.frame(x=d.minmax, y=d.minmax),
                aes(x=x, ymin=y), ymax=d.max, fill="green", alpha=0.05) +
    geom_ribbon(data=data.frame(x=c(0, d.max), y=d.minmax),
                aes(x=x), ymin=d.min, ymax=0, fill="red", alpha=0.05) +
    geom_ribbon(data=data.frame(x=c(d.min, 0), y=d.minmax),
                aes(x=x), ymin=0, ymax=d.max, fill="green", alpha=0.05) +
    geom_point(aes(x=val.x, y=val.y, color=algorithm,
                   shape=factor(testName), linetype=factor(testName))) +
    stat_smooth(aes(x=val.x, y=val.y, color=algorithm,
                    shape=factor(testName), linetype=factor(testName)), method=lm, se=F) +
    geom_abline(intercept=0,slope=1) +
    facet_grid(~Type) +
    scale_x_continuous(limits=d.minmax) +
    scale_y_continuous(limits=d.minmax) +
    scale_linetype_discrete(name="Noise Type",
                            guide=guide_legend(keyheight=2,
                                               keywidth=2)) +
    scale_color_discrete(name="Algorithm",
                         guide=guide_legend(keyheight=2,
                                            keywidth=2)) +
    scale_shape(name="Noise Type",
                guide=guide_legend(keyheight=2,
                                   keywidth=2)) +
    theme_bw() + xlab("Score Before Modifications") +
    ylab("Score With Phoneme Modifications") + ggtitle(evalMethods[[evalMethod]]) +
  theme(legend.position="none")
  print(p)
  pdf(paste0(folder, evalMethod, ".pdf", sep=""), width=5, height=5)
  print(p)
  dev.off()
  saveLeg(folder, "leg",
          g_legend(p +
                     theme(legend.position="bottom")),
          w=11, h=1.1)
}