--
--  Agario Checkers - Checkers-like game with inspiration from agar.io
--  Copyright (C) 2015 Delwink, LLC
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
require 'board'

Piece = class()

local colors = {
   {255, 0, 255},
   {255, 255, 0}
}

local texture = love.graphics.newImage('res/piece.png')

function Piece:__init(x, y, team)
   self.x = x
   self.y = y
   self.team = team

   self.size = 10
   self.king = false
end

function Piece:move(dtx, dty)
   self.x = self.x + dtx
   self.y = self.y + dty
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
end

function teamcolor(team)
   return colors[team]
end
