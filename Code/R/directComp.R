library(ggplot2)
library(gridExtra)

rm(list=ls());
data <- read.csv('litresults.csv',header=T);

xp <- "PRRimp";
yp <- "PESQimp";
cp <- "Algorithm";
sp <- "Name";

uniqueInitials <- c("K","l","1","2","3","4","B","M","P","p","R","S","c","e","W","w")
initialShapes <- unlist(lapply(uniqueInitials, utf8ToInt))

data.plot = data[complete.cases(data[,c(xp,yp)]),
                 c(xp,yp,cp,sp)]
p <- (ggplot(data.plot,aes(x=data.plot[,xp], y=data.plot[,yp],
                           color=data.plot[,cp], shape=data.plot[,sp])) +
   geom_point() +
   scale_colour_brewer(name=cp, type="div", palette="Set1") +
   #scale_shape(name=sp) +
   scale_shape_manual(values = initialShapes) +
   theme_bw() + xlab(xp) + ylab(yp))
# LOESS
p1 <- p + stat_smooth(method=loess, se=F, level=0.5) +
   ggtitle("Human vs. Machine Improvement (LOESS fit)");
# LM
p2 <- p + stat_smooth(method=lm, se=F, level=0.5) +
   ggtitle("Human vs. Machine Improvement (LM fit)");
print(grid.arrange(p1, p2))

pdf("fig/HumanMachinePaliwalLOESS.pdf",width=7,height=5)
print(p1)
dev.off()
pdf("fig/HumanMachinePaliwalLM.pdf",width=7,height=5)
print(p2)
dev.off()
pdf("fig/HumanMachinePaliwal.pdf",width=7,height=10)
print(grid.arrange(p1, p2))
dev.off()

# Get the stats
data.byClass <- split(data,data[,cp]);
n <- length(data.byClass);
classFit <- list();
fit.m <- numeric(n);
fit.c <- numeric(n);
fit.r2 <- numeric(n);
for (i in 1:n) {
  classDat <- data.byClass[[i]];
  className <- names(data.byClass)[i];
  classFit[className] <- tryCatch( {
    fit <- lm(y ~ x, data.frame(x=classDat[,xp], y=classDat[,yp]))
    fit.m[i] <- format(coef(fit)[2], digits = 3);
    fit.c[i] <- format(coef(fit)[1], digits = 3);
    fit.r2[i] <- format(summary(fit)$r.squared, digits = 4)
    (paste("y = ", fit.m[i],
                 "x + ", fit.c[i],
                 ", r2 = ", fit.r2[i], sep=""));
  }, error=function(cond) {
    return(NA);
  } );
}
cat(paste(names(data.byClass)[!is.na(classFit)],
          ":",
          classFit[!is.na(classFit)],
          collapse="\n"));
fit.sum <- data.frame(m=fit.m,
                      c=fit.c,
                      rsquared=fit.r2,
                      row.names=names(data.byClass));
fit.sum <- fit.sum[fit.sum$m!=0 | fit.sum$c!=0 | fit.sum$rsquared!=0,];
colnames(fit.sum) <- c("$m$","$c$","$r^2$");

write.table(fit.sum,"dat/HumanMachinePaliwal.csv", sep=",",
            col.names=NA,
            append=F, quote=F)