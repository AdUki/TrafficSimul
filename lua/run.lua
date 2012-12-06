#!/usr/bin/lua
--
-- Run this file for simluation only.
-- If you want visualisation too, run 
-- compile program with make and then
-- run transport file.
--

dofile("init.lua")

SIMUL_TIME = arg[3] or 8000

print "Begining simulation"

while (GLOB_TIME <= SIMUL_TIME) do
	carsArrive()
	carsMove()
	carsReact()
	GLOB_TIME = GLOB_TIME + 1
	AVG_CARS_ON_ROAD = AVG_CARS_ON_ROAD + CARS_ON_ROAD
	
	if GLOB_TIME % math.floor(SIMUL_TIME / 13) == 0 then
		print (math.floor(100*(GLOB_TIME/SIMUL_TIME)) .."% complete")
	end
end

if CARS_PASSED == 0 then CARS_PASSED = 1 end

print ("STATISTICS:")
print ("==========================================")
print ("Track lenght " .. Track.finish - Track.begin)
print ("Number of tracks " .. Track.number)
print ("Time elapsed " .. GLOB_TIME)
print ("Cars passed " .. CARS_PASSED)
print ("Cars on road " .. CARS_ON_ROAD) 
print ("Most cars on road " .. MOST_CARS_ON_ROAD)
print ("Average number of cars " .. AVG_CARS_ON_ROAD/GLOB_TIME)
print ("Average car travel time " .. AVG_CAR_TIME/CARS_PASSED)
print ("Average car utilization " .. (AVG_CAR_UTIL/CARS_PASSED)*100 .. "%")
print ("Shortest car travel time " .. BEST_CAR_TIME)
print ("Longest car travel time " .. WORST_CAR_TIME)
print ("==========================================")
