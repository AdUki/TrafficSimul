--[[
	Here are behaviours for cars. All cars share same behaviour by default.
	You can change behaviur assignemnt in arrive functions.
--]]

--  simplest behaviour. Cars just follow each other in queue.
function stupid(i, car)
	
	-- basic beginning
	local ncar = getNextCar(i, car.track)
	if not ncar then car:setSpeed(car.maxspeed) return end
	
	-- stop from crashing to car ahead
	if car:isSafe(ncar) then car:setSpeed(car.maxspeed)
	else car:setSpeed(0) end
	
end

-- cars start to race.
function race(i, car)
	
	local ncar = getNextCar(i, car.track)
	
	if not ncar then car:setSpeed(car.maxspeed)
	elseif car:isSafe(ncar) then car:setSpeed(car.maxspeed)
	else
		car:setSpeed(0)
		
		if not car.racing then -- car want to race
			if canMoveTo(i, car, car.track - 1) then
				car.racing = car.track - 1
				car:setTrack(car.track - 1)
				return
			elseif canMoveTo(i, car, car.track + 1) then
				car.racing = car.track + 1
				car:setTrack(car.track + 1)
				return
			end
		end
	end
	
	if car.racing then -- continue with racing
		car:setTrack(car.racing)
		if car.track == car.racing then -- stop with race
			car.racing = nil
		end
	end
end

-- cars want to go to specific track(sweet track :D ) according to their maxspeed
function uniform(i, car)
	local ncar = getNextCar(i, car.track)
	
--	if not car.sweet then
		local newTrack = math.ceil((car.maxspeed - Car.minspeed)/
			((Car.maxspeed - Car.minspeed)/Track.number))
		if car.track == newTrack then car.sweet = true end	
--	end
	
	if ncar and not car:isSafe(ncar) then car:setSpeed(0) end
	
	if not ncar or car:isSafe(ncar) and car:isSafe(car.ahead) then 
		car:setSpeed(car.maxspeed)
	end
	
	if not car.sweet then
		if not car.racing then
		
			local safe, prevc, nextc
		
			if car.track > newTrack then
				safe, prevc, nextc = canMoveTo(i, car, car.track - 1)
				if safe then
					car.racing = car.track - 1
					car:setTrack(car.track - 1)
					return
				end
			elseif car.track < newTrack then
				safe, prevc, nextc = canMoveTo(i, car, car.track + 1)
				if safe then
					car.racing = car.track + 1
					car:setTrack(car.track + 1)
					return
				end
			end
			return
		else -- continue with racing
			car:setTrack(car.racing)
			if car.track == car.racing then -- stop with race
				car.racing = nil
			end
		end
	end
	

end

-- cars race each other. If car cant race, it gets angry and tells car in front it to move away.
function angry(i, car)

	local ncar = getNextCar(i, car.track)
	
	if not ncar then car:setSpeed(car.maxspeed)
	elseif car:isSafe(ncar) then car:setSpeed(car.maxspeed)
	else
		car:setSpeed(0)
		
		if not car.racing then -- car want to race
			if canMoveTo(i, car, car.track - 1) then
				car.racing = car.track - 1
				car:setTrack(car.track - 1)
				return
			elseif canMoveTo(i, car, car.track + 1) then
				car.racing = car.track + 1
				car:setTrack(car.track + 1)
				return
			else -- car is angry, it cannot race
				ncar.angry = not ncar.racing or true
			end
		end
	end

	if car.angry and not car.racing
	then -- car is in the way of other cars
		if canMoveTo(i, car, car.track - 1) then
			car.racing = car.track - 1
			car:setTrack(car.track - 1)
			return
		elseif canMoveTo(i, car, car.track + 1) then
			car.racing = car.track + 1
			car:setTrack(car.track + 1)
			return
		else car.angry = nil end
		
	elseif car.racing then -- continue with racing
		car:setTrack(car.racing)
		if car.track == car.racing then -- stop with race
			car.racing = nil
			car.angry = not car.angry and nil
		end
	end

end
