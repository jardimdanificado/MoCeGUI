local util = require "util"
local mouse = 
{
	current = 1,
	cursor = {},
	draggin = false
}

local function closeWindow(window)
	window[window.current] = nil
end

local window = 
{
	current = 1,
	{
		color={0.3,0.3,0.4,1},
		position={10,10},
		size={300,110},
		button = 
		{
			{
				position = {300-12,0},
				size = {12,12},
				color = {1,0.5,0.5,1},
				pcolor = {0.5,0.1,0.1,1},
				func = closeWindow,
				args = {}
			}
		},
		hide = false,
	} 
}
window[1].button[1].args[1] = window

local function bRect(px,py,sx,sy,color,bordercolor)
	love.graphics.setColor(bordercolor or {1,1,1,1})
	love.graphics.rectangle( 'fill', px-1, py-1, sx+2, sy+2)
	love.graphics.setColor(unpack(color))
	love.graphics.rectangle( 'fill', px, py, sx, sy)
end

function love.load()
  mouse.cursor[1] = love.graphics.newImage("png/cursor-pointer-18.png")
  mouse.cursor[2] = love.graphics.newImage("png/cursor-direction-25.png")
  love.mouse.setVisible(false)
end

function love.keypressed(key)
end

function love.mousemoved( x, y, dx, dy, istouch )
	if mouse.draggin then
		mouse.draggin[1] = mouse.draggin[1] + dx
		mouse.draggin[2] = mouse.draggin[2] + dy
	end
end

function love.mousereleased(x, y, button)
	local currentWindow = window[window.current]
	if button == 1 and currentWindow then
		for index, _button in ipairs(currentWindow.button) do
			if x >= currentWindow.position[1] + _button.position[1] + 8 and
			   x <= currentWindow.position[1] + _button.position[1] + _button.size[1] + 8 and
			   y >= currentWindow.position[2] + _button.position[2] + 8 and
			   y <= currentWindow.position[2] + _button.position[2] + _button.size[2] + 8 then
				_button.func(window)
				_button.pressed = false
			end
		end
		if mouse.draggin then
			mouse.draggin = false
			mouse.current = 1
		end
	elseif button == 3 then
		if mouse.draggin then
			mouse.draggin = false
			mouse.current = 1
		end
	end
 end

 function love.mousepressed(x, y, button, istouch)
    local currentWindow = window[window.current]
    
    if button == 1 and currentWindow then
        if x >= currentWindow.position[1] + 8 and
           x <= currentWindow.position[1] + currentWindow.size[1] + 8 and
           y >= currentWindow.position[2] + 8 and
           y <= currentWindow.position[2] + 20 then
            mouse.draggin = currentWindow.position
            mouse.current = 2
        end
		for index, _button in ipairs(currentWindow.button) do
			if x >= currentWindow.position[1] + _button.position[1] + 8 and
			   x <= currentWindow.position[1] + _button.position[1] + _button.size[1] + 8 and
			   y >= currentWindow.position[2] + _button.position[2] + 8 and
			   y <= currentWindow.position[2] + _button.position[2] + _button.size[2] + 8 then
				_button.pressed = true
			end
		end
    elseif button == 3 then
        if x >= currentWindow.position[1] and
           x <= currentWindow.position[1] + currentWindow.size[1] and
           y >= currentWindow.position[2] and
           y <= currentWindow.position[2] + currentWindow.size[2] then
            mouse.draggin = currentWindow.position
            mouse.current = 2
        end
    end
end


function love.update()
end

function love.draw()
	love.graphics.push()
	for key, v in ipairs(window) do
		bRect(v.position[1], v.position[2], v.size[1], v.size[2], v.color)
		bRect(v.position[1], v.position[2], v.size[1], 12, {1,1,1,1})
		for key, button in pairs(v.button) do
			bRect(v.position[1]+button.position[1], v.position[2]+button.position[2], button.size[1], button.size[2],(button.pressed and button.pcolor or button.color))
		end
		-- close button
	end
	
	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(mouse.cursor[mouse.current], love.mouse.getX() - mouse.cursor[mouse.current]:getWidth() / 2, love.mouse.getY() - mouse.cursor[mouse.current]:getHeight() / 2)
	love.graphics.pop()
	love.graphics.print("Current FPS: " .. tostring(love.timer.getFPS()), 1, 1)

end