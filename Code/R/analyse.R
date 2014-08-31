rm(list=ls());
data <- read.csv('litresults.csv',header=T);
attach(data);

algorithms <- unique(Algorithm); # list of algorithms
# list of tests, (all rows after Input SNR)
tests <- colnames(data)[(grep("^Input.SNR$", colnames(data))+1):ncol(data)];
colours <- palette();

score.raw = matrix(nrow=length(algorithms),
                   ncol=length(tests),
                   dimnames=list(algorithms,tests));

for (i in 1:length(tests)) {
  test = tests[i];
  
  plot (range(Input.SNR), # x
        range(data[test],na.rm=T), # y
        type="n", # sets the x and y axes scales
        xlab="Input SNR",ylab=test); # adds titles to the axes
  
  for (j in 1:length(algorithms)) {
    a <- algorithms[j];
    print(a);
    X <- na.omit(data.frame(x=Input.SNR[Algorithm==a],
                            y=data[Algorithm==a,test]));
    
    if ((nrow(X) > 0)) { # interesting check
      points(X,col=colours[j]);
      if (nrow(unique(X["x"])) > 1) { # can only fit for multiple x vals
        fit <- lm(y~x,data=X) # Regression fit
        abline(fit,col=colours[j]);
        score.raw[j,i] <- fit[[1]][1]; # store intercept
      } else {
        fit <- mean(X[,"y"])
        abline(h=fit,col=colours[j])
        score.raw[j,i] <-fit; # store equiv. of intercept
      }
    }
  }
  par(xpd=F,mar=c(5, 4, 4, 7.5)+0.1) 
  title("Performance of Algorithms and Regression Fit")
  legend(max(Input.SNR) + 0.05*diff(range(Input.SNR)), # x (5% past max)
         max(data[test],na.rm=T), # y (in line with max)
         algorithms, # puts text in the legend
         xpd=T, # allows displaying outside limits
         lty=c(1,1), # gives the legend appropriate symbols (lines)
         lwd=c(2.5,2.5),col=colours); # gives the legend lines color and width
  #Sys.sleep(1)
}
score.z.trim <- score.raw[,-grep("raw",colnames(score.raw))];
score.z <- scale(score.z.trim);
score.z.m <- melt(score.z,varnames=c("Algorithm","Test"),value.name="score")
d <- ggplot(score.z.m, aes(x=Algorithm,y=Test));
(d <- d + geom_tile(aes(fill=score))
  + scale_fill_gradient(low="white", high="steelblue"))