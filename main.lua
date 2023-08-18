local util = require "util"
local mouse = 
{
	current = 1,
	cursor = {},
	draggin = false
}

local function closeWindow(window)
	for i, value in ipairs(window) do
		if value and i ~= window.current then
			window[window.current] = nil
			window.current = i
			return
		end
	end
	window[window.current] = nil
	window.current = nil
end

local window = 
{
	current = 0
}

local function newWindow(title,position,size,color)
	local win = {
		color= color or {0.3,0.3,0.4,1},
		position= position or {50,50},
		size=size or {300,110},
		button = 
		{
			{
				position = {0,0},
				size = {12,12},
				color = {1,0.5,0.5,1},
				pcolor = {0.5,0.1,0.1,1},
				func = closeWindow,
				args = {}
			}
		},
		hide = false,
		title = title or 'JLsZ|::>>Ç#@#)!(%%LFsafa)generic title'
	}
	position = {win.size[1]-12,0}
	win.button[1].args[1] = window
	win.button.new = function(position,size,func,args,color,pcolor)
		local btn = {
			position = position or {300-12,0},
			size = size or {12,12},
			color = color or {1,0.5,0.5,1},
			pcolor = pcolor or {0.5,0.1,0.1,1},
			func = func or closeWindow,
			args = args or {}
		}
		btn.position = position or {size[1]-12,0}
		win.button[#win.button+1] = btn
	end
	table.insert(window,win)
	window.current = #window
	return win
end

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
	if not (x >= currentWindow.position[1] + 8 and
		x <= currentWindow.position[1] + currentWindow.size[1] + 8 and
		y >= currentWindow.position[2] + 8 and
		y <= currentWindow.position[2] + currentWindow.size[2] + 8) then
			for index, win in pairs(window) do
				if index ~= 'current' and
				x >= win.position[1] + 8 and
				x <= win.position[1] + win.size[1] + 8 and
				y >= win.position[2] + 8 and
				y <= win.position[2] + win.size[2] + 8 then
					window.current = index
					break
				end
			end
	end
    currentWindow = window[window.current]
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
        if x >= currentWindow.position[1] + 8 and
           x <= currentWindow.position[1] + currentWindow.size[1] + 8 and
           y >= currentWindow.position[2] + 8 and
           y <= currentWindow.position[2] + currentWindow.size[2] + 8 then
            mouse.draggin = currentWindow.position
            mouse.current = 2
        end
    end
end


function love.update()
end

function love.draw()
	love.graphics.push()
	for key, v in pairs(window) do
		if key ~= 'current' and key ~= window.current then
			bRect(v.position[1], v.position[2], v.size[1], v.size[2], v.color)
			bRect(v.position[1], v.position[2], v.size[1], 12, {1,1,1,1})
			for key, button in ipairs(v.button) do
				bRect(v.position[1]+button.position[1], v.position[2]+button.position[2], button.size[1], button.size[2],(button.pressed and button.pcolor or button.color))
			end
			love.graphics.setColor(unpack(v.color))
			love.graphics.print(v.title,v.position[1]+14,v.position[2],0,0.8,0.8)
		end
	end
	if window[window.current] then
		bRect(window[window.current].position[1], window[window.current].position[2], window[window.current].size[1], window[window.current].size[2], window[window.current].color)
		bRect(window[window.current].position[1], window[window.current].position[2], window[window.current].size[1], 12, {1,1,1,1})
		for key, button in ipairs(window[window.current].button) do
			bRect(window[window.current].position[1]+button.position[1], window[window.current].position[2]+button.position[2], button.size[1], button.size[2],(button.pressed and button.pcolor or button.color))
		end
		love.graphics.setColor(unpack(window[window.current].color))
		love.graphics.print(window[window.current].title,window[window.current].position[1]+14,window[window.current].position[2],0,0.8,0.8)
	end
	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(mouse.cursor[mouse.current], love.mouse.getX() - mouse.cursor[mouse.current]:getWidth() / 2, love.mouse.getY() - mouse.cursor[mouse.current]:getHeight() / 2)
	love.graphics.pop()
	love.graphics.print("Current FPS: " .. tostring(love.timer.getFPS()), 1, 1)
end


local testwin = newWindow() -- default window
local testwin2 = newWindow('title?',{311,180},{80,60},{0.3,0.4,0.5,1}) -- default window
-- window[1].button.new() -- default btn