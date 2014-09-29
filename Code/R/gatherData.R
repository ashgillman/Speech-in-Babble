library(plyr)

loc <- "/Users/Ash/Documents/ThesisData/testdat/"
mosfile <- "/Users/Ash/Documents/ThesisData/testdat/MOSScores.csv"
prrfile <- "/Users/Ash/Documents/ThesisData/ASR/ClassifierTraining/Results/MFCOutput.txt"
outfile <- "dat/testResults.csv"

testDesc <- c("SoI = c3c(f)\nNoise = c3f(m)",
              "SoI = c3l(f)\nNoise = c31(m)",
              "SoI = c3s(m)\nNoise = c31(m)",
              "SoI = c3s(m)\nNoise = c31(m)+c34(m)+c35(m)",
              "SoI = c3s(m)\nNoise = c3f(m)+c3c(f)+c35(m)",
              "SoI = c3s(m)\nNoise = c3f(m)+c3c(f)",
              "SoI = c3s(m)\nNoise = c3f(m)",
              "SoI = c3s(m)\nNoise = NOIZEUS car",
              "SoI = c3s(m)\nNoise = NOIZEUS babble",
              "SoI = c3s(m)\nNoise = NOIZEUS street")

# tests to use
test <- c(1,2,3,4,5,6,7,8,9,10);

##### PESQ SEGSNR #####

# load PESQ and segSNR data
i <- 1
file <- paste0(loc, test[i], "/results.csv")
dnew <- read.csv(file, header=T);
dnew$testNo <- rep(i, nrow(dnew))
dnew$testName <- rep(testDesc[i], nrow(dnew))
if (!("phonemes" %in% colnames(dnew))) {
  dnew$phonemes <- rep(-1, nrow(dnew))
}
d <- dnew
if (length(test) > 1) {
  for (i in 2:length(test)) {
    file <- paste0(loc, test[i],"/results.csv")
    dnew <- read.csv(file, header=T);
    dnew$testNo <- rep(i, nrow(dnew))
    dnew$testName <- rep(testDesc[i], nrow(dnew))
    if (!("phonemes" %in% colnames(dnew))) {
      dnew$phonemes <- rep(-1, nrow(dnew))
    }
    d <- rbind(d, dnew)
  }
}
# NA flags
d$utterances[d$utterances==-1] <- NA
d$phonemes[d$phonemes==-1] <- NA

##### MOS #####

# load MOS data
mos <- read.csv(mosfile, header=T, na.strings="45")
mos <- mos[!(is.na(mos$MOS) & is.na(mos$MOSle) & is.na(mos$MOSlp) &
               is.na(mos$CCR)), ]
mos[!grepl("phoneme", mos$algorithm), "utterances"] <-
  mos[!grepl("phoneme", mos$algorithm), "utterances.phns"]
mos[grepl("phoneme", mos$algorithm), "phonemes"] <-
  mos[grepl("phoneme", mos$algorithm), "utterances.phns"]

# average MOS scores
by <- c("testNo", "algorithm", "Input.SNR", "utterances", "phonemes");
mos.MOS <- ddply(mos, by,
                 function(x) {
                   mean(x$MOS)
                 }, .drop=T)
colnames(mos.MOS)[length(by)+1] <- "MOS"
mos.MOSle <- ddply(mos, by,
                 function(x) {
                   mean(x$MOSle)
                 }, .drop=T)
colnames(mos.MOSle)[length(by)+1] <- "MOSle"
mos.CMOS <- ddply(mos, by,
                 function(x) {
                   mean(x$CCR)
                 }, .drop=T)
colnames(mos.CMOS)[length(by)+1] <- "CMOS"

# combine avg MOS scores
d <- merge(d, merge(mos.MOS, merge(mos.MOSle, mos.CMOS, by=by), by=by), by=by,
           all=T)

##### PRR #####

