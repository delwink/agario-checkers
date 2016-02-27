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

require 'board'
require 'button'
require 'geom'
require 'piece'
require 'state'

local authorlogo = love.graphics.newImage('res/author.png')
local mainfont = love.graphics.getFont()
local winfont = love.graphics.newFont(25)

local function spaceisdown()
   return love.keyboard.isDown(' ') or love.keyboard.isDown('space')
end

local function resetgamestate()
   if activestate:is_a(GameState) then
      activestate:_resetgame()
   end
end

GameState = class(State)

function GameState:__init()
   self:_resetgame()

   local resetbutton = Button(5, 5, 50, 18, {245, 245, 245}, {0, 0, 0})
   resetbutton:settext('Reset')
   resetbutton:setvisible(true)
   resetbutton:addlistener(resetgamestate)

   self._buttons = { resetbutton }
end

function GameState:_initrow(start, y)
   local board_dim = BOARD_SIZE / boardsqsize()
   for i=0,3 do
      local x = start + i * 2
      table.insert(self._pieces, Piece(x, y, 1))
      table.insert(self._pieces, Piece(board_dim - (x - 1),
				       board_dim - (y - 1),
				       2))
   end
end

function GameState:_resetgame()
   self._pieces = {}
   self:_initrow(2, 1)
   self:_initrow(1, 2)
   self:_initrow(2, 3)

   self._turn = 1
   self._selected = nil
   self._targetspace = nil
   self._wantsplit = false
   self._winner = 0
end

function GameState:_checkwinner()
   local numpieces = {0, 0}
   local biggest = nil
   for _,piece in ipairs(self._pieces) do
      numpieces[piece.team] = numpieces[piece.team] + 1

      if not biggest or piece.size > biggest.size then
	 biggest = piece
      end
   end

   if numpieces[1] == 0 then
      self._winner = 2
   elseif numpieces[2] == 0 then
      self._winner = 1
   elseif (numpieces[1] == 1 and numpieces[2] == 1
	   and self._pieces[1].size ~= self._pieces[2].size) then
      self._winner = biggest.team
   else
      self._winner = 0
   end
end

function GameState:_trymove(quad, distance)
   if distance == 2 and not self:_trymove(quad, 1) then
      return nil
   end

   local x, y

   if quad == 1 then
      x = self._selected.x + distance
      y = self._selected.y + distance
   elseif quad == 2 then
      x = self._selected.x - distance
      y = self._selected.y + distance
   elseif quad == 3 then
      x = self._selected.x - distance
      y = self._selected.y - distance
   else
      x = self._selected.x + distance
      y = self._selected.y - distance
   end

   if not self._selected:canmove(x, y) then
      return nil
   end

   return {x=x, y=y}
end

function GameState:_getmove()
   local start = getcenter(self._selected.x, self._selected.y)
   local mx, my = love.mouse.getX(), love.mouse.getY()
   local quad = getquadrant(mx - start.x, my - start.y)
   if not quad then
      return nil
   end

   if self._wantsplit then
      local move = self:_trymove(quad, 2)
      if move then
	 return move
      end
   end

   return self:_trymove(quad, 1)
end

function GameState:update(dt)
   self:_checkwinner()
   if self._winner ~= 0 then
      return
   end

   if self._selected then
      self._wantsplit = spaceisdown()
      self._targetspace = self:_getmove()
   end
end

function GameState:draw()
   local wwidth = love.graphics.getWidth()
   local wheight = love.graphics.getHeight()

   -- white background
   love.graphics.setBackgroundColor(255, 255, 255)

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

   -- checkerboard squares
   drawboard()

   -- draw author logo
   love.graphics.setColor(0, 0, 0)
   love.graphics.draw(authorlogo, 0, wheight - authorlogo:getHeight()/2, 0,
		      0.5, 0.5)

   -- draw idle pieces in position
   for _,piece in ipairs(self._pieces) do
      piece:draw()
   end

   -- draw box around selected piece
   if self._selected then
      love.graphics.setColor(teamcolor(self._selected.team))

      local spos = getsqpos(self._selected.x, self._selected.y)
      local sqsize = boardsqsize()
      drawbox(spos.x, spos.y, sqsize, sqsize)

      -- draw arrow to attempted move
      if self._targetspace then
	 local from = getcenter(self._selected.x, self._selected.y)
	 local to = getcenter(self._targetspace.x, self._targetspace.y)
	 drawarrow(from.x, from.y, to.x, to.y)
      end
   end

   -- draw all buttons
   for _,button in ipairs(self._buttons) do
      button:draw()
   end

   -- indicate winner
   if self._winner ~= 0 then
      local winstr = string.format('Player %d wins!', self._winner)
      local bpos = getboardpos()
      local y = winfont:getHeight() + 12
      love.graphics.setFont(winfont)
      love.graphics.printf(winstr, bpos.x, bpos.y - y, BOARD_SIZE, 'center')
      love.graphics.setFont(mainfont)
   end
