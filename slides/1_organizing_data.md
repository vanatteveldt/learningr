<style>

.reveal .slides > sectionx {
    top: -70%;
}

.reveal pre code.r {background-color: #ccF}

.section .reveal li {color:white}
.section .reveal em {font-weight: bold; font-style: "none"}

</style>




Text Analysis in R
========================================================
author: Wouter van Atteveldt
date: Managing data in R

Motivational Example
========================================================






```r
library(twitteR)
tweets = searchTwitteR("#bigdata", resultType="recent", n = 100)
tweets = plyr::ldply(tweets, as.data.frame)
```


```r
head(tweets[c("id", "created", "text")])
```



|id                 |created             |text                                                                                                                    |
|:------------------|:-------------------|:-----------------------------------------------------------------------------------------------------------------------|
|752094937693519873 |2016-07-10 10:59:41 |RT @IOTsoc: Prototyping IoT Analytics with MATLAB and ThingSpeak https://t.co/1avWo3ghqz #iot #bigdata                  |
|752094856038658048 |2016-07-10 10:59:21 |RT @CRM_CWS_Cloud: Three Ages of #DigitalTransformation &#124; @CloudExpo #IoT #DevOps #BigData https://t.co/iQw5Yy2ues |
|752094842226814976 |2016-07-10 10:59:18 |RT @data_nerd: Embedded Microsoft &#124; @DevOpsSummit @Azure #BigData #DevOps #Docker https://t.co/rnsoSt6gAp          |
|752094836338155520 |2016-07-10 10:59:16 |RT @bobehayes: One-Third of #BigData Developers Use #MachineLearning https://t.co/iwJEdvOHEZ #datascience               |
|752094816557686785 |2016-07-10 10:59:12 |RT @CRM_CWS_Cloud: SDN, SDS and Agility &#124; @CloudExpo #BigData #SDN #DataCenter #Storage https://t.co/6X5IoYzdPL    |
|752094791333089280 |2016-07-10 10:59:06 |RT @CRM_CWS_Cloud: The Big Data Science &#124; @CloudExpo @Codero #IoT #M2M #ML #BigData https://t.co/GKvOoAKrB5        |

Motivational Example
======


```r
library(RTextTools)
library(corpustools)
dtm = create_matrix(tweets$text)
dtm.wordcloud(dtm, freq.fun = sqrt)
```

![plot of chunk unnamed-chunk-5](1_organizing_data-figure/unnamed-chunk-5-1.png)


What is R?
===

+ Programming language
+ Statistics Toolkit
+ Open Source
+ Community driven
  + Packages/libraries
  + Including many text analysis libraries
  
Cathedral and Bazar
===

<img src="cath_bazar.jpg">
  
The R Ecosystem
===

+ R
+ RStudio
  + RMarkdown / RPresentation
+ Packages
  + CRAN
  + Github


Interactive 1a: What is R?
====
type: section

Installing and using packages
===


```r
install.packages("plyr")
library(plyr)
plyr::rename

devtools::install_github("amcat/amcat-r")
```

Data types: vectors
===


```r
x = 12
class(x)
```

```
[1] "numeric"
```

```r
x = c(1, 2, 3)
class(x)
```

```
[1] "numeric"
```

```r
x = "a text"
class(x)
```

```
[1] "character"
```

Data Frames
===


```r
df = data.frame(id=1:3, age=c(14, 18, 24), 
          name=c("Mary", "John", "Luke"))
df
```

```
  id age name
1  1  14 Mary
2  2  18 John
3  3  24 Luke
```

```r
class(df)
```

```
[1] "data.frame"
```

Selecting a column
===


```r
df$age
```

```
[1] 14 18 24
```

```r
df[["age"]]
```

```
[1] 14 18 24
```

```r
class(df$age)
```

```
[1] "numeric"
```

```r
class(df$name)
```

```
[1] "factor"
```

Useful functions
===

Data frames:


```r
colnames(df)
head(df)
tail(df)
nrow(df)
ncol(df)
summary(df)
```

Vectors:


```r
mean(df$age)
length(df$age)
```


Other data types
===

+ Data frame:
  + Rectangular data frame
  + Columns vectors of same length
    + (vetor always has one type)
+ List:
  + Contain anything (inc data frames, lists)
  + Elements arbitrary type
+ Matrix:
  + Rectangular
  + All cells same (primitive) type
  
  
Finding help (and packages)
===

+ Built-in documentation
  + CRAN package vignettes
+ Task views
+ Google (sorry...)
  + r mailing list
  + stack exchange
  
Organizing Data in R
===
type: section
  

Subsetting

Recoding & Renaming columns

Ordering



Subsetting
===


```r
df[1:2, 1:2]
```

```
  id age
1  1  14
2  2  18
```

```r
df[df$id %% 2 == 1, ]
```

```
  id age name
1  1  14 Mary
3  3  24 Luke
```

```r
df[, c("id", "name")]
```

```
  id name
1  1 Mary
2  2 John
3  3 Luke
```

Subsetting: `subset` function
===

```r
subset(df, id == 1)
```

```
  id age name
1  1  14 Mary
```

```r
subset(df, id >1 & age < 20)
```

```
  id age name
2  2  18 John
```

Recoding columns
===
  

```r
df2 = df
df2$age2 = df2$age + df2$id
df2$age[df2$id == 1] = NA
df2$id = NULL
df2$old = df2$age > 20
df2$agecat = 
  ifelse(df2$age > 20, "Old", "Young")
df2
```

```
  age name age2   old agecat
1  NA Mary   15    NA   <NA>
2  18 John   20 FALSE  Young
3  24 Luke   27  TRUE    Old
```

Text columns
===

+ `character` vs `factor`


```r
df2=df
df2$name = as.character(df2$name)
df2$name[df2$id != 1] = 
    paste("Mr.", df2$name[df2$id != 1])
df2$name = toupper(df2$name)
df2$name = gsub("\\.\\s*", "_", df2$name)
df2[grepl("mr", df2$name, ignore.case = T), ]
```

```
  id age    name
2  2  18 MR_JOHN
3  3  24 MR_LUKE
```

Renaming columns
===


```r
df2 = df
colnames(df2) = c("ID", "AGE", "NAME")
colnames(df2)[2] = "leeftijd"
df2 = plyr::rename(df2, c("NAME"="naam"))
df2
```

```
  ID leeftijd naam
1  1       14 Mary
2  2       18 John
3  3       24 Luke
```
  
Ordering
====


```r
df[order(df$age), ]
```

```
  id age name
1  1  14 Mary
2  2  18 John
3  3  24 Luke
```

```r
plyr::arrange(df, -age)
```

```
  id age name
1  3  24 Luke
2  2  18 John
3  1  14 Mary
```

Accessing elements
====

+ Data frame
  + Select one column: `df$col`, ` df[["col"]]`, 
  + Select columns: `df[c("col1" ,"col2")]`
  + Subset: `df[rows, columns]`
+ List:
  + Select one element: `l$el`, ` l[["el"]]`, `l[[1]]` 
  + Select columns: `l[[1:3]]`
+ Matrix:
  + All cells same type
  + Subset: `m[rows, columns]`

Hands-on
====
type: section

Break

Hand-outs:
+ Playing with data
+ Organizing data
