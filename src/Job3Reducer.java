import java.io.IOException;

import org.apache.hadoop.io.DoubleWritable;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

public class Job3Reducer
  extends Reducer<Text, IntWritable, Text, DoubleWritable> {
  
  private static double N=71025;
  
  @Override
  public void reduce(Text key, Iterable<IntWritable> values,
      Context context)
      throws IOException, InterruptedException {
    
    int sum = 0;
    for (IntWritable value : values) {
    	sum+=value.get();
    }
    context.write(key, new DoubleWritable(Math.log(N/sum)));
  }
}