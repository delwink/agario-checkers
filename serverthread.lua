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
require 'geom'
require 'piece'
require 'util'

local socket = require 'socket'
local finished = false

local AFFIRMATIVE = 'Y\nEND\n'
local NEGATIVE = 'N\nEND\n'
local ERR_ARGNUM = 'ERR ARGNUM\nEND\n'
local ERR_SYNTAX = 'ERR SYNTAX\nEND\n'

Server = class()

function Server:__init(server, socks, comm)
   self._srv = server
   self._socks = socks
   self._names = { 'Player 1', 'Player 2' }
   self._rooms = { 1, 0 }
   self._queue = { {}, {} }
   self._updatequeue = { {}, {} }
   self._comm = comm
   self._done = false

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

   self._updatequeue[1] = { 'CLEARBOARD' }
   self._updatequeue[2] = { 'CLEARBOARD' }
   for i,piece in ipairs(self._pieces) do
      piece.id = i

      for _,queue in ipairs(self._updatequeue) do
         table.insert(queue, 'PIECE ' .. i .. ' ' .. piece.x .. ' ' .. piece.y
                         .. ' ' .. piece.team)
      end
   end

   self._turn = 1
   self._selected = nil
   self._targetspace = nil
   self._winner = nil
end

function Server:_toggleturn()
   if self._turn == 1 then
      self._turn = 2
   else
      self._turn = 1
   end
end

function Server:_getoccupying(x, y)
   for _,piece in ipairs(self._pieces) do
      if piece.x == x and piece.y == y then
	 return piece
      end
   end
end

function Server:_trymove(quad, distance, sizemod)
   if not sizemod then
      sizemode = 1
   end

   local step1
   if distance == 2 then
      step1 = self._trymove(quad, 1, sizemod)
      if not step1 then
         return nil
      end
   end

   local x, y

   if quad == 1 then
      x = self._selected.x + distance
      y = self._selected.y + distance
   elseif quad == 2 then
      x = self._selected.x - distance
      y = self._selected.y + distance
   elseif quad == 3 then
      x = self._selected.x - distance
      y = self._selected.y - distance
   else
      x = self._selected.x + distance
      y = self._selected.y - distance
   end

   if not self._selected:canmove(x, y) then
      return nil
   end

   local newsize = self._selected.size + sizemod
   if distance == 2 then
      local o = self._getoccupying(step1.x, step1.y)
      if o then
         newsize = newsize + o.size
      end
   end

   local o = self:_getoccupying(x, y)
   if o and o.team ~= self._selected.team and o.size >= newsize then
      return nil
   end

   return {x=x, y=y}
end

function Server:_getmove(dx, dy, wantsplit)
   local quad = getquadrant(dx, dy)
   if not quad then
      return nil
   end

   if wantsplit then
      if self._selected.size < 10 then
         return nil
      end

      return self:_trymove(quad, 2, -self._selected.size / 2)
   end

   return self:_trymove(quad, 1)
end

function Server:_sendall(msg)
   for _,sock in ipairs(self._socks) do
      sock:send(msg)
   end
end

