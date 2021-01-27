Scene = Class:extend('Scene')

function Scene:new()
	@.id     = ''
	@.timer  = Timer()
	@.camera = Camera()
	@._queue = {}
	@._ents  = {}
	@._ents_by_id   = {}
	@._ents_by_type = {}
end

function Scene:update(dt)
	@.timer:update(dt)
	@.camera:update(dt)

	-- update entitites
	ifor @._ents do 
		it:update(dt) 
	end

	-- delete dead entities
	rfor @._ents do 
		if it.dead then
			for type in it.types do @._ents_by_type[type][it.id] = nil end
			@._ents_by_id[it.id] = nil
			table.remove(@._ents, key)
		end
	end

	-- push entities from queue
	for queued_ent in @._queue do
		ifor type in queued_ent.types do 
			@._ents_by_type[type] = get(@, {'_ents_by_type', type}, {}) -- create type table if not already existing
			@._ents_by_type[type][queued_ent.id] = queued_ent
		end
		@._ents_by_id[queued_ent.id] = queued_ent
		insert(@._ents, queued_ent)
	end
	@._queue = {}
end

function Scene:draw()
	table.sort(@._ents, fn(a, b) if a.z == b.z then return a.id < b.id else return a.z < b.z end end)

	local _r, _g, _b, _a = lg.getColor()
	@.camera:draw(function()
		@:draw_inside_camera_bg()
		lg.setColor(_r, _g, _b, _a)

		for @._ents do 
			if it.draw && !it.outside_camera then 
				it:draw()
				lg.setColor(_r, _g, _b, _a)
			end
		end

		@:draw_inside_camera_fg()
		lg.setColor(_r, _g, _b, _a)
	end)

	@:draw_outside_camera_bg()
	lg.setColor(_r, _g, _b, _a)

	for @._ents do 
		if it.draw && it.outside_camera then
			it:draw()
			lg.setColor(_r, _g, _b, _a)
		end
	end

	@:draw_outside_camera_fg()
	lg.setColor(_r, _g, _b, _a)
end

function Scene:add(a, b, c)
	local id, types, entity

	if   type(a) == 'string' and type(b) == 'table' and type(c) == 'nil' then
		id, types, entity = a, {}, b
	elif type(a) == 'string' and type(b) == 'table' and type(c) == 'table' then
		id, types, entity = a, b, c
	elif type(a) == 'string' and type(b) == 'string' and type(c) == 'table' then 
		id, types, entity = a, {b}, c
	elif type(a) == 'table' and type(b) == 'table' and type(c) == 'nil' then
		id, types, entity = uid(), a, b
	elif type(a) == 'table' and type(b) == 'nil' and type(c) == 'nil' then
		id, types, entity = uid(), {}, a
	end

	insert(types, entity:class())
	for entity.types do insert(types, it) end

	entity.types = types  
	entity.id    = id

	-- TODO: what to do wehn already existing id ?
	if @._ents_by_id[id] then
		print('id already exist') 
	else
		entity.scene  = @
		@._queue[id] = entity
	end 

	return entity
end

function Scene:kill(id) 
	local entity = @:get(id)
	if entity then entity:kill() end
end

function Scene:get(id) 
	local entity = @._ents_by_id[id]
	if !entity or entity.dead then return false end
	return entity
end

function Scene:get_all()
	return @._ents
end

function Scene:get_by_type(...)
	local entities = {}
	local types    = {...}
	local filtered = {} -- filter duplicate entities using id

	for type in types do
		if @._ents_by_type[type] then
			for @._ents_by_type[type] do
				if !it.dead then filtered[it.id] = it end
			end
		end
	end

	for filtered do insert(entities, it) end

	return entities
end

function Scene:count(...)
	return #@:get_by_type(...)
end

function Scene:draw_inside_camera_bg()
end

function Scene:draw_outside_camera_bg()
end

function Scene:draw_inside_camera_fg()
end

function Scene:draw_outside_camera_fg()
end

function Scene:enter() 
end

function Scene:exit() 
end

function Scene:after(...)
	@.timer:after(...)
end

function Scene:after_true(...)
	@.timer:after_true(...)
end

function Scene:every_true(...)
	@.timer:every_true(...)
end

function Scene:during_true(...)
	@.timer:during_true(...)
end

function Scene:tween(...)
	@.timer:tween(...)
end

function Scene:every(...)
	@.timer:every(...)
end

function Scene:every_immediate(...)
	@.timer:every_immediate(...)
end

function Scene:during(...)
	@.timer:during(...)
end

function Scene:once(...)
	@.timer:once(...)
end

function Scene:always(...)
	@.timer:always(...)
end

function Scene:zoom(...)
	@.camera:zoom(...)
end

function Scene:shake(...)
	@.camera:shake(...)
end

function Scene:follow(...)
	@.camera:follow(...)
end

function Scene:get_mouse_position_inside_camera() 
	local x, y = @.camera:get_mouse_position()
	return {x, y}
end

function Scene:get_mouse_position_outside_camera()
	local x, y = lm.getPosition()
	return {x, y} 
end