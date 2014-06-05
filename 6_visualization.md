
```
## (C) (cc by-sa) Wouter van Atteveldt, file generated juni 06 2014
```


> Note on the data used in this howto: 
> This data can be downloaded from http://piketty.pse.ens.fr/files/capital21c/en/xls/, 
> but the excel format is a bit difficult to parse at it is meant to be human readable, with multiple header rows etc. 
> For that reason, I've extracted csv files for some interesting tables that I've uploaded to 
> http://vanatteveldt.com/uploads/rcourse/data

Plotting data in R
===

In this hands-on we continue with the `capital` variable created in the [transforming data howto](4_transforming.md).
You can also download this variable from the course pages:


```r
download.file("http://vanatteveldt.com/uploads/rcourse/data/capital.rdata", 
    destfile = "capital.rdata")
load("capital.rdata")
head(capital)
```

```
##   Year   Country Public Private Total
## 1 1970 Australia   0.61    3.30  3.91
## 2 1970    Canada   0.37    2.47  2.84
## 3 1970    France   0.41    3.10  3.51
## 4 1970   Germany   0.88    2.25  3.13
## 5 1970     Italy   0.20    2.39  2.59
## 6 1970     Japan   0.61    2.99  3.60
```


We also make a 'wide' vesion of this data frame using melt, and we turn the first column into the row names so all columns contain actual data:


```r
library(reshape)
wide = cast(capital, Year ~ Country, value = "Total")
head(wide)
```

```
##   Year U.S. Japan Germany France U.K. Italy Canada Australia Spain
## 1 1970 4.03  3.60    3.13   3.51 3.65  2.59   2.84      3.91    NA
## 2 1971 4.05  3.95    3.09   3.47 3.97  2.61   2.91      4.03    NA
## 3 1972 4.13  4.44    3.10   3.52 4.33  2.69   2.91      4.12    NA
## 4 1973 4.04  4.79    3.06   3.51 4.33  2.63   2.86      4.18    NA
## 5 1974 3.95  4.77    3.10   3.51 4.48  2.93   2.83      4.26    NA
## 6 1975 3.97  4.68    3.16   3.70 4.03  3.26   2.88      4.33    NA
```


Plotting multiple lines with a loop
----

In many cases, just calling ~plot~ on an R object gives a good quick visualizations.
Sometimes, however, we want to have more control over the exact placing and look of a graph, e.g. to prepare a graph for publication.
In such cases, it is usually best to start with an empty plot, and then put in all the plot elements such as the lines but also the axes, legend, etc.
We first determine the needed x and y limits to fit all the data, and then plot an empty plot with those limits:



```r
ylim = c(min(wide[-1], na.rm = T), max(wide[-1], na.rm = T))
xlim = c(min(wide$Year), max(wide$Year))
plot(0, type = "n", xlim = xlim, ylim = ylim, frame.plot = F, xlab = "Year", 
    ylab = "Capital", axes = F, main = "Capital accumulation as proportion of national income")
```

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4.png) 


This gives us an empty 'canvas' to start drawing plot elements in. Let's add lines, axes, a legend, and a dashed horizontal line at y=0.  For plotting multiple lines, it is often best to use a for loop over the data frame columns, and draw from a predefined color set such as the ~rainbow~ colors. 



```r
plot(0, type = "n", xlim = xlim, ylim = ylim, frame.plot = F, xlab = "Year", 
    ylab = "Capital", axes = F, main = "Capital accumulation as proportion of national income")
axis(2)  # normal vertical axis
axis(1, at = seq(xlim[1], xlim[2], 5), las = 2)  # specify vertical ticks every 5 years
colors = rainbow(ncol(wide))
for (i in 2:ncol(wide)) {
    lines(x = wide$Year, y = wide[[i]], col = colors[i])
}
legend("topleft", legend = colnames(wide)[-1], col = colors[-1], lty = 1, cex = 0.65, 
    ncol = 2)
# regression line for US case
abline(lm(U.S. ~ Year, wide), col = colors[2], lty = 2)
```

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5.png) 


*Note*: In RStudio, the exact positioning of plot elements is determined by the size of the plot window.
If you are preparing a plot for publication, you normally want to produce an external plot.
It is usually best to create the plot as a file directly and open it in a second window in a photo viewer, 
so the positioning is correct for the file, rather than for the RStudio window. 
You create a plot file by opening it using the `png` function, running the plot commands, and then closing the file with `dev.off()`.

```
png("fig1.png", width=1600, height=1200)
... plot commands ...
dev.off()
```

Bar plots
----

The visualizations so far were mainly line graphs.
We could also create a bar plot of e.g. the average accumulation of capital per country:


```r
total.capital = aggregate(capital$Total, capital["Country"], FUN = mean)
barplot(total.capital$x, names.arg = total.capital$Country, las = 2)
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6.png) 


We can also put e.g. the public and private wealth side by side.
Annoyingly, the barplot function needs a matrix with the countries in the columns,
so we use `as.matrix` to convert the aggregated data to a matrix form, and then use `t()` to transpose it;


```r
total.capital = aggregate(capital[c("Public", "Private")], capital["Country"], 
    FUN = mean)
