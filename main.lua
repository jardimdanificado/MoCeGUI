local util = require "util"
local mouse = {current = 1,cursor = {}}
local window = { {color={0.5,0.12,0.75,1},poisiton={10,10},size={300,120}} }

function love.load()
  mouse.cursor[1] = love.graphics.newImage("png/cursor-pointer-18.png")
  mouse.cursor[2] = love.graphics.newImage("png/cursor-direction-25.png")
  love.mouse.setVisible(false)
end

function love.keypressed(key)
end

function love.update()
end

function love.draw()
	love.graphics.push()
	for key, v in pairs(window) do
		love.graphics.setColor(unpack(v.color))
		love.graphics.rectangle( 'fill', v.poisiton[1], v.poisiton[2], v.size[1], v.size[2], 0, 0, 120 )
	end
	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(mouse.cursor[mouse.current], love.mouse.getX() - mouse.cursor[mouse.current]:getWidth() / 2, love.mouse.getY() - mouse.cursor[mouse.current]:getHeight() / 2)
	love.graphics.pop()
end