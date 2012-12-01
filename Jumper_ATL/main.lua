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

-- Loading callback
function love.load()

  -- Loading relevant libraries
  Jumper = require 'lib.Jumper'  
  ATL = require 'lib.AdvTiledLoader'
  
  -- Configuring ATL for "tmx" map loading
  ATL.Loader.path = 'assets/maps/'
  
  -- loads the map. Caution here, the map built
  -- with Tiled, and the starting tile is (0,0)
  map = ATL.Loader.load('map.tmx') 
  map.drawObjects = false
  map.useSpriteBatch = true
  
  -- Some fonts
  font7 = love.graphics.newFont(7)
  font12 = love.graphics.newFont(12) 
  
  -- WorldMap entity will handle camera translation
  -- translate_x/translate_y are the same as x,y properties, but floored down to integers
  -- scale refers to the scaling
  WorldMap = { x = 0, y = 0, scroll_speed = 250, scale = 1}
  WorldMap.translate_x, WorldMap.translate_y = WorldMap.x, WorldMap.y
  
  -- Requires collision map making tool. Not directly related to Jumper,
  -- but provides facilities to create a collision map from ATL map 
  -- to be used later on to init Jumper
  collision_map_maker = require 'collision_map'
  
  -- Creates a collision map from the "Collision" layer
  collision_map = collision_map_maker.create(map, 'Ground', 'Collision')
  
  -- Function which converts x,y on the screen to tile coordinates
  -- All tiles are 32-pixels wide (width, height). Function returns nil
  -- if we clicked out of the map bounds
  function WorldMap.toTile(x,y)
    local _x = math.floor(x/(32*WorldMap.scale))
    local _y = math.floor(y/(32*WorldMap.scale))
    if collision_map[_y] and collision_map[_y][_x] then 
      return _x,_y
    end
  end
  
  -- Initializing Jumper
  searchMode = 'DIAGONAL' -- whether or not diagonal moves are allowed
  heuristics = {'MANHATTAN','EUCLIDIAN','DIAGONAL','CARDINTCARD'} -- valid distance heuristics names
  current_heuristic = 1 -- indexes the chosen heuristics within 'heuristics' table
  filling = false -- whether or not returned paths will be smoothed
  postProcess = false -- whether or not the grid should be postProcessed
  pather = Jumper(collision_map,0, postProcess) -- Inits Jumper
  pather:setMode(searchMode)
  pather:setHeuristic(heuristics[current_heuristic])
  pather:setAutoFill(filling)
  drawPath = false  -- whether or not the path will be drawn
  
  -- Provides a set of utilities to output useful informations
  Debug = require 'debug_utils'
  
  -- Loads The player object
  Player = require 'player'
  
  -- We "tie" the player to a predefinied layer on the ".tmx" map,
  -- to prevent Z-ordering issues with the map objects (ground, trees, holes, rocks,...)
  Player.layer = map:newCustomLayer("playerLayer", map:layerPosition("Player"))
  Player.layer.draw = Player.draw -- This layer will be drawn by ATL using our custom Player.draw  
  Player.spawnAt(0,10) -- We spawns the player at a specific tile to start  
 
  printPathInfo = {} -- This will hold debug information to be drawned with 'Debug.printPathInfo'
end

-- Update callback
function love.update(dt)
  if love.keyboard.isDown('up','w') then WorldMap.y = WorldMap.y + WorldMap.scroll_speed*dt end
  if love.keyboard.isDown('down','s') then WorldMap.y = WorldMap.y - WorldMap.scroll_speed*dt  end
  if love.keyboard.isDown('left','a') then WorldMap.x = WorldMap.x + WorldMap.scroll_speed*dt  end
  if love.keyboard.isDown('right','d') then WorldMap.x = WorldMap.x - WorldMap.scroll_speed*dt  end
  WorldMap.translate_x, WorldMap.translate_y = math.floor(WorldMap.x), math.floor(WorldMap.y)
  Player.update(dt)
end

