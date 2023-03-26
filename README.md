Original grammar borrowed from: https://github.com/jr-robotics/RobSharper.Ros.MessageParser

Convered to Bison/Flex from Antlr due to runtime footprint of Antlr in a microcontroller. 

This is  a module that will support runtime IDL compilation along with the ability to marshal data between the MicroROS layer and MicroPython.

My approach is to create a ROS .msg parser that will compile the ROS message definition into a condensed list of data movement instructions supportingthe native data types and provide methods like toC and toPython.  

As an example, take the cmd_vel mesg which consists of 2 Vector3's which in them selves at a type of floats.  The parser would build a command list such as(ptr)->CopyFloat, X3, labels (Linear( x,y,z))(ptr)->CopyFloat, X2, labels (Angular(x,y,z))

So when I receive a cmd_vel message, I can lookup the cmd_vel.msg in the NVS compile and cache the instruction list, the execute the list to move data to the python space where you can reference the data mp_obj_ptr as  data.linear.x 


I like Antlr but when looking at it for the prospective of a limited memory micro-controller Antlr's runtime library is huge. I haven't worked with Bison/Flex in many years but I like it in that it sacrifices speed for memory efficiency and since I will either pre-compile or cache the instruction list, I am not too concerned with parser speed.  
