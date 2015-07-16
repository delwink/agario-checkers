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

function love.load()
end

function love.update(dt)
end

function love.draw()
   local wwidth = love.window.getWidth()
   local wheight = love.window.getHeight()

   -- white background
   love.graphics.setColor(255, 255, 255)
   love.graphics.rectangle('fill', 0, 0, wwidth, wheight)

   -- black checkerboard squares
   drawboard()

   -- Agario-style background grid
   love.graphics.setColor(170, 170, 170)
   local gridxstart = wwidth / 2
   local gridystart = wheight / 2
   local gridsize = BOARD_SQUARE_SIZE / 3

   local gridxnum = 0
   while gridxstart - gridsize > 0 do
      gridxstart = gridxstart - gridsize
      gridxnum = gridxnum + 1
   end
   gridxnum = gridxnum * 2

   local gridynum = 0
   while gridystart - gridsize > 0 do
      gridystart = gridystart - gridsize
      gridynum = gridynum + 1
   end
   gridynum = gridynum * 2

   for i=0,gridxnum do
      local xpos = gridxstart + i * gridsize
      love.graphics.line(xpos, 0, xpos, wheight)
   end

   for i=0,gridynum do
      local ypos = gridystart + i * gridsize
      love.graphics.line(0, ypos, wwidth, ypos)
   end
end
