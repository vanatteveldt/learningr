
```
## (C) (cc by-sa) Wouter van Atteveldt & Jan Kleinnijenhuis, file generated June 06 2014
```


Multilevel Modeling with R
====

```
*Caveat* I am not an expert on multilevel modelling. Please take this document as a source of inspiration rather than as a definitive set of answers.
```

This document gives an overview of two commonly used packages for multi-level modelling in R (also called 'mixed models' or 'random effects models'). 

Since the yearly time series data we used so far are not suitable for multilevel analysis, 
let's take the textbook data of Joop Hox on popularity of pupils in schools:
(see also http://www.ats.ucla.edu/stat/examples/ma_hox/)


```r
library(foreign)
popdata<-read.dta("http://www.ats.ucla.edu/stat/stata/examples/mlm_ma_hox/popular.dta")
head(popdata)
```

```
##   pupil school popular  sex texp const teachpop
## 1     1      1       8 girl   24     1        7
## 2     2      1       7  boy   24     1        7
## 3     3      1       7 girl   24     1        6
## 4     4      1       9 girl   24     1        6
## 5     5      1       8 girl   24     1        7
## 6     6      1       7  boy   24     1        7
```

Now, we can model a time series model with only the random intercept at the school level:



```r
library(nlme)
m = lme(popular ~ sex + texp, random=~1|school, popdata)
summary(m)
```

```
## Linear mixed-effects model fit by REML
##  Data: popdata 
##    AIC  BIC logLik
##   4454 4482  -2222
## 
## Random effects:
##  Formula: ~1 | school
##         (Intercept) Residual
## StdDev:      0.6971   0.6782
## 
## Fixed effects: popular ~ sex + texp 
##             Value Std.Error   DF t-value p-value
## (Intercept) 3.561   0.17148 1899  20.765       0
## sexgirl     0.845   0.03095 1899  27.291       0
## texp        0.093   0.01085   98   8.609       0
##  Correlation: 
##         (Intr) sexgrl
## sexgirl -0.088       
## texp    -0.905  0.000
## 
## Standardized Within-Group Residuals:
##      Min       Q1      Med       Q3      Max 
## -3.35852 -0.67970  0.02436  0.59332  3.78515 
## 
## Number of Observations: 2000
## Number of Groups: 100
```

So, popularity of a course is determined by both gender and teacher experience. 
Let's try a varying slopes model, with teacher experience also differing per school,
and see whether that is a significant improvement:


```r
m2 = lme(popular ~ sex + texp, random=~texp|school, popdata)
anova(m, m2)
```

```
##    Model df  AIC  BIC logLik   Test L.Ratio p-value
## m      1  5 4454 4482  -2222                       
## m2     2  7 4456 4496  -2221 1 vs 2   1.915  0.3838
```

So, although the log likelihood of m2 is slightly better, it also uses more degrees of freedom and the BIC is higher, 
indicating a worse model. The `anova` output means that this change is not significant. 

Next, let's have a look at the slope of the  gender effect.
First, a useful tool can be a visual inspection of the slope for a random sample of schools, just to get an idea of variation.
First, take a random sample of 12 schools from the list of unique school ids:



```r
schools = sample(unique(popdata$school), size=12, replace=F)
sample = popdata[popdata$school %in% schools, ]
```

Now, we can use the `xyplot` function from the `lattice` package:


```r
library(lattice)
xyplot(popular~sex|as.factor(school),type=c("p","g","r"), col.line="black", data=sample)
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6.png) 

So, (at least in my sample) there is considerable variation: in some schools gender has almost no effect,
but in other schools the slope is relatively steep and generally positive (meaning girls have higher popularity).
Let's test whether a model with a random slope on gender is a significant improvement:


```r
library(texreg)
```

```
## Version:  1.32
## Date:     2014-05-01
## Author:   Philip Leifeld (University of Konstanz)
```

```r
m2 = lme(popular ~ sex + texp, random=~sex|school, popdata)
anova(m, m2)
```

```
##    Model df  AIC  BIC logLik   Test L.Ratio p-value
## m      1  5 4454 4482  -2222                       
## m2     2  7 4290 4329  -2138 1 vs 2   168.5  <.0001
```

```r
screenreg(list(m, m2))
```

```
## 
## ==========================================
##                 Model 1       Model 2     
## ------------------------------------------
## (Intercept)         3.56 ***      3.34 ***
##                    (0.17)        (0.16)   
## sexgirl             0.84 ***      0.84 ***
##                    (0.03)        (0.06)   
## texp                0.09 ***      0.11 ***
##                    (0.01)        (0.01)   
## ------------------------------------------
## AIC              4454.36       4289.89    
## BIC              4482.36       4329.09    
## Log Likelihood  -2222.18      -2137.95    
## Num. obs.        2000          2000       
## Num. groups       100           100       
## ==========================================
## *** p < 0.001, ** p < 0.01, * p < 0.05
```

So, `m2` is indeed a significant improvement. 

The lme4 package
====

`lme4` is a package that gives a bit more flexibility in specifying time series.
Specifically, it allows us to specify a binomial family, i.e. logistic regression.
The following dichotomized the popularity and checks whether the effect of gender on popularity is dependent on the school:


```r
library(lme4)
```

```
## Loading required package: Matrix
## Loading required package: Rcpp
## 
## Attaching package: 'lme4'
## 
## The following object is masked from 'package:nlme':
## 
##     lmList
```

```r
popdata$dich = cut(popdata$popular, 2, labels=c("lo","hi"))

m = glmer(dich ~ sex + (1|school), popdata, family="binomial")
m2 = glmer(dich ~ sex + (1 + sex|school), popdata, family="binomial")
summary(m2)
```

```
## Generalized linear mixed model fit by maximum likelihood (Laplace
##   Approximation) [glmerMod]
##  Family: binomial ( logit )
## Formula: dich ~ sex + (1 + sex | school)
##    Data: popdata
## 
##      AIC      BIC   logLik deviance df.resid 
##   1536.2   1564.2   -763.1   1526.2     1995 
## 
## Scaled residuals: 
##    Min     1Q Median     3Q    Max 
## -3.781 -0.326 -0.112  0.266  5.314 
## 
## Random effects:
##  Groups Name        Variance Std.Dev. Corr
##  school (Intercept) 8.5      2.91         
##         sexgirl     3.4      1.84     0.16
## Number of obs: 2000, groups: school, 100
## 
## Fixed effects:
##             Estimate Std. Error z value Pr(>|z|)    
## (Intercept)   -2.097      0.351   -5.97  2.4e-09 ***
## sexgirl        2.858      0.297    9.63  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##         (Intr)
## sexgirl -0.215
```

```r
anova(m, m2)
```

```
## Data: popdata
## Models:
## m: dich ~ sex + (1 | school)
## m2: dich ~ sex + (1 + sex | school)
##    Df  AIC  BIC logLik deviance Chisq Chi Df Pr(>Chisq)    
## m   3 1572 1589   -783     1566                            
## m2  5 1536 1564   -763     1526  39.8      2    2.3e-09 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

If we would like to see for which schools the effect of gender were the strongest, 
we can use the `ranef` function to get the intercepts and slopes per group, and order them by slope:


```r
effects = ranef(m2)$school
effects = effects[order(effects$sexgirl), ]
head(effects)
```

```
##    (Intercept) sexgirl
## 38      1.9160  -3.514
## 53      0.5028  -3.225
## 10     -1.2437  -2.345
## 80      1.9169  -2.132
## 12      0.1725  -2.116
## 61     -0.6707  -1.897
```

```r
tail(effects)
```

```
##    (Intercept) sexgirl
## 32     -0.7054   1.753
## 8       0.4938   1.758
## 7       0.2000   1.798
## 16      0.5682   1.872
## 54     -0.4788   2.132
## 52     -0.4730   2.362
```
