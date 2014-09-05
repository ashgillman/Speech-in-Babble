library(ggplot2)
library(gridExtra)

rm(list=ls());
data <- read.csv('litresults.csv',header=T);

figdir <- "fig/dir/"

# Function to Extract Legend 
g_legend<-function(a.gplot){ 
  tmp <- ggplot_gtable(ggplot_build(a.gplot)) 
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box") 
  legend <- tmp$grobs[[leg]] 
  return(legend)} 

### PLOT UNGROUPED ###

# set plot params:
xp <- "PRRimp"; # x parameter
yp <- "PESQimp"; # y parameter
cp <- "Algorithm"; # colour parameter
sp <- "Name"; # shape parameter

# set highlighting, leave blank if desired
highlight <- c("pKLT","logMMSE-SPU-4")
hname <- paste(highlight,collapse="-")

# setup shapes
uniqueInitials <- c("K","l","1","2","3","4","B","M","P","p","R","S","c","e",
                    "W","w")
initialShapes <- unlist(lapply(uniqueInitials, utf8ToInt))

# plotting data
data.plot <- data[complete.cases(data[,c(xp,yp)]),
                 c(xp,yp,cp,sp)]
if (length(highlight)==0) {
  data.plot$highlight <- rep(1,nrow(data.plot))
} else {
  data.plot$highlight <- 1*data.plot[["Name"]] %in% highlight
}
p <- (ggplot(data.plot,aes(x=data.plot[,xp], y=data.plot[,yp],
                           color=data.plot[,cp], shape=data.plot[,sp],
                           alpha=data.plot$highlight)) +
  geom_point() +
  scale_colour_brewer(name="Algorithm Class", type="div", palette="Set1") +
  scale_shape_manual(name="Algorithm",values=initialShapes) +
  scale_alpha(guide = FALSE,range=c(0.3,1),limits=c(0,1)) +
  theme_bw() + xlab(xp) + ylab(yp))
# LOESS
p1 <- p + geom_line(stat="smooth",method=loess, se=F, level=0.5) +
  theme(legend.position = "none") +
  ggtitle("Human vs. Machine Improvement (LOESS fit)");
# LM
p2 <- p + geom_line(stat="smooth",method=lm, se=F, level=0.5) +
  theme(legend.position = "none") +
  ggtitle("Human vs. Machine Improvement (LM fit)");
print(grid.arrange(p1, p2))

# Save
dir.create(file.path(figdir, hname), showWarnings = FALSE)
pdf(paste(figdir,hname,"/HumanMachineAllLOESS.pdf",sep=""),width=7,height=5)
print(p1)
dev.off()
pdf(paste(figdir,hname,"/HumanMachineAllLM.pdf",sep=""),width=7,height=5)
print(p2)
dev.off()
pdf(paste(figdir,hname,"/HumanMachineAll.pdf",sep=""),width=7,height=10)
print(grid.arrange(p1, p2))
dev.off()
pdf(paste(figdir,hname,"/HumanMachineAllLegend.pdf",sep=""),width=2,height=6)
grid.draw(g_legend(p))
dev.off()

### PLOT UNGROUPED ###

sp <- "ID";

data.plot = data[complete.cases(data[,c(xp,yp)]),
                 c(xp,yp,cp,sp)]
p <- (ggplot(data.plot,aes(x=data.plot[,xp], y=data.plot[,yp],
                           color=data.plot[,cp], shape=data.plot[,sp])) +
        geom_point() +
        scale_colour_brewer(name="Class", type="div", palette="Set1") +
        scale_shape(name="Paper") +
        theme_bw() + xlab(xp) + ylab(yp))
# LOESS
p1 <- p + stat_smooth(method=loess, se=F, level=0.5) +
  ggtitle("Human vs. Machine Improvement (LOESS fit)");
# LM
p2 <- p + stat_smooth(method=lm, se=F, level=0.5) +
  ggtitle("Human vs. Machine Improvement (LM fit)");
print(grid.arrange(p1, p2))

pdf(paste(figdir,"HumanMachineGroupedLOESS.pdf"),width=7,height=5)
print(p1)
dev.off()
pdf(paste(figdir,"HumanMachineGroupedLM.pdf"),width=7,height=5)
print(p2)
dev.off()
pdf(paste(figdir,"HumanMachineGrouped.pdf"),width=7,height=10)
print(grid.arrange(p1, p2))
dev.off()

### GROUPED STATS ###

# Get the stats
data.byClass <- split(data,data[,cp]);
n <- length(data.byClass);
classFit <- list();
fit.m <- numeric(n); # slopes
fit.c <- numeric(n); # intercepts
fit.r2 <- numeric(n); # r^2
for (i in 1:n) {
  classDat <- data.byClass[[i]];
  className <- names(data.byClass)[i];
  classFit[className] <- tryCatch( {
    # do the fit
    fit <- lm(y ~ x, data.frame(x=classDat[,xp], y=classDat[,yp]))
    # save results
    fit.m[i] <- format(coef(fit)[2], digits = 3);
    fit.c[i] <- format(coef(fit)[1], digits = 3);
    fit.r2[i] <- format(summary(fit)$r.squared, digits = 4)
    # formatting
    (paste("y = ", fit.m[i],
                 "x + ", fit.c[i],
                 ", r2 = ", fit.r2[i], sep=""));
  }, error=function(cond) {
    # Couldn't fit
    return(NA);
  } );
}
# print to console
cat(paste(names(data.byClass)[!is.na(classFit)],
          ":",
          classFit[!is.na(classFit)],
          collapse="\n"));
# format results
fit.sum <- data.frame(m=fit.m,
                      c=fit.c,
                      rsquared=fit.r2,
                      row.names=names(data.byClass));
fit.sum <- fit.sum[fit.sum$m!=0 | fit.sum$c!=0 | fit.sum$rsquared!=0,];
colnames(fit.sum) <- c("$m$","$c$","$r^2$");

# save results
write.table(fit.sum,"dat/HumanMachinePaliwal.csv", sep=",",
            col.names=NA,
            append=F, quote=F)