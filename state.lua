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

require 'class'

activestate = nil

function setstate(state)
   if activestate then
      activestate:unload()
   end

   state:load()
   activestate = state
end

State = class()

function State:__init()

end

function State:load()

end

function State:unload()

end

function State:update(dt)

end

function State:draw()

end

function State:keypressed(key, isrepeat)

end

function State:mousepressed(x, y, button)

end

function State:mousereleased(x, y, button)

end
