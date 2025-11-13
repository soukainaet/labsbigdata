# Hadoop Docker Lab Setup

This project demonstrates setting up a Hadoop cluster using Docker containers and creating Java applications to interact with HDFS.

## Project Structure

```
Lab Big data 0/
├── docker-compose.yml          # Docker container configuration
├── demo/                       # Maven Java project
│   ├── pom.xml                # Maven dependencies and build configuration
│   ├── src/
│   │   └── main/
│   │       └── java/
│   │           └── edu/
│   │               └── ensias/
│   │                   └── hadoop/
│   │                       ├── Main.java
│   │                       └── hdfslab/
│   │                           ├── HadoopFileStatus.java
│   │                           └── HDFSWrite.java
│   └── target/
│       ├── HDFSWrite.jar      # Generated JAR file
│       └── classes/           # Compiled Java classes
└── README.md                  # This documentation
```

## Docker Setup

### Container Configuration
- **hadoop-master**: Main Hadoop node with NameNode and ResourceManager
  - Ports: 9870 (NameNode UI), 8088 (ResourceManager UI), 8080 (Spark UI), 9000 (NameNode IPC)
  - Shared volume: `C:/Users/mouad/Documents/hadoop_project:/shared_volume`
- **hadoop-slave1**: Worker node (port 8040:8042)
- **hadoop-slave2**: Worker node (port 8041:8042)

### Starting the Cluster
```bash
docker-compose up -d
```

### Accessing the Master Container
```bash
docker exec -it hadoop-master bash
```

## Hadoop Services

### Starting HDFS and YARN
```bash
# Inside the hadoop-master container
start-dfs.sh
start-yarn.sh
```

### Verifying Services
```bash
hdfs dfsadmin -report
```

## HDFS Operations

### Creating Directories
```bash
# Create user directory structure
hdfs dfs -mkdir -p /user/root/input

# Create general input directory
hdfs dfs -mkdir -p /input
```

### File Operations
```bash
# Upload files to HDFS
hdfs dfs -put /shared_volume/purchases.txt /user/root/input/

# List files in HDFS
hdfs dfs -ls /user/root/input/

# Read file content
hdfs dfs -cat /user/root/input/purchases.txt

# Download files from HDFS
hdfs dfs -get /user/root/bonjour.txt /shared_volume/
```

## Java Applications

### HDFSWrite Class
A Java application that creates files in HDFS with custom content.

**Location**: `demo/src/main/java/edu/ensias/hadoop/hdfslab/HDFSWrite.java`

**Functionality**:
- Takes two arguments: file path and message
- Creates a file in HDFS if it doesn't exist
- Writes "Bonjour tout le monde !" and the provided message

### Building the JAR
```bash
# In Windows Command Prompt, navigate to demo directory
cd "C:\Users\mouad\OneDrive - um5.ac.ma\Desktop\Lab Big data 0\demo"

# Build the project
mvn clean compile package

# Copy JAR to shared volume
copy target\HDFSWrite.jar "C:\Users\mouad\Documents\hadoop_project\"
```

### Running the HDFSWrite Application
```bash
# Inside hadoop-master container
hadoop jar /shared_volume/HDFSWrite.jar /user/root/bonjour.txt "Hello HDFS!"
hadoop jar /shared_volume/HDFSWrite.jar /user/root/input/bonjour.txt "Hello HDFS!"
```
<img width="1069" height="220" alt="image" src="https://github.com/user-attachments/assets/2ce2405d-91ce-4172-9957-6f3c992e6b64" />

### HadoopFileStatus Class
A Java application that displays detailed information about files stored in HDFS.

**Location**: `demo/src/main/java/edu/ensias/hadoop/hdfslab/HadoopFileStatus.java`

**Functionality**:
- Checks if `/user/root/input/purchases.txt` exists in HDFS
- Displays file size, owner, permissions, replication factor, and block size
- Shows block locations and hosts
- Renames the file from `purchases.txt` to `achats.txt`

### Setting up Data for HadoopFileStatus
```bash
# Create input directory in HDFS
hdfs dfs -mkdir -p /user/root/input

# Create sample purchases.txt file
cat > /shared_volume/purchases.txt << EOF
1,apple,2.50
2,banana,1.25
3,orange,3.00
4,grape,4.75
5,strawberry,5.50
6,pineapple,6.25
7,mango,3.75
8,kiwi,2.25
9,peach,4.00
10,watermelon,8.50
EOF

# Upload file to HDFS
hdfs dfs -put /shared_volume/purchases.txt /user/root/input/

# Verify file exists
hdfs dfs -ls /user/root/input/
hdfs dfs -cat /user/root/input/purchases.txt
```

