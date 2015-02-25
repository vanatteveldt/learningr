Learning R
==========

R is a very powerful and flexible statistics package and programming language.

This repository contains a number of 'howto' files aimed to providing an introduction to R and some os its possibilities.

Some other great sites for learning R are:
- [OpenIntro statistics](http://openintro.org/stat/labs.php) with a number of good statistics 'labs' in R
- [Quick-R](http://www.statmethods.net) with explanations and sample code for a wide array of applications
- [Advanced R Programming](http://adv-r.had.co.nz/) for (much) more information on what is really going on.

To install R and RStudio, please see [lab 0 of the OpenIntro statistics book](http://openintro.org/download.php?file=os2_lab_00A&referrer=/stat/labs.php).

General Howto's
----

- Getting started
  - [using R as a calculator](https://rawgit.com/vanatteveldt/learningr/master/1_r_calculator.html) ([source](https://github.com/vanatteveldt/learningr/blob/master/1_r_calculator.Rmd))
  - [playing with data in R](https://rawgit.com/vanatteveldt/learningr/master/2_playing.html) ([source](https://github.com/vanatteveldt/learningr/blob/master/2_playing.Rmd))
- Data preparation
  - [Organizing data](https://rawgit.com/vanatteveldt/learningr/master/3_organizing.html) ([source](https://github.com/vanatteveldt/learningr/blob/master/3_organizing.Rmd))
  - [Transforming and merging data](https://rawgit.com/vanatteveldt/learningr/master/4_transforming.html) ([source](https://github.com/vanatteveldt/learningr/blob/master/4_transforming.Rmd))
- Data analysis
  - [Plotting your data](https://rawgit.com/vanatteveldt/learningr/master/6_visualization.html) ([source](https://github.com/vanatteveldt/learningr/blob/master/6_visualization.Rmd))
  - [Data modeling: T-tests to linear models](https://rawgit.com/vanatteveldt/learningr/master/5_modeling.html) ([source](https://github.com/vanatteveldt/learningr/blob/master/5_modeling.Rmd))
- Advanced modeling
  - [Time series models](https://rawgit.com/vanatteveldt/learningr/master/7_timeseries.html) ([source](https://github.com/vanatteveldt/learningr/blob/master/7_timeseries.Rmd))
  - [Multi-level models](https://rawgit.com/vanatteveldt/learningr/master/8_multilevel.html)
 ([source](https://github.com/vanatteveldt/learningr/blob/master/8_multilevel.Rmd))

Dealing with textual data
----

For textual data, we have also developed two R packages to [communicate with the AmCAT text analysis framework](http://github.com/amcat/amcat-r) and to [deal with corpus analysis and topic models](http://github/com/kasperwelbers/corpustools). We also wrote two relevant howto's:

- [Corpus Analysis: Term document Matrices, frequency analysis, and topic modeling](https://rawgit.com/vanatteveldt/learningr/master/corpus.html) ([source](https://github.com/vanatteveldt/learningr/blob/master/corpus.Rmd)))
- [Claues Analysis: Using grammatical analysis for semantic network analysis](https://rawgit.com/vanatteveldt/learningr/master/clauses.html) ([source](https://github.com/vanatteveldt/learningr/blob/master/clauses.Rmd)))

Below are also some handouts that do not depend on AmCAT, based on a Dutch data set:

  - [Corpus Analysis: Term Document Matrices](https://rawgit.com/vanatteveldt/learningr/master/text_1_corpus.html) ([source](https://github.com/vanatteveldt/learningr/blob/master/text_1_corpus.Rmd))
  - [LDA topic modeling](https://rawgit.com/vanatteveldt/learningr/master/text_2_lda.html) ([source](https://github.com/vanatteveldt/learningr/blob/master/text_2_lda.Rmd))
  - [Lemmatization](https://rawgit.com/vanatteveldt/learningr/master/text_3_lemma.html) ([source](https://github.com/vanatteveldt/learningr/blob/master/text_3_lemma.Rmd))
  - [Machine Learning with RTextTools](https://rawgit.com/vanatteveldt/learningr/master/text_4_texttools.html) ([source](https://github.com/vanatteveldt/learningr/blob/master/text_4_texttools.Rmd))


Network Analysis
----

- [Using igraph](https://github.com/kasperwelbers/network-tools/blob/master/howto/howto_using_igraph.md)([source](https://github.com/kasperwelbers/network-tools/blob/master/howto/howto_using_igraph.Rmd))
- [Communication networks](https://github.com/kasperwelbers/network-tools/blob/master/howto/howto_explicit_ties_in_communication_networks.md)([source](https://github.com/kasperwelbers/network-tools/blob/master/howto/howto_explicit_ties_in_communication_networks.Rmd))
- [Content Similarity Networks](https://github.com/kasperwelbers/network-tools/blob/master/howto/howto_content_similarity_network.md)([source](https://github.com/kasperwelbers/network-tools/blob/master/howto/howto_content_similarity_network.Rmd))

(The last part of the 'semantic network analysis' demo above also has  a simplistic network analysis at the end)
