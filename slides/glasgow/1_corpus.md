Text Analysis with R
========================================================
author: Wouter van Atteveldt
date:   Glasgow Text Analysis, 2016-11-17

Course Overview
========================================================
Morning Session:
- Frequency Based Analysis and the DTM
- Dictionary Analysis with AmCAT and R
- Corpus Analysis and Visualization

Afternoon Session:
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
  

```r
library(quanteda)
```
