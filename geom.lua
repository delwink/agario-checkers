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

local RIGHT_ANGLE = math.pi / 2
local DEG45 = math.pi / 4

local function drawline(x1, y1, x2, y2)
   for y=-1,1 do
      for x=-1,1 do
	 love.graphics.line(x1 + x, y1 + y, x2 + x, y2 + y)
      end
   end
end

function drawbox(x, y, w, h)
   drawline(x, y, x + w, y)
   drawline(x, y + h, x + w, y + h)
   drawline(x, y, x, y + h)
   drawline(x + w, y, x + w, y + h)
end

local function getquadrant(deltax, deltay)
   if deltax > 0 then
      if deltay > 0 then
	 return 1
      else
	 return 4
      end
   else
      if deltay > 0 then
	 return 2
      else
	 return 3
      end
   end
end

function getangle(x1, y1, x2, y2)
   local deltax = x2 - x1
   local deltay = y2 - y1

   if 0 == deltax then
      if deltay < 0 then
	 return RIGHT_ANGLE
      else
	 return 3 * RIGHT_ANGLE
      end
   elseif 0 == deltay then
      if deltax < 0 then
	 return 2 * RIGHT_ANGLE
      else
	 return 0
      end
   end

   local angle = -math.abs(math.atan(deltay / deltax))

   local quad = getquadrant(deltax, deltay)
   if 2 == quad then
      angle = math.pi - angle
   elseif 3 == quad then
      angle = math.pi + angle
   elseif 4 == quad then
      angle = -angle
   end

   while angle < 0 do
      angle = angle + (2 * math.pi)
   end

   return angle
end

function drawlineangle(x, y, length, angle)
   local change = angle + RIGHT_ANGLE -- use real angles
   love.graphics.translate(x, y)
   love.graphics.rotate(-change)
   drawline(0, 0, 0, length)
   love.graphics.rotate(change)
   love.graphics.translate(-x, -y)
end

function drawarrow(x1, y1, x2, y2)
   local angle = getangle(x1, y1, x2, y2)
   drawline(x1, y1, x2, y2)
   local change = DEG45 * 3
   drawlineangle(x2, y2, 5, angle - change)
   drawlineangle(x2, y2, 5, angle + change)
end
