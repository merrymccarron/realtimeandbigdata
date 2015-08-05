import java.io.IOException;

import org.apache.hadoop.io.DoubleWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

public class Job4Mapper
  extends Mapper<LongWritable, Text, Text, DoubleWritable> {
  
  @Override
  public void map(LongWritable key, Text value, Context context)
      throws IOException, InterruptedException {
	  	String line = value.toString();
	    String[] record = line.split("\t");
	    context.write(new Text(record[0]), new DoubleWritable(Double.parseDouble(record[1])));
  }
}
