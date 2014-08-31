rm(list=ls());
data <- read.csv('litresults.csv',header=T);

tests <- c("SDR","SIR","SAR","SegSNR","PESQimp","MOSimp","STOIimp","WRR",
           "PRRimp");

scores <- as.matrix(data[,tests])

scores.cor <- cor(scores,use="pairwise.complete.obs")

d <- ggplot(melt(scores.cor),aes(x=Var1,y=Var2,colour=value)) +
  geom_tile() + scale_fill_continuous()

print(d)