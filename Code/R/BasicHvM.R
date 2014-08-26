rm(list=ls());
data <- read.csv('litresults.csv',header=T);

# GET EQUATION AND R-SQUARED AS STRING
# SOURCE: http://goo.gl/K4yh
lm_eqn = function(df) {
  m = ml(y ~ x, df);
  eq <- substitute(italic(y) == a + b %.% italic(x)*","~~italic(r)^2~"="~r2, 
                   list(a = format(coef(m)[1], digits = 2), 
                        b = format(coef(m)[2], digits = 2), 
                        r2 = format(summary(m)$r.squared, digits = 3)))
  as.character(as.expression(eq));                 
}

data.plot = data[complete.cases(data[,c("PRRimp","PESQimp")]),
                 c("PRRimp","PESQimp","Class","ID")]
(d <- ggplot(data.plot,aes(x=PRRimp, y=PESQimp, color=Class, shape=ID)) +
   geom_point() + scale_colour_brewer(type="qual", palette="Set1") + 
   scale_shape() + 
   stat_smooth(method=gam, se=F, level=0.5) +
   theme_bw());

# Get the stats
data.byClass <- split(data,data$Class)
classFit = list()
for (className in names(data.byClass)) {
  classDat = data.byClass[[className]];
  classFit[className] = tryCatch( {
    fit =lm(y ~ x, data.frame(x=classDat$PRRimp, y=classDat$PESQimp))
    (paste("y = ", format(coef(fit)[2], digits = 2),
                 "x + ", format(coef(fit)[1], digits = 2),
                 ", r2 = ", format(summary(fit)$r.squared, digits = 3), sep=""));
  }, error = function(cond) {
    return(NA);
  } );
}
cat(paste(names(data.byClass)[!is.na(classFit)],
          ":",
          classFit[!is.na(classFit)],
          collapse="\n"))