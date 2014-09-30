library(ggplot2)
library(gridExtra)
library(RColorBrewer)
library(corrgram)

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
                     "algorithm"])=
d$algorithm <- factor(d$algorithm, levels=algOrder)

# PESQ vs. MOS, no IDBM
corVal1 <- cor(d[, c("pesq", "MOS")], use="complete.obs")[2]
corVal2 <- cor(d[!grepl("IDBM", d$algorithm), c("pesq", "MOS")],
               use="complete.obs")[2]
p1 <- ggplot(d, aes(x=MOS, y=pesq, color=algorithm)) +
  geom_point() +
  geom_abline(aes(linetype="Expected (PESQ=MOS)"), intercept=0, slope=1) +
  scale_shape_discrete() +
  scale_color_manual(name="Algorithm", rainbow(10)) +
  ggtitle(paste0("With IDBM (cor = ", as.character(round(corVal1, 3)), ")")) +
  theme_bw() + ylab("PESQ")
p2 <- ggplot(d[!grepl("IDBM", d$algorithm),], aes(x=MOS, y=pesq,
                                                  color=factor(algorithm))) +
  geom_point() +
  geom_abline(aes(linetype="Expected (PESQ=MOS)"), intercept=0, slope=1) +
  scale_shape_discrete() +
  scale_color_manual(name="Algorithm", rainbow(10)) +
  ggtitle(paste0("Without IDBM (cor = ", as.character(round(corVal2, 3)), ")")) +
  theme_bw() + ylab("PESQ")
print(p1)
print(p2)
#saveLeg("fig/pair/my", "pesq-mos_leg",  g_legend(p1), w=2.5, h=3)
#p1 <- p1 + theme(legend.position="none")
#p2 <- p2 + theme(legend.position="none")
saveP("fig/pair/my", "pesq-mos", p1, w=7, h=6)
saveP("fig/pair/my", "pesq-mos_no-IDBM", p2, w=7, h=6)

# PRRacc vs. MOS
corMosCorr <- cor(d[, c("MOS", "PRRcorr")], use="complete.obs")[2]
corMosAcc <- cor(d[, c("MOS", "PRRacc")], use="complete.obs")[2]
corMosCorrImp <- cor(d[, c("CMOS", "PRRcorrImp")], use="complete.obs")[2]
corMosAccImp <- cor(d[, c("CMOS", "PRRaccImp")], use="complete.obs")[2]
pMosCorr <- ggplot(d[!is.na(d$MOS) & !is.na(d$PRRcorr),],
                   aes(x=PRRcorr, y=MOS, color=testName)) +
  geom_point() + geom_point(color="black", size=0.75) +
  geom_density2d(alpha=0.2, show_guide=F) +
  geom_point(size=50, alpha=0.02, show_guide=F) +
  scale_color_discrete(name="Test Name", drop=T) +
  theme_bw() + xlab("Correctness (PRR)") +
  ggtitle("MOS vs. ASR Correctness, Grouping Highlighted")
pMosAcc <- ggplot(d[!is.na(d$MOS) & !is.na(d$PRRacc),],
                  aes(x=PRRacc, y=MOS, color=testName)) +
  geom_point() +
  scale_color_discrete(name="Test Name", drop=T) +
  theme_bw() + xlab("Accuracy (PRR)") +
  ggtitle("MOS vs. ASR Accuracy")
pMosCorrImp <- ggplot(d[!is.na(d$CMOS) & !is.na(d$PRRcorrImp),],
                  aes(x=PRRcorrImp, y=CMOS, color=testName)) +
  geom_point() +
  scale_color_discrete(name="Test Name", drop=T) +
  theme_bw() + xlab("Correctness (PRR) Improvement") + ylab("Comparative MOS") +
  ggtitle("Comparative MOS vs. ASR Correctness Improvement, Grouping Highlighted")
pMosAccImp <- ggplot(d[!is.na(d$CMOS) & !is.na(d$PRRaccImp),],
                  aes(x=PRRaccImp, y=CMOS, color=testName)) +
  geom_point() +
  scale_color_discrete(name="Test Name", drop=T) +
  theme_bw() + xlab("Accuracy (PRR) Improvement") + ylab("Comparative MOS") +
  ggtitle("Comparative MOS vs. ASR Accuracy Improvement")
print(pMosCorr)
print(pMosAcc)
print(pMosCorrImp)
print(pMosAccImp)
saveP("fig/pair/my", "mos-prrcorr",
      pMosCorr + theme(legend.position="none"), w=7, h=6)
saveP("fig/pair/my", "mos-prracc",
      pMosAcc + theme(legend.position="none"), w=7, h=6)
saveP("fig/pair/my", "cmos-prrcorrimp",
      pMosCorrImp + theme(legend.position="none"), w=7, h=6)
saveP("fig/pair/my", "cmos-prraccimp",
      pMosAccImp + theme(legend.position="none"), w=7, h=6)
saveLeg("fig/pair/my", "cmos-prr-leg",
        g_legend(pMosCorr +
                   geom_point(size=3) +
                   theme(legend.position="bottom") +
                   scale_color_discrete(name="Test Name",
                                        guide=guide_legend(nrow=2,
                                                           keyheight=1.5,
                                                           keywidth=1.5))),
        w=7, h=1)