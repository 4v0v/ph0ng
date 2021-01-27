Tween = Class:extend('Tween')

function Tween:new(value, method, ...)
	@.current  = value
	@.target   = value
	@.method   = method or 'linear'
	@.args     = {...}
	@.duration = 0
	@.elapsed  = 0
	@.delta    = 0
end

function Tween:update(dt)
	if @.elapsed == @.duration then return end

	@.elapsed += dt

	local progress = @.elapsed / @.duration

	if progress > 1 then 
		@.current = @.target
		@.elapsed = @.duration
	else
		@.current = @.target - (1 - @:construct(@.method, progress, @.args) ) * @.delta
	end
end

function Tween:tween(target, time, method, ...)
	local args = {...}
	if #args == 0 then args = @.args end

	@.elapsed  = 0
	@.duration = time 
	@.target   = target
	@.delta    = target - @.current
	@.method   = method or @.method
	@.args     = args
end

function Tween:get() 
	return @.current
end

function Tween:set(value)
	@.current  = value
	@.target   = value
	@.duration = 0
	@.elapsed  = 0
	@.delta    = 0
end

function Tween:construct(name, ...) -- construct tween function
	if     name:find('in%-out%-') then 
		return Tween.chain(Tween[name:sub(8, -1)], Tween.out(Tween[name:sub(8, -1)]))(...) 
	elseif name:find('in%-')      then 
		return Tween[name:sub(4, -1)](...)
	elseif name:find('out%-')     then
		return Tween.out(Tween[name:sub(5, -1)])(...) 
	else  
		return Tween[name](...) 
	end
end

function Tween.out(f) 
	return function(x, ...) return 1 - f(1-x, ...) end 
end

function Tween.chain(f1, f2) 
	return function(x, ...) return (x < 0.5 and f1(2*x, ...) or 1 + f2(2*x-1, ...))*0.5 end 
end

function Tween.linear(x)
	 return x 
end

function Tween.quad(x) 
	return x^2 
end

function Tween.cubic(x) 
	return x^3 
end

function Tween.quart(x) 
	return x^4 
end

function Tween.quint(x) 
	return x^5 
end

function Tween.sine(x) 
	return 1 - math.cos(x * math.pi/2 ) 
end

function Tween.expo(x) 
	return 2^(10 * (x - 1)) 
end

function Tween.circ(x) 
	return 1 - math.sqrt(1 - x^2) 
end

function Tween.back(x, args) -- bounciness
	local b = args[1] or 1.70158
	return x * x * ((b+1) * x - b) 
end

function Tween.bounce(x) 
	local a, b = 7.5625, 1/2.75
	return math.min(
		a * x^2, 
		a * (x - 1.5   * b) ^ 2 + .75,
		a * (x - 2.25  * b) ^ 2 + .9375, 
		a * (x - 2.625 * b) ^ 2 + .984375
	) 
end

function Tween.elastic(x, args) -- amp, period
	local a = args[1] or 1
	local p = args[2] or .3
	a = math.max(1, a) 
	return (-a * math.sin(2 * math.pi/p * (x-1) - math.asin(1/a))) * 2^(10 * (x-1)) 
end
