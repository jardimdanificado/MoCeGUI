--Mouse Centered Graphical User Interface(MoCeGUI)
if not rl then
    gl = '21'
    rl = require('mocegui.lib.raylib')
    gl = nil
end

package.path = 'mocegui/luatils/?.lua' .. ";" .. package.path
local mocegui={version="0.1.7",pending = {},font={}}
local util = require "mocegui.luatils.init"
mocegui.util = util
local options = require "data.config"
local mouse =
{
	draggin = false,
	lastposition = {x=0,y=0},
	moved = {x=0,y=0},
}

mocegui.window = {}

function mocegui.closeWindow()
	mocegui.window[1] = nil
	mocegui.window = util.array.clear(mocegui.window)
end

function mocegui.newWindow(title,position,size,color)
	local win = 
	{
		func = nil,
		color= color or {76,76,104,255},
		position= position or {x=16,y=16},
		size=size or {x=16,y=16},
		text = {},
		button = not title and 
		{
		} or
		{
			{
				position = {x=(size and size.x or 50)-12,y=0},
				size = {x=12,y=12},
				color = {r=255,g=127,b=127,a=255},
				pcolor = {r=127,g=25,b=25,a=255},
				func = mocegui.closeWindow,
				args = {}
			}
		},
		hide = false,
		title = title
	}
	win.text.new = function(text,position,size,color,pcolor)
		local newtxt = function (txt)
			return {
				position = {x=position.x or 0,y= position.y or 0},
				size = size or 12,
				color = {r=255 or color.r,g=255 or color.g,b=255 or color.b,a=255 or color.a},
				text = (txt .. '') or 'blank'
			}
		end
		if util.string.includes(text,'\n') then
			local result = {}
			local temp
			for key, value in ipairs(util.string.split(text,'\n')) do
				temp = newtxt(value)
				temp.position.y = temp.position.y + (12*(key-1))
				table.insert(win.text,1,temp)
				table.insert(result,win.text[1])
			end
			return result
		else
			table.insert(win.text,1,newtxt(text))
			return win.text[1]
		end
	end
	win.button.new = function(position,size,func,args,color,pcolor)
		local btn = {
			position = position,
			size = size or {x=12,y=12},
			color = color or {r=0,g=127,b=127,a=255},
			pcolor = pcolor or {r=127,g=25,b=26,a=255},
			func = func or mocegui.closeWindow,
			args = args or {}
		}
		btn.position = position or {x=size.x-12,y=0}
		table.insert(win.button,1,btn)
		return win.button[1]
	end
	table.insert(mocegui.window,2,win)
	mocegui.window = util.array.clear(mocegui.window)
	return win
end

local function bRect(px,py,sx,sy,color,bordercolor)
	rl.DrawRectangle(px-1, py-1, sx+2, sy+2, bordercolor or rl.WHITE)
	rl.DrawRectangle(px, py, sx, sy, color or rl.BLUE)
end

