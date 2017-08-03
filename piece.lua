--
-- Agario Checkers - Checkers-like game with inspiration from agar.io
-- Copyright (C) 2015-2017 Delwink, LLC
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
require 'board'

Piece = class()

local colors = {
   {255, 0, 255},
   {255, 255, 0}
}

local texture = love.graphics.newImage('res/piece.png')
local king = love.graphics.newImage('res/king.png')

function Piece:__init(x, y, team, id)
   self.x = x
   self.y = y
   self.team = team
   self.id = id

   self.size = 10
   self.king = false
end

function Piece:move(x, y)
   self.x = x
   self.y = y
end

function Piece:canmove(x, y)
   if x < 1 or y < 1 or x > 8 or y > 8 then
      return false
   end

   if not self.king then
      if 1 == self.team then
	 if y < self.y then
	    return false
	 end
      else
	 if y > self.y then
	    return false
	 end
      end
   end

   return true
end

function Piece:resize(dt)
   self.size = self.size + dt
end

function Piece:getrealcoords()
   local center = getcenter(self.x, self.y)
   local scale = (BOARD_SIZE / 1024) * (self.size / 64)
   local halfsize = (texture:getWidth() * scale) / 2

   return {x=center.x - halfsize, y=center.y - halfsize, scale=scale}
end

function Piece:draw()
   local c = self:getrealcoords()

   love.graphics.setColor(colors[self.team])
   love.graphics.draw(texture, c.x, c.y, 0, c.scale, c.scale)

   if self.king then
      love.graphics.setColor(colors[self.team][1], colors[self.team][2],
			     colors[self.team][3], 50)
      love.graphics.draw(king, c.x, c.y, 0, c.scale, c.scale)
   end
end

function teamcolor(team)
   return colors[team]
end
