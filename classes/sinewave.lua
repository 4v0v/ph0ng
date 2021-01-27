Sinewave = Class:extend('Sinewave')

function Sinewave:new(value, speed, amplitude)
	@.initial = value     or 0
	@.speed   = speed     or 1
	@.amp     = amplitude or 1
	@.time    = 0
	@.sine    = 0
	@.playing = true
end

function Sinewave:update(dt)
	if !@.playing then return end
	@.time += dt
	@.sin = @.amp * math.sin(@.time * @.speed)
	@.cos = @.amp * math.cos(@.time * @.speed)
end

function Sinewave:stop()
	@.playing = false
end

function Sinewave:play()
	@.playing = true
end

function Sinewave:get() 
	return @.initial + @.sin
end

function Sinewave:get_sin() 
	return @.initial + @.sin
end

function Sinewave:get_cos() 
	return @.initial + @.cos
end

function Sinewave:set(value)
	@.initial = value
end