end

function GameState:keypressed(key, isrepeat)
   if isrepeat then
      return
   end

   if key == 'escape' then
      love.event.quit()
   end
end

function GameState:_selectpiece(x, y)
   local space = getspace(x, y)
   for _,piece in ipairs(self._pieces) do
      if (piece.team == self._turn
	  and space.x == piece.x and space.y == piece.y) then
	 return piece
      end
   end

   return nil
end

function GameState:_getoccupying(x, y)
   for i,piece in ipairs(self._pieces) do
      if piece.x == x and piece.y == y then
	 return i
      end
   end
end

function GameState:_canabsorb(o, sizemod)
   if not sizemod then
      sizemod = 1
   end

   if o and not (self._selected.team == self._pieces[o].team
		 or self._selected.size / sizemod > self._pieces[o].size) then
      return false
   end

   return true
end

function GameState:_absorb(o)
   self._selected:move(self._pieces[o].x, self._pieces[o].y)
   self._selected.size = self._selected.size + self._pieces[o].size

   if self._pieces[o].team == self._selected.team and self._pieces[o].king then
      self._selected.king = true
   end

   table.remove(self._pieces, o)
end

function GameState:_singlemove(o)
   if not o then
      o = self:_getoccupying(self._targetspace.x, self._targetspace.y)
   end

   if o then
      if self:_canabsorb(o) then
	 self:_absorb(o)
      else
	 return false
      end
   else
      self._selected:move(self._targetspace.x, self._targetspace.y)
   end

   return true
end

function GameState:_split()
   local new = Piece(self._selected.x, self._selected.y, self._selected.team)
   self._selected.size = self._selected.size / 2
   new.size = self._selected.size
   table.insert(self._pieces, new)
   self._selected = new
end

function GameState:_makemove()
   if self._wantsplit then
      if self._selected.size < 10 then
	 return
      end

      local o = self:_getoccupying(self._targetspace.x, self._targetspace.y)
      if math.abs(self._targetspace.x - self._selected.x) == 2 then
	 if not self:_canabsorb(o, 2) then
	    return
	 end

	 local space = {x = self._targetspace.x, y = self._targetspace.y}
	 local orig = {x = space.x, y = space.y}
	 if space.x < self._selected.x then
	    space.x = space.x + 1
	 else
	    space.x = space.x - 1
	 end

	 if space.y < self._selected.y then
	    space.y = space.y + 1
	 else
	    space.y = space.y - 1
	 end

	 o = self:_getoccupying(space.x, space.y)
	 if not self:_canabsorb(o, 2) then
	    return
	 end

	 self:_split()
	 self._targetspace = space
	 self:_singlemove()
	 self._targetspace = orig
      elseif not self:_canabsorb(o, 2) then
	 return
      else
	 self:_split()
      end
   end

   if not self:_singlemove() then
      return
   end

   if ((self._selected.y == 1 and self._selected.team == 2)
      or (self._selected.y == 8 and self._selected.team == 1)) then
      self._selected.king = true
   end

   self._selected = nil
   if self._turn == 1 then
      self._turn = 2
   else
      self._turn = 1
   end
end

function GameState:mousepressed(x, y, button)
   if button == 1 or button == 'l' then
      for _,button in ipairs(self._buttons) do
	 if button:isvisible() and button:contains(x, y) then
	    button:onpress()
	    return
	 end
      end

      if self._winner ~= 0 then
	 return
      end

      if not self._selected then
	 self._selected = self:_selectpiece(x, y)
      elseif self._targetspace then
	 self:_makemove()
      end
   elseif button == 2 or button == 'r' then
      self._selected = nil
      self._targetspace = nil
   end
end

function GameState:mousereleased(x, y, button)
   if button == 'l' or button == 1 then
      for _,button in ipairs(self._buttons) do
	 if button:isvisible() then
	    button:onrelease(x, y)
	 end
      end
   end
end
