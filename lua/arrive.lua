--[[
	Here are functions which control cars arrivals.`
--]]

function flood()
	if (GLOB_TIME % 10 == 1) then
		for n=1, Track.number do
			local car = car or Car.create()
			if canArrive(n, car) then
				launchCar(n, car)
				car = nil
			end
		end
	end
end

function random()
	local car = car or Car.create()
	if not random_i then
		random_i = math.random(Track.number)
	end
	
	if canArrive(random_i, car) then 
		launchCar(random_i, car)
		random_i = nil
		car = nil
	end
end
