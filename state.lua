--
--  Agario Checkers - Checkers-like game with inspiration from agar.io
--  Copyright (C) 2016 Delwink, LLC
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU Affero General Public License as published by
--  the Free Software Foundation, version 3 only.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU Affero General Public License for more details.
--
--  You should have received a copy of the GNU Affero General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--

require 'class'

activestate = nil

function setstate(state)
   if activestate then
      activestate:unload()
   end

   state:load()
   activestate = state
end

local authorlogo = love.graphics.newImage('res/author.png')

State = class()

function State:__init()
   self._buttons = {}
end

function State:load()

end

function State:unload()

end

function State:update(dt)

end

function State:draw()
   local wwidth = love.graphics.getWidth()
   local wheight = love.graphics.getHeight()

   -- Agario-style background grid
   love.graphics.setColor(170, 170, 170)
   local gridsize = boardsqsize() / 3

   local mid = wwidth / 2
   local diff = 0
   while diff * 2 < wwidth do
      love.graphics.line(mid - diff, 0, mid - diff, wheight)
      love.graphics.line(mid + diff, 0, mid + diff, wheight)
      diff = diff + gridsize
   end

   mid = wheight / 2
   diff = 0
   while diff * 2 < wheight do
      love.graphics.line(0, mid - diff, wwidth, mid - diff)
      love.graphics.line(0, mid + diff, wwidth, mid + diff)
      diff = diff + gridsize
   end

   -- draw all buttons
   for _,button in ipairs(self._buttons) do
      button:draw()
   end

   -- draw author logo
   love.graphics.setColor(0, 0, 0)
   love.graphics.draw(authorlogo, 0, wheight - authorlogo:getHeight()/2, 0,
		      0.5, 0.5)
end

function State:keypressed(key, isrepeat)

end

function State:mousepressed(x, y, button)
   if button == 1 then
      for _,button in ipairs(self._buttons) do
	 if button:isvisible() and button:contains(x, y) then
	    button:onpress()
	    return
	 end
      end
   end
end

function State:mousereleased(x, y, button)
   if button == 1 then
      for _,button in ipairs(self._buttons) do
	 if button:isvisible() then
	    button:onrelease(x, y)
	 end
      end
   end
end
