--
--  Agario Checkers - Checkers-like game with inspiration from agar.io
--  Copyright (C) 2016-2017 Delwink, LLC
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

require 'button'

local function entergamestate()
   setstate(GameState())
end

MainMenuState = class(State)

local function dynbuttonx(self)
   return (love.graphics.getWidth() / 2) - (self:w() / 2)
end

local function dynbuttonw(self)
   return love.graphics.getWidth() - 400
end

local bheight = 50

function MainMenuState:_nexty()
   return 180 + (#self._buttons * (bheight + 10))
end

function MainMenuState:_addbutton(text, listeners)
   local btn = Button(dynbuttonx, self:_nexty(), dynbuttonw, bheight,
                      {245, 245, 245}, {0, 0, 0})
   btn:settext(text)
   btn:setvisible(true)

   if listeners then
      for _,listener in ipairs(listeners) do
         btn:addlistener(listener)
      end
   end

   table.insert(self._buttons, btn)

   return btn
end

function MainMenuState:__init()
   self._base.__init(self)
   self:_addbutton('Local Game', {entergamestate})
   self:_addbutton('Host TCP/IP Game')
   self:_addbutton('Join TCP/IP Game')
   self:_addbutton('Quit', {love.event.quit})
end

function MainMenuState:keypressed(key, isrepeat)
   if key == 'escape' then
      love.event.quit()
   end
end
