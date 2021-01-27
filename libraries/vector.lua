local acos, atan2, sqrt, cos, sin, min, max = math.acos, math.atan2, math.sqrt, math.cos, math.sin, math.min, math.max
local status, ffi

local function new(x, y) return setmetatable({x = x or 0, y = y or 0}, Vec2) end

if type(jit) == 'table' and jit.status() then
	status, ffi = pcall(require, 'ffi')
	if status then
		ffi.cdef('typedef struct { double x, y;} vector2;')
		new = ffi.typeof('vector2')
	end
end

local Vec2 = {}

function Vec2.new(x, y)
	if Vec2.is_vec2(x) then 
		return Vec2.copy(x)
	elseif x and y then
		assert(type(x) == 'number', 'new: Wrong argument type for x (<number> expected)')
		assert(type(y) == 'number', 'new: Wrong argument type for y (<number> expected)')
		return new(x, y)
	elseif type(x) == 'table' then
		local xx, yy = x.x or x[1], x.y or x[2]
		assert(type(xx) == 'number', 'new: Wrong argument type for x (<number> expected)')
		assert(type(yy) == 'number', 'new: Wrong argument type for y (<number> expected)')
		return new(xx, yy)
	elseif type(x) == 'number' then 
		return new(x, x) 
	else 
		return new() 
	end
end

function Vec2.clone(a) return new(a.x, a.y) end
function Vec2.copy(a) return new(a.x, a.y) end
function Vec2.add(a, b) return new(a.x + b.x, a.y + b.y) end
function Vec2.sub(a, b) return new(a.x - b.x, a.y - b.y) end
function Vec2.mul(a, b) if Vec2.is_vec2(b) then return new(a.x * b.x, a.y * b.y) else return new(a.x * b, a.y * b) end end
function Vec2.div(a, b) return new(a.x / b.x, a.y / b.y) end
function Vec2.trim(a, length) return a:normalized():mul(min(a:len(), length)) end
function Vec2.cross(a, b) return a.x * b.y - a.y * b.x end
function Vec2.dot(a, b) return a.x * b.x + a.y * b.y end
function Vec2.length(a) return sqrt(a.x * a.x + a.y * a.y) end
function Vec2.len(a) return sqrt(a.x * a.x + a.y * a.y) end
function Vec2.len2(a) return a.x * a.x + a.y * a.y end
function Vec2.normalize(a) local temp if a:is_zero() then temp = new() else temp = a:mul(1 / a:len()) end a.x, a.y = temp.x, temp.y return a end
function Vec2.scale(a, b) local temp = new(a.x, a.y):normalized():mul(b) a.x, a.y = temp.x, temp.y return a end
function Vec2.rotate(a, angle) local temp = new(cos(angle) * a.x - sin(angle) * a.y, sin(angle) * a.x + cos(angle) * a.y) a.x, a.y = temp.x, temp.y return a end
function Vec2.normalized(a) if a:is_zero() then return new() else return a:mul(1 / a:len()) end end
function Vec2.scaled(a, b) return new(a.x, a.y):normalized():mul(b) end
function Vec2.rotated(a, phi) local c = cos(phi) local s = sin(phi) return new(c * a.x - s * a.y, s * a.x + c * a.y) end
function Vec2.perpendicular(a) return new(-a.y, a.x) end
function Vec2.angle(a) return atan2(a.y, a.x) end
function Vec2.lerp(a, b, s) return a + (b - a) * s end
function Vec2.unpack(a) return a.x, a.y end
function Vec2.component_min(a, b) return new(min(a.x, b.x), min(a.y, b.y)) end
function Vec2.component_max(a, b) return new(max(a.x, b.x), max(a.y, b.y)) end
function Vec2.from_cartesian(length, angle) return new(length * cos(angle), length * sin(angle)) end
function Vec2.is_vec2(a) if type(a) == 'cdata' then return ffi.istype('vector2', a) end return type(a) == 'table' and type(a.x) == 'number' and type(a.y) == 'number' end
function Vec2.is_zero(a) return a.x == 0 and a.y == 0 end
function Vec2.to_string(a) return string.format('(%+0.3f,%+0.3f)', a.x, a.y) end
function Vec2.unit_x() return new(1, 0) end
function Vec2.unit_y() return new(0, 1) end
function Vec2.zero() return new(0, 0) end
function Vec2.length_to(a, b) local dx = a.x - b.x local dy = a.y - b.y return sqrt(dx * dx + dy * dy) end
function Vec2.len_to(a, b) local dx = a.x - b.x local dy = a.y - b.y return sqrt(dx * dx + dy * dy) end
function Vec2.len2_to(a, b) local dx = a.x - b.x local dy = a.y - b.y return dx * dx + dy * dy end
function Vec2.to_polar(a) local length = sqrt(a.x^2 + a.y^2) local angle = atan2(a.y, a.x) angle = angle > 0 and angle or angle + 2 * math.pi return length, angle end
function Vec2.angle_to(a, b) return atan2(b.y - a.y, b.x - a.x) end
function Vec2.angle_between(a, b) local source, target = a:angle(), b:angle() return atan2(sin(source-target), cos(source-target)) end

function Vec2.__index(_, v)
	return Vec2[v] 
end
function Vec2.__tostring(a)
	return Vec2.to_string(a)
end
function Vec2.__call(_, x, y) 
	return Vec2.new(x, y) 
end
function Vec2.__unm(a) 
	return new(-a.x, -a.y) 
end
function Vec2.__eq(a, b) 
	if not Vec2.is_vec2(a) or not Vec2.is_vec2(b) then return false end 
	return a.x == b.x and a.y == b.y 
end
function Vec2.__add(a, b)
	assert(Vec2.is_vec2(a), '__add: Wrong argument type for left hand operand. (<Vector> expected)')
	assert(Vec2.is_vec2(b), '__add: Wrong argument type for right hand operand. (<Vector> expected)')
	return a:add(b)
end
function Vec2.__sub(a, b)
	assert(Vec2.is_vec2(a), '__add: Wrong argument type for left hand operand. (<Vector> expected)')
	assert(Vec2.is_vec2(b), '__add: Wrong argument type for right hand operand. (<Vector> expected)')
	return a:sub(b)
end
function Vec2.__mul(a, b)
	assert(Vec2.is_vec2(a), '__mul: Wrong argument type for left hand operand. (<Vector> expected)')
	assert(Vec2.is_vec2(b) or type(b) == 'number', '__mul: Wrong argument type for right hand operand. (<Vector> or <number> expected)')
	return a:mul(b)
end
function Vec2.__div(a, b)
	assert(Vec2.is_vec2(a), '__div: Wrong argument type for left hand operand. (<Vector> expected)')
	assert(Vec2.is_vec2(b) or type(b) == 'number', '__div: Wrong argument type for right hand operand. (<Vector> or <number> expected)')
	if Vec2.is_vec2(b) then return a:div(b) end
	return a:mul(1 / b)
end

if status then ffi.metatype(new, Vec2) end

return setmetatable({}, Vec2)
