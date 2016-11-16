<style>

.reveal .slides > sectionx {
    top: -70%;
}

.reveal pre code.r {background-color: #ccF}
.reveal pre code {font-size: 1.3em}

.section .reveal li {color:white}
.section .reveal em {font-weight: bold; font-style: "none"}

</style>



Text Analysis with R
========================================================
author: Wouter van Atteveldt
date:   Glasgow Text Analysis, 2016-11-17

Course Overview
========================================================
Morning Session:
- Recap: Frequency Based Analysis and the DTM
- Dictionary Analysis with AmCAT and R
- Corpus Analysis and Visualization

Afternoon Session:
- Simple Natural Language Processing
- Topic Modeling and Visualization
- Sentiment Analysis with dictionaries
- Sentiment Analysis with proximity

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


































```
Error in library(quanteda) : there is no package called 'quanteda'
```
