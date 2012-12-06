-- Table with all cars
cars = {}

-- To have nice random numbers
math.randomseed(os.time())

------------------
--				--
--	CAR CLASS	--
--				--
------------------
Car.__index = Car

-- constructor for car
function Car.create(maxspeed, thrust, lenght, manuver)
	local newcar = {}
	setmetatable(newcar, Car)

	newcar.util = 0
	newcar.speed = Car.minspeed
	newcar.maxspeed = maxspeed or 
		Car.minspeed + math.random()*(Car.maxspeed - Car.minspeed)
	newcar.thrust = thrust or Car.breakes
	newcar.react = defaultBehaviour
	
	newcar.track = 0
	newcar.position = Track.begin - Car.lenght

	
	return newcar
end

function Car:setSpeed( newspeed )
	
	if newspeed > self.speed then
		
		self.speed = self.speed + self.thrust
		if self.speed > self.maxspeed then self.speed = self.maxspeed end
		if self.speed > newspeed then self.speed = newspeed end
		
	else
		
		self.speed = self.speed - Car.breakes
		if self.speed < newspeed then self.speed = newspeed end
		if self.speed < 0 then self.speed = 0 end
	
	end
		
end

function Car:isSafe( car , distance )
	distance = distance or Car.safe
	if not car or
		math.abs(car.position - self.position - Car.lenght) >
		(math.pow(self.speed,2) - math.pow(car.speed,2))/(2*Car.breakes) + distance
	then return true
	else return false
	end
end

function Car:setTrack( newtrack )

	if newtrack > self.track then
	
		self.track = self.track + Car.manuver
		if self.track > newtrack then self.track = newtrack end
		if self.track > Track.number then self.track = Track.number end
		
	elseif newtrack < self.track then
	
		self.track = self.track - Car.manuver
		if self.track < newtrack then self.track = newtrack end
		if self.track < 1 then self.track = 1 end
		
	end
	
end

-- never use protected argument! will lead to infinite recursion!
function getNextCar(i, track, protected)
	
	-- fix if two or more cars ano on same position but in other tracks
	if not protected then local n = getPrevCar(i, track, true) end
	if n and cars[n].position == cars[i].position then return cars[n] end
	
	-- find next car
	local n = i + 1
	while
		n <= #cars and 
		not sameTrack(track, cars[n].track)
	do n = n + 1 end
	
	if n > #cars then return nil else return cars[n] end
end

-- never use protected argument! will lead to infinite recursion!
function getPrevCar(i, track, protected)
	
	-- fix if two or more cars ano on same position but in other tracks
	if not protected then local n = getNextCar(i, track, true) end
	if n and cars[n].position == cars[i].position then return cars[n] end
	
	-- find previous car
	local n = i - 1
	while
		n > 0 and 
		not sameTrack(track, cars[n].track)
	do n = n - 1 end
	
	if n == 0 then return nil else return cars[n] end
end

-- return true if car can safely move to other track
-- if not it returns false with both cars which would
-- make this movement unsafe(first previous car then
-- next car)
function canMoveTo(i, car, track)
	
	if track < 1 then return false
	elseif track > Track.number then return false end
	
	local nextc = getNextCar(i, track)
	local prevc = getPrevCar(i, track)
	
	local crash =
		not isSpaceFree(prevc, cars[i].position) or not
		isSpaceFree(nextc, cars[i].position)
	
	if crash then return false end
	
	-- make sure everyone is safe :)
	local safeBack = not nextc or car:isSafe(nextc)
	local safeFront = not prevc or prevc:isSafe(car)
	
	if safeBack and safeFront then return true
	else return false, prevc, nextc end
	
end


function sameTrack(track1, track2)
	return
		math.floor(track1) == math.floor(track2) or
		math.floor(track1) == math.ceil(track2) or
		math.ceil(track1) == math.floor(track2) or
		math.ceil(track1) == math.ceil(track2)
