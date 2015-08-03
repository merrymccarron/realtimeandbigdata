import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

public class Job3Mapper
  extends Mapper<LongWritable, Text, Text, IntWritable> {
  
  @Override
  public void map(LongWritable key, Text value, Context context)
      throws IOException, InterruptedException {
    
    String line = value.toString().toLowerCase();
    if (!line.contains("billnum")){
	    String[] record = line.split(",");
	    
	    String[] words = record[7].split(" ");
	    Set<String> distinctWords = new HashSet<String>(Arrays.asList(words));
	    
	    for (String word : distinctWords){
	    	context.write(new Text(word), new IntWritable(1));
	    }
    }
  }
}
