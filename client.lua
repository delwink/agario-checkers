--
-- Agario Checkers - Checkers-like game with inspiration from agar.io
-- Copyright (C) 2017 Delwink, LLC
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
      local split = line:split('"')
      local name = split[2]
      split = line:split(' ')
      table.insert(rooms, { split[1], name, split[#split] })
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

   return r[1] == 'Y'
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

function Client:getteam()
   local r = self:request('TEAM')
   if iserror(r) then
      return nil
   end

   return tonumber(r[1])
end

function Client:forfeit()
   local r = self:request('FORFEIT')
   if iserror(r) then
      return nil
   end

   return true
end
