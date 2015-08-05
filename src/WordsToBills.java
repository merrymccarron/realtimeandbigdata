import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class WordsToBills {
	public static void main(String[] args) throws Exception {
	    if (args.length != 3) {
	      System.err.println("Usage: WordCount <input_path> <output_path> <list_of_stopwords>");
	      System.exit(-1);
	    }
	     
	    Configuration conf = new Configuration();
	    conf.set("stopwords", args[2]);
	    Job job = new Job(conf, "WordsToBills");
	    job.setJarByClass(WordsToBills.class);

	    FileInputFormat.addInputPath(job, new Path(args[0]));
	    FileOutputFormat.setOutputPath(job, new Path(args[1]));
	    
	    job.setMapperClass(WordsToBillsMapper.class);
	    job.setReducerClass(WordsToBillsReducer.class);

	    job.setOutputKeyClass(Text.class);
	    job.setOutputValueClass(Text.class);
	    
	    System.exit(job.waitForCompletion(true) ? 0 : 1);
	  }
}
