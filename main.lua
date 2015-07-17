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

require 'board'
require 'piece'

local pieces = {}

local function initrow(start, y)
   local board_dim = BOARD_SIZE / BOARD_SQUARE_SIZE
   for i=0,3 do
      local x = start + i * 2
      table.insert(pieces, Piece(x, y, 1))
      table.insert(pieces, Piece(board_dim - (x - 1), board_dim - (y - 1), 2))
   end
end

function love.load()
   -- add pieces to each team
   initrow(2, 1)
   initrow(1, 2)
   initrow(2, 3)
end

function love.update(dt)
end

function love.draw()
   -- white background
   love.graphics.setBackgroundColor(255, 255, 255)

   -- checkerboard squares
   drawboard()

   -- Agario-style background grid
   love.graphics.setColor(170, 170, 170)

   local wwidth = love.window.getWidth()
   local wheight = love.window.getHeight()
   local gridsize = BOARD_SQUARE_SIZE / 3

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

   -- draw idle pieces in position
   for _,piece in ipairs(pieces) do
      piece:draw()
   end
end
