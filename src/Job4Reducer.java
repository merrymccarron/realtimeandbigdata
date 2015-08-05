import java.io.IOException;

import org.apache.hadoop.io.DoubleWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

public class Job4Reducer
  extends Reducer<Text, DoubleWritable, Text, DoubleWritable> {
    
  @Override
  public void reduce(Text key, Iterable<DoubleWritable> values,
      Context context)
      throws IOException, InterruptedException {
    
    double tfidf = 1;
    for (DoubleWritable value : values) {
    	tfidf = tfidf * value.get();
    }
    context.write(key, new DoubleWritable(tfidf));
  }
}