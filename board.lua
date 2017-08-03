--
-- Agario Checkers - Checkers-like game with inspiration from agar.io
-- Copyright (C) 2015-2016 Delwink, LLC
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

BOARD_SIZE = 512
BOARD_SQ_SIZE = BOARD_SIZE / 8

local darkcolor = {0, 0, 0}

function boardsqsize()
   return BOARD_SQ_SIZE
end

function getboardpos()
   local halfsize = BOARD_SIZE / 2
   local xpos = love.graphics.getWidth()/2 - halfsize
   local ypos = love.graphics.getHeight()/2 - halfsize

   return {x=xpos, y=ypos}
end

function getcenter(x, y)
   local bpos = getboardpos()
   local sqsize = boardsqsize()
   local halfsize = sqsize / 2
   local xpos = bpos.x + (x - 1) * sqsize + halfsize
   local ypos = bpos.y + (y - 1) * sqsize + halfsize

   return {x=xpos, y=ypos}
end

local function drawsquare(x, y)
   love.graphics.rectangle('fill', x, y, boardsqsize(), boardsqsize())
end

local function drawrow(start, y)
   local sqsize = boardsqsize()

   for i=0,3 do
      drawsquare(start + i * sqsize * 2, y)
   end
end

function drawboard()
   local boardpos = getboardpos()
   local sqsize = boardsqsize()

   love.graphics.setColor(darkcolor)

   for i=0,3 do
      local ypos = boardpos.y + i * sqsize * 2
      drawrow(boardpos.x + sqsize, ypos)
      drawrow(boardpos.x, ypos + sqsize)
   end
end

function inspace(space, x, y)
   local sqsize = boardsqsize()
   return (x >= space.x and y >= space.y and x <= space.x + sqsize
	      and y <= space.y + sqsize)
end

function getsqpos(x, y)
   local bpos = getboardpos()
   local sqsize = boardsqsize()
   x = x - 1
   y = y - 1

   return {x=bpos.x + (x * sqsize), y=bpos.y + (y * sqsize)}
end

function onboard(x, y)
   local bpos = getboardpos()
   return (x >= bpos.x and x <= bpos.x + BOARD_SIZE
	      and y >= bpos.y and y <= bpos.y + BOARD_SIZE)
end

function getspace(x, y)
   local bpos = getboardpos()
   local sqsize = boardsqsize()

   if not onboard(x, y) then
      return {x=-1, y=-1}
   end

   return {x=math.floor((x - bpos.x) / sqsize) + 1,
	   y=math.floor((y - bpos.y) / sqsize) + 1}
end