m = t(as.matrix(total.capital[-1]))
m
```

```
##           [,1]   [,2]   [,3]   [,4]   [,5]   [,6]     [,7]   [,8] [,9]
## Public  0.4944 0.6939 0.5012 0.3961 0.6137 -0.329 -0.05683 0.7366   NA
## Private 3.8271 5.2834 3.0371 3.6717 4.0017  4.530  3.13439 4.0298   NA
```

```r
barplot(m, names.arg = total.capital$Country, las = 2, beside = T, col = rainbow(2), 
    ylim = c(0, 6))
legend("top", c("Public", "Private"), fill = rainbow(2), ncol = 2)
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7.png) 


Combined bar/line plots
---

Sometimes it is more intuitive to combine bars and lines into a single plot. 
For example, we could combine the capital data with the inequality data used earlier and plot the latter as a line.
First, we download the income data again, select the years from 1970, and melt the data into the same form as `capital`:

```r
library(plyr)
```

```
## 
## Attaching package: 'plyr'
## 
## The following objects are masked from 'package:reshape':
## 
##     rename, round_any
```

```r
download.file("http://vanatteveldt.com/wp-content/uploads/rcourse/data/income_toppercentile.csv", 
    destfile = "income_toppercentile.csv")
income = read.csv("income_toppercentile.csv")
income = rename(income, c(US = "U.S."))
income = income[income$Year >= 1970, ]
income.long = melt(income, id.vars = "Year", na.rm = T)
colnames(income.long) = c("Year", "Country", "income")
head(income.long)
```

```
##   Year Country income
## 1 1970  Canada  0.090
## 2 1971  Canada  0.089
## 3 1972  Canada  0.088
## 4 1973  Canada  0.088
## 5 1974  Canada  0.088
## 6 1975  Canada  0.087
```


Now, we can compute the total income inequality and combine that with the capital accumulation:


```r
total.income = aggregate(income.long["income"], income.long["Country"], FUN = mean)
total = merge(total.capital, total.income)
total
```

```
##     Country   Public Private  income
## 1 Australia  0.73659   4.030 0.06792
## 2    Canada -0.05683   3.134 0.10076
## 3    France  0.39610   3.672 0.08095
## 4     Italy -0.32902   4.530 0.07968
## 5     Spain       NA      NA 0.08217
## 6      U.S.  0.49439   3.827 0.14600
```


Note that by default, merge only keeps rows for with both data frames have values.
By specifying `all=T` you can keep all rows, getting NA for missing values. 
Note that we need to specify a secondary axis for the inequality to account for the different scale. 


```r
par(mar = c(5, 5, 5, 5))
x = barplot(total$Private, names.arg = total$Country, las = 2, ylab = "Capital accumulation")
lines(x = x, y = total$income * 20)
axis(side = 4, at = 0:5, labels = 0:5 * 20)
mtext("Top percentile share of income", 4, line = 3)
```

![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10.png) 


Scatter plots
---

We can also create a scatter plot of inequality versus capital accumulation:


```r
plot(x = total$Private, y = total$income, xlim = c(3, 6), frame.plot = F)
text(x = total$Private, y = total$income, labels = total$Country, pos = 4)
```

![plot of chunk unnamed-chunk-11](figure/unnamed-chunk-11.png) 


Note that calling plot on a data frame with all interval columns automatically creates pairwise scatter plots:


```r
plot(total[-1])
```

![plot of chunk unnamed-chunk-12](figure/unnamed-chunk-12.png) 


This can also be done using the `pairs` function, which moreover can add a 'panel' line to give a visual indication of the seeming linear or curved relation between two variables:


```r
pairs(total[-1], panel = panel.smooth)
```

![plot of chunk unnamed-chunk-13](figure/unnamed-chunk-13.png) 


Finally, let's create a scatter plot for all yearly values rather than the totals per country. 


```r
d = merge(capital, income.long)
au = d[d$Country == "Australia", ]
ca = d[d$Country == "Canada", ]
us = d[d$Country == "U.S.", ]
fr = d[d$Country == "France", ]
plot(0, ylim = c(2, 6), xlim = c(0.05, 0.25), type = "n")
points(y = au$Private, x = au$income, col = "red")
points(y = ca$Private, x = ca$income, col = "blue")
points(y = us$Private, x = us$income, col = "darkgreen")
points(y = fr$Private, x = fr$income, col = "purple")
```

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-14.png) 


It seems that for australia and canada there is a fairly linear relation between capital and income inequality. 
Using the `abline` command based on a linear model fit, we can plot the regression lines for all points as well:


```r
plot(0, ylim = c(2, 6), xlim = c(0.05, 0.25), type = "n", xlab = "Income inequality", 
    ylab = "Capital Accumulation", frame.plot = F)
points(y = au$Private, x = au$income, col = "red")
abline(lm(au$Private ~ au$income), col = "red")
points(y = ca$Private, x = ca$income, col = "blue")
abline(lm(ca$Private ~ ca$income), col = "blue")
points(y = us$Private, x = us$income, col = "darkgreen")
abline(lm(us$Private ~ us$income), col = "darkgreen")
points(y = fr$Private, x = fr$income, col = "purple")
abline(lm(fr$Private ~ fr$income), col = "purple")
legend(0.17, 3, legend = c("Australia", "Canada", "US", "France"), ncol = 2, 
    fill = c("red", "blue", "darkgreen", "purple"))
```

![plot of chunk unnamed-chunk-15](figure/unnamed-chunk-15.png) 


(Of course, this code can be made more generic by using a for loop rather than copying the commands for each country,
which is left as an exercise for the reader. 
