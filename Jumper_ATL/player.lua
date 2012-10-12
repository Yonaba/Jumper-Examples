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

-- Requires anim8, to be used to animate our sprites
local anim8 = require 'lib.anim8.anim8'

-- The player table. x, y will holds the players coordinates on the world
-- while tile_x and tile_y will hold be the corresponding tile location
local player = {x = 400, y = 300, tile_x = 0, tile_y = 0, speed = 100}
player.image = love.graphics.newImage('assets/princess.png') -- player spritesheet

-- Sets the animation grid (parses our spritesheet)
local animationGrid = anim8.newGrid(64, 64, player.image:getWidth(), player.image:getHeight())

-- Each state matches a direction of move, and goes with a specific animation.
player.state = {
  ['up'] = anim8.newAnimation('loop', animationGrid('1-9,1'), 0.1),
  ['left'] = anim8.newAnimation('loop', animationGrid('1-9,2'), 0.1),
  ['down'] = anim8.newAnimation('loop', animationGrid('1-9,3'), 0.1),
  ['right'] = anim8.newAnimation('loop', animationGrid('1-9,4'), 0.1),
}
player.dir = 'right' -- holds the current player direction

-- Spawns the player at a specific tile
-- Here we take into account that our sprite is 2-tiles high.
-- We need the lower tile to be standing on the specified tile,
-- so we substract one time our tile size (32) on y-axis
function player.spawnAt(tile_x, tile_y)
  player.x = tile_x*32
  player.y = tile_y*32-32 
  player.tile_x, player.tile_y = tile_x, tile_y
end

-- Update the coordinates of the tile the player is standing on.
-- We add the tile size on Y-axis for the same reason exposed above.
function player.setTilePosition()
  player.tile_x = math.floor(player.x/32)
  player.tile_y = math.floor((player.y+32)/32)
end

-- Sends to the player the order to move
function player.orderMove(path)
  player.path = path -- the path to follow
  player.isMoving = true -- whether or not the player should start moving
  player.cur = 1 -- indexes the current reached step on the path to follow
  player.there = true -- whether or not the player has reached a step
end

-- Moves the player, checks after each step move if the player 
-- has reached the end of the path, processes accordingly
function player.move(dt)
  if player.isMoving then
    if not player.there then
      -- Walk to the assigned location
      player.moveToTile(player.path[player.cur].x,player.path[player.cur].y, dt)
    else
      -- Make the next step move
      if player.path[player.cur+1] then
        player.cur = player.cur + 1
        player.there = false
      else
        -- Reached the goal!
        player.isMoving = false
        player.path = nil
      end        
    end
    -- Animate only when moving
    player.state[player.dir]:update(dt)
  end
end

-- Updates the player sprite according to
-- the direction of the move.
function player.updateDirection(dx, dy, goal_tile_x, goal_tile_y)
  if (goal_tile_y == player.tile_y) and (goal_tile_x ~= player.tile_x) then
    player.dir = dx > 0 and 'right' or 'left'
  elseif (goal_tile_y ~= player.tile_y) and (goal_tile_x == player.tile_x) then
    player.dir = dy > 0 and 'down' or 'up'
  else
    player.dir = dx > 0 and 'right' or (dx < 0 and 'left' or player.dir)
  end   
end

-- Performs a step move along a path. A step move consists of moving 
-- from one node to the next one allong a path.
function player.moveToTile(goal_tile_x,goal_tile_y, dt)
  -- Watches if the player has reached the goal on x/y
  local reached_x, reached_y = false, false 
  
  -- Compute the goal location in pixels from the goal tile coordinates
  local goal_x = goal_tile_x*32
  local goal_y = goal_tile_y*32-32
  
  -- Computes the unit vector of move
  local vx = (goal_x-player.x)/math.abs(goal_x-player.x)
  local vy = (goal_y-player.y)/math.abs(goal_y-player.y)
  
  -- Updates the direction of the move of the player
  player.updateDirection(vx, vy, goal_tile_x,goal_tile_y) 
  
  local dy, dx
  -- Moves on the player on y-axis
  if (player.y~=goal_y) then
    dy = dt*player.speed*vy
    if vy > 0 then
      player.y = player.y + math.min(dy,goal_y-player.y)
    else 
      player.y = player.y + math.max(dy,goal_y-player.y)
    end
  else
    player.y = goal_y
    reached_y = true
  end  
  
  -- Moves on the player on x-axis
  if (player.x ~= goal_x) then
    dx = dt*player.speed*vx
    if vx > 0 then
      player.x = player.x + math.min(dx,goal_x-player.x)
    else
      player.x = player.x + math.max(dx,goal_x-player.x)
    end
  else 
    player.x = goal_x
    reached_x = true
  end  
  if (reached_x and reached_y) then player.there = true end   
end

-- Updates the player on each update cycle
function player.update(dt)
  player.setTilePosition()
  player.move(dt)
end

-- Draws the player animation according to 
-- the direction he is facing to. We are using here an offset of 16 
-- on x-axis for a better alignment of the player quad with our tiles
function player.draw()
  player.state[player.dir]:draw(player.image,player.x,player.y,0,1,1,16,0)
end

return player 