--
-- Agario Checkers - Checkers-like game with inspiration from agar.io
-- Copyright (C) 2015-2017 Delwink, LLC
--
-- Redistributions, modified or unmodified, in whole or in part, must retain
-- applicable copyright or other legal privilege notices, these conditions, and
-- the following license terms and disclaimer.  Subject to these conditions,
-- the holder(s) of copyright or other legal privileges, author(s) or
-- assembler(s), and contributors of this work hereby grant to any person who
-- obtains a copy of this work in any form:
--
-- 1. Permission to reproduce, modify, distribute, publish, sell, sublicense,
-- use, and/or otherwise deal in the licensed material without restriction.
--
-- 2. A perpetual, worldwide, non-exclusive, royalty-free, irrevocable patent
-- license to reproduce, modify, distribute, publish, sell, use, and/or
-- otherwise deal in the licensed material without restriction, for any and all
-- patents:
--
--     a. Held by each such holder of copyright or other legal privilege,
--     author or assembler, or contributor, necessarily infringed by the
--     contributions alone or by combination with the work, of that privilege
--     holder, author or assembler, or contributor.
--
--     b. Necessarily infringed by the work at the time that holder of
--     copyright or other privilege, author or assembler, or contributor made
--     any contribution to the work.
--
-- NO WARRANTY OF ANY KIND IS IMPLIED BY, OR SHOULD BE INFERRED FROM, THIS
-- LICENSE OR THE ACT OF DISTRIBUTION UNDER THE TERMS OF THIS LICENSE,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR
-- A PARTICULAR PURPOSE, AND NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS,
-- ASSEMBLERS, OR HOLDERS OF COPYRIGHT OR OTHER LEGAL PRIVILEGE BE LIABLE FOR
-- ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN ACTION OF CONTRACT, TORT,
-- OR OTHERWISE ARISING FROM, OUT OF, OR IN CONNECTION WITH THE WORK OR THE USE
-- OF OR OTHER DEALINGS IN THE WORK.
--

require 'class'

local defaultfont = love.graphics.getFont()

local function normalizedim(d)
   if type(d) ~= 'function' then
      return function(self) return d end
   end

   return d
end

GuiComponent = class()

function GuiComponent:__init(x, y, w, h, bg, fg, state)
   self.x = normalizedim(x)
   self.y = normalizedim(y)
   self.w = normalizedim(w)
   self.h = normalizedim(h)

   self.bg = bg
   self.fg = fg
   self.state = state

   self.clicked = false
   self.clicklisteners = {}
   self.text = ''
   self.visible = false
end

function GuiComponent:addclicklistener(listener)
   table.insert(self.clicklisteners, listener)
end

function GuiComponent:_triggerclicklisteners()
   for _,listener in ipairs(self.clicklisteners) do
      listener()
   end
end

function GuiComponent:onpress()
   self.clicked = true
end

function GuiComponent:onrelease(x, y)
   if self.clicked then
      self.clicked = false

      if self:contains(x, y) then
         self:_triggerclicklisteners()
      end
   end
end

function GuiComponent:onkey(key)

end

function GuiComponent:contains(x, y)
   return (x >= self:x() and x <= (self:x() + self:w())
	      and y >= self:y() and y <= (self:y() + self:h()))
end

function GuiComponent:setvisible(b)
   self.visible = b
end

function GuiComponent:isvisible()
   return self.visible
end

function GuiComponent:settext(text)
   self.text = text
end

function GuiComponent:_halfheight()
   return self:h() / 2
end

Button = class(GuiComponent)

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
   love.graphics.rectangle('fill', self:x(), self:y(), self:w(), self:h())

   love.graphics.setColor(self.fg)
   love.graphics.rectangle('line', self:x(), self:y(), self:w(), self:h())

   if not self._lasth or self:h() ~= self._lasth then
      self._font = love.graphics.newFont(self:h() * 0.8)
      self._lasth = self:h()
   end

   love.graphics.setFont(self._font)
   love.graphics.printf(self.text, self:x(),
			(self:y() + (self:h() / 2)) - self:_halfheight(),
			self:w(), 'center')
   love.graphics.setFont(defaultfont)
end

TextField = class(GuiComponent)

function TextField:__init(x, y, w, h, bg, fg, state)
   self._base.__init(self, x, y, w, h, bg, fg, state)
   self._placeholdertext = ''

   self:addclicklistener(function()
         self.state._activecomponent = self
   end)
end
