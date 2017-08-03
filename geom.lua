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

local RIGHT_ANGLE = math.pi / 2
local DEG45 = math.pi / 4

function drawbox(x, y, w, h)
   love.graphics.setLineWidth(3)

   love.graphics.line(
      x, y,
      x + w, y,
      x + w, y + h,
      x, y + h,
      x, y
   )

   love.graphics.setLineWidth(1)
end

function getquadrant(deltax, deltay)
   if deltax > 0 then
      if deltay > 0 then
	 return 1
      else
	 return 4
      end
   else
      if deltay > 0 then
	 return 2
      else
	 return 3
      end
   end
end

function getangle(x1, y1, x2, y2)
   local deltax = x2 - x1
   local deltay = y2 - y1

   if 0 == deltax then
      if deltay < 0 then
	 return RIGHT_ANGLE
      else
	 return 3 * RIGHT_ANGLE
      end
   elseif 0 == deltay then
      if deltax < 0 then
	 return 2 * RIGHT_ANGLE
      else
	 return 0
      end
   end

   local angle = -math.abs(math.atan(deltay / deltax))

   local quad = getquadrant(deltax, deltay)
   if 2 == quad then
      angle = math.pi - angle
   elseif 3 == quad then
      angle = math.pi + angle
   elseif 4 == quad then
      angle = -angle
   end

   while angle < 0 do
      angle = angle + (2 * math.pi)
   end

   return angle
end

function drawlineangle(x, y, length, angle)
   local change = angle + RIGHT_ANGLE -- use real angles
   love.graphics.setLineWidth(3)
   love.graphics.translate(x, y)
   love.graphics.rotate(-change)
   love.graphics.line(0, 0, 0, length)
   love.graphics.rotate(change)
   love.graphics.translate(-x, -y)
   love.graphics.setLineWidth(1)
end

function drawarrow(x1, y1, x2, y2)
   local angle = getangle(x1, y1, x2, y2)
   love.graphics.setLineWidth(3)
   love.graphics.line(x1, y1, x2, y2)
   love.graphics.setLineWidth(1)
   local change = DEG45 * 3
   drawlineangle(x2, y2, 5, angle - change)
   drawlineangle(x2, y2, 5, angle + change)
end
