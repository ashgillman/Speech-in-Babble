# Anaylyses dat/testResults.csv, and plots performance against the number of
# utterances used in training.

library(ggplot2)
library(corrgram)
library(plyr)

rm(list=ls());

figdir <- "fig/train/"
dir.create(file.path(figdir),recursive=T,showWarnings=F)

file = "dat/testResults.csv"
d <- read.csv(file, header=T);

d$Input.SNR <- factor(d$Input.SNR)
d$testNo <- factor(d$testNo)

# filter
d <- d[(d$testNo %in% 1:7) & 
         (d$algorithm %in% c("mohammadiaOnline", "mohammadiaSupervised")), ]

## plot funcs
plotBefAft <- function(d, xp, xName, yp, yName, cp, cName, xwp, ywp, title) {
  d <- d[!is.na(d[, xp]) & !is.na(d[, yp]), ]
  d$bef <- d[, yp] - d[, paste0(yp, "Imp")]
  p <- ggplot(d, aes_string(x=xp, y=yp, group=cp, colour=cp)) +
    geom_line(aes(linetype="enhanced")) +
    geom_line(aes(y=bef, linetype="dirty")) +
    scale_color_discrete(cName) +
    scale_linetype_manual("Enhanced?",
                          values=c("enhanced"="solid","dirty"="dashed")) +
    facet_grid(paste0(ywp, "~", xwp)) +
    theme_bw() + ggtitle(title) + xlab(xName) + ylab(yName)
  return(p)
}
plotSimple <- function(d, xp, xName, yp, yName, cp, cName, xwp, ywp, title) {
  d <- d[!is.na(d[, xp]) & !is.na(d[, yp]), ]
  p <- ggplot(d, aes_string(x=xp, y=yp, group=cp, colour=cp)) +
    geom_line() +
    scale_color_discrete(cName) +
    facet_grid(paste0(ywp, "~", xwp)) +
    theme_bw() + ggtitle(title) + xlab(xName) + ylab(yName)
  return(p)
}

## PESQ
p <- plotBefAft(d, "utterances", "Utterances", "pesq", "PESQ", "Input.SNR",
                "Input SNR", "testName", "algorithm", "PESQ Score")
print(p)
pdf(paste(figdir,"pesq.pdf",sep=""),width=18,height=10)
print(p)
dev.off()

p <- plotSimple(d, "utterances", "Utterances", "pesqImp", "PESQ Improvement",
                "Input.SNR", "Input SNR", "testName", "algorithm",
                "PESQ Improvement")
print(p)
pdf(paste(figdir,"pesqImp.pdf",sep=""),width=18,height=10)
print(p)
dev.off()

## SegSNR
p <- plotBefAft(d, "utterances", "Utterances", "segSNR", "Segmental SNR",
                "Input.SNR", "Input SNR", "testName", "algorithm",
                "Segmental SNR Score")
print(p)
pdf(paste(figdir,"segSNR.pdf",sep=""),width=18,height=10)
print(p)
dev.off()

p <- plotSimple(d, "utterances", "Utterances", "segSNRImp",
                "Segmental SNR Improvement", "Input.SNR", "Input SNR",
                "testName", "algorithm", "Segmental SNR Improvement")
print(p)
pdf(paste(figdir,"segSNRImp.pdf",sep=""),width=18,height=10)
print(p)
dev.off()

## MOS
p <- plotSimple(d, "utterances", "Utterances", "MOS", "MOS",
                "Input.SNR", "Input SNR", "testName", "algorithm",
                "MOS")
print(p)
pdf(paste(figdir,"MOS.pdf",sep=""),width=18,height=10)
print(p)
dev.off()

p <- plotSimple(d, "utterances", "Utterances", "MOSle", "MOS Listening Effort",
                "Input.SNR", "Input SNR", "testName", "algorithm",
                "MOS Listening Effort")
print(p)
pdf(paste(figdir,"MOSle.pdf",sep=""),width=18,height=10)
print(p)
dev.off()

p <- plotSimple(d, "utterances", "Utterances", "CMOS", "Comparative MOS",
                "Input.SNR", "Input SNR", "testName", "algorithm",
                "Comparative MOS")
print(p)
pdf(paste(figdir,"CMOS.pdf",sep=""),width=18,height=10)
print(p)
dev.off()

## PRR
p <- plotBefAft(d, "utterances", "Utterances", "PRRcorr", "Correctness PRR",
                "Input.SNR", "Input SNR", "testName", "algorithm",
                "Correctness PRR")
print(p)
pdf(paste(figdir,"PRRcorr.pdf",sep=""),width=18,height=10)
print(p)
dev.off()

p <- plotBefAft(d, "utterances", "Utterances", "PRRacc", "Accuracy PRR",
                "Input.SNR", "Input SNR", "testName", "algorithm",
                "Accuracy PRR")
print(p)
pdf(paste(figdir,"PRRacc.pdf",sep=""),width=18,height=10)
print(p)
dev.off()