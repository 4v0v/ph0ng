Rectangle = Entity:extend('Rectangle')

function Rectangle:new(x, y, w, h, opts)
	Rectangle.super.new(@, { x = x, y = y, z = get(opts, 'z'), outside_camera = get(opts, 'outside_camera')})
	
	@.w        = w
	@.h        = h
	@.rx       = get(opts, 'rx', 0) -- rounded corners
	@.ry       = get(opts, 'ry', 0) -- rounded corners
	@.lw       = get(opts, 'lw', 1) -- line width
	@.segments = get(opts, 'segments', nil) -- nb of segments for rounded corners
	@.centered = get(opts, 'centered', false)
	@.mode     = get(opts, 'mode', 'line')
	@.color    = get(opts, 'color', {1, 1, 1, 1})
end

function Rectangle:update(dt)
	Rectangle.super.update(@, dt)
end

function Rectangle:draw()
	lg.setColor(@.color)
	lg.setLineWidth(@.lw)
	if @.centered then 
		lg.rectangle(@.mode, @.pos.x - @.w/2, @.pos.y - @.h/2, @.w , @.h , @.rx, @.ry, @.segments)
	else
		lg.rectangle(@.mode, @.pos.x, @.pos.y, @.w, @.h, @.rx, @.ry, @.segments)
	end
	lg.setColor(1, 1, 1, 1)
	lg.setLineWidth(1)
end

function Rectangle:center()
	if @.centered then 
		return {self.pos.x, self.pos.y}
	else
		return rect_center({@.pos.x, @.pos.y, @.w, @.h})
	end
end

function Rectangle:collide_with_point(p)
	return rect_point_collision({@.pos.x, @.pos.y, @.w, @.h}, p)
end

function Rectangle:collide_with_circ(c)
	return rect_circ_collision({@.pos.x, @.pos.y, @.w, @.h}, c)
end

function Rectangle:collide_with_rect(r)
	return rect_rect_collision({@.pos.x, @.pos.y, @.w, @.h}, r)
end