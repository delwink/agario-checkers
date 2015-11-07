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

   self.listeners = {}
   self.text = ''
   self.visible = false

   self.font = love.graphics.newFont(self.h * 0.8)
--   while self.font:getHeight() < self.h do
--      self.font:setLineHeight(self.font:getLineHeight() + 1)
--   end
   --self.font:setLineHeight(self.font:getLineHeight() - 1)
   self.halfheight = self.font:getHeight() / 2
end

function Button:addlistener(listener)
   table.insert(self.listeners, listener)
end

function Button:onclick()
   for _,listener in ipairs(self.listeners) do
      listener()
   end
end

function Button:isclick(x, y)
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

   love.graphics.setColor(self.bg)
   love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)

   love.graphics.setColor(self.fg)
   love.graphics.rectangle('line', self.x, self.y, self.w, self.h)

   love.graphics.setFont(self.font)
   love.graphics.printf(self.text, self.x,
			(self.y + (self.h / 2)) - self.halfheight,
			self.w, 'center')
   love.graphics.setFont(defaultfont)
end