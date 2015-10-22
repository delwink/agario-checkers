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
require 'geom'
require 'piece'

local pieces = {}
local selected = nil
local targetspace = nil
local turn = 0
local wheight = 0
local wwidth = 0

local TOO_FAR = 0
local MOVE = 1
local JOIN = 2
local ABSORB = 3
local FEED = 4
local moveactions = {
   {text='Move', color={255, 255, 0}},
   {text='Join', color={0, 0, 255}},
   {text='Absorb', color={0, 255, 0}},
   {text='Feed', color={255, 0, 0}}
}

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

local function selectpiece(x, y)
   local space = getspace(x, y)
   for _,piece in ipairs(pieces) do
      if space.x == piece.x and space.y == piece.y then
	 return piece
      end
   end

   return nil
end

local function even(n)
   return n % 2 == 0
end

local function odd(n)
   return not even(n)
end

local function darkspace(space)
   if odd(space.y) then
      return even(space.x)
   end

   return odd(space.x)
end

local function selectspace(x, y)
   local space = getspace(x, y)
   if space.x < 0 or space.y < 0 or not darkspace(space) then
      return nil
   end

   return space
end

function love.mousepressed(x, y, button)
   if 'l' == button then
      if not selected then
	 selected = selectpiece(x, y)
      else
	 targetspace = selectspace(x, y)
      end
   elseif 'r' == button then
      selected = nil
      targetspace = nil
   end
end

function love.update(dt)
   wwidth = love.window.getWidth()
   wheight = love.window.getHeight()
end

local function getmoveaction(space, x, y)
   return MOVE
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

   local mx, my = love.mouse.getX(), love.mouse.getY()
   if selected then
      love.graphics.setColor(teamcolor(selected.team))

      local spos = getsqpos(selected.x, selected.y)
      local sqsize = boardsqsize()
      drawbox(spos.x, spos.y, sqsize, sqsize)

      if not targetspace then
	 local center = getcenter(selected.x, selected.y)
	 drawarrow(center.x, center.y, mx, my)

	 local mspos = getspace(mx, my)
	 local msqpos = getsqpos(mspos.x, mspos.y)
	 local moveaction = getmoveaction(selected, mx, my)
	 if TOO_FAR == moveaction then
	    love.graphics.setColor(255, 0, 0)
	 else
	    love.graphics.setColor(moveactions[moveaction].color)
	    love.graphics.print(moveactions[moveaction].text, msqpos.x,
				msqpos.y)
	 end

	 drawbox(msqpos.x, msqpos.y, sqsize, sqsize)
      end
   end

   if targetspace then
      love.graphics.setColor(255, 255, 0)

      local c = getsqpos(targetspace.x, targetspace.y)
      local sqsize = boardsqsize()
      drawbox(c.x, c.y, sqsize, sqsize)
   end

   love.graphics.setColor(0, 0, 0)
   love.graphics.printf(string.format("Mouse: %d, %d", mx, my),
			0, 0, wwidth, 'left')

   local spos = getspace(mx, my)
   love.graphics.printf(string.format("Space: %d, %d", spos.x, spos.y),
			0, 0, wwidth, 'right')
end
