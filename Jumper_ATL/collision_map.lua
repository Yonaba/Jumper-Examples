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

local pathfinding = {}

-- This function's purpose is to create a collision map from the ".tmx" file 
-- loaded within ATL, to be used to init Juper later on. The collision map 
-- will be sized with a "ground" layer, then we set obstacles regards to a "collision" layer
function pathfinding.create (map, groundLayer, collisionLayer, walkable, unwalkable)
  local _map = {}
  for x,y in map(groundLayer):iterate() do
    _map[y] = _map[y] or {}
    _map[y][x] = walkable or 0
  end
  for x,y in map(collisionLayer):iterate() do
    _map[y][x] = unwalkable or 1
  end
  return _map
end

return pathfinding