
From Vector3 import Vector3


class Twist:
   def __init__(self, linear:Vector3, angular:Vector3):
	self.linear:Vector3 = linear
	self.angular:Vector3 = angular


   #
   # Marshal data to ROS
   #
   def publishToROS(self, endPoint:str):
      pass


