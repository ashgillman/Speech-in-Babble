library(ggplot2)
library(corrgram)
library(plyr)

rm(list=ls());

figdir <- "fig/trainPh/"
dir.create(file.path(figdir),recursive=T,showWarnings=F)

file = "dat/testResults.csv"
d <- read.csv(file, header=T);

d$Input.SNR <- factor(d$Input.SNR)
d$testNo <- factor(d$testNo)

# filter
d <- d[!is.na(d$phonemes), ]

## plot funcs
plotBefAft <- function(d, xp, xName, yp, yName, cp, cName, xwp, ywp, title) {
  d <- d[!is.na(d[, xp]) & !is.na(d[, yp]), ]
  d$bef <- d[, yp] - d[, paste0(yp, "Imp")]
  p <- ggplot(d, aes_string(x=xp, y=yp, group=cp, colour=cp)) +
    geom_line(aes(linetype="enhanced")) +
    geom_line(aes(y=bef, linetype="dirty")) +
    scale_color_discrete(cName, drop=F) +
    scale_x_log10() +
    scale_linetype_manual("Enhanced?",
                          values=c("enhanced"="solid","dirty"="dashed")) +
    facet_grid(paste0(ywp, "~", xwp)) +
    theme_bw() + ggtitle(title) + xlab(xName) + ylab(yName) +
    theme(legend.position="bottom", legend.box = "horizontal")
  return(p)
}
plotSimple <- function(d, xp, xName, yp, yName, cp, cName, xwp, ywp, title) {
  d <- d[!is.na(d[, xp]) & !is.na(d[, yp]), ]
  p <- ggplot(d, aes_string(x=xp, y=yp, group=cp, colour=cp)) +
    geom_line() +
    scale_color_discrete(cName, drop=F) +
    scale_x_log10() +
    facet_grid(paste0(ywp, "~", xwp)) +
    theme_bw() + ggtitle(title) + xlab(xName) + ylab(yName) +
    theme(legend.position="bottom", legend.box = "horizontal")
  return(p)
}

## PESQ
p <- plotBefAft(d, "phonemes", "Phonemes", "pesq", "PESQ", "Input.SNR",
                "Input SNR", "testName", "algorithm", "PESQ Score")
print(p)
pdf(paste(figdir,"pesq.pdf",sep=""),width=11,height=16)
print(p)
dev.off()

p <- plotSimple(d, "phonemes", "Phonemes", "pesqImp", "PESQ Improvement",
                "Input.SNR", "Input SNR", "testName", "algorithm",
                "PESQ Improvement")
print(p)
pdf(paste(figdir,"pesqImp.pdf",sep=""),width=11,height=16)
print(p)
dev.off()

## SegSNR
p <- plotBefAft(d, "phonemes", "Phonemes", "segSNR", "Segmental SNR",
                "Input.SNR", "Input SNR", "testName", "algorithm",
                "Segmental SNR Score")
print(p)
pdf(paste(figdir,"segSNR.pdf",sep=""),width=11,height=16)
print(p)
dev.off()

p <- plotSimple(d, "phonemes", "Phonemes", "segSNRImp",
                "Segmental SNR Improvement", "Input.SNR", "Input SNR",
                "testName", "algorithm", "Segmental SNR Improvement")
print(p)
pdf(paste(figdir,"segSNRImp.pdf",sep=""),width=11,height=16)
print(p)
dev.off()

## MOS
p <- plotSimple(d, "phonemes", "Phonemes", "MOS", "MOS",
                "Input.SNR", "Input SNR", "testName", "algorithm",
                "MOS")
print(p)
pdf(paste(figdir,"MOS.pdf",sep=""),width=11,height=16)
print(p)
dev.off()

p <- plotSimple(d, "phonemes", "Phonemes", "MOSle", "MOS Listening Effort",
                "Input.SNR", "Input SNR", "testName", "algorithm",
                "MOS Listening Effort")
print(p)
pdf(paste(figdir,"MOSle.pdf",sep=""),width=11,height=16)
print(p)
dev.off()

p <- plotSimple(d, "phonemes", "Phonemes", "CMOS", "Comparative MOS",
                "Input.SNR", "Input SNR", "testName", "algorithm",
                "Comparative MOS")
print(p)
pdf(paste(figdir,"CMOS.pdf",sep=""),width=11,height=16)
print(p)
dev.off()

## PRR
p <- plotBefAft(d, "phonemes", "Phonemes", "PRRcorr", "Correctness PRR",
                "Input.SNR", "Input SNR", "testName", "algorithm",
                "Correctness PRR")
print(p)
pdf(paste(figdir,"PRRcorr.pdf",sep=""),width=11,height=16)
print(p)
dev.off()

p <- plotBefAft(d, "phonemes", "Phonemes", "PRRacc", "Accuracy PRR",
                "Input.SNR", "Input SNR", "testName", "algorithm",
                "Accuracy PRR")
print(p)
pdf(paste(figdir,"PRRacc.pdf",sep=""),width=11,height=16)
print(p)
dev.off()

p <- plotSimple(d, "phonemes", "Phonemes", "PRRinss", "PRR Insertions",
                "Input.SNR", "Input SNR", "testName", "algorithm",
                "PRR Insertions")
print(p)
pdf(paste(figdir,"PRRinss.pdf",sep=""),width=11,height=16)
print(p)
dev.off()

p <- plotSimple(d, "phonemes", "Phonemes", "PRRdels", "PRR Deletions",
                "Input.SNR", "Input SNR", "testName", "algorithm",
                "PRR Deletions")
print(p)
pdf(paste(figdir,"PRRdels.pdf",sep=""),width=11,height=16)
print(p)
dev.off()

p <- plotSimple(d, "phonemes", "Phonemes", "PRRsubs", "PRR Substitutions",
                "Input.SNR", "Input SNR", "testName", "algorithm",
                "PRR Substitutions")
print(p)
pdf(paste(figdir,"PRRsubs.pdf",sep=""),width=11,height=16)
print(p)
dev.off()