import java.io.IOException;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;


public class Job2Mapper   
	extends Mapper<LongWritable, Text, Text, IntWritable> {
	  
	  @Override
	  public void map(LongWritable key, Text value, Context context)
	      throws IOException, InterruptedException {
	    
	    String line = value.toString().toLowerCase();
		    String[] record = line.split("\t|,");
		    
		    Text word = new Text(record[0]);
		    IntWritable count = new IntWritable(Integer.parseInt(record[2]));
		    
		    context.write(word, count);
	  }
	}
