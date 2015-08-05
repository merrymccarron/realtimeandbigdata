import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.DoubleWritable;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.MultipleInputs;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

public class ChainJobs extends Configured implements Tool {

 private static final String OUTPUT_PATH1 = "intermediate_output1";
 private static final String OUTPUT_PATH2 = "intermediate_output2";
 private static final String OUTPUT_PATH3 = "intermediate_output3";
 
 @Override
 public int run(String[] args) throws Exception {
  /*
   * Job 1
   */
  Configuration conf1 = new Configuration();
  conf1.set("stopwords", args[2]);
  Job job = new Job(conf1, "Job1");
  job.setJarByClass(ChainJobs.class);

  job.setMapperClass(Job1Mapper.class);
  job.setReducerClass(Job1Reducer.class);

  job.setOutputKeyClass(Text.class);
  job.setOutputValueClass(IntWritable.class);

  job.setInputFormatClass(TextInputFormat.class);
  job.setOutputFormatClass(TextOutputFormat.class);

  TextInputFormat.addInputPath(job, new Path(args[0]));
  TextOutputFormat.setOutputPath(job, new Path(OUTPUT_PATH1));

  job.waitForCompletion(true);

  /*
   * Job 2
   */
  Configuration conf2 = getConf();
  Job job2 = new Job(conf2, "Job 2");
  job2.setJarByClass(ChainJobs.class);

  job2.setMapperClass(Job2Mapper.class);
  job2.setReducerClass(Job2Reducer.class);

  job2.setOutputKeyClass(Text.class);
  job2.setOutputValueClass(IntWritable.class);

  job2.setInputFormatClass(TextInputFormat.class);
  job2.setOutputFormatClass(TextOutputFormat.class);

  TextInputFormat.addInputPath(job2, new Path(OUTPUT_PATH1));
  TextOutputFormat.setOutputPath(job2, new Path(OUTPUT_PATH2));
  
  job2.waitForCompletion(true);

  /*
   * Job 3
   */
  Configuration conf3 = new Configuration();
  conf3.set("stopwords", args[2]);  Job job3 = new Job(conf3, "Job 3");
  job3.setJarByClass(ChainJobs.class);

  job3.setMapperClass(Job3Mapper.class);
  job3.setReducerClass(Job3Reducer.class);

  job3.setOutputKeyClass(Text.class);
  job3.setOutputValueClass(IntWritable.class);

  job3.setInputFormatClass(TextInputFormat.class);
  job3.setOutputFormatClass(TextOutputFormat.class);

  TextInputFormat.addInputPath(job3, new Path(args[0]));
  TextOutputFormat.setOutputPath(job3, new Path(OUTPUT_PATH3));
  
  job3.waitForCompletion(true);
  
  /*
   * Job 4
   */
  Configuration conf4 = getConf();
  Job job4 = new Job(conf4, "Job 4");
  job4.setJarByClass(ChainJobs.class);

  job4.setMapperClass(Job4Mapper.class);
  job4.setReducerClass(Job4Reducer.class);

  job4.setOutputKeyClass(Text.class);
  job4.setOutputValueClass(DoubleWritable.class);

  job4.setOutputFormatClass(TextOutputFormat.class);

  MultipleInputs.addInputPath(job4,new Path(OUTPUT_PATH2),TextInputFormat.class,Job4Mapper.class);
  MultipleInputs.addInputPath(job4,new Path(OUTPUT_PATH3),TextInputFormat.class,Job4Mapper.class);
  TextOutputFormat.setOutputPath(job4, new Path(args[1]));
  
  job4.waitForCompletion(true);

  return job3.waitForCompletion(true) ? 0 : 1;
 }

 /**
  * Method Name: main Return type: none Purpose:Read the arguments from
  * command line and run the Job till completion
  * 
  */
 public static void main(String[] args) throws Exception {
  // TODO Auto-generated method stub
  if (args.length != 3) {
   System.err.println("Enter valid number of arguments <Inputdirectory>  <Outputlocation> <stopwords file>");
   System.exit(0);
  }
  ToolRunner.run(new Configuration(), new ChainJobs(), args);
 }
}