Our code this week is for the first three (out of a total of four) steps to run a TF-IDF algorithm on the text of 
New York State Assembly and Senate bills. You can see the pseudo-code for jobs 1, 2 and 3 (also submitted last week),
in a Google Doc here: 

https://docs.google.com/document/d/13sZtfVq1TAunuRKekOtXbi_5YJOYhxLafG5Djy5TGbg/edit

Our data is in a good state right now -- all 71,000 bills are accessible in a single file. We have been 
testing our code on a small subset of bills (first five). We have already addressed a few bugs with our data--
the file format is comma delimited, but our MapReduce code was struggling with fields that had commas in their text.
We have taken out the unnecessary fields that were giving us those problems. 