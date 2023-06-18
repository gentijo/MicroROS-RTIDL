<p style="background-color:#D9D919; color:black; font-size:150%;"><i>
Note: This Repo is to evaluate a POC for managing ROS msg's in a Python environment, it has not been optimized, it not code complete, nor is it pretty and is basically a hack to provide a real world example.

The Data Transfer agent or build-in common base Classes, are not part of this project so that the focus can stay on the compilation process and it's outputs
</i></p>

<br/><br/>

# Problem Statement
While developing the Micropython integration for MicroROS, it became apparent that there was a need to provide native python interfaces for the .msg files in MicroROS as it would be too cumbersome to write C code that would produce a C/C++ class that would interface ROS Types to Micropython. This would require C Coding and a recompile of the ROS image which may beyond the scope of the Python programmer and may also cause problematic drift between images loaded on  various devices where a embedded type may be missing requiring that all devices be upgraded to the latest image.

</br>

# Propose Solution
Create a small footprint Parser that will be able to build a memory based Data Transfer Instruction structure that provides information to a generic data marshaling engine can use to marshal ROS msg data to/from Python. This will be coupled with a template based python class generator to allow the Micropython code to selectively use all existing .msg files or create new msg types at runtime without the need for a recompile of the device image.

As an example, take the Twist msg which consists of 2 Vector3's which in themselves are a collection of 3 floats.  

The parser would build a Data Transfer instruction list, where the DTEngine will allocate memory for the full msg size, then copy data to/from by using a void pointer that will copy data to structure for the native types. Continuing with the Twist example, Twist defined two types of Vector3, which each consist of 3 Float64, a native type. 
**Example DTI definition for Twist**

* 1.0 Vector3 Linear
  * 1.1 Float64 x
  * 1.2 Float64 y
  * 1.3 Float64 z
    
</br>

* 2.0 Vector3 Angular
  * 2.1 Float64 x
  * 2.2 Float64 y
  * 2.3 Float64 z

Would result in a memory allocation of Float64 x 6, then a routine that will walk thru the primitive types and perform

ptr = copyToRos(ptr, Float64)
where the return value will be incremented by sizeof(float64) on each call. 

Data flow from ROS to Python will be defined when registering the listener for a message. 
the Python code 

 > **registerMsgListener("cmd_vel", Twist, pythonCallBack)** 
 
 would instruct the Data Transfer Engine to create a Twist python object and populate the named values using the DTI definiton on recipt of the message. 

**Here is an overview of the data flow to produce the DTI definitions and artifacts**

![](images/Overview.png)

# How this would work on the device. 

First upload .msg files along with the dependant .msg files to the device storage
In python there will be a MicroROS.py that is builtin to the device that support MicroRos operations
In boot.py, you would import ROSType then add statements for all the ROSTypes you want to use on your device
</br></br>
> **from MicroROS import ROSType**
> 
> **ROSType.registerType(TypeName, msgDir,  pyDir)**
<br/>
This would create and register the DTI structure in a memory based map
It would also create the .py artifacts in the pyDir
</br></br>
Then in your code you send a message with
<br/>
<br/>

> **from Twist import Twist**
> 
> **from MicroROS import ROSMessages**
> 
> **twist:Twist**
> 
> **twist.linear.x = 0**
> 
> **twist.linear.y = 0**
> 
> **twist.linear.z = 0**
> 
> **twist.angular.x = 0**
> 
> **twist.angular.x = 0**
> 
> **twist.angular.x = 0**
>
> **ROSMessages.publishMsg("/cmd_vel", twist)**


# Running the example Code as a Linux command line app.
In the project root dir execute

* buildNode.sh
* startNode.sh
  
to create the docker image

then connect to the running docker container using the temrminal app

**Inside the terminal app execute:**

* cd /opt/rosbots-rtidl/test
* sh run.sh

**Inspect run.sh to see the parameters to try different types**

**If you are on a Linux host, you can also just cd to the test directory and run the same command**

**Make sure to remove the contents of the Output dir to see new files build.**

**You can use any other ROS type although the current parser does not support constant or array types.**



# Example Code.
* [The test folder includes an executable that will run in a Linux env or Docker container defined here](test)

* [The output folder contains the examples of the output produced for the Python artifacts and a DTI definition](test/output/)

* [Example of Python Artifact](test/output/Twist.py)
* [Template to produce Python Artifact based on a lighrwright version of Jinja](test/pythonTypeTemplate.j2)

* [Example of a DTI file rendered as a CSV file](test/output/Twist.dti)

* [Source code](src)
  
* Grammar files
  * [Lexer](src/lexer.l)
  * [Parser](src/parser.y)

# Alternatives to this approach
This POC code could be ported back to Python using ANTLR and added as an extension to [RShell](https://github.com/dhylands/rshell) to parse, produce output files and directly load the final output to the device. This could be further extended to be used as an extension to [Visual Code Studio](https://code.visualstudio.com/docs/languages/python) or [Thonny](https://github.com/thonny/thonny/wiki/Plugins) 

</br>

# **Notes:**
* [Original ANTLR grammar borrowed from:</br> 
github.com/jr-robotics/RobSharper.Ros.MessageParser](https://github.com/jr-robotics/RobSharper.Ros.MessageParser)

* Converted to Bison/Flex from Antlr due to the size of the runtime footprint of Antlr in a microcontroller. 