end

function isCollision(car1, car2)
	
	if sameTrack(car1.track, car2.track)
	then return math.abs(car1.position - car2.position) <= Car.lenght
	else return false end
	
end

function isSpaceFree(car, position)
	return not car or math.abs(car.position - position) > Car.lenght
end

--------------------------
--						--
--	END OF CAR CLASS	--
--						--
--------------------------

-- Main function for simulation
-- Bind this function to C code
function simulate()
	carsArrive()
	carsMove()
	carsDraw()
	carsReact()
	GLOB_TIME = GLOB_TIME + 1
end

function canArrive(track, car)
	
	local ncar = getNextCar(0, track)
	return not ncar or (
		isSpaceFree(ncar, Car.lenght) and
		isSpaceFree(ncar, Car.lenght*ARRIVE_COEFICIENT) and
		car:isSafe(ncar))
		
end

-- Function that will call other file for user script that will control
-- arrival of cars and their behavior
function carsArrive()
	defaultArrive()
end

-- Function that will call C code which will send positions of cars
-- to the application so that they can be drawn for user output
function carsDraw()
	for i, car in ipairs(cars) do
		sendCar(car.track, Car.lenght, car.position, 
			car.maxspeed, car.speed)
	end	
end

-- Call this function to move all cars
-- This function leaves table cars sorted according to their positions
function carsMove()	
	for i, car in ipairs(cars) do
		-- update car position according to speed
		car.position = car.position + car.speed
		car.util = car.util + car.speed/car.maxspeed
		if	-- car arrived to finish
			car.maxspeed < 0 and 
			car.position <= Track.begin - Car.lenght or 
			car.position >= Track.finish
		then
			-- statistics
			CARS_PASSED = CARS_PASSED + 1
			CARS_ON_ROAD = CARS_ON_ROAD - 1
			AVG_CAR_TIME = AVG_CAR_TIME + GLOB_TIME - cars[i].time
--			AVG_CAR_TIME = AVG_CAR_TIME/2
			if WORST_CAR_TIME < GLOB_TIME - cars[i].time
			then WORST_CAR_TIME = GLOB_TIME - cars[i].time end
			if BEST_CAR_TIME == 0 or BEST_CAR_TIME > GLOB_TIME - cars[i].time
			then BEST_CAR_TIME = GLOB_TIME - cars[i].time end
			AVG_CAR_UTIL = AVG_CAR_UTIL + cars[i].util/(GLOB_TIME - cars[i].time)
--			AVG_CAR_UTIL = AVG_CAR_UTIL/2
			
			-- delete car
			if i == #cars then
				cars[i] = nil
			else
				cars[i] = cars[#cars]
				cars[#cars] = nil
			end
		end
	end
	-- sort table according to positions
	table.sort(cars, function(a, b) return a.position < b.position end)
end

-- Call this function for changing riders reaction to traffic
function carsReact()
	for i, car in ipairs(cars) do
		car.react(i, car)
	end
end

-- Function for adding new car to the traffic
-- All arguments are proprietary(default values are 1,1,10)
function launchCar(track, newcar, speed)

	-- check car and its atributes
	newcar = newcar or Car.create()
	newcar.track = track or newcar.track
	newcar.speed = speed or newcar.speed
	
	-- statistics
	newcar.time = GLOB_TIME
	CARS_ON_ROAD = CARS_ON_ROAD + 1
	if MOST_CARS_ON_ROAD < CARS_ON_ROAD
	then MOST_CARS_ON_ROAD = CARS_ON_ROAD end
	
	if -- check for direction
		newcar.maxspeed > 0
	then -- put car to the beginning of the Track
		newcar.position = Track.begin - Car.lenght
		for i = #cars, 1, -1 do cars[i+1] = cars[i] end
		cars[1] = newcar
	else -- put car in the end of the Track
		newcar.position = Track.finish
		cars[#cars+1] = newcar
	end
end

