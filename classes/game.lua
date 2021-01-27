Game = Class:extend('Game')

function Game:new()
	@.current  = ''
	@.scenes    = {}
	@.timer    = Timer()
	@.bg_color = {r = 0, g = 0, b = 0, a = 0}
end

function Game:update(dt)
	@.timer:update(dt)
	if @.current == '' then return end
	@.scenes[@.current]:update(dt)
end

function Game:draw()
	if @.current == '' then return end
	@.scenes[@.current]:draw()

	local _r, _g, _b, _a = lg.getColor()
	lg.setColor(@.bg_color.r, @.bg_color.g, @.bg_color.b, @.bg_color.a)
	lg.rectangle("fill", 0, 0, lg.getWidth(), lg.getHeight())
	lg.setColor(_r, _g, _b, _a)
end

function Game:handle(name, a, b, c, d, e, f)
	if @.current == '' || !@.scenes[@.current][name] then return end
	@.scenes[@.current][name](@.scenes[@.current], a, b, c, d, e, f)
end

function Game:add_scene(id, scene)
	scene.id     = id
	@.scenes[id] = scene
end

function Game:change_scene(name, ...)
	local args = {...}
	local previous = @.current
	if @.current != '' then @.scenes[@.current]:exit() end
	@.current = name
	@.scenes[@.current]:enter(previous, args)
end

function Game:change_scene_with_transition(name, ...)
	local args = {...}
	@.timer:tween(.4, @.bg_color, {a = 1}, 'in-cubic', 'transition_fade_in', fn() 
		local previous = @.current
		if @.current != '' then @.scenes[@.current]:exit() end
		@.current = name
		@.scenes[@.current]:enter(previous, args)
		@.timer:tween(.4, @.bg_color, {a = 0}, 'out-cubic', 'transition_fade_out')
	end)
end