MAPPING = list('poo' = 'phonememodifiedOnline',
               'pos' = 'phonememodifiedSupervised',
               'pmo' = 'phonememohammadiaOnline',
               'pms' = 'phonememohammadiaSupervised',
               'umo' = 'mohammadiaOnline',
               'ums' = 'mohammadiaSupervised')

# Read PRR data
prr.txt <- readLines(prrfile, encoding="UTF-8")
prr.start <- which(grepl("File Results", prr.txt))[1] + 1
prr.end <- which(grepl("Overall Results", prr.txt))[1] - 1
prr.res <- prr.txt[prr.start:prr.end]

## Enhanced PRR ##

# extract meta from string
testNo <- as.numeric(lapply(strsplit(prr.res, "[^- 0-9]+"), "[", 1)) # 1st number
algorithm <- unlist(lapply(strsplit(prr.res, "[^a-z A-Z]+"), "[", 2)) # 2nd str
for (str in names(MAPPING)) {
  algorithm <- sub(str, MAPPING[str], algorithm) # map short names to full names
}
train <- unlist(lapply(strsplit(prr.res, "[^a-z A-Z]+"), "[", 3)) # 3rd str
utterances <- ifelse(train=="ut",
                     as.numeric(lapply(strsplit(prr.res, "[^- 0-9]+"), "[", 2)),
                     NA)
phonemes <- ifelse(train=="ph",
                   as.numeric(lapply(strsplit(prr.res, "[^- 0-9]+"), "[", 2)),
                   NA)
Input.SNR <- as.numeric(lapply(strsplit(prr.res, "[^- 0-9]+"), "[", 3)) # 3rd number

# extract results from str
res <- unlist(lapply(strsplit(prr.res,":"), "[", 2))
PRRcorr <- as.numeric(lapply(strsplit(res, "[^-.0-9]+"), "[", 2)) # 1st number
PRRacc <- as.numeric(lapply(strsplit(res, "[^-.0-9]+"), "[", 3)) # 2nd number
PRRdels <- as.numeric(lapply(strsplit(res, "[^-.0-9]+"), "[", 5))
PRRsubs <- as.numeric(lapply(strsplit(res, "[^-.0-9]+"), "[", 6))
PRRinss <- as.numeric(lapply(strsplit(res, "[^-.0-9]+"), "[", 7))
PRRn <- as.numeric(lapply(strsplit(res, "[^-.0-9]+"), "[", 8))

# into data frame
prr <- data.frame(testNo, algorithm, utterances, phonemes, Input.SNR, PRRcorr,
                  PRRacc, PRRdels, PRRsubs, PRRinss, PRRn)
prr <- prr[prr$algorithm != 'test',] # remove clean and dirty, enh only

## PRR Improvement ##

# extract meta from string
testNo <- as.numeric(lapply(strsplit(prr.res, "[^- 0-9]+"), "[", 1)) # 1st number
Input.SNR <- as.numeric(lapply(strsplit(prr.res, "[^- 0-9]+"), "[", 2)) # 2nd no

# dirty (unenhanced) into data frame
prrBef <- data.frame(testNo, Input.SNR, PRRcorr, PRRacc)
prrBef <- prrBef[grepl("test_dirty",prr.res),] # remove clean and dirty, enh only
colnames(prrBef) <- c("testNo", "Input.SNR", "PRRcorrBef", "PRRaccBef")

# calc improvement
prr <- merge(prr, prrBef, by=c("testNo", "Input.SNR"), all.x=T)
prr$PRRcorrImp <- prr$PRRcorr - prr$PRRcorrBef
prr$PRRaccImp <- prr$PRRacc - prr$PRRaccBef
prr <- subset(prr, select=-c(PRRcorrBef,PRRaccBef))

# combine PRR scores
d <- merge(d, prr, by=by, all=T)

##### Save to File #####

write.table(d, outfile, sep=",",
            row.names=F,
            append=F, quote=T)