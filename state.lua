--
-- Agario Checkers - Checkers-like game with inspiration from agar.io
-- Copyright (C) 2016 Delwink, LLC
--
-- Redistributions, modified or unmodified, in whole or in part, must retain
-- applicable copyright or other legal privilege notices, these conditions, and
-- the following license terms and disclaimer.  Subject to these conditions,
-- the holder(s) of copyright or other legal privileges, author(s) or
-- assembler(s), and contributors of this work hereby grant to any person who
-- obtains a copy of this work in any form:
--
-- 1. Permission to reproduce, modify, distribute, publish, sell, sublicense,
-- use, and/or otherwise deal in the licensed material without restriction.
--
-- 2. A perpetual, worldwide, non-exclusive, royalty-free, irrevocable patent
-- license to reproduce, modify, distribute, publish, sell, use, and/or
-- otherwise deal in the licensed material without restriction, for any and all
-- patents:
--
--     a. Held by each such holder of copyright or other legal privilege,
--     author or assembler, or contributor, necessarily infringed by the
--     contributions alone or by combination with the work, of that privilege
--     holder, author or assembler, or contributor.
--
--     b. Necessarily infringed by the work at the time that holder of
--     copyright or other privilege, author or assembler, or contributor made
--     any contribution to the work.
--
-- NO WARRANTY OF ANY KIND IS IMPLIED BY, OR SHOULD BE INFERRED FROM, THIS
-- LICENSE OR THE ACT OF DISTRIBUTION UNDER THE TERMS OF THIS LICENSE,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR
-- A PARTICULAR PURPOSE, AND NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS,
-- ASSEMBLERS, OR HOLDERS OF COPYRIGHT OR OTHER LEGAL PRIVILEGE BE LIABLE FOR
-- ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN ACTION OF CONTRACT, TORT,
-- OR OTHERWISE ARISING FROM, OUT OF, OR IN CONNECTION WITH THE WORK OR THE USE
-- OF OR OTHER DEALINGS IN THE WORK.
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
