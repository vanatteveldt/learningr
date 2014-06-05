
```
## (C) (cc by-sa) Wouter van Atteveldt & Jan Kleinnijenhuis, file generated juni 06 2014
```


> Note on the data used in this howto: 
> This data can be downloaded from http://piketty.pse.ens.fr/files/capital21c/en/xls/, 
> but the excel format is a bit difficult to parse at it is meant to be human readable, with multiple header rows etc. 
> For that reason, I've extracted csv files for some interesting tables that I've uploaded to 
> http://vanatteveldt.com/uploads/rcourse/data


Time Series Analysis with R
====================

```
*Caveat*: I am not an expert on time series modelling. Please take this document as a source of inspiration rather than as a definitive set of answers.
```


Time series analysis consists of statistical procedures that take into account that observations are sequential and often serially autocorrelated. Typical questions for time series analysis are whether change in one variable affects another variable at a later date; and in reciprocal series which effect is stronger (granger causality).

In R, there is an object type `ts` that can be used to represent time series.


```r
download.file("http://vanatteveldt.com/wp-content/uploads/rcourse/data/income_toppercentile.csv", 
    destfile = "income_toppercentile.csv")
income = read.csv("income_toppercentile.csv")
income = ts(income[-1], start = income[1, 1], frequency = 1)
class(income)
```

```
## [1] "mts"    "ts"     "matrix"
```


As you can see from the `class` output, a time series is really a specialised type of matrix. One of the nice things is that the default plot for `ts` objects gives an overview of the different time series over time:


```r
plot(income, main = "Income Inequality (percentage of income earned by top 1%)")
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3.png) 


Univariate time series analysis
-----

Let's first consider the univariate case. 
We focus on the US series since it is a long series without missing values. 


```r
us = na.omit(income[, "US"])
plot(us)
```

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4.png) 


We could easily do a "naive" time series by just running a linear model with a lagged variable, e.g. to model the autocorrelation:


```r
summary(lm(us ~ lag(us)))
```

```
## 
## Call:
## lm(formula = us ~ lag(us))
## 
## Residuals:
##       Min        1Q    Median        3Q       Max 
## -1.19e-16 -8.00e-20  9.20e-19  2.64e-18  1.10e-17 
## 
## Coefficients:
##             Estimate Std. Error  t value Pr(>|t|)    
## (Intercept) 6.63e-17   4.64e-18 1.43e+01   <2e-16 ***
## lag(us)     1.00e+00   3.07e-17 3.26e+16   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 1.23e-17 on 99 degrees of freedom
## Multiple R-squared:     1,	Adjusted R-squared:     1 
## F-statistic: 1.06e+33 on 1 and 99 DF,  p-value: <2e-16
```


However, we generally want to use the more specialized methods such as VAR and ARIMA. 

Transforming time series
-----

Before going on with the analysis, we need to know whether the time series is /stationary/, i.e. whether its properties such as mean and variance are constant over time. 
Nonstationarity means that a time series shows an upward or downward trend for many time points; the series does not revert to it mean (almost) immediately. Nonstationary time series easily show either a positive or a negative spurious correlation, since it's unlikely that two series that show an upward or downward trend for a long sequence of time points will not show such a correlation.  
Since a non-stationary time series gives estimation problems it should be transformed first, generally with a combination of differencing, log transformation or Box-Cox transformation. 

The first test for stationarity is just looking at the graph. It looks like the series is much more variable initially and at the end, which could be a problem. Moreover, there is an obvious U-shape which means that the mean is not constant.

Formal tests for stationarity include the KPSS tests and the Augmented Dickey-Fuller (ADF) test. 


```r
library(tseries)
kpss.test(us)
```

```
## Warning: p-value smaller than printed p-value
```

```
## 
## 	KPSS Test for Level Stationarity
## 
## data:  us
## KPSS Level = 0.7546, Truncation lag parameter = 2, p-value = 0.01
```

```r
adf.test(us)
```

```
## 
## 	Augmented Dickey-Fuller Test
## 
## data:  us
## Dickey-Fuller = -0.9225, Lag order = 4, p-value = 0.9465
## alternative hypothesis: stationary
```


Take care with interpreting these: the null hypothesis for KPSS is stationarity (rejected in this case), while the null hypothesis for ADF is a unit root, i.e. non-stationarity (not rejected). 

A final diagnostic tools is looking at the auto-correlation grapf and partial auto-correlation graph. 
For a stationary series, both ACF and PACF should drop to zero relatively quickly. 


```r
par(mfrow = c(3, 1))
plot(us)
acf(us)
pacf(us)
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7.png) 


Thus, the ACF plot also points to a non-stationary series. 
As a first start, let's difference the series, i.e. instead of analysing income inequality we will analyse change in income inequality. 

