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

require 'class'

Button = class()

local defaultfont = love.graphics.getFont()

function Button:__init(x, y, w, h, bg, fg)
   self.x = x
   self.y = y
   self.w = w
   self.h = h
   self.bg = bg
   self.fg = fg

   self.clicked = false
   self.listeners = {}
   self.text = ''
   self.visible = false

   self.font = love.graphics.newFont(self.h * 0.8)
   self.halfheight = self.font:getHeight() / 2
end

function Button:addlistener(listener)
   table.insert(self.listeners, listener)
end

function Button:onpress()
   self.clicked = true
end

function Button:onrelease(x, y)
   if self.clicked then
      self.clicked = false

      if self:contains(x, y) then
	 for _,listener in ipairs(self.listeners) do
	    listener()
	 end
      end
   end
end

function Button:contains(x, y)
   return (x >= self.x and x <= (self.x + self.w)
	      and y >= self.y and y <= (self.y + self.h))
end

function Button:setvisible(b)
   self.visible = b
end

function Button:isvisible()
   return self.visible
end

function Button:settext(text)
   self.text = text
end

function Button:draw()
   if not self.visible then
      return
   end

   local bg = {self.bg[1], self.bg[2], self.bg[3]}
   local mx, my = love.mouse.getPosition()
   if self.clicked and self:contains(mx, my) then
      for i,val in ipairs(bg) do
	 bg[i] = bg[i] - 50
      end
   end

   love.graphics.setColor(bg)
   love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)

   love.graphics.setColor(self.fg)
   love.graphics.rectangle('line', self.x, self.y, self.w, self.h)

   love.graphics.setFont(self.font)
   love.graphics.printf(self.text, self.x,
			(self.y + (self.h / 2)) - self.halfheight,
			self.w, 'center')
   love.graphics.setFont(defaultfont)
end
