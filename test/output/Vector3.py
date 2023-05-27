
From float64 import float64


class Vector3:
   def __init__(self, x:float64, y:float64, z:float64):
	self.x:float64 = x
	self.y:float64 = y
	self.z:float64 = z


   #
   # Marshal data to ROS
   #
   def publishToROS(self, endPoint:str):
      pass


