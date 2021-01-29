--[[
 4v0v - MIT license
 based on groverbuger's g3d 
 https://github.com/groverburger/g3d
      __ __        __     
     /\ \\ \      /\ \    
   __\ \ \\ \     \_\ \   
 /'_ `\ \ \\ \_   /'_` \  
/\ \L\ \ \__ ,__\/\ \L\ \ 
\ \____ \/_/\_\_/\ \___,_\
 \/___L\ \ \/_/   \/__,_ /
   /\____/                
   \_/__/                 
--]]

love.graphics.setDepthMode("lequal", true)

G4D_PATH     = ...
local model  = require(G4D_PATH .. "/g4d_model")
local camera = require(G4D_PATH .. "/g4d_camera")
local shader = require(G4D_PATH .. "/g4d_shaderloader")
G4D_PATH     = nil

local G4d = {
	camera    = camera,
	shader    = shader, 
	add_model = model,
	models    = model.models,
	canvas    = love.graphics.newCanvas(),
}

function G4d:draw(x, y)
	self:update_lights()

	love.graphics.setCanvas({self.canvas, depth=true})
	love.graphics.clear()
	love.graphics.setShader(self.shader)

		for _, model in ipairs(self.models) do 
			model:draw()
		end

	love.graphics.setShader()
	love.graphics.setCanvas()

	love.graphics.draw(self.canvas, x or 0, y or 0)
end


function G4d:update_lights()
	local lights = {}
	for _, model in ipairs(self.models) do 
		if model.light.is_light then 
			table.insert(lights, {
				position           = {model.x, model.y, model.z, 1},
				color              = model.light.color,
				max_distance       = model.light.max_distance,
				ambient_intensity  = model.light.ambient_intensity,
				diffuse_intensity  = model.light.diffuse_intensity,
				specular_intensity = model.light.specular_intensity,
			})
		end
	end

	for i, light in ipairs(lights) do
		local c_index = i-1
		self.shader:send('lights['.. c_index ..'].position'          , light.position)
		self.shader:send('lights['.. c_index ..'].color'             , light.color)
		self.shader:send('lights['.. c_index ..'].max_distance'      , light.max_distance)
		self.shader:send('lights['.. c_index ..'].ambient_intensity' , light.ambient_intensity)
		self.shader:send('lights['.. c_index ..'].diffuse_intensity' , light.diffuse_intensity)
		self.shader:send('lights['.. c_index ..'].specular_intensity', light.specular_intensity)
	end

	self.shader:send('lights_count', #lights)
end

return G4d