### Running the HadoopFileStatus Application
```bash
# Inside hadoop-master container
hadoop jar /shared_volume/HadoopFileStatus.jar

# The program will display file information and rename purchases.txt to achats.txt
# Note: The command line argument is ignored as the file path is hardcoded
```

## Maven Configuration

### Dependencies
- `hadoop-hdfs` (3.2.0)
- `hadoop-common` (3.2.0) 
- `hadoop-mapreduce-client-core` (3.2.0)

### Build Configuration
- Java version: 1.8
- Main class: `edu.ensias.hadoop.hdfslab.HDFSWrite`
- Final JAR name: `HDFSWrite.jar`

## Shared Volume

The shared volume allows file exchange between Windows host and Docker containers:
- **Host path**: `C:/Users/mouad/Documents/hadoop_project`
- **Container path**: `/shared_volume`

Files placed in either location are accessible from both environments.

## Web Interfaces

- **Hadoop NameNode UI**: http://localhost:9870
- **Hadoop ResourceManager UI**: http://localhost:8088
- **Spark Master UI**: http://localhost:8080
- **MapReduce History Server**: http://localhost:19888

## Troubleshooting

### Common Issues

1. **HDFS Connection Refused**
   - Ensure HDFS services are started: `start-dfs.sh`
   - Check if NameNode is running: `jps`

2. **Shared Volume Empty**
   - Verify Docker Desktop file sharing permissions
   - Check that files exist in local directory
   - Restart containers if needed

3. **JAR Execution Errors**
   - Rebuild JAR: `mvn clean package`
   - Verify main class configuration in pom.xml
   - Check JAR contents: `jar -tf HDFSWrite.jar`

## Accomplished Tasks

✅ Docker Compose configuration for Hadoop cluster  
✅ HDFS service setup and configuration  
✅ Java application development (HDFSWrite)  
✅ Maven build configuration  
✅ JAR file creation and deployment  
✅ HDFS file operations (create, read, upload, download)  
✅ Shared volume configuration between host and containers  
✅ Successful execution of Hadoop jobs  

## MapReduce Programming - WordCount Application

### Project Structure
```
LAB MAP_REDUCE/demo/
├── pom.xml
└── src/
    └── main/
        └── java/
            └── edu/
                └── ensias/
                    └── hadoop/
                        └── mapreducelab/
                            ├── WordCount.java          # Main class
                            ├── TokenizerMapper.java    # Mapper class
                            └── IntSumReducer.java      # Reducer class
```

### Objective
Create a MapReduce application to count word occurrences in a text file.

**Process**:
1. **Mapping Phase**: Text is split into words. For each word, generate a key/value pair `(word, 1)`.
2. **Reducing Phase**: Pairs are grouped by word (key). The reducer aggregates values to get total occurrences.

### Implementation Steps

#### 1. Create Package Structure
```bash
# Package: edu.ensias.hadoop.mapreducelab
# Location: src/main/java/edu/ensias/hadoop/mapreducelab/
```

#### 2. TokenizerMapper Class
Splits text into words and emits `(word, 1)` pairs.

```java
package edu.ensias.hadoop.mapreducelab;

import java.io.IOException;
import java.util.StringTokenizer;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

public class TokenizerMapper extends Mapper<Object, Text, Text, IntWritable> {
    private final static IntWritable one = new IntWritable(1);
    private Text word = new Text();

    public void map(Object key, Text value, Context context) 
            throws IOException, InterruptedException {
        StringTokenizer itr = new StringTokenizer(value.toString());
        while (itr.hasMoreTokens()) {
            word.set(itr.nextToken());
            context.write(word, one);
        }
    }
}
```

#### 3. IntSumReducer Class
Aggregates word counts by summing values for each key.

```java
package edu.ensias.hadoop.mapreducelab;

import java.io.IOException;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.Reducer;

public class IntSumReducer extends Reducer<Text, IntWritable, Text, IntWritable> {
    private IntWritable result = new IntWritable();
    
    public void reduce(Text key, Iterable<IntWritable> values, Context context) 
            throws IOException, InterruptedException {
        int sum = 0;
        for (IntWritable val : values) {
            sum += val.get();
        }
        result.set(sum);
        context.write(key, result);
    }
}
```

#### 4. WordCount Main Class
Configures and launches the MapReduce job.

```java
package edu.ensias.hadoop.mapreducelab;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class WordCount {
    public static void main(String[] args) throws Exception {
        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "word count");
        
        job.setJarByClass(WordCount.class);
        job.setMapperClass(TokenizerMapper.class);
        job.setCombinerClass(IntSumReducer.class);
        job.setReducerClass(IntSumReducer.class);
        
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);
        
        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));
        
        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
```

### Building the JAR

