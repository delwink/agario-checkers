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
local selected = {0, 0}
local turn = 0
local wheight = 0
local wwidth = 0

local function initrow(start, y)
   local board_dim = BOARD_SIZE / boardsqsize()
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

   turn = 1
end

function love.keypressed(key, isrepeat)
   if isrepeat then
      return
   end

   if 'escape' == key then
      love.event.quit()
   end
end

function love.mousepressed(x, y, button)
   if 'l' == button then
      for _,piece in ipairs(pieces) do
	 local c = piece:getrealcoords()
	 local len = c.scale * 128
	 local loc = love.physics.newRectangleShape(len, len)

	 if loc:testPoint(c.x + len/2, c.y + len/2, 0, x, y) then
	    selected = {piece.x, piece.y}
	    break
	 end
      end
   end
end

function love.update(dt)
   wwidth = love.window.getWidth()
   wheight = love.window.getHeight()
end

function love.draw()
   -- white background
   love.graphics.setBackgroundColor(255, 255, 255)

   -- checkerboard squares
   drawboard()

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

   -- draw idle pieces in position
   for _,piece in ipairs(pieces) do
      piece:draw()
   end
end
