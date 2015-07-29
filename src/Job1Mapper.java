import java.io.IOException;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

public class Job1Mapper
  extends Mapper<LongWritable, Text, Text, IntWritable> {
  
  @Override
  public void map(LongWritable key, Text value, Context context)
      throws IOException, InterruptedException {
    
    String line = value.toString().toLowerCase();
    if (!line.contains("billnum")){
	    String[] record = line.split(",");
	    String billID = "("+record[3]+ "-" + record[12]+")";
	    
	    String[] words = record[7].split(" ");
	    for (String word : words){
	    	context.write(new Text(word+","+billID), new IntWritable(1));
	    }
    }
  }
}
