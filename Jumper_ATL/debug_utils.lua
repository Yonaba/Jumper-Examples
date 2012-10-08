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

local Debug = {}

-- Draws informations relevant to the last path search
-- Outputs whether or not the path was found, the time of search 
-- in milliseconds and the path length.
function Debug.printPathInfo(font,x,y,pathInfo)
  love.graphics.setFont(font)
  love.graphics.print(('Path: %s - Time: %.2f ms - Length: %.2f'):
                        format(pathInfo.path and 'Found' or 'False' ,
                                  pathInfo.time or 0.00, 
                                  pathInfo.len or 0.00)
                        ,x,y)
end

-- Draws a path with a set of points on each node, lines
-- linking them and involved nodes coordinates
function Debug.drawPath(font, path, shouldDraw)
  local x1,y1,x2,y2
  if shouldDraw and path then
    love.graphics.setLine(1,'smooth')
    love.graphics.setPoint(5,'smooth')
    for i = 2,#path do
      x1,y1 = path[i-1].x*32+16, path[i-1].y*32+16
      x2,y2 = path[i].x*32+16, path[i].y*32+16
      love.graphics.setColor(255,255,0,255)
      love.graphics.line(x1,y1,x2,y2)
      love.graphics.setColor(255,0,0,255)      
      love.graphics.point(x1,y1)
      love.graphics.point(x2,y2)
      love.graphics.setColor(255,255,255,255)
      love.graphics.setFont(font)
      love.graphics.printf(('(%d,%d)'):format(path[i-1].x,path[i-1].y),x1-16,y1+5,32,'center')
      love.graphics.printf(('(%d,%d)'):format(path[i].x, path[i].y),x2-16,y2+5,32,'center')
    end
  end  
end

return Debug