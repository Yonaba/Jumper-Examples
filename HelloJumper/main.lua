--[[
Copyright (c) 2012 Zeliarden & Roland Yonaba

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

local Jumper = require 'Jumper.init'
local map = {
  {0,0,0,1,0},
  {0,1,0,1,0},
  {0,1,0,1,0},
  {0,1,0,0,0},
}

local walkable = 0
local postProcess = false
local pather = Jumper(map,walkable,postProcess)
local sx,sy = 1,4
local ex,ey = 5,4
print('Hello Jumper! from Corona')
local path = pather:getPath(sx,sy,ex,ey)
if path then
  print(('Path from [%d,%d] to [%d,%d] was : found!'):format(sx,sy,ex,ey))
  for i,node in ipairs(path) do
    print(('Step %d. Node [%d,%d]'):format(i,node.x,node.y))
  end
else
    print(('Path from [%d,%d] to [%d,%d] was : not found!'):format(sx,sy,ex,ey))
end  
