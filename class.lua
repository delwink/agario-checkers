--[[

Copyright (C) 2015 Delwink, LLC

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED “AS IS” AND ISC DISCLAIMS ALL WARRANTIES WITH REGARD
TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL ISC BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
SOFTWARE.

--]]

function class(base, __init)
   local c = {}

   if not __init and type(base) == 'function' then
      __init = base
      base = nil
   elseif type(base) == 'table' then
      for i,v in pairs(base) do
         c[i] = v
      end

      c._base = base
   end

   c.__index = c

   local mt = {}
   mt.__call = function(class_tbl, ...)
      local obj = {}
      setmetatable(obj, c)

      if class_tbl.__init then
	 class_tbl.__init(obj, ...)
      else 
	 if base and base.__init then
	    base.__init(obj, ...)
	 end
      end

      return obj
   end

   c.__init = __init
   c.is_a = function(self, klass)
      local m = getmetatable(self)
      while m do 
         if m == klass then return true end
         m = m._base
      end

      return false
   end

   setmetatable(c, mt)
   return c
end
