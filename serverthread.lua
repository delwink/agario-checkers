--
--  Agario Checkers - Checkers-like game with inspiration from agar.io
--  Copyright (C) 2017 Delwink, LLC
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
require 'class'
require 'piece'

local socket = require 'socket'
local finished = false

Server = class()

function Server:__init(server, socks, comm)
   self._srv = server
   self._socks = socks
   self._names = { 'Player 1', 'Player 2' }
   self._queue = { {}, {} }
   self._comm = comm

   self:_resetgame()
end

function Server:_cleanup()
   for _,sock in ipairs(self._socks) do
      sock:send('SHUTDOWN\nEND\n')
      sock:close()
   end

   self._srv:close()
end

function Server:_initrow(start, y)
   local board_dim = BOARD_SIZE / boardsqsize()
   for i=0,3 do
      local x = start + i * 2
      table.insert(self._pieces, Piece(x, y, 1))
      table.insert(self._pieces, Piece(board_dim - (x - 1),
				       board_dim - (y - 1),
				       2))
   end
end

function Server:_resetgame()
   self._pieces = {}
   self:_initrow(2, 1)
   self:_initrow(1, 2)
   self:_initrow(2, 3)

   self._turn = 1
   self._selected = nil
   self._targetspace = nil
   self._wantsplit = false
   self._winner = nil
end

function Server:_toggleturn()
   if self._turn == 1 then
      self._turn = 2
   else
      self._turn = 1
   end
end

function Server:run()
   local err = nil

   while true do

   end

   self:_cleanup()
   return err
end

local function respondlocal(str, comm, server, socks)
   if str == 'quit' then
      for _,sock in ipairs(socks) do
         sock:send('SHUTDOWN\nEND\n')
         sock:close()
      end

      server:close()
      finished = true
   end
end

local function servermain()
   local comm = love.thread.getChannel('server')
   comm:supply('ready')

   local server = socket.bind('*', comm:demand())
   if not server then
      comm:supply('fail bind')
      return
   end

   local ip, port = server:getsockname()
   comm:supply(string(ip) .. ' ' .. string(port))

   server:settimeout(1000)
   local socks = {}
   while #socks < 2 do
      local sock = server:accept()
      if sock then
         sock:settimeout(1000)
         local line, err = sock:receive()
         if line then
            if line == 'AGARIO CHECKERS CLIENT' then
               sock:send('AGARIO CHECKERS SERVER\n')
            else
               err = 'protocol'
            end
         end

         if err then
            for _,sock in ipairs(socks) do
               sock:send('SHUTDOWN\nEND\n')
               sock:close()
            end

            server:close()
            comm:supply('err ' .. err)
            return
         end
      end

      local str = comm:pop()
      if str then
         respondlocal(str, comm, server, socks)
         if finished then
            return
         end
      end
   end

   server = Server(server, socks, comm)
   local err = server:run()

   if err then
      comm:supply('err ' .. err)
   else
      comm:supply('done')
   end
end

servermain()
