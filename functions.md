# Some useful R Functions

### Help!
* `?`	?command gives help on the given command, e.g. ?names

### Inspecting data		
*	`dim`	dim(d) gives the number of rows and columns in d
*	`names`	column names in d
*	`head`, `tail`	the top/bottom N rows of d
*	`summary`	A summary of the columns in d
*	`nrow`, `ncol`	the number of rows/columns in d

### Data characteristics		
*	`length`	length(x) gives the number of items in x
*	`mean`, `var`, `sd`, `median`	the mean/variance/stdev/median of the values in x

### Selecting and subsetting data		
*	`d[rows, columns]`	Select given row(s) and column(s)
*	`d$column`, `d[[column]]`	Select given column

### Tabulating and plotting		
*	`table`	table(x) gives the frequency of items in x; table(x,y) crosstabulates x and y
*	`plot`	plot(x, y) gives a scatter plot of x. Use plot(x, y, type='l') to get a line plot
*	`barplot`	barplot(x) gives a barplot of the values in x
*	`hist`	hist(x) gives a histogram of x, automatically binning the items
*	`lines`	lines(x, y) adds a new line to an existing plot

### Installing packages and other files		
*	`install.packages`	"Install the given packages. (Can also be done interactively in the packages tab in Rstudio)"
*	`library`	Load a given package that is already installed
*	`source`	Run a file (or URL) containing R commands
*	`download.file`	Download a file from the Internet

### Normal distributions		
*	`rnorm`	Generate numbers from a normal distribution
*	`pnorm`	Proportion of 
*	`qqnorm`, `qqline`	Plot the Q-Q scatter and normal line of a distribution