function Server:_process()
   local other = 2
   for this,queue in ipairs(self._queue) do
      for _,line in ipairs(queue) do
         if line == 'DC' then
            self:_sendall('SHUTDOWN\nEND\n')
            self._done = true
            return
         elseif line:startswith('SETNAME') then
            line = line:split(' ')
            if #line < 2 then
               self._socks[this]:send(ERR_ARGNUM)
               break
            end

            local name = table.concat(line, ' ', 2)
            if name == self._names[other] then
               self._socks[this]:send('ERR NAMETAKEN\nEND\n')
            elseif #name > 16 then
               self._socks[this]:send('ERR NAMELEN\nEND\n')
            elseif name:find('"') then
               self._socks[this]:send('ERR NAMECHAR\nEND\n')
            else
               self._names[this] = name
               self._socks[this]:send(AFFIRMATIVE)
            end
         elseif line == 'GETROOMS' then
            local players = 1
            if self._rooms[2] == 1 then
               players = 2
            end

            self._socks[this]:send('1 "' .. self._names[1] .. '" '
                                      .. players .. '\nEND\n')
         elseif line:startswith('JOIN') then
            line = line:split(' ')
            if #line ~= 2 then
               self._socks[this]:send(ERR_ARGNUM)
               break
            end

            if line[2] ~= '1' then
               self._socks[this]:send('ERR ROOMNUM\nEND\n')
            else
               self._rooms[this] = 1
               self._socks[this]:send('FOE "' .. self._names[other]
                                         .. '"\nEND\n')
               self._socks[other]:send('FOE "' .. self._names[this]
                                          .. '"\nEND\n')
            end
         elseif line == 'MAKEROOM' then
            self._socks[this]:send(NEGATIVE)
         elseif line == 'TEAM' then
            self._socks[this]:send(this .. '\nEND\n')
         elseif line:startswith('SELECT') then
            if self._turn ~= this then
               self._socks[this]:send(NEGATIVE)
               break
            end

            line = line:split(' ')
            if #line ~= 2 then
               self._socks[this]:send(ERR_ARGNUM)
               break
            end

            local i = tonumber(line[2])
            if not i then
               self._socks[this]:send(ERR_SYNTAX)
            elseif self._pieces[i].team ~= this then
               self._socks[this]:send(NEGATIVE)
            else
               self._selected = self._pieces[i]
               self._socks[this]:send(AFFIRMATIVE)

               for _,queue in ipairs(self._updatequeue) do
                  queue:insert('SELECTED ' .. i)
               end
            end
         elseif line == 'DESELECT' then
            if self._turn ~= this then
               self._socks[this]:send(NEGATIVE)
            else
               self._selected = nil
               self._socks[this]:send(AFFIRMATIVE)

               for _,queue in ipairs(self._updatequeue) do
                  table.insert(queue, 'DESELECTED')
               end
            end
         elseif (line:startswith('TRYMOVE')
                    or line:startswith('TRYSPLIT')
                    or line:startswith('MOVE')
                    or line:startswith('SPLIT')) then
            line = line:split(' ')
            if self._turn ~= this or not self._selected then
               self._socks[this]:send(NEGATIVE)
            elseif #line ~= 3 then
               self._socks[this]:send(ERR_ARGNUM)
            else
               local dx = tonumber(line[2])
               local dy = tonumber(line[3])

               if not dx or not dy then
                  self._socks[this]:send(ERR_SYNTAX)
               else
                  local split = line[1] == 'TRYSPLIT' or line[1] == 'SPLIT'
                  local move = self:_getmove(dx, dy, split)
                  if not move then
                     self._socks[this]:send(NEGATIVE)
                     break
                  end

                  self._socks[this]:send(
                     table.concat({'Y', move.x, move.y, 'END'}, '\n'))

                  for _,queue in ipairs(self._updatequeue) do
                     table.insert(queue, line[1] .. ' ' .. self._selected.id
                                     .. ' ' move.x .. ' ' .. move.y)

                     if not line[1]:startswith('TRY') then
                        table.insert(queue, 'DESELECTED')
                     end
                  end
               end
            end
         elseif line == 'FORFEIT' then
            self._sendall('FORFEIT ' .. this .. '\nSHUTDOWN\nEND\n')
            self._done = true
            return
         elseif line == 'UPDATE' then
            table.insert(self._updatequeue[this], 'END')
            self._socks[this]:send(table.concat(self._updatequeue, '\n'))
            self._updatequeue[this] = {}
         else
            self._socks[this]:send('ERR COMMAND\nEND\n')
         end
      end

      self._queue[i] = {}
      other = 1
   end
end

function Server:run()
   local err = nil

   while not self._done do
      local recvable, _, err = socket.select(self._socks, {}, 1000)

      for _,r in ipairs(recvable) do
         if r == self._socks[1] then
            table.insert(self._queue[1], r:recv())
         else
            table.insert(self._queue[2], r:recv())
         end
      end

      self:_process()
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
