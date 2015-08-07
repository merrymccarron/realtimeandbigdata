words_metrics <- read.csv('outputs/hiveout/words_metrics_master.csv')
colnames(words_metrics) <- c('word','num_of_bills','tfidf','total_spent','avg_spent')

hist(words_metrics$tfidf, main="TF-IDF (modified) score distibution",
     xlab="TF-IDF (modified)", ylab="Frequency", col="#deebf7", breaks=30)

key_words <- subset(words_metrics, tfidf >= 20)
key_words_selected <- subset(key_words, word %in% c('food','beer','earthquake','kill','disease','smoking','drug','rape','marijuana'))
key_words_selected <- key_words_selected[order(key_words_selected$num_of_bills),]
key_words_selected$total_spent <- as.numeric(as.character(key_words_selected$total_spent))/1000000
key_words_selected$avg_spent <- as.numeric(as.character(key_words_selected$avg_spent))/1000


par(mfrow=c(1,3),mai=c(0.5,1,0.7,0.5))
barplot(height=key_words_selected$num_of_bills, width=0.7, horiz=TRUE, names.arg=key_words_selected$word,las=1,col="#bdbdbd", xlab="# of bills", main="Number of bills")
barplot(height=key_words_selected$total_spent, width=0.7, horiz=TRUE, names.arg=key_words_selected$word,las=1,col="#a1d99b", xlab="$ (Millions)", main="Total amount spent on lobbying")
barplot(height=key_words_selected$avg_spent, width=0.7, horiz=TRUE, names.arg=key_words_selected$word,las=1,col="#9ecae1", xlab="$ (K)", main="AVG amount spent per bill on lobbying")
title(main="Metrics by keyword",outer=T)

