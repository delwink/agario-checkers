--
-- Agario Checkers - Checkers-like game with inspiration from agar.io
-- Copyright (C) 2016-2018 Delwink, LLC
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

require 'gui'

MainMenuState = class(State)

local function dynbuttonx(self)
   return (love.graphics.getWidth() / 2) - (self:w() / 2)
end

local function dynbuttonw(self)
   return love.graphics.getWidth() - 400
end

local bheight = 50

function MainMenuState:_nexty()
   return 180 + (#self._gui._components * (bheight + 10))
end

function MainMenuState:_addbutton(text, listeners)
   local btn = Button(dynbuttonx, self:_nexty(), dynbuttonw, bheight,
                      {245, 245, 245}, {0, 0, 0})
   btn:settext(text)
   btn:setvisible(true)

   if listeners then
      for _,listener in ipairs(listeners) do
         btn:addclicklistener(listener)
      end
   end

   self._gui:addcomponent(btn)

   return btn
end

function MainMenuState:__init()
   self._base.__init(self)
   self:_addbutton('Local Game', {function() setstate(GameState()) end})
   self:_addbutton('Host TCP/IP Game')
   self:_addbutton('Join TCP/IP Game')
   self:_addbutton('Quit', {love.event.quit})
end

function MainMenuState:keypressed(key, isrepeat)
   if key == 'escape' and not isrepeat then
      love.event.quit()
   end
end
