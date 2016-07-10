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
date: Accessing APIs from R


What is an API?
===

+ Application Programming Interface
+ Computer-friendly web page
  + Standardized requests
  + Structured response
    + json/ csv
+ Access directly (HTTP call)
+ Client library for popular APIs

Demo: APIs and HTTP requests
===
type: section
    
Package twitteR
===


```r
install_github("geoffjentry/twitteR") 
setup_twitter_oauth(...)
tweets = searchTwitteR("#Trump2016", resultType="recent", n = 10)
tweets = plyr::ldply(tweets, as.data.frame)
```

Package Rfacebook
===


```r
install_github("pablobarbera/Rfacebook", subdir="Rfacebook")
fb_token = fbOAuth(fb_app_id, fb_app_secret)
p = getPage(page="nytimes", token=fb_token)
post = getPost(p$id[1], token=fb_token)
```

Package rtimes
====


```r
install.packages("rtimes")
options(nytimes_as_key = nyt_api_key)

res = as_search(q="trump", 
  begin_date = "20160101", 
  end_date = '20160501')

arts = plyr::ldply(res$data, 
  function(x) c(headline=x$headline$main, 
                date=x$pub_date))
```

APIs and rate limits
===

+ Most APIs have access limits
+ Log on with key or token
+ Response size (page) limited to n results
+ Requests limited to n per hour/day
+ Some clients deal with this, some don't
+ See API and client documentation


Directly accessing APIs
===

+ Make HTTP requests directly from R
  + package `httr` (or `RCurl`)
+ Can access all web data source
+ Need to figure out authentication, structure, etc


Directly accessing APIs
===


```r
domain = 'https://api.nytimes.com'
path = 'svc/search/v2/articlesearch.json'
url = paste(domain, path, url, sep='/')
query = list(`api-key`=key, q="clinton")
r = httr::GET(url, query=query)
status_code(r)
result = content(r)
result$response$docs[[1]]$headline
```


Hands-on 
====
type: section

Break

Hand-out:
+ Accesing APIs
+ Bonus: modeling and visualizing