#### Maven Configuration (pom.xml)
```xml
<properties>
    <maven.compiler.source>1.8</maven.compiler.source>
    <maven.compiler.target>1.8</maven.compiler.target>
</properties>

<dependencies>
    <dependency>
        <groupId>org.apache.hadoop</groupId>
        <artifactId>hadoop-hdfs</artifactId>
        <version>3.2.0</version>
    </dependency>
    <dependency>
        <groupId>org.apache.hadoop</groupId>
        <artifactId>hadoop-common</artifactId>
        <version>3.2.0</version>
    </dependency>
    <dependency>
        <groupId>org.apache.hadoop</groupId>
        <artifactId>hadoop-mapreduce-client-core</artifactId>
        <version>3.2.0</version>
    </dependency>
</dependencies>

<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-jar-plugin</artifactId>
            <version>3.2.2</version>
            <configuration>
                <archive>
                    <manifest>
                        <mainClass>edu.ensias.hadoop.mapreducelab.WordCount</mainClass>
                    </manifest>
                </archive>
                <finalName>WordCount</finalName>
            </configuration>
        </plugin>
    </plugins>
</build>
```

#### Build Commands
```bash
# Navigate to project directory
cd "C:\Users\mouad\OneDrive - um5.ac.ma\Desktop\Lab Big data 0\LAB MAP_REDUCE\demo"

# Build the project
mvn clean package

# Copy JAR to shared volume
copy target\WordCount.jar "C:\Users\mouad\OneDrive - um5.ac.ma\Documents\hadoop_project\"
```

### Running the MapReduce Job

#### Prepare Input Data
```bash
# Inside hadoop-master container
# Create sample text file
echo "hello world hello hadoop mapreduce wordcount example hello world" > /shared_volume/test.txt

# Create input directory in HDFS
hdfs dfs -mkdir -p /input

# Upload text file to HDFS
hdfs dfs -put /shared_volume/test.txt /input/textfile.txt

# Verify file exists
hdfs dfs -ls /input/
hdfs dfs -cat /input/textfile.txt
```

#### Execute MapReduce Job
```bash
# Make sure HDFS is not in safe mode
hdfs dfsadmin -safemode leave

# Delete output directory if it exists (MapReduce requires output directory to not exist)
hdfs dfs -rm -r /output

# Run the WordCount job
# Syntax: hadoop jar <jar-file> <input-path> <output-path>
hadoop jar /shared_volume/WordCount.jar /input/textfile.txt /output
```
<img width="1304" height="340" alt="image" src="https://github.com/user-attachments/assets/21a324b6-6ddd-44c1-aea3-e43eed9a224f" />

**Important**: When the JAR has a manifest with Main-Class, you don't need to specify the class name in the command.

#### View Results
```bash
# List output files
hdfs dfs -ls /output/

# View word count results
hdfs dfs -cat /output/part-r-00000

# Download results to local
hdfs dfs -get /output/part-r-00000 /shared_volume/wordcount_results.txt
```

### Expected Output
```
example	1
hadoop	1
hello	3
mapreduce	1
world	2
wordcount	1
```

### Job Execution Summary
- **Map tasks**: 1
- **Reduce tasks**: 1
- **Input records**: 1
- **Output records**: 6 (unique words)
- **Combiner**: Used to optimize shuffle phase

### Common Issues & Solutions

#### 1. Safe Mode Error
```
Cannot create directory. Name node is in safe mode.
```
**Solution**: Wait 15-20 seconds or run:
```bash
hdfs dfsadmin -safemode leave
```

#### 2. Output Directory Already Exists
```
Output directory already exists
```
**Solution**: Delete the output directory before running:
```bash
hdfs dfs -rm -r /output
```

#### 3. Input Path Does Not Exist
```
Input path does not exist
```
**Solution**: Verify input file exists in HDFS:
```bash
hdfs dfs -ls /input/
hdfs dfs -put /shared_volume/yourfile.txt /input/textfile.txt
```

#### 4. Connection Refused Error
```
Call From hadoop-master to hadoop-master:9000 failed on connection exception
```
**Solution**: Start HDFS services:
```bash
start-dfs.sh
start-yarn.sh
jps  # Verify NameNode and DataNode are running
```

### Monitoring

#### Web Interfaces
- **Job Tracker**: http://localhost:8088
  - View running/completed jobs
  - Check job progress and statistics
  - View logs and counters

- **NameNode UI**: http://localhost:9870
  - Browse HDFS filesystem
  - Check DataNode status
  - View file blocks and replication

#### Command Line Monitoring
```bash
# Check running jobs
yarn application -list

# View job history
mapred job -list all

# Check HDFS report
hdfs dfsadmin -report

# View specific job details
yarn logs -applicationId <application_id>
```

## Next Steps

- Implement advanced MapReduce patterns (joins, sorting)
- Add more data processing applications
- Configure Spark for big data analytics
- Integrate with Hive for SQL-like queries
