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
local selected
local targetspace
local wantsplit
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

local function selectpiece(x, y)
   local space = getspace(x, y)
   for _,piece in ipairs(pieces) do
      if piece.team == turn and space.x == piece.x and space.y == piece.y then
	 return piece
      end
   end

   return nil
end

local function getoccupying(x, y)
   for i,piece in ipairs(pieces) do
      if piece.x == x and piece.y == y then
	 return i
      end
   end
end

local function absorb(o)
   selected:move(pieces[o].x, pieces[o].y)
   selected.size = selected.size + pieces[o].size
   if pieces[o].team == selected.team and pieces[o].king then
      selected.king = true
   end
   table.remove(pieces, o)
end

local function canabsorb(o, sizemod)
   if not sizemod then
      sizemod = 1
   end

   if o and not (selected.team == pieces[o].team
		 or selected.size / sizemod > pieces[o].size) then
      return false
   end

   return true
end

local function singlemove(o)
   if not o then
      o = getoccupying(targetspace.x, targetspace.y)
   end

   if o then
      if canabsorb(o) then
	 absorb(o)
      else
	 return false
      end
   else
      selected:move(targetspace.x, targetspace.y)
   end

   return true
end

local function split()
   local new = Piece(selected.x, selected.y, selected.team)
   selected.size = selected.size / 2
   new.size = selected.size
   table.insert(pieces, new)
   selected = new
end

local function makemove()
   if wantsplit then
      local o = getoccupying(targetspace.x, targetspace.y)
      if math.abs(targetspace.x - selected.x) == 2 then
	 if not canabsorb(o, 2) then
	    return
	 end

	 local space = {x = targetspace.x, y = targetspace.y}
	 local orig = {x = targetspace.x, y = targetspace.y}
	 if space.x < selected.x then
	    space.x = space.x + 1
	 else
	    space.x = space.x - 1
	 end

	 if space.y < selected.y then
	    space.y = space.y + 1
	 else
	    space.y = space.y - 1
	 end

	 o = getoccupying(space.x, space.y)
	 if not canabsorb(o, 2) then
	    return
	 end

	 split()
	 targetspace = space
	 singlemove()
	 targetspace = orig
      elseif not canabsorb(o, 2) then
	 return
      else
	 split()
      end
   end

   if not singlemove() then
      return
   end

   if selected.y == 1 or selected.y == 8 then
      selected.king = true
   end

   selected = nil
   if turn == 1 then
      turn = 2
   else
      turn = 1
   end
end

function love.mousepressed(x, y, button)
   if 'l' == button then
      if not selected then
	 selected = selectpiece(x, y)
      elseif targetspace then
	 makemove()
      end
   elseif 'r' == button then
      selected = nil
      targetspace = nil
   end
end

local function trymove(quad, distance)
   if distance == 2 and not trymove(quad, 1) then
      return nil
   end

   local x, y

   if 1 == quad then
      x = selected.x + distance
      y = selected.y + distance
   elseif 2 == quad then
      x = selected.x - distance
      y = selected.y + distance
   elseif 3 == quad then
      x = selected.x - distance
      y = selected.y - distance
   else
      x = selected.x + distance
      y = selected.y - distance
   end

   if not selected:canmove(x, y) then
      return nil
   end

   return {x=x, y=y}
end

local function getmove()
   if not selected then
      return nil
   end

   local start = getcenter(selected.x, selected.y)
   local mx, my = love.mouse.getX(), love.mouse.getY()
   local quad = getquadrant(mx - start.x, my - start.y)
   if not quad then
      return nil
   end

   if wantsplit then
      local move = trymove(quad, 2)
      if move and trymove(quad, 1) then
	 return move
      end
   end

   return trymove(quad, 1)
end

function love.update(dt)
   wwidth = love.window.getWidth()
   wheight = love.window.getHeight()

   if selected then
      wantsplit = love.keyboard.isDown(' ')
      targetspace = getmove()
   end
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

   if selected then
      love.graphics.setColor(teamcolor(selected.team))

      local spos = getsqpos(selected.x, selected.y)
      local sqsize = boardsqsize()
      drawbox(spos.x, spos.y, sqsize, sqsize)

      if targetspace then
	 local from = getcenter(selected.x, selected.y)
	 local to = getcenter(targetspace.x, targetspace.y)
	 drawarrow(from.x, from.y, to.x, to.y)
      end
   end
end
