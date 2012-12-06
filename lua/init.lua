--[[

	TRAFFIC FLOW SIMULATION

	Author: Simon Mikuda
	Program created on 26 nov. 2011
	for subject Modeling and Simulation
	on STU FIIT in Bratislava

--]]

--[[

	TODO--------------------------------------------------------TODO
	 
	> Fix cars arrivals, somtimes they arrive to quickly when 
	car lenght is low. Reimplement function canArrive(maybe
	imbue this function to launchCar).
	
	> Fix that cars somtimes crashes into each other(mystic bug :D)
	
	> Reimplement function that require arguments i as index and car
	that they would be class Car methods.
	
	> add to setspeed that it can't be called more than once within
	one simulation step
	
	TODO--------------------------------------------------------TODO

--]]

-- Tracks setup
Track = {
	begin = 100,
	finish = 30100,
	number = 4
}

-- Car setup

Car = {
	width = 16,
	lenght = 45, -- less then 42 causes trouble
	breakes = 0.2,
	manuver = 0.1,
	safe = 25,
	maxspeed = 20,
	minspeed = 5
}


-- Screeen setup
Screen = {
	width = 1676,
	height = 500
}

-- Global variables
GLOB_TIME = 0
CARS_PASSED = 0
CARS_ON_ROAD = 0
AVG_CARS_ON_ROAD = 0
AVG_CAR_TIME = 0
BEST_CAR_TIME = 0
WORST_CAR_TIME = 0
MOST_CARS_ON_ROAD = 0
ARRIVE_COEFICIENT = 1.3
AVG_CAR_UTIL = 0

-- Launch user script with arrive() function
defaultBehaviour = (arg and _G[arg[1]]) or angry
defaultArrive = (arg and _G[arg[2]]) or random