function mocegui.load()
	if options.fullscreen then
        rl.SetConfigFlags(rl.FLAG_FULLSCREEN_MODE)
    end
    if options.vsync then
        rl.SetConfigFlags(rl.FLAG_VSYNC_HINT)
    end
    if options.runonbackground then
        rl.SetConfigFlags(rl.FLAG_WINDOW_ALWAYS_RUN)
    end
    if options.msaa then
        rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT)
    end
    if options.interlace then
        rl.SetConfigFlags(rl.FLAG_INTERLACED_HINT)
    end 
    if options.highdpi then
        rl.SetConfigFlags(rl.FLAG_WINDOW_HIGHDPI)
    end
	rl.SetConfigFlags(rl.FLAG_WINDOW_RESIZABLE)
    rl.InitWindow(600,400, "MoCeGUI-" .. mocegui.version)
    rl.SetTargetFPS(0)
	local iconImageData = rl.LoadImage("mocegui/png/icon.png")
    rl.SetWindowIcon(iconImageData)
	mocegui.titlecache = "MoCeGUI-" .. mocegui.version

	local debugwin = mocegui.newWindow('debug window',{x=1,y=1},{x=110,y=56})
	local debugtxt = debugwin.text.new(mocegui.titlecache .. "\nCurrent FPS: " .. tostring(rl.GetFPS()) .. "\nWindow amount:" .. 
	#mocegui.window, {x=1,y=14},{x=0.9,y=0.9})
	debugwin.func = function ()
		debugtxt[3].text = "Window amount:" .. #mocegui.window
		debugtxt[2].text = "Current FPS: " .. rl.GetFPS()
	end
	options.rendertexture = rl.LoadRenderTexture(options.screen.x, options.screen.y)
end

function mocegui.keypressed(key)
end

function mocegui.mousereleased()
	local x,y = rl.GetMouseX(),rl.GetMouseY()
	if mocegui.window[1] then
		if rl.IsMouseButtonPressed(0) then
			mocegui.window[1].button = util.array.clear(mocegui.window[1].button)
			for index, _button in ipairs(mocegui.window[1].button) do
				if _button and _button.position and mocegui.window[1] and mocegui.window[1].position then
					if x >= mocegui.window[1].position.x + _button.position.x  and
					   x <= mocegui.window[1].position.x + _button.position.x + _button.size.x  and
					   y >= mocegui.window[1].position.y + _button.position.y  and
					   y <= mocegui.window[1].position.y + _button.position.y + _button.size.y  then
						_button.func(mocegui.window)
						_button.pressed = false
					end
				end
			end
			if mouse.draggin then
				mouse.draggin = false
			end
		elseif rl.IsMouseButtonPressed(2) then
			if mouse.draggin then
				mouse.draggin = false
			end
		elseif rl.IsMouseButtonPressed(1) then
			if x >= mocegui.window[1].position.x  and
			x <= mocegui.window[1].position.x + mocegui.window[1].size.x  and
			y >= mocegui.window[1].position.y  and
			y <= mocegui.window[1].position.y + mocegui.window[1].size.y  then
				mocegui.closeWindow()
			end
		end
	end
end

function mocegui.mousepressed()
	local x,y = rl.GetMouseX(),rl.GetMouseY()
	if mocegui.window[1] then
		if rl.IsMouseButtonPressed(0) or rl.IsMouseButtonPressed(1) or rl.IsMouseButtonPressed(2) then
			if not (x >= mocegui.window[1].position.x  and
			x <= mocegui.window[1].position.x + mocegui.window[1].size.x  and
			y >= mocegui.window[1].position.y  and
			y <= mocegui.window[1].position.y + mocegui.window[1].size.y ) then
				for index, win in pairs(mocegui.window) do
					if x >= win.position.x  and
					x <= win.position.x + win.size.x  and
					y >= win.position.y  and
					y <= win.position.y + win.size.y  then
						util.table.move(mocegui.window,index,1)
						break
					end
				end
			end
		end
		if rl.IsMouseButtonPressed(0) then
			for index, _button in ipairs(mocegui.window[1].button) do
				if x >= mocegui.window[1].position.x + _button.position.x  and
				x <= mocegui.window[1].position.x + _button.position.x + _button.size.x  and
				y >= mocegui.window[1].position.y + _button.position.y  and
				y <= mocegui.window[1].position.y + _button.position.y + _button.size.y  then
					_button.pressed = true
				end
			end
		end
	end
end

function mocegui.mousedown()
	local x,y = rl.GetMouseX(),rl.GetMouseY()
	local delta = rl.GetMouseDelta()
	if rl.IsMouseButtonDown(2) then
		if x >= mocegui.window[1].position.x  and
		x <= mocegui.window[1].position.x + mocegui.window[1].size.x  and
		y >= mocegui.window[1].position.y  and
		y <= mocegui.window[1].position.y + mocegui.window[1].size.y  then
			mocegui.window[1].position.x = mocegui.window[1].position.x + delta.x
			mocegui.window[1].position.y = mocegui.window[1].position.y + delta.y
		end
	elseif rl.IsMouseButtonDown(0) then
		if mocegui.window[1].title and
			x >= mocegui.window[1].position.x  and
			x <= mocegui.window[1].position.x + mocegui.window[1].size.x  and
			y >= mocegui.window[1].position.y  and
			y <= mocegui.window[1].position.y + 20 then
				mocegui.window[1].position.x = mocegui.window[1].position.x + delta.x
				mocegui.window[1].position.y = mocegui.window[1].position.y + delta.y
		end
	end
end

function mocegui.render()
	mocegui.util.repeater(mocegui.pending)
    if(rl.IsWindowResized()) then
        rl.UnloadRenderTexture(options.rendertexture)
        options.screen.x = rl.GetScreenWidth()
        options.screen.y = rl.GetScreenHeight()
        options.rendertexture = rl.LoadRenderTexture(options.screen.x, options.screen.y)
        --world.redraw=true
    end
    mocegui.mousepressed()
    mocegui.mousereleased()
    mocegui.mousedown()
    rl.BeginDrawing()
    --if(world.redraw == true and options.freeze == false) then
	rl.BeginTextureMode(options.rendertexture)
	rl.ClearBackground(rl.BLACK)
	--rl.BeginMode3D(options.camera)
	--rl.EndMode3D()
	util.array.selfclear(mocegui.window)
	--love.graphics.push()
	for index = #mocegui.window, 1, -1 do
		local v = mocegui.window[index]
		if v.func then
			v.func(v.args and unpack(v.args) or 0)
		end
		if v.title then
			rl.DrawRectangle(v.position.x-1, v.position.y-1, v.size.x+2, v.size.y+2, rl.WHITE)
			rl.DrawRectangle(v.position.x, v.position.y+13, v.size.x, v.size.y-13,v.color)
			if mocegui.font[1] then
				rl.DrawTextEx(mocegui.font[1],v.title, {x=v.position.x,y=v.position.y}, 12, 0, v.color)
			else
				rl.DrawText(v.title, v.position.x,v.position.y, 12, v.color)
			end
		else
			bRect(v.position.x, v.position.y, v.size.x, v.size.y, v.color)
		end
		for key, button in ipairs(v.button) do
			if button.func ~= mocegui.closeWindow then
				bRect(v.position.x+button.position.x, v.position.y+button.position.y, button.size.x, button.size.y,(button.pressed and button.pcolor or button.color))
			else
				local c = button.pressed and button.pcolor or button.color
				rl.DrawRectangle(v.position.x+button.position.x, v.position.y+button.position.y, button.size.x, button.size.y, c)
			end
		end
		for key, text in ipairs(v.text) do
			if mocegui.font[1] then
				rl.DrawTextEx(mocegui.font[1],text.text, {x=v.position.x+text.position.x, y=v.position.y+text.position.y}, 12, 0, text.color)
			else
				rl.DrawText(text.text, v.position.x+text.position.x, v.position.y+text.position.y, 12, text.color)
			end
		end
			--world.redraw = false
			--end
	end
	rl.EndTextureMode();
    rl.DrawTexturePro(
        options.rendertexture.texture,
        {
            x=0,
            y=0,
            width=options.screen.x,
            height=options.screen.y*-1
        },
        {x=0,y=0,width=options.screen.x,height=options.screen.y},
        {x=0,y=0},
        0,
        rl.WHITE
    );
    rl.EndDrawing()
end

mocegui.close = function()
	rl.CloseWindow()
end

mocegui.mouse = mouse

return mocegui