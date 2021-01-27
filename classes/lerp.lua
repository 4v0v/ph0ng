Lerp = Class:extend('Lerp')
Lerp.delta = .01

function Lerp:new(value, speed)
	@.current = value
	@.target  = value
	@.speed   = speed or 20
end

function Lerp:update(dt)
	if @.current == @.target then return end
	@.current += (@.target - @.current) * @.speed * dt

	if @.target - Lerp.delta < @.current && @.target + Lerp.delta > @.current then 
		@.current = @.target
	end
end

function Lerp:lerp(target)
	@.target = target
end

function Lerp:get() 
	return @.current
end

function Lerp:set(value)
	@.current = value
	@.target  = value
end
