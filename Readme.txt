------------ Fourth and Final Code Drop README text -----------------------------
An additional MapReduce job has been added to map words to bills. This job’s output together with the about of the chain jobs (TF-IDF (modified algorithm), are used in the second part of our analysis which was implemented in Hive.

Our hive script (found under “hive/hivequeries.q” - reads the data from the several map reduced jobs, as well as two other tables in the original Oracle database. If performs the joins and relevant calculations and its final output is the table: master_word_metrics. The table contains for each word, the calculation of 3 metrics: number of bills it appeared in, total amount spent on lobbying, average amount spent on lobbying per bill.

Our final addition to the code is the visualization script written in R (“visualiztions/visualizations.R”). This script reads the final output, and produces some plots that will help us to communicate our findings.


------------ Third Code Drop README text -----------------------------
All four MapReduce scripts for the TF-IDF portion of the project are written and running correctly. We have processed the data for all 71,000 bills and are so far happy with the result. The four MapReduce scripts are processed by one script that chains each MapReduce job together, since the output from job 1 is the input for job 2, etc. Issues with commas in our bill text have been resolved. 

The next step is to do processing in Hive to calculate the amount spent per bill. We feel that we're in a very good place in the state of our analytic.

------------ Second Code Drop README text -----------------------------
Our code this week is for the first three (out of a total of four) steps to run a TF-IDF algorithm on the text of 
New York State Assembly and Senate bills. You can see the pseudo-code for jobs 1, 2 and 3 (also submitted last week),
in a Google Doc here: 

https://docs.google.com/document/d/13sZtfVq1TAunuRKekOtXbi_5YJOYhxLafG5Djy5TGbg/edit

Our data is in a good state right now -- all 71,000 bills are accessible in a single file. We have been 
testing our code on a small subset of bills (first five). We have already addressed a few bugs with our data--
the file format is comma delimited, but our MapReduce code was struggling with fields that had commas in their text.
We have taken out the unnecessary fields that were giving us those problems. 

------------ First Code Drop README text -----------------------------
We've submitted a pseudo-code for our modified TF-IDF algorithm.
