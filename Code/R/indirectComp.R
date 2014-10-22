library(reshape2)
library(plyr)

rm(list=ls());
data <- read.csv('litresults.csv',header=T);

xp <- "Name";
yp <- "Score";
cp <- "Measure";
sp <- "Class";

tests <- c("SDR","SIR","SAR","SegSNR","PESQimp","MOSimp","STOIimp","WRR",
           "PRRimp");
types <- c("Statistical","Statistical","Statistical","Statistical","Human",
           "Human","Human","Machine","Machine")

data[,tests] <- scale(data[,tests]); # normalise test values (accross each test)
data <- melt(data[data$Input.SNR==0,c(xp,sp,tests)]); # reduce and make tall
data <- data[!is.na(data$value),]; # Remove NAs

# find algorithms rough average performance
data.avg <- ddply(data,~Name,summarise,mean=mean(value));

data.testMeas <- data.frame(variable=tests,type=types)

# order the data by performance
data <- merge(data,data.avg);
data <- merge(data,data.testMeas);

d <- ggplot(data, aes(x=reorder(Name,mean),y=value,color=variable)) +
  geom_point() + scale_colour_brewer(name="test", type="div", palette="Set1") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  facet_grid(.~type)

print(d)