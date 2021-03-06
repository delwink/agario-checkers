--
-- Agario Checkers - Checkers-like game with inspiration from agar.io
-- Copyright (C) 2015-2018 Delwink, LLC
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
require 'util'

local defaultfont = love.graphics.getFont()

Gui = class()

function Gui:__init()
   self._components = {}
   self._activecomponent = nil
end

function Gui:addcomponent(component)
   table.insert(self._components, component)
   component.gui = self
end

function Gui:mousepressed(x, y, button)
   local ret = false

   for _,component in ipairs(self._components) do
      if component:mousepressed(x, y, button) then
         ret = true
         self._activecomponent = component
      end
   end

   if not ret then
      self._activecomponent = nil
   end

   return ret
end

function Gui:mousereleased(x, y, button)
   local ret = false

   for _,component in ipairs(self._components) do
      if component:mousereleased(x, y, button) then
         ret = true
      end
   end

   return ret
end

function Gui:textinput(c)
   if self._activecomponent and self._activecomponent.texteditable then
      self._activecomponent:textinput(c)
      return true
   end

   return false
end

function Gui:keypressed(key, isrepeat)
   for _,component in ipairs(self._components) do
      if component:keypressed(key, isrepeat) then
         return true
      end
   end

   return false
end

function Gui:draw()
   for _,component in ipairs(self._components) do
      component:draw()
   end
end

GuiComponent = class()

function GuiComponent:__init(x, y, w, h, bg, fg)
   self.x = functionize(x)
   self.y = functionize(y)
   self.w = functionize(w)
   self.h = functionize(h)

   self.bg = functionize(bg)
   self.fg = functionize(fg)

   self.clicked = {}
   self.clicklisteners = {}
   self.text = ''
   self.texteditable = false
   self.visible = false
end

function GuiComponent:font()
   if not self._lasth or self:h() ~= self._lasth then
      self._font = love.graphics.newFont(self:h() * 0.8)
      self._lasth = self:h()
   end

   return self._font
end

function GuiComponent:draw()
   if not self.visible then
      return false
   end

   return true
end

function GuiComponent:drawbox()
   love.graphics.setColor(self:bg())
   love.graphics.rectangle('fill', self:x(), self:y(), self:w(), self:h())

   love.graphics.setColor(self:fg())
   love.graphics.rectangle('line', self:x(), self:y(), self:w(), self:h())
end

function GuiComponent:addclicklistener(listener)
   table.insert(self.clicklisteners, listener)
end

function GuiComponent:_triggerclicklisteners(x, y, button)
   for _,listener in ipairs(self.clicklisteners) do
      listener(x, y, button)
   end
end

function GuiComponent:mousepressed(x, y, button)
   self.clicked[button] = self.visible and self:contains(x, y)
   return self.clicked[button]
end

function GuiComponent:mousereleased(x, y, button)
   if self.clicked[button] then
      self.clicked[button] = false

      if self:contains(x, y) then
         self:_triggerclicklisteners(x, y, button)
      end
   end
end

function GuiComponent:keypressed(key, isrepeat)

end

function GuiComponent:contains(x, y)
   return (x >= self:x()
              and x <= (self:x() + self:w())
	      and y >= self:y()
              and y <= (self:y() + self:h()))
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

function GuiComponent:textinput(c)

end

Button = class(GuiComponent)

function Button:__init(x, y, w, h, bg, fg)
   self._base.__init(self, x, y, w, h, bg, fg)

   self._origbg = self.bg
   self.bg = function()
      local bg = { unpack(self:_origbg()) }
      local mx, my = love.mouse.getPosition()
      if self.clicked[1] and self:contains(mx, my) then
         for i,val in ipairs(bg) do
            bg[i] = bg[i] - 50
         end
      end

      return bg
   end
end

function Button:draw()
   if not self._base.draw(self) then
      return false
   end

   self:drawbox()

   love.graphics.setFont(self:font())
   love.graphics.printf(self.text, self:x(), self:y(), self:w(), 'center')
   love.graphics.setFont(defaultfont)

   return true
end

TextField = class(GuiComponent)

function TextField:__init(x, y, w, h, bg, fg)
   self._base.__init(self, x, y, w, h, bg, fg)
   self.texteditable = true

   self._scrollindex = 0
end

function TextField:draw()
   if not self._base.draw(self) then
      return false
   end

   self:drawbox()

   local disptext = self.text:sub(self._scrollindex, self.text:len())
   disptext = disptext:fitwidth(self:w() * 0.95, self.font())

   local textx = self:x() + self:w()*0.05
   local texty = self:y() + self:h()/2 - self:font():getHeight()/2

   love.graphics.setFont(self:font())
   love.graphics.print(self.text, textx, texty)
   love.graphics.setFont(defaultfont)

   return true
end
