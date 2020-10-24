local bit32 = require("bit32")
local component = require("component")
local hworld = require("hworld")

local function areNumericCoords(x, y, z)
  checkArg(1, x, "number")
  checkArg(2, y, "number")
  checkArg(3, z, "number")
end

local function modu(a, b) a=a-1 return math.floor(a/b)+1, (a%b)+1 end
local function replace(str, index, rep) return string.sub(str, 1, index-1)..string.char(rep)..string.sub(str, index+1, string.len(str)) end
local function get(str, index) return string.byte(string.sub(str, index, index)) end
local function ps(...) local ret="" local whatever=table.pack(...) for i=1,#whatever do ret=ret.." "..tostring(whatever[i]) end return ret end

local func_Wrap = function(driveAddress, world)
  checkArg(1, driveAddress, "string")
  checkArg(2, world, "table")
  
  local reason = nil
  driveAddress, reason = component.get(driveAddress)
  if not driveAddress then
    return nil, reason
  end
  driveAddress, reason = component.proxy(driveAddress)
  if not driveAddress then
    return nil, reason
  end
  
  assert(not world.voxels, "Not a hworld-instance.")
  
  local ws = world.getWidth() * world.getHeight() * world.getDepth()
  assert(ws <= drive.getCapacity(), "World size exceeds drive capacity! ("..tostring(ws).." > "..tostring(dr.getCapacity())..")")
  
  ------------------------------------------------------------------
  
  local dhworld = world
  
  dhworld.voxels = nil -- Remove voxels table, not used here anyway
  
  dhworld.internal.drive = dr
  
  function dhworld.reset()
    local sectorSize = dhworld.internal.drive.getSectorSize()
    local worldSize = world.getWidth() * world.getHeight() * world.getDepth()
    local sectors = dhworld.internal.drive.getCapacity() / sectorSize
    local used = math.ceil(worldSize / sectorSize)
    
    local empty = ""
    for i=1,sectorSize do empty = empty .. string.char(0) end
    
    for sector=1,used do dhworld.internal.drive.writeSector(sector, empty) os.sleep(0) end
  end
  
  local lastSector, lastSectorData = nil, nil
  
  function dhworld.setVoxel(x, y, z, value)
    areNumericCoords(x, y, z)
    if not world.inBounds(x, y, z) then return false end
    
    assert(type(value)=="number", "setVoxel expects number, got "..type(value).." instead.")
    
    value = bit32.band(value, 0xFF)
    
    local old = dhworld.getVoxel(x, y, z, value)
    if value ~= bit32.band(old, 0xFF) then
      local worldIndex = world.toIndex(x, y, z)
      local sector, sectorIndex = modu(worldIndex, dhworld.internal.drive.getSectorSize())
      
      lastSectorData = replace(lastSectorData, sectorIndex, value)
      
      dhworld.internal.drive.writeSector(sector, lastSectorData)
      return true
    end
    
    return false
  end
  
  function dhworld.getVoxel(x, y, z)
    areNumericCoords(x, y, z)
    
    if not world.inBounds(x, y, z) then return 0 end
    
    local worldIndex = world.toIndex(x, y, z)
    local sector, sectorIndex = modu(worldIndex, dhworld.internal.drive.getSectorSize())
    
    if sector~=lastSector then
      lastSector = sector
      lastSectorData = dhworld.internal.drive.readSector(sector)
    end
    
    return get(lastSectorData, sectorIndex)
  end
  
  return dhworld
end

local func_Create = function(driveAddress, width, height, depth)
  return func_Wrap(driveAddress, hworld.create(width, height, depth))
end

return { ["wrap"] = func_Wrap, ["create"] = func_Create }