The reasoning for differencing is as follows: Since it would be highly coincidental that two series that show a spurious correlations if we compare their *levels* also show a correlation if we compare their *changes*, it's often a good idea to difference the time series. A famous example is the spurious correlation that indeed gradually less babies were born in Western countries in the twentieth century as the number of storks gradually decreased. If this is not a spurious correlation, then one would expect also a correlation of the differences. Thus, one would expect that the birth cohort immediately after the second world war was preceded by an increase of storks a year before. One would also expect that the decrease of birth immediately after the introduction of the contraception pill was preceded by a mass extinction of storks.  

We can difference is series using the `diff` command:


```r
par(mfrow = c(3, 1))
plot(diff(us))
acf(diff(us))
pacf(diff(us))
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8.png) 


This looks a lot more stationary, but variance still seems bigger at the extremes of the series. 


```r
kpss.test(diff(us))
```

```
## Warning: p-value greater than printed p-value
```

```
## 
## 	KPSS Test for Level Stationarity
## 
## data:  diff(us)
## KPSS Level = 0.1863, Truncation lag parameter = 2, p-value = 0.1
```

```r
adf.test(diff(us))
```

```
## Warning: p-value smaller than printed p-value
```

```
## 
## 	Augmented Dickey-Fuller Test
## 
## data:  diff(us)
## Dickey-Fuller = -6.189, Lag order = 4, p-value = 0.01
## alternative hypothesis: stationary
```


So that is also looking better. However, we should probably still do a log transformation to normalize the variance:




```r
par(mfrow = c(3, 1))
plot(diff(log(us)))
acf(diff(log(us)))
pacf(diff(log(us)))
```

![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10.png) 


Now, variance looks about right for the whole series, and there are not ACF's or PACF's. 

One should realize that these transformations may either facilitate or complicate the interpretation of research results. A linear relationship between log transformed variables, for example, can be understood often in economics and in finance as a relationship between percentual changes, thus in terms of elasticities. Theory comes first, which means that without a proper interpretation transformations a regression equation based on non-transformed variables may be preferable, although his increases the risk of spurious correlations (stork-baby-correlation). 
We will come back to the "error correction model" as another way to get rid of trends in the data at the end of this document.

ARIMA modeling
----

ARIMA (AutoRegressive Integrated Moving Average) models model a time series with a mixture of autoregressive, integrative, and moving average components. 
One can base the components needed on the (P)ACF plots as presented above. 
Very briefly put: decaying ACF's such as in the plot of the untransformed series point to an integrative component. 
After eliminating integrative components, we check the remaining (p)acf plots, and ACF spikes suggest an AR component, while
if there are more PACF spikes then ACF spikes we should use MA components. 

In our case, since the transformed plots had no significant spikes in either the ACF or the PACF plots, 
we don't need an AR or MA component. 
Thus, we can fit the ARIMA model, and inspect the residuals with the `tsdiag` function:



```r
library(forecast)
```

```
## Loading required package: zoo
## 
## Attaching package: 'zoo'
## 
## The following objects are masked from 'package:base':
## 
##     as.Date, as.Date.numeric
## 
## Loading required package: timeDate
## This is forecast 5.4
```

```r
m = arima(diff(log(us)), c(0, 0, 0))
summary(m)
```

```
## Series: diff(log(us)) 
## ARIMA(0,0,0) with non-zero mean 
## 
## Coefficients:
##       intercept
##           0.001
## s.e.      0.009
## 
## sigma^2 estimated as 0.00735:  log likelihood=103.8
## AIC=-203.5   AICc=-203.4   BIC=-198.3
## 
## Training set error measures:
##                     ME    RMSE     MAE  MPE MAPE MASE
## Training set 7.482e-19 0.08573 0.06778 -Inf  Inf    1
```

```r
tsdiag(m)
```

![plot of chunk unnamed-chunk-11](figure/unnamed-chunk-11.png) 


What this in fact means is that the best estimate of next years inequality is slightly higher than this years, 
but other than the very slight trend there are no regularities in the time series. 

We can also use the `auto.arima` and `ets` functions that automatically fit a time series,
and we can use `forecast` to project the regularities into the future.
In this case, of course, that is not very interesting as there were no regularities in the time series,


```r
m = auto.arima(us)
summary(m)
```

```
## Series: us 
## ARIMA(0,1,0)                    
## 
## sigma^2 estimated as 0.000193:  log likelihood=285.6
## AIC=-569.2   AICc=-569.2   BIC=-566.6
## 
## Training set error measures:
##                     ME    RMSE     MAE    MPE MAPE   MASE
## Training set 0.0001998 0.01384 0.01028 -0.261 6.76 0.2963
```

```r
forecast(m, 4)
```

```
##      Point Forecast  Lo 80  Hi 80  Lo 95  Hi 95
## 2011          0.198 0.1802 0.2158 0.1707 0.2253
## 2012          0.198 0.1728 0.2232 0.1594 0.2366
## 2013          0.198 0.1671 0.2289 0.1508 0.2452
## 2014          0.198 0.1623 0.2337 0.1435 0.2525
```


Note that the auto.arima even ignores the slight trend, presumably because the gain in fit is too small.

VAR models for multivariate time series
---

VAR (Vector Auto Regression) models can be used to model effects between different time series. 
Let's take the time series of France, US, and Canada and see whether change in income inequality in one country predicts change in the other countries.


```r
income = na.omit(income[, c("US", "France", "Canada")])
plot(income, main = "Income Inequality")
```

![plot of chunk unnamed-chunk-13](figure/unnamed-chunk-13.png) 



```r
library(vars)
```

```
## Loading required package: MASS
## Loading required package: strucchange
## Loading required package: sandwich
## Loading required package: urca
## Loading required package: lmtest
```

```r
m = VAR(income)
summary(m)
```

```
## 
## VAR Estimation Results:
## ========================= 
## Endogenous variables: US, France, Canada 
## Deterministic variables: const 
## Sample size: 90 
## Log Likelihood: 933.934 
## Roots of the characteristic polynomial:
## 0.969 0.934 0.792
## Call:
## VAR(y = income)
## 
## 
## Estimation results for equation US: 
## =================================== 
## US = US.l1 + France.l1 + Canada.l1 + const 
## 
##           Estimate Std. Error t value Pr(>|t|)    
## US.l1      0.93692    0.05421   17.28   <2e-16 ***
## France.l1  0.00748    0.07795    0.10     0.92    
## Canada.l1  0.01708    0.11030    0.15     0.88    
## const      0.00678    0.00629    1.08     0.28    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## 
## Residual standard error: 0.0144 on 86 degrees of freedom
## Multiple R-Squared: 0.881,	Adjusted R-squared: 0.877 
## F-statistic:  213 on 3 and 86 DF,  p-value: <2e-16 
## 
## 
## Estimation results for equation France: 
## ======================================= 
## France = US.l1 + France.l1 + Canada.l1 + const 
## 
##           Estimate Std. Error t value Pr(>|t|)    
## US.l1     -0.00752    0.01779   -0.42     0.67    
## France.l1  0.93276    0.02558   36.46   <2e-16 ***
## Canada.l1  0.04696    0.03620    1.30     0.20    
## const      0.00166    0.00206    0.80     0.42    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## 
## Residual standard error: 0.00472 on 86 degrees of freedom
## Multiple R-Squared: 0.98,	Adjusted R-squared: 0.979 
## F-statistic: 1.41e+03 on 3 and 86 DF,  p-value: <2e-16 
## 
## 
## Estimation results for equation Canada: 
## ======================================= 
## Canada = US.l1 + France.l1 + Canada.l1 + const 
## 
##           Estimate Std. Error t value Pr(>|t|)    
## US.l1      0.07161    0.02777    2.58    0.012 *  
## France.l1  0.07574    0.03992    1.90    0.061 .  
## Canada.l1  0.82477    0.05649   14.60   <2e-16 ***
## const      0.00175    0.00322    0.54    0.589    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## 
## Residual standard error: 0.00736 on 86 degrees of freedom
## Multiple R-Squared: 0.941,	Adjusted R-squared: 0.938 
## F-statistic:  453 on 3 and 86 DF,  p-value: <2e-16 
## 
## 
## 
## Covariance matrix of residuals:
##              US   France   Canada
## US     2.06e-04 1.69e-05 2.13e-05
## France 1.69e-05 2.22e-05 3.44e-06
## Canada 2.13e-05 3.44e-06 5.42e-05
## 
## Correlation matrix of residuals:
##           US France Canada
## US     1.000 0.2501 0.2014
## France 0.250 1.0000 0.0991
## Canada 0.201 0.0991 1.0000
```

```r
plot(m)
```

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-141.png) ![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-142.png) ![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-143.png) 


All countries have a strong autocorrelation, and only for Canada an second effect is found: a high level of income inequality in the US predicts a high level of inequality in Canada the next year, controlled for the autocorrelation. 
We can do a VAR analysis on the differenced time series to get rid of the strong autocorrelations 
(and essentially predict how changes in one country respond to changes in another country)


```r
library(vars)
m = VAR(diff(income))
summary(m)
```

```
## 
## VAR Estimation Results:
## ========================= 
## Endogenous variables: US, France, Canada 
## Deterministic variables: const 
## Sample size: 89 
## Log Likelihood: 931.976 
## Roots of the characteristic polynomial:
## 0.373 0.152 0.152
## Call:
## VAR(y = diff(income))
## 
## 
## Estimation results for equation US: 
## =================================== 
## US = US.l1 + France.l1 + Canada.l1 + const 
## 
##           Estimate Std. Error t value Pr(>|t|)  
## US.l1     0.007659   0.111161    0.07    0.945  
## France.l1 0.245752   0.321907    0.76    0.447  
## Canada.l1 0.340025   0.200722    1.69    0.094 .
## const     0.000814   0.001556    0.52    0.602  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## 
## Residual standard error: 0.0143 on 85 degrees of freedom
## Multiple R-Squared: 0.043,	Adjusted R-squared: 0.0092 
## F-statistic: 1.27 on 3 and 85 DF,  p-value: 0.289 
## 
## 
## Estimation results for equation France: 
## ======================================= 
## France = US.l1 + France.l1 + Canada.l1 + const 
## 
##            Estimate Std. Error t value Pr(>|t|)  
## US.l1      0.073816   0.035524    2.08    0.041 *
## France.l1  0.203419   0.102873    1.98    0.051 .
## Canada.l1  0.089739   0.064145    1.40    0.165  
## const     -0.000742   0.000497   -1.49    0.140  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## 
## Residual standard error: 0.00456 on 85 degrees of freedom
## Multiple R-Squared: 0.144,	Adjusted R-squared: 0.114 
## F-statistic: 4.76 on 3 and 85 DF,  p-value: 0.0041 
## 
## 
## Estimation results for equation Canada: 
## ======================================= 
## Canada = US.l1 + France.l1 + Canada.l1 + const 
## 
##            Estimate Std. Error t value Pr(>|t|)  
## US.l1     -0.035232   0.053251   -0.66     0.51  
## France.l1  0.306155   0.154208    1.99     0.05 .
## Canada.l1  0.032668   0.096155    0.34     0.73  
## const     -0.000244   0.000746   -0.33     0.74  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## 
## Residual standard error: 0.00684 on 85 degrees of freedom
## Multiple R-Squared: 0.0462,	Adjusted R-squared: 0.0125 
## F-statistic: 1.37 on 3 and 85 DF,  p-value: 0.257 
## 
## 
## 
## Covariance matrix of residuals:
##              US   France   Canada
## US     2.04e-04 1.37e-05 1.45e-05
## France 1.37e-05 2.08e-05 3.25e-06
## Canada 1.45e-05 3.25e-06 4.68e-05
## 
## Correlation matrix of residuals:
##           US France Canada
## US     1.000  0.210  0.148
## France 0.210  1.000  0.104
## Canada 0.148  0.104  1.000
```


In the case of reciprocal relations it can be useful to use a Granger causality test. 
Let's use this test to see whether ht 

```r
m = VAR(income)
causality(m, cause = "US")
```

```
## $Granger
## 
## 	Granger causality H0: US do not Granger-cause France Canada
## 
## data:  VAR object m
## F-Test = 3.558, df1 = 2, df2 = 258, p-value = 0.02989
## 
## 
## $Instant
## 
## 	H0: No instantaneous causality between: US and France Canada
## 
## data:  VAR object m
## Chi-squared = 7.735, df = 2, p-value = 0.02091
```


So, the null hypothesis that there is no granger or instantaneous causality between the US is (presumably erronously) rejected.
Add a small piece on Cointegration and vector error correction models?

Error correction models
----

Another way to look at the data fro the US, France and Canada is that they show in spite of their differences a common trend called "cointegration": up until somewhere in the roaring twenties, downward until the eighties, upwards thereafter, with also some common ripples, e.eg. the short recovery in the late thirties, and the common fall roughly in 2007. The idea of "vector error correction models" (VECM) is that the nonstationarity in each country is caused by the long-term cointegration of economic trends in these countries - due to a common world market. The procedure to test a VECM model is to (1) test whether covariation is present indeed (e.g. with the Johannsen test) (2) test a model in which current changes do not simply depend on previous changes, but also on previous levels. A nickname of the VECM model is the drunk lady and her dog model. They may run apart unexpectedly long, but after a while they will walk together once more.

Non-constant variance
----

In statistical tests for small n one often has to assume a constant variance. Both in economics and in the social sciences changes in volatility (variance) are often more important. GARCH models deal not only with changes in means, but also with changes in volatility (AutoRegressive Conditional Heteroscedasticity). Let's give an example in which changes in volatility are extremely important. Understanding the gambler's paradox essentially comes down to understanding that precisely with a fair toss without memory (equal chances on +1p or -1p at each successive toss, and a starting capital C, the chances that one will be bankrupt if the number of tosses is extended forever, however large C, and however small p, since the variance (of a random walk) increases. Whether the risk of going bankrupt is still acceptable depends critically on the volatility, thus (simplified) on the question whether p increases or decreases in a subsequence of tosses. 

