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
date: Transforming Data

Transforming data
====
type:section

Combining data

Reshaping data

Combining data
=====




```r
cbind(df, country=c("nl", "uk", "uk"))
```

```
  id age name country
1  1  14 Mary      nl
2  2  18 John      uk
3  3  24 Luke      uk
```

```r
rbind(df, c(id=1, age=2, name="Mary"))
```

```
  id age name
1  1  14 Mary
2  2  18 John
3  3  24 Luke
4  1   2 Mary
```

Merging data
===


```r
countries = data.frame(id=1:2, country=c("nl", "uk"))
merge(df, countries)
```

```
  id age name country
1  1  14 Mary      nl
2  2  18 John      uk
```

```r
merge(df, countries, all=T)
```

```
  id age name country
1  1  14 Mary      nl
2  2  18 John      uk
3  3  24 Luke    <NA>
```

Merging data
===


```r
merge(data1, data2)
merge(data1, data2, by="id")
merge(data1, data2, by.x="id", by.y="ID")
merge(data1, data2, by="id", all=T)
merge(data1, data2, by="id", all.x=T)
```

Reshaping data
===

+ `reshape2` package:
  + `melt`: wide to long
  + `dcast`: long to wide (pivot table) 

Melting data
===


```r
wide = data.frame(id=1:3, 
  group=c("a","a","b"), 
  width=c(100, 110, 120), 
  height=c(50, 100, 150))
wide
```

```
  id group width height
1  1     a   100     50
2  2     a   110    100
3  3     b   120    150
```

Melting data
===


```r
library(reshape2)
long = melt(wide, id.vars=c("id", "group"))
long
```

```
  id group variable value
1  1     a    width   100
2  2     a    width   110
3  3     b    width   120
4  1     a   height    50
5  2     a   height   100
6  3     b   height   150
```


Casting data
===


```r
dcast(long, id + group ~ variable, value.var="value")
```

```
  id group width height
1  1     a   100     50
2  2     a   110    100
3  3     b   120    150
```

Casting data: aggregation
===


```r
dcast(long, group ~ variable, value.var = "value", fun.aggregate = max)
```

```
  group width height
1     a   110    100
2     b   120    150
```

```r
dcast(long, id ~., value.var = "value", fun.aggregate = mean)
```

```
  id   .
1  1  75
2  2 105
3  3 135
```

Aggregation with `aggregate`
===


```r
aggregate(long["value"], long["group"], max)
```

```
  group value
1     a   110
2     b   150
```

`aggregate` vs `dcast`
===

Aggregate
+ One aggregation function
+ Multiple value columns
+ Groups go in rows (long format)
+ Specify with column subsets

Cast
+ One aggregation function
+ One value column
+ Groups go in rows or columns
+ Specify with formula (`rows ~ columns`)


Simple statistics
===

Vector properties


```r
mean(x)
sd(x)
sum(x)
```

Basic tests


```r
t.test(wide, width ~ group)
t.test(wide$width, wide$height, paired=T)
cor.test(wide$width, wide$height)
m = lm(long, width ~ group + height)
summary(m)
```



Hands-on
====
type: section

Handout: Transforming Data
