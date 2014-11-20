Machine Learning using RTextTools
=================================

_(C) 2014 Wouter van Atteveldt, license: [CC-BY-SA]_

Machine Learning or automatic text classification is a set of techniques to train a statistical model on a set of annotated (coded) training texts, that can then be used to predict the category or class of new texts.

R has a number of different packages for various machine learning algorithm such as maximum entropy modeling, neural networks, and support vector machines. 
`RTextTools` provides an easy way to access a large number of these algorithms.

In principle, like 'classical' statistical models, machine learning uses a number of (independent) variables called _features_ to predict a target (dependent) category or class. 
In text mining, the independent variables are generally the term frequencies, and as such the input for the machine learning is the document-term matrix. 

Training models using RTextTools
----

So, the first step is to create a document-term matrix. 
We only want to use the documents for which the sentiment is known (for now).
As before, we use the `achmea.csv` that can be downloaded from [github](https://raw.githubusercontent.com/vanatteveldt/learningr/master/achmea.csv).


```r
library(RTextTools)
```

```
## Loading required package: SparseM
## 
## Attaching package: 'SparseM'
## 
## The following object is masked from 'package:base':
## 
##     backsolve
```

```r
d = read.csv("achmea.csv")
ds = d[!is.na(d$SENTIMENT), ]
m = create_matrix(ds$CONTENT, language="dutch", stemWords=F)
```

The next step is to create the RTextTools _container_. 
This contains both the d-t matrix and the manually coded classes,
and you specify which parts to use for training and which for testing.

To make sure that we get a random sample of documents for training and testing,
we sample 80% of the set for training and the remainder for testing.
(Note that it is important to sort the indices as otherwise GLMNET will fail)


```r
n = nrow(m)
train = sort(sample(1:n, n*.8))
test = sort(setdiff(1:n, train))
length(train)
```

```
## [1] 4252
```

```r
length(test)
```

```
## [1] 1063
```

Now, we are ready to create the container:


```r
c = create_container(m, ds$SENTIMENT, trainSize=train, testSize=test, virgin=F)
```

Using this container, we can train different models:


```r
SVM <- train_model(c,"SVM")
MAXENT <- train_model(c,"MAXENT")
GLMNET <- train_model(c,"GLMNET")
```

Testing model performance
----

Using the same container, we can classify the 'test' dataset


```r
SVM_CLASSIFY <- classify_model(c, SVM)
MAXENT_CLASSIFY <- classify_model(c, MAXENT)
GLMNET_CLASSIFY <- classify_model(c, GLMNET)
```

Let's have a look at what these classifications yield:


```r
head(SVM_CLASSIFY)
```

```
##   SVM_LABEL SVM_PROB
## 1         1   0.9584
## 2         1   0.9967
## 3         1   0.9829
## 4         1   0.9049
## 5         1   0.9261
## 6         1   0.7481
```

```r
nrow(SVM_CLASSIFY)
```

```
## [1] 1063
```

For each document in the test set, the predicted label and probability are given. 
We can compare these predictions to the correct classes manually:


```r
t = table(SVM_CLASSIFY$SVM_LABEL, as.character(ds$SENTIMENT[test]))
t
```

```
##     
##        1  -1
##   1  552  95
##   -1  61 355
```

(Note that the as.character cast is necessary to align the rows and columns)
And compute the accuracy:


```r
sum(diag(t)) / sum(t)
```

```
## [1] 0.8532
```


Analytics
----

To make it easier to compute the relevant metrics, RTextTools has a built-in analytics function:


```r
analytics <- create_analytics(c, cbind(SVM_CLASSIFY, GLMNET_CLASSIFY, MAXENT_CLASSIFY))
names(attributes(analytics))
```

```
## [1] "label_summary"     "document_summary"  "algorithm_summary"
## [4] "ensemble_summary"  "class"
```

The `algorithm_summary` gives the performance of the various algorithms, with precision, recall, and f-score given per algorithm:


```r
analytics@algorithm_summary
```

```
##    SVM_PRECISION SVM_RECALL SVM_FSCORE GLMNET_PRECISION GLMNET_RECALL
## -1          0.85       0.79       0.82             0.86          0.69
## 1           0.85       0.90       0.87             0.80          0.92
##    GLMNET_FSCORE MAXENTROPY_PRECISION MAXENTROPY_RECALL MAXENTROPY_FSCORE
## -1          0.77                 0.74              0.78              0.76
## 1           0.86                 0.84              0.80              0.82
```

The `label_summary` gives the performance per label (class):


```r
analytics@label_summary
```

```
##    NUM_MANUALLY_CODED NUM_CONSENSUS_CODED NUM_PROBABILITY_CODED
## -1                450                 398                   445
## 1                 613                 665                   618
##    PCT_CONSENSUS_CODED PCT_PROBABILITY_CODED PCT_CORRECTLY_CODED_CONSENSUS
## -1               88.44                 98.89                         76.44
## 1               108.48                100.82                         91.19
##    PCT_CORRECTLY_CODED_PROBABILITY
## -1                           76.89
## 1                            83.85
```

Finally, the `ensemble_summary` gives an indication of how performance changes based on the amount of classifiers that agree on the classification:


```r
analytics@ensemble_summary
```

```
##        n-ENSEMBLE COVERAGE n-ENSEMBLE RECALL
## n >= 1                1.00              0.85
## n >= 2                1.00              0.85
## n >= 3                0.77              0.90
```

The last attribute, `document_summary`, contains the classifications of the various algorithms per document, and also lists how many agree and whether the consensus and the highest probability classifier where correct:


```r
head(analytics@document_summary)
```

```
##   SVM_LABEL SVM_PROB GLMNET_LABEL GLMNET_PROB MAXENTROPY_LABEL
## 1         1   0.9584            1      0.9658                1
## 2         1   0.9967            1      0.9903                1
## 3         1   0.9829            1      0.9573                1
## 4         1   0.9049            1      0.8988                1
## 5         1   0.9261            1      0.7553                1
## 6         1   0.7481            1      0.8328                1
##   MAXENTROPY_PROB MANUAL_CODE CONSENSUS_CODE CONSENSUS_AGREE
## 1          1.0000           1              1               3
## 2          1.0000           1              1               3
## 3          1.0000           1              1               3
## 4          1.0000           1              1               3
## 5          0.9994           1              1               3
## 6          1.0000           1              1               3
##   CONSENSUS_INCORRECT PROBABILITY_CODE PROBABILITY_INCORRECT
## 1                   0                1                     0
## 2                   0                1                     0
## 3                   0                1                     0
## 4                   0                1                     0
## 5                   0                1                     0
## 6                   0                1                     0
```

Classifying new material
----

New material (called 'virgin data' in RTextTools) can be coded by placing the old and new material in a single container. 
We now set all documents with a sentiment score as training material, and specify `virgin=T` to indicate that we don't have coded classes on the test material:


```r
m_full = create_matrix(d$CONTENT, language="dutch", stemWords=F)
coded = which(!is.na(d$SENTIMENT))
c_full = create_container(m_full, d$SENTIMENT, trainSize=coded, virgin=T)
```

We can now build and test the model as before:


```r
SVM <- train_model(c_full,"SVM")
MAXENT <- train_model(c_full,"MAXENT")
GLMNET <- train_model(c_full,"GLMNET")
SVM_CLASSIFY <- classify_model(c_full, SVM)
MAXENT_CLASSIFY <- classify_model(c_full, MAXENT)
GLMNET_CLASSIFY <- classify_model(c_full, GLMNET)
analytics <- create_analytics(c, cbind(SVM_CLASSIFY, GLMNET_CLASSIFY, MAXENT_CLASSIFY))
```

```
## Error: all arguments must have the same length
```

```r
names(attributes(analytics))
```

```
## [1] "label_summary"     "document_summary"  "algorithm_summary"
## [4] "ensemble_summary"  "class"
```

As you can see, the analytics now only has the `label_summary` and `document_summary`:


```r
analytics@label_summary
```

```
##    NUM_MANUALLY_CODED NUM_CONSENSUS_CODED NUM_PROBABILITY_CODED
## -1                450                 398                   445
## 1                 613                 665                   618
##    PCT_CONSENSUS_CODED PCT_PROBABILITY_CODED PCT_CORRECTLY_CODED_CONSENSUS
## -1               88.44                 98.89                         76.44
## 1               108.48                100.82                         91.19
##    PCT_CORRECTLY_CODED_PROBABILITY
## -1                           76.89
## 1                            83.85
```

```r
head(analytics@document_summary)
```

```
##   SVM_LABEL SVM_PROB GLMNET_LABEL GLMNET_PROB MAXENTROPY_LABEL
## 1         1   0.9584            1      0.9658                1
## 2         1   0.9967            1      0.9903                1
## 3         1   0.9829            1      0.9573                1
## 4         1   0.9049            1      0.8988                1
## 5         1   0.9261            1      0.7553                1
## 6         1   0.7481            1      0.8328                1
##   MAXENTROPY_PROB MANUAL_CODE CONSENSUS_CODE CONSENSUS_AGREE
## 1          1.0000           1              1               3
## 2          1.0000           1              1               3
## 3          1.0000           1              1               3
## 4          1.0000           1              1               3
## 5          0.9994           1              1               3
## 6          1.0000           1              1               3
##   CONSENSUS_INCORRECT PROBABILITY_CODE PROBABILITY_INCORRECT
## 1                   0                1                     0
## 2                   0                1                     0
## 3                   0                1                     0
## 4                   0                1                     0
## 5                   0                1                     0
## 6                   0                1                     0
```

The label summary now only contains an overview of how many where coded using consensus and probability. The document_summary lists the output of all algorithms, and the consensus and probability code. 