-- Drawing callback
function love.draw()
  -- Pushes rendering routines to the graphics transformation stack
  -- We are doing it here because we need to translate things (maps, objetcs)
  -- while keeping other things fixed (printed debug information)
  love.graphics.push() -- saves the default coordinates system
    love.graphics.scale(WorldMap.scale) -- scales the view
    love.graphics.translate(WorldMap.translate_x, WorldMap.translate_y ) -- viewpoint scrolling on x/y-axis
    map:autoDrawRange(WorldMap.translate_x, WorldMap.translate_y, WorldMap.scale) -- sets the map drawing range
    map:draw() -- renders the map with ATL
    Debug.drawPath(font7, Player.path, drawPath) -- draws the path
  love.graphics.pop() -- restores the default coordinates system
  love.graphics.setColor(255,255,255,255)
  Debug.printPathInfo(font12,10,580,printPathInfo) -- prints infos about the last path search
  
  -- Keys Directions
  love.graphics.print(('[U]: Search Mode (%s)'):format(searchMode), 10,10)
  love.graphics.print(('[H]: Heuristic (%s)'):format(heuristics[current_heuristic]), 10,25)
  love.graphics.print(('[J]: Smooth Path (%s)'):format(tostring(filling)), 10,40)
  love.graphics.print(('[K]: Draw Path (%s)'):format(tostring(drawPath)), 10,55)
  love.graphics.print(('[W/A/S/D - Arrows]: Move camera'), 10,70)
  love.graphics.print(('[Left Mouse Button]: Move character'), 10,85)
  love.graphics.print(('[Mouse Wheel]: Scale: %s'):format(WorldMap.scale), 10,100)
end

-- Mouse callback
function love.mousepressed(x,y,button)
  if button == 'l' then
    -- Converts the clicked location on the screen to world coordinates
    local map_location_x, map_location_y = (x-(WorldMap.translate_x*WorldMap.scale)), (y-(WorldMap.translate_y*WorldMap.scale))
    -- Converts world coordinates to the corresponding tile
    local map_tile_x, map_tile_y = WorldMap.toTile(map_location_x, map_location_y)
    
    -- Processes a path search from the player location
    -- to the clicked location if this location is walkable
    if pather.grid:isWalkableAt(map_tile_x,map_tile_y) then
      local start_tick = love.timer.getMicroTime()*1000 -- Start time
      local path,length = pather:getPath(Player.tile_x, Player.tile_y, map_tile_x, map_tile_y)
      local time = (love.timer.getMicroTime()*1000 - start_tick) -- Gets the time of search in milliseconds
      
      -- In case a path exists
      if path then
        Player.orderMove(path) -- We order the player to move along the found path
        -- We store informations relevant to the found path to be printed with Debug.printPathInfo
        printPathInfo.path = path 
        printPathInfo.len = length
        printPathInfo.time = time
      else printPathInfo = {} -- Clears informations about the current path request
      end
    else  printPathInfo = {} -- Clears informations about the current path request
    end
  -- Scaling
  elseif button == 'wu' then
    if WorldMap.scale < 4 then WorldMap.scale = WorldMap.scale + 0.1 end
  elseif button == 'wd' then 
    if WorldMap.scale > 0.1 then WorldMap.scale = WorldMap.scale - 0.1 end
  end
end

-- Keyboard callback
function love.keypressed(key, unicode)
  if key == 'u' then searchMode = (searchMode == 'DIAGONAL' and 'ORTHOGONAL' or 'DIAGONAL') end -- changes search Mode on/off
  if key == 'h' then 
    current_heuristic = (heuristics[current_heuristic+1] and current_heuristic+1 or 1) -- Changes the heuristic used
  end
  if key == 'k' then drawPath = not drawPath end -- switches the path drawing on/off
  if key == 'j' then filling = not filling end -- switches path filling on/off
  
  -- Reconfigure the pather with new options
  -- We are using here the chaining feature of Jumper
  pather:setMode(searchMode)
        :setHeuristic(heuristics[current_heuristic])
        :setAutoFill(filling)
end