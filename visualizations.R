#read data and convert types
words_metrics <- read.csv('outputs/hiveout/words_metrics_master.csv')
colnames(words_metrics) <- c('word','num_of_bills','tfidf','total_spent','avg_spent')
words_metrics$avg_spent <- as.numeric(as.character(words_metrics$avg_spent))/1000
words_metrics$total_spent <- as.numeric(as.character(words_metrics$total_spent))/1000000

#produce TF-IDF scoring distribution
hist(words_metrics$tfidf, main="TF-IDF (modified) score distibution",
     xlab="TF-IDF (modified)", ylab="Frequency", col="#deebf7", breaks=30)

#find keywords
key_words <- subset(words_metrics, tfidf >= 20)
key_words_selected <- subset(key_words, word %in% c('food','beer','earthquake','kill','disease','smoking','drug','rape','marijuana'))
key_words_selected <- key_words_selected[order(key_words_selected$num_of_bills),]

par(mfrow=c(1,3),mai=c(0.5,1,0.7,0.5))
barplot(height=key_words_selected$num_of_bills, width=0.7, horiz=TRUE, names.arg=key_words_selected$word,las=1,col="#bdbdbd", xlab="# of bills", main="Number of bills")
barplot(height=key_words_selected$total_spent, width=0.7, horiz=TRUE, names.arg=key_words_selected$word,las=1,col="#a1d99b", xlab="$ (Millions)", main="Total amount spent on lobbying")
barplot(height=key_words_selected$avg_spent, width=0.7, horiz=TRUE, names.arg=key_words_selected$word,las=1,col="#9ecae1", xlab="$ (K)", main="AVG amount spent per bill on lobbying")
title(main="Keyword",outer=T)

#find keywords associated with high spending
words_metrics <- words_metrics[order(words_metrics$total_spent),]
top_spent_selected <- subset(words_metrics, word %in% c('health','tax','care','insurance','school','property','city','motor','vehicle'))

par(mfrow=c(1,3), oma=c(2,2,2,2))
barplot(height=top_spent_selected$num_of_bills, width=0.5, horiz=TRUE, names.arg=top_spent_selected$word,las=1,col="#bdbdbd", xlab="# of bills", main="Number of bills")
barplot(height=top_spent_selected$total_spent, width=0.5, horiz=TRUE, names.arg=top_spent_selected$word,las=1,col="#a1d99b", xlab="$ (Millions)", main="Total amount spent on lobbying")
barplot(height=top_spent_selected$avg_spent, width=0.5, horiz=TRUE, names.arg=top_spent_selected$word,las=1,col="#9ecae1", xlab="$ (K)", main="AVG amount spent per bill on lobbying")
title(main="Keyword with top spending",outer=T)

#aux function
## Add an alpha value to a colour
add.alpha <- function(col, alpha=1){
  if(missing(col))
    stop("Please provide a vector of colours.")
  apply(sapply(col, col2rgb)/255, 2, 
        function(x) 
          rgb(x[1], x[2], x[3], alpha=alpha))  
}

#scatter plots
words_metrics <- subset(words_metrics,total_spent>=0)
plot(words_metrics$tfidf,words_metrics$avg_spent, pch=16, xlab="TF-IDF", ylab="AVG spent per bill (K $)", col=add.alpha("blue",0.5), main="TF-IDF score vs. AVG spent per bill")
words_metrics <- words_metrics[order(-words_metrics$avg_spent),]
text(words_metrics$tfidf[1:3],words_metrics$avg_spent[1:3], labels=words_metrics$word[1:3], pos=c(4,1,2), cex=0.6)
words_metrics <- words_metrics[order(-words_metrics$tfidf),]
text(words_metrics$tfidf[1:3],words_metrics$avg_spent[1:3], labels=words_metrics$word[1:3], pos=c(3,3,1), cex=0.6)



plot(words_metrics$tfidf,words_metrics$total_spent, pch=16)
plot(words_metrics$tfidf,words_metrics$num_of_bills, pch=16)
plot(words_metrics$num_of_bills,words_metrics$avg_spent, pch=16)



