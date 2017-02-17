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

require 'class'
require 'util'

local socket = require 'socket'

Client = class()

local function iserror(r)
   return #r == 1 and r[1]:startswith('ERR')
end

function Client:__init(host, port)
   self._host = host
   self._port = port
end

function Client:connect()
   self._conn = socket.connect(self._host, self._port)
   if self._conn then
      self._conn:settimeout(2000)
      self:sendline('AGARIO CHECKERS CLIENT')

      if self:recvline() ~= 'AGARIO CHECKERS SERVER' then
         self._conn:close()
         self._conn = nil
      end
   end

   return self._conn ~= nil
end

function Client:disconnect()
   self._conn:sendline('DC')
   self._conn:close()
   self._conn = nil
end

function Client:sendline(s)
   return self._conn:send(s .. '\n')
end

function Client:request(r)
   if not self:sendline(r) then
      return {'ERR SEND'}
   end

   r = {}
   local line = self:recvline()
   while line ~= 'END' do
      if line:sub(1, 3) == 'ERR' then
         return {line}
      end

      table.insert(r, line)
      line = self:recvline()
   end

   return r
end

function Client:recvline()
   local line, err = self._conn:receive()
   return line or ('ERR ' .. err)
end

function Client:setname(name)
   local r = self:request('SETNAME ' .. name)
   return #r == 1 and r[1] == 'Y'
end

function Client:getrooms()
   local r = self:request('GETROOMS')
   if iserror(r) then
      return nil
   end

   local rooms = {}
   for _,line in ipairs(r) do
      line = line:split(' ')
      table.insert(rooms, line[2])
   end

   return rooms
end

function Client:joinroom(room)
   return self:request('JOIN ' .. room)
end

function Client:createroom()
   local r = self:request('MAKEROOM')
   if iserror(r) then
      return false
   end

   return r[1] == 'Y'
end

function Client:update()
   local r = self:request('UPDATE')
   if iserror(r) then
      return nil
   end

   return r
end

function Client:selectpiece(id)
   local r = self:request(string.format('SELECT %d', id))
   if iserror(r) then
      return false
   end

   return r[1] == 'Y'
end

function Client:deselect()
   local r = self:request('DESELECT')
   if iserror(r) then
      return false
   end

   return r[1] == 'Y'
end

function Client:_move(kind, dx, dy)
   local r = self:request(string.format('%s %d %d', kind, dx, dy))
   if iserror(r) then
      return nil
   end

   r = r[1]:split(' ')
   if r[1] ~= 'Y' then
      return false
   end

   return {tonumber(r[2]), tonumber(r[3])}
end

function Client:trymove(dx, dy)
   return self:_move('TRYMOVE', dx, dy)
end

function Client:move(dx, dy)
   return self:_move('MOVE', dx, dy)
end

function Client:trysplit(dx, dy)
   return self:_move('TRYSPLIT', dx, dy)
end

function Client:split(dx, dy)
   return self:_move('SPLIT', dx, dy)
end

function Client:checkwinner()
   local r = self:request('GETWINNER')
   if iserror(r) then
      return nil
   end

   return tonumber(r[1])
end

function Client:getteam()
   local r = self:request('TEAM')
   if iserror(r) then
      return nil
   end

   return tonumber(r[1])
end

function Client:surrender()
   local r = self:request('FORFEIT')
   if iserror(r) then
      return nil
   end

   return r[1] == 'Y'
end
