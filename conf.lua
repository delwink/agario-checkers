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

function love.conf(t)
   t.identity = 'agario-checkers'
   t.console = false

   t.window = t.window or t.screen
   t.window.title = 'Agario Checkers'
   t.window.resizable = true
   t.window.minwidth = 800
   t.window.minheight = 600
   t.screen = t.screen or t.window

   t.modules.joystick = false
   t.modules.math = false
   t.modules.physics = false
   t.modules.timer = false
end
