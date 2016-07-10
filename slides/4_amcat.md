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
date: Querying and analysing text


What is AmCAT
====

+ Open source text analysis platform
  + Queries, manual annotation
  + API
  + (Working on R plugins...) 
+ Developed at VU Amsterdam
+ Free account at `http://amcat.nl` 
  + (or install on your own server)

AmCAT and R
====

+ AmCAT for
  + Organizing large corpora
  + Central storage and access control
  + Fast search with elastic
  + Linguistic processing with `nlpipe`
+ R for flexible analysis
  + Corpus Analysis
  + Semantic netwok analysis
  + Visualizations
  + Reproducability

Demo: AmCAT
======
type:section


Connecting to AmCAT from R
====

+ AmCAT API 
  + (Create account at `https://amcat.nl`)


```r
install_github("amcat/amcat-r")
amcat.save.password("https://amcat.nl", "user", "pwd")
```

```r
library(amcatr)
conn = amcat.connect("https://amcat.nl")
```

Querying AmCAT: aggregation
====


```r
a = amcat.aggregate(conn, "mortgage*", sets=29454, axis1 = "year", axis2="medium") 
head(a)
```



| count|medium    |year       |query     |
|-----:|:---------|:----------|:---------|
|     1|The Times |2007-06-01 |mortgage* |
|     2|The Times |2007-09-01 |mortgage* |
|     3|The Times |2007-10-01 |mortgage* |
|     1|The Times |2007-12-01 |mortgage* |
|     1|The Times |2008-02-01 |mortgage* |
|     1|The Times |2008-03-01 |mortgage* |

Querying AmCAT: raw counts
====


```r
h = amcat.hits(conn, "mortgage*", sets=29454)
head(h)
```



| count|       id|query     |
|-----:|--------:|:---------|
|     1| 21794967|mortgage* |
|     1| 21795537|mortgage* |
|     1| 21795699|mortgage* |
|     1| 21796592|mortgage* |
|     1| 21798565|mortgage* |
|     1| 21798673|mortgage* |

Merging with metadata
=====


```r
meta = amcat.getarticlemeta(conn, 41, 29454, dateparts = T)
h = merge(meta, h)
peryear = aggregate(h["count"], h[c("year")], sum)
library(ggplot2)
ggplot(peryear, aes(x=year, y=count)) + geom_line()
```

![plot of chunk unnamed-chunk-6](4_amcat-figure/unnamed-chunk-6-1.png)


Uploading text to AmCAT
===




```r
tweets = searchTwitteR("#bigdata", resultType="recent", n = 100)
tweets = plyr::ldply(tweets, as.data.frame)
set = amcat.upload.articles(conn, project=1, 
  articleset="twitter test", medium="twitter",
  text=tweets$text, headline=tweets$text, 
  date=tweets$created, author=tweets$screenName)
amcat.flush(conn)
head(amcat.getarticlemeta(conn, 1, set, columns=c('date', 'headline')))
```



|        id|date       |headline                                                                                                                                          |
|---------:|:----------|:-------------------------------------------------------------------------------------------------------------------------------------------------|
| 168347873|2016-07-10 |RT @PyramidEU: How #BigData will take the role of the CIO to the next level: https://t.co/CbxaEhP62D #DigitalTransformation https://t.co/uq…      |
| 168347866|2016-07-10 |RT @CloudsceneMedia: @HuffingtonPost How cloud technology will evolve in 2016 #cloud #data #BigData #technology https://t.co/skX5d0HQm5 htt…      |
| 168347739|2016-07-10 |What to Do on Your First Day as Data Science Leader - by @michaelyoungMBN https://t.co/BtDRVgHQZJ #BigData                                        |
| 168347746|2016-07-10 |#bigdata Robot FX: Get your hands on the most advanced autotrading software in the industry! https://t.co/cIISMXqqs7                              |
| 168347753|2016-07-10 |RT @SeanKyleBordner: Embedded Microsoft &#124; @DevOpsSummit @Azure #BigData #DevOps #Docker: How do you balance the need to “go fast” ... https… |
| 168347760|2016-07-10 |RT @SeanKyleBordner: Embedded Microsoft &#124; @DevOpsSummit @Azure #BigData #DevOps #Docker: How do you balance the need to “go fast” ... https… |

Saving selection as article set
===


```r
h = amcat.hits(conn, "data*", sets=set)
set2 = amcat.add.articles.to.set(conn, project=1, articles=h$id,
  articleset.name="Visualization", articleset.provenance="From R")
amcat.flush(conn)
head(amcat.getarticlemeta(conn, 1, set2, columns=c('date', 'headline')))
```



|        id|date       |headline                                                                                                                                               |
|---------:|:----------|:------------------------------------------------------------------------------------------------------------------------------------------------------|
| 168347866|2016-07-10 |RT @CloudsceneMedia: @HuffingtonPost How cloud technology will evolve in 2016 #cloud #data #BigData #technology https://t.co/skX5d0HQm5 htt…           |
| 168347739|2016-07-10 |What to Do on Your First Day as Data Science Leader - by @michaelyoungMBN https://t.co/BtDRVgHQZJ #BigData                                             |
| 168347867|2016-07-10 |RT @Ronald_vanLoon: IoT and Data Analytics &#124; @ThingsExpo #IoT #M2M #API #BigData &#124; #Analytics #Sport #RT https://t.co/M8zL9Jzwnj https://t.… |
| 168347831|2016-07-10 |RT @lastknight: 10 Industries That Are Changing Because of Data https://t.co/jj0aEYAEcH #bigdata #datascience                                          |
| 168347764|2016-07-10 |10 Industries That Are Changing Because of Data https://t.co/jj0aEYAEcH #bigdata #datascience                                                          |
| 168347771|2016-07-10 |6 Powerful Reasons Why Your Business Should Visualize Data https://t.co/iiYnD0IZFo #dataviz #datascience #bigdata                                      |

Hands-on session
====
type: section

Break

Handouts:
+ Text anlaysis with R and AmCAT
