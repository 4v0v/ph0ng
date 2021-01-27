local function lerp(a, b, x, dt) 
	return a + (b - a) * (1.0 - math.exp(-x * dt)) 
end

local function random(x) 
	return love.math.noise(love.math.random()) - 0.5 
end

local Camera = {}

function Camera:new(x, y, w, h, s)
	local obj = {}
		obj.x = x or 0
		obj.y = y or 0
		obj.w = w or love.graphics.getWidth()
		obj.h = h or love.graphics.getHeight()
		obj.cam = { x = 0, y = 0, s = s or 1, target_x = 0, target_y = 0, target_s = s or 1, sv = 10, ssv = 10 }
		obj.shk = { tick = 1/60, timer = 0, s = 0, xrs = 0, yrs = 0}
	return setmetatable(obj, {__index = Camera})
end

function Camera:update(dt)
	self.cam.x = lerp(self.cam.x, self.cam.target_x, self.cam.sv, dt)
	self.cam.y = lerp(self.cam.y, self.cam.target_y, self.cam.sv, dt)
	self.cam.s = lerp(self.cam.s, self.cam.target_s, self.cam.ssv, dt)

	self.shk.timer = self.shk.timer + dt
	if self.shk.timer > self.shk.tick then 
		if self.shk.s ~= 0 then self.shk.xrs, self.shk.yrs = random()*self.shk.s, random()*self.shk.s else self.shk.xrs, self.shk.yrs = 0, 0 end
		self.shk.timer = self.shk.timer - self.shk.tick
	end
	if math.abs(self.shk.s) > 5 then self.shk.s = lerp(self.shk.s, 0, 5, dt) else if self.shk.s ~= 0 then self.shk.s = 0 end end
end

function Camera:draw(func)
	love.graphics.push()
	love.graphics.translate(self.x + self.w/2, self.y + self.h/2)
	love.graphics.scale(self.cam.s)
	love.graphics.translate(-self.cam.x + self.shk.xrs, -self.cam.y + self.shk.yrs)
	func()
	love.graphics.pop()
end

function Camera:follow(x, y)
	local _x, _y = x, y
	self.cam.target_x = _x or self.cam.target_x
	self.cam.target_y = _y or self.cam.target_y
end

function Camera:zoom(s) 
	self.cam.target_s = s 
end

function Camera:shake(s) 
	self.shk.s = s or 0
end

function Camera:get_position() 
	return self.cam.x, self.cam.y, self.cam.target_x, self.cam.target_y 
end

function Camera:get_zoom() 
	return self.cam.s, self.cam.target_s 
end

function Camera:setlerpness(sv) 
	self.cam.sv = sv 
end

function Camera:set_zoomlerpness(sv) 
	self.cam.ssv = ssv 
end

function Camera:set_zoom(s) 
	self.cam.s, self.cam.target_s = s, s 
end

function Camera:set_position(x, y) 
	self.cam.x, self.cam.target_x = x or self.cam.x, x or self.cam.target_x
	self.cam.y, self.cam.target_y = y or self.cam.y, y or self.cam.target_y
end

function Camera:cam_to_screen(x, y)
	x, y = x - self.cam.x, y - self.cam.y
	x, y = x * self.cam.s, y * self.cam.s
	x, y = x + self.w / 2 + self.x, y + self.h / 2 + self.y
	return x, y
end

function Camera:screen_to_cam(x, y)
	x, y = x - self.w / 2 - self.x, y - self.h / 2 - self.y
	x, y = x / self.cam.s, y / self.cam.s
	x, y = x + self.cam.x, y + self.cam.y
	return x, y
end

function Camera:get_mouse_position() return
	self:screen_to_cam(love.mouse.getPosition()) 
end

return setmetatable({}, {__call = Camera.new})
