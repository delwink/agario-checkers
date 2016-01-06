--
--  Agario Checkers - Checkers-like game with inspiration from agar.io
--  Copyright (C) 2015-2016 Delwink, LLC
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

BOARD_SIZE = 512
BOARD_SQ_SIZE = BOARD_SIZE / 8

local darkcolor = {0, 0, 0}

function boardsqsize()
   return BOARD_SQ_SIZE
end

function getboardpos()
   local halfsize = BOARD_SIZE / 2
   local xpos = love.graphics.getWidth()/2 - halfsize
   local ypos = love.graphics.getHeight()/2 - halfsize

   return {x=xpos, y=ypos}
end

function getcenter(x, y)
   local bpos = getboardpos()
   local sqsize = boardsqsize()
   local halfsize = sqsize / 2
   local xpos = bpos.x + (x - 1) * sqsize + halfsize
   local ypos = bpos.y + (y - 1) * sqsize + halfsize

   return {x=xpos, y=ypos}
end

local function drawsquare(x, y)
   love.graphics.rectangle('fill', x, y, boardsqsize(), boardsqsize())
end

local function drawrow(start, y)
   local sqsize = boardsqsize()

   for i=0,3 do
      drawsquare(start + i * sqsize * 2, y)
   end
end

function drawboard()
   local boardpos = getboardpos()
   local sqsize = boardsqsize()

   love.graphics.setColor(darkcolor)

   for i=0,3 do
      local ypos = boardpos.y + i * sqsize * 2
      drawrow(boardpos.x + sqsize, ypos)
      drawrow(boardpos.x, ypos + sqsize)
   end
end

function inspace(space, x, y)
   local sqsize = boardsqsize()
   return (x >= space.x and y >= space.y and x <= space.x + sqsize
	      and y <= space.y + sqsize)
end

function getsqpos(x, y)
   local bpos = getboardpos()
   local sqsize = boardsqsize()
   x = x - 1
   y = y - 1

   return {x=bpos.x + (x * sqsize), y=bpos.y + (y * sqsize)}
end

function onboard(x, y)
   local bpos = getboardpos()
   return (x >= bpos.x and x <= bpos.x + BOARD_SIZE
	      and y >= bpos.y and y <= bpos.y + BOARD_SIZE)
end

function getspace(x, y)
   local bpos = getboardpos()
   local sqsize = boardsqsize()

   if not onboard(x, y) then
      return {x=-1, y=-1}
   end

   return {x=math.floor((x - bpos.x) / sqsize) + 1,
	   y=math.floor((y - bpos.y) / sqsize) + 1}
end
