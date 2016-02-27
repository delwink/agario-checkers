--
--  Agario Checkers - Checkers-like game with inspiration from agar.io
--  Copyright (C) 2016 Delwink, LLC
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

require 'state'
require 'gamestate'
require 'mainmenustate'

function love.load()
   love.graphics.setBackgroundColor(255, 255, 255)
   setstate(MainMenuState())
end

function love.keypressed(key, isrepeat)
   activestate:keypressed(key, isrepeat)
end

local function normalizemousebutton(button)
   if button == 'l' then
      return 1
   end

   if button == 'r' then
      return 2
   end

   return button
end

function love.mousepressed(x, y, button)
   activestate:mousepressed(x, y, normalizemousebutton(button))
end

function love.mousereleased(x, y, button)
   activestate:mousereleased(x, y, normalizemousebutton(button))
end

function love.update(dt)
   activestate:update(dt)
end

function love.draw()
   activestate:draw()
end
