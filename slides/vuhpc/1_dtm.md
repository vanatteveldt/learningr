<style>

.reveal .slides > sectionx {
    top: -70%;
}

.reveal pre code.r {background-color: #ccF}
.reveal pre code {font-size: 1.3em}

.small-code pre code {
  font-size: 1.15em;
}
.section .reveal li {color:white}
.section .reveal em {font-weight: bold; font-style: "none"}

</style>



Text Analysis with R
========================================================
author: Wouter van Atteveldt
date:   VU-HPC, 20167-11-05

Course Overview
========================================================

9:00 - 10:30
- R as a data analysis evironment
- Frequency Based Analysis and the DTM
- Dictionary Analysis with AmCAT and R

11:00 - 13:00
- Simple Natural Language Processing
- Corpus Analysis and Visualization
- Topic Modeling and Visualization

+ Please install R+Rstudio now! `:-)`

R as a data analysis environment
===
type: section

Why R?
===

+ Open source, active community
+ Native vector/matrix calculus
+ Slow, but modules mostly in C or Fortran
+ R vs Python
  + Strongly converging (numpy/pandas)
  + Python more 'programming', R more 'statistics'
+ R vs SPSS
  + ...

R basics
===

+ Functionality in packages
  + `install.packages("quanteda")`
  + `library(quanteda)`
  + OR: `quanteda::dfm(..)`
+ Lazy evaluation, functions are objects, (most) functions don't change arguments, most functions apply to vectors

R primitives
===

+ Basic variables are *vectors* of numbers, texts, etc
  + `c(1,2,3)`, `1:3`, `c("a", "b")`
+ Data frames are a named list of columns (vectors)
+ Subsetting: `a[elements]` or `a[rows, columns]`
+ Element selection: `d$column`

Some R Packages
===

+ `stringr` - basic string manipulation
+ `quanteda` - bag-of-words text analysis
+ `readtext` - reading text in various formats
+ `topicmodels` - topic modeling
+ `corpustools` - tokenlist text analysis

RStudio
===

+ Shell around R
+ Use projects to organize scripts+data
+ R-markdown and R-presentation to weave code and data

Frequency Based Analysis: The DTM
===
type: section

Frequency Based Analysis
===

- Analysis based on word frequency only
  - "Bag of words" assumption
  - Ignore grammar, proximity, relations, ...
- Main data: Document-term matrix (dtm)
- Can also use other features (dfm)
  - Bag of stems, lemmata, word pairs, ...
  
Creating a DTM
===

1. Text source
 - Text files
 - Data frames / vectors or text
 - External sources/APIs
2. Preprocessing
 - Stemming, lowercasing, lemmatizing
 - Collocations
2. Feature selection
 - Frequency
 - Stopwords

Creating a DTM from text
===


```r
library(quanteda)
texts=c("This is a test", "They tested a test", "I found a test!")
dfm(texts)
```

```
Document-feature matrix of: 3 documents, 9 features (51.9% sparse).
3 x 9 sparse Matrix of class "dfmSparse"
       features
docs    this is a test they tested i found !
  text1    1  1 1    1    0      0 0     0 0
  text2    0  0 1    1    1      1 0     0 0
  text3    0  0 1    1    0      0 1     1 1
```

Reading texts from file (or URL)
===


```r
library(readtext)
filepath <- "http://bit.ly/2uhqjJE?.csv"
t <- readtext(filepath, text_field = 'texts')
dfm(t$text)
```

```
Document-feature matrix of: 5 documents, 1,948 features (69.5% sparse).
```

Preprocessing: stemming, stopword removal
===


```r
dfm(texts, stem=T, remove=stopwords("english"))
```

```
Document-feature matrix of: 3 documents, 3 features (44.4% sparse).
3 x 3 sparse Matrix of class "dfmSparse"
       features
docs    test found !
  text1    1     0 0
  text2    2     0 0
  text3    1     1 1
```

Feature selection
===


```r
dfm = dfm(texts, stem=T)
dfm = dfm_trim(dfm, min_doc = 2)
dfm
```

```
Document-feature matrix of: 3 documents, 2 features (0% sparse).
3 x 2 sparse Matrix of class "dfmSparse"
       features
docs    a test
  text1 1    1
  text2 1    2
  text3 1    1
```

More control: quanteda step-by-step
===


```r
tokens = tokenize(texts, remove_punct = T)
tokens = toLower(tokens)
tokens = tokens_wordstem(tokens, "english")
dfm = dfm(tokens)
dfm = dfm_select(dfm, stopwords("english"), "remove")
dfm = dfm_trim(dfm, min_count = 1)
dfm
```

```
Document-feature matrix of: 3 documents, 2 features (33.3% sparse).
3 x 2 sparse Matrix of class "dfmSparse"
       features
docs    test found
  text1    1     0
  text2    2     0
  text3    1     1
```

Preprocessing: collocations
===


```r
coll = textstat_collocations(tokens)
head(coll)
```

```
  collocation count length   lambda        z
1      a test     3      2 3.245193 1.833062
```

Preprocessing: collocations
===


```r
compounded = tokens_compound(tokens, coll)
dfm(compounded)
```

```
Document-feature matrix of: 3 documents, 7 features (57.1% sparse).
3 x 7 sparse Matrix of class "dfmSparse"
       features
docs    this is a_test they test i found
  text1    1  1      1    0    0 0     0
  text2    0  0      1    1    1 0     0
  text3    0  0      1    0    0 1     1
```

(De-)Motivational example:  Dutch stemming
===


```r
dfm_nl = dfm(c("De kippen eten", "De kip heeft gegeten"), remove=stopwords("dutch"))
dfm_nl
```

```
Document-feature matrix of: 2 documents, 4 features (50% sparse).
2 x 4 sparse Matrix of class "dfmSparse"
       features
docs    kippen eten kip gegeten
  text1      1    1   0       0
  text2      0    0   1       1
```

```r
dfm_wordstem(dfm_nl, language="dutch")
```

```
Document-feature matrix of: 2 documents, 4 features (50% sparse).
2 x 4 sparse Matrix of class "dfmSparse"
       features
docs    kipp eten kip geget
  text1    1    1   0     0
  text2    0    0   1     1
```

(We will cover lemmatizing and POS-tagging this afternoon!)

Dictionary-based analysis
===
type:section


Dictionary-based analysis
===

- Use list of keywords to define a concept
- (words, wildcards, boolean combinations, phrases, etc.)
- Measure (co-)occurrence of these concepts

Advantages of dictionaries?
- Easy to explain
- Easy to use
- Control over operationalization

AmCAT 
===

- Free and Open Source text analysis infrastructure
- Easy corpus management, keyword queries
- Integrates with R / quanteda
- Run your own server or use ours (amcat.nl)


AmCAT demo
===
type:section

Connecting to AmCAT from R
===
class: small-code


```r
devtools::install_github("amcat/amcat-r")
library(amcatr)
amcat.save.password("https://amcat.nl", username="...", 
                    password="...")
```


```r
conn = amcat.connect("https://amcat.nl")
meta = amcat.articles(conn, project=1235, articleset=32114, dateparts = T)
table(meta$medium)
```

```

      The New York Times The New York Times Blogs                USA TODAY 
                    9551                     1660                     1993 
```

```r
saveRDS(meta, "meta.rds")
```

Running AmCAT queries in R
===

```r
a = amcat.aggregate(conn, sets=32139, queries = c("trump", "clinton"), axis1 = "week")
head(a)
```

```
  count       week query
1    14 2015-12-28 trump
2    51 2016-01-04 trump
3    65 2016-01-11 trump
4    66 2016-01-18 trump
5    92 2016-01-25 trump
6    94 2016-02-01 trump
```

Running AmCAT queries in R
===

```r
library(ggplot2)
ggplot(data=a, mapping=aes(x=week, y=count, color=query)) + geom_line()
```

![plot of chunk unnamed-chunk-13](1_dtm-figure/unnamed-chunk-13-1.png)

Getting AmCAT data into R
===

```r
h = amcat.hits(conn, sets=32142, 
               queries=c("trump", "clinton"))
meta = amcat.articles(conn, project=1235, 
                      articleset=32142)
h = merge(meta, h)
head(h)
```

```
         id       date             medium count   query
1 162317450 2016-03-01 The New York Times     1 clinton
2 162317731 2016-02-02 The New York Times     7   trump
3 162317731 2016-02-02 The New York Times     4 clinton
4 162317809 2016-01-25 The New York Times     1   trump
5 162317820 2016-01-24 The New York Times     1 clinton
6 162317856 2016-01-18 The New York Times     1   trump
```

Getting AmCAT texts into R
===

```r
articles = amcat.articles(conn, project=1235, 
  articleset=32142, dateparts=T,
  columns=c("date", "headline", "text"))
saveRDS(articles, "articles.rds")
articles$text[1]
```

```
[1] "WASHINGTON -- IT'S hard not to feel sorry for Hillary Clinton. She is hearing\nghostly footsteps.\n\nShe's having her inevitability challenged a second time by a moralizing senator\nwith few accomplishments who chides her on her bad judgment on Iraq and\nspecial-interest money, breezily rakes in millions in small donations online,\ndraws tens of thousands to rock-star rallies and gets more votes from young\nwomen.\n\nBut at least last time, it was a dazzling newcomer who also offered the chance\nto break a barrier. This time, Hillary is trying to fend off a choleric\n74-year-old democratic socialist.\n\nSome close to the campaign say that those ghostly footsteps have made Hillary\nrestive. The déjà vu has exasperated Bill Clinton, who griped to an audience in\nNew York on Friday that young supporters of Bernie Sanders get excited because\nit sounds good to say, ''Just shoot every third person on Wall Street and\neverything will be fine.''\n\nAt the Brooklyn debate, there was acrimony, cacophony, sanctimony and,\nnaturally, baloney.\n\nHillary gazed at Bernie as though she could hypnotize him into skedaddling. And\nBernie waved his index finger and flapped his hands, miming that he won't budge,\nno matter how aggravating it is for Clinton Inc.\n\nSanders flew to the Vatican that night to underscore his vision of himself as\nthe moral candidate. And Hillary headed to California, underscoring Bernie's\nportrayal of her as the mercenary candidate. She attended fund-raisers headlined\nby George and Amal Clooney in San Francisco and at the Clooneys' L.A. mansion\nthat cost $33,400 per person and $353,400 for two seats at the head table in San\nFrancisco -- an ''Ocean's Eleven'' safecracking that Sanders labeled\n''obscene.''\n\nClinton sowed suspicion again, refusing to cough up her Wall Street speech\ntranscripts. And Sanders faltered on guns, fracking and releasing his tax\nreturns. But he was gutsy, in a New York primary, to say he'd be more evenhanded\nwith Israel and the Palestinians. As my colleague Tom Friedman has warned, we\ncan hurt Israel by loving Israel to death.\n\nHillary alternately tried to blame and hug the men in her life, divvying up\ncredit in a self-serving way.\n\nAfter showing some remorse for the 1994 crime bill, saying it had had\n''unintended'' consequences, she stressed that her husband ''was the president\nwho actually signed it.'' On Libya, she noted that ''the decision was the\npresident's.'' And on her desire to train and arm Syrian rebels, she recalled,\n''The president said no.''\n\nBut she wrapped herself in President Obama's record on climate change and, when\ncriticized on her ''super PACs,'' said, well, Obama did it, too.\n\nSanders accused her of pandering to Israel after she said that ''if Yasir Arafat\nhad agreed with my husband at Camp David,'' there would have been a Palestinian\nstate for 15 years.\n\nHillary may be right that Bernie is building socialist castles in the sky. But\nBernie is right that Hillary's judgment has often been faulty.\n\nShe has shown an unwillingness to be introspective and learn from her mistakes.\nFrom health care to Iraq to the email server, she only apologizes at the point\nof a gun. And even then, she leaves the impression that she is merely sorry to\nbe facing criticism, not that she miscalculated in the first place.\n\nOn the server, she told Andrea Mitchell of NBC News that she was sorry it had\nbeen ''confusing to people and raised a lot of questions.'' She has never\nacknowledged, maybe even to herself, that routing diplomatic emails with\nclassified information through a homebrew server was an outrageous, reckless and\nfoolish thing to do, and disloyal to Obama, whose administration put in place\nrules for record-keeping that she flouted.\n\nWouldn't it be a relief to people if Hillary just acknowledged some mistakes? If\nshe said that her intentions on Libya were good but that she got distracted by\nother global issues and took her eye off the ball? That the questions that\nshould have been asked about Libya were not asked and knowing this now would\nmake her a better chief executive?\n\nObama, introspective to a fault, told Chris Wallace of Fox News that not having\na better plan after Muammar el-Qaddafi was overthrown was the worst mistake of\nhis presidency. But as usual, Clinton, who talked Obama into it, is defiantly\ndoubling down. As her national security advisers told Kim Ghattas for a piece in\nForeign Policy, Clinton ''does not see the Libya intervention as a failure, but\nas a work in progress.''\n\nClinton accused Sanders of not doing his homework on how he would break up the\nbanks. And she is the queen of homework, always impressively well versed in\nmeetings. But that is what makes her failure to read the National Intelligence\nEstimate that raised doubts about whether Iraq posed a threat to the U.S. so\negregious.\n\nLike other decisions, it was put through a political filter and a paranoid\nmind-set. She did not want to be seen, in that blindingly patriotic time, as the\nbohemian woman standing to the left of the military.\n\nWhen Barack Obama was warned by some supporters in 2002 not to make a speech\nagainst the Iraq invasion because it might hurt his political future, he said he\nwas going to do it anyhow because the war was a really terrible idea.\n\nWhat worries me is whether Hillary has the confidence to make decisions contrary\nto her political interests. Can she say, ''But it's a really terrible idea''?\n\nFollow Maureen Dowd on Twitter.\n\nFollow The New York Times Opinion section on Facebook and Twitter, and sign up\nfor the Opinion Today newsletter.\n\n\n\n\nURL: http://www.nytimes.com/2016/04/17/opinion/sunday/hillary-is-not-sorry.html"
```


AmCAT and quanteda
===

```r
d = dfm(articles$text, stem=T, 
        remove=stopwords("english"), remove_punct=T)
d = dfm_trim(d, min_doc=10)
topfeatures(d)
```

```
        mr      trump       said    clinton        new      state 
      9553       5568       4970       3565       2749       2175 
       one republican        mrs      polit 
      2100       2078       2030       1955 
```

```r
textplot_wordcloud(d, max.words = 50, scale = c(4, 0.5))
```

![plot of chunk unnamed-chunk-16](1_dtm-figure/unnamed-chunk-16-1.png)

AmCAT and quanteda (2)
===

```r
c = quanteda.corpus(conn, project=1235, articleset=32142, dateparts=T)
d = dfm(c, remove=stopwords("english"))
head(d)
```

```
Document-feature matrix of: 6 documents, 6 features (52.8% sparse).
6 x 6 sparse Matrix of class "dfmSparse"
           features
docs        washington  - hard feel sorry hillary
  171937712          1  4    1    1     3       9
  171937755          2 27    1    1     0       0
  171933722          0 36    2    0     0       0
  171937938          0  0    0    0     0       0
  171937818          0  3    0    0     0       1
  171940575          1  2    0    0     0       1
```

Dictionares within R
===


```r
issues = dictionary(list(economy=c("econ*", "inflation"), immigration=c("immigr*", "mexican*")))
d2 = dfm_lookup(d, issues, exclusive=T)
tail(d2)
```

```
Document-feature matrix of: 6 documents, 2 features (83.3% sparse).
6 x 2 sparse Matrix of class "dfmSparse"
           features
docs        economy immigration
  171937494       0           2
  171937704       0           0
  171944064       0           0
  171943751       0           0
  171941697       7           0
  171943991       0           0
```

Dictionares within R
===


```r
d2 = cbind(docvars(c), as.matrix(d2))
a = aggregate(d2[names(issues)], d2["week"], sum)
ggplot(a, aes(x=week)) +
  geom_line(aes(y = economy, color="green"))  +
  geom_line(aes(y = immigration, color="red"))
```

![plot of chunk unnamed-chunk-19](1_dtm-figure/unnamed-chunk-19-1.png)

Where to get dictionaries?
===

- Create your own
- Create from corpora (next session)
- Replication materials
- wordstat, LIWC, ...

Hands-on session I
===

- Why did Trump win the (primary) election?
- Operationalize a variable using search strings
  - candidates, issues, emotion, populism, ...
  - download or create word list
- Plot variable over time / co-occurring with either candidate
- Use AmCAT GUI, AmCAT R, quanteda, ...
