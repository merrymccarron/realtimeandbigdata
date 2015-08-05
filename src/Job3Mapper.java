import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

public class Job3Mapper
  extends Mapper<LongWritable, Text, Text, IntWritable> {

  private static final HashSet<String> STOPWORDS = new HashSet<String>() ;
  
  protected void setup(Context context) throws IOException, InterruptedException {
	  Configuration conf = context.getConfiguration();
		  
	  BufferedReader br = new BufferedReader(new FileReader(conf.get("stopwords")));
	  try {
	      StringBuilder sb = new StringBuilder();
	      String line = br.readLine();
	      while (line != null) {
	          sb.append(line);
	          sb.append(System.lineSeparator());
	          line = br.readLine();
	      }
	      String everything = sb.toString();
	      for(String stword: everything.split(",")) {
			  STOPWORDS.add(stword);
		  }
	  } finally {
	      br.close();
	  } 
   }
	
  @Override
  public void map(LongWritable key, Text value, Context context)
      throws IOException, InterruptedException {
    
    String line = value.toString().toLowerCase();
    if (!line.contains("billnumamend")){
	    String[] record = line.split(",");
	    
	    //bill title:
	    record[1] = record[1].replaceAll("[^a-z\\s]", "");
	    record[1] = record[1].replaceAll("\\s+", " ").trim();
	    
	    String[] words = record[1].split(" ");
	    Set<String> distinctWords = new HashSet<String>(Arrays.asList(words));
	    
	    for (String word : distinctWords){
	    	if ((!(STOPWORDS.contains(word))) & (word.length()>1)){
	    		context.write(new Text(word), new IntWritable(1));
	    	}
	    }
    }
  }
}
