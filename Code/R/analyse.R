attach(read.csv('litresults.csv',header=T));

plot (c(-10,17),c(0,1),type="n", # sets the x and y axes scales
      xlab="Input SNR",ylab="Word Recognition Rate (WRR)"); # adds titles to the axes 

algorithms <- unique(Algorithm);
tests <- colnames(data)[(grep("^Input.SNR$", colnames(data))+1):length(colnames(data))];
colours <- palette();

score.z = matrix(nrow=);

for (i in 1:length(algorithms)) {
  a <- algorithms[i];
  print(a);
  X <- na.omit(data.frame(x = Input.SNR[Algorithm==a],
                          y = WRR[Algorithm==a]));
  
  if (dim(X)[1]!=0) {
    fit <- lm(y~x,data=X) # Regression fit
    points(X,col=colours[i]);
    abline(fit,col=colours[i]);
  }
}
legend(11,1, # places a legend at the appropriate place
       algorithms, # puts text in the legend 
       lty=c(1,1), # gives the legend appropriate symbols (lines)
       lwd=c(2.5,2.5),col=colours); # gives the legend lines the correct color and width
