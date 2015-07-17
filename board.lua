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

BOARD_SIZE = 512

local darkcolor = {0, 0, 0}

function boardsqsize()
   return BOARD_SIZE / 8
end

function getboardpos()
   local halfsize = BOARD_SIZE / 2
   local xpos = love.window.getWidth()/2 - halfsize
   local ypos = love.window.getHeight()/2 - halfsize

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
