loc <- "/Users/Ash/Documents/ThesisData/testdat/"
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

# load data
i <- 1
file <- paste0(loc,test[i],"/results.csv")
dnew <- read.csv(file,header=T);
dnew$testNo <- rep(i,nrow(dnew))
dnew$testName <- rep(testDesc[i],nrow(dnew))
if (!("phonemes" %in% colnames(dnew))) {
  dnew$phonemes <- rep(-1,nrow(dnew))
}
d <- dnew
if (length(test) > 1) {
  for (i in 2:length(test)) {
    file <- paste0(loc,test[i],"/results.csv")
    dnew <- read.csv(file,header=T);
    dnew$testNo <- rep(i,nrow(dnew))
    dnew$testName <- rep(testDesc[i],nrow(dnew))
    if (!("phonemes" %in% colnames(dnew))) {
      dnew$phonemes <- rep(-1,nrow(dnew))
    }
    d <- rbind(d,dnew)
  }
}

# clean not tested flages
d$utterances[d$utterances==-1] <- NA
d$phonemes[d$phonemes==-1] <- NA

write.table(d,outfile, sep=",",
            row.names=F,
            append=F, quote=T)