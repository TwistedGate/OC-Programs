local function areNumericCoords(x, y, z)
  checkArg(1, x, "number")
  checkArg(2, y, "number")
  checkArg(3, z, "number")
end

local function modu(a, b) a=a-1 return math.floor(a/b)+1, (a%b)+1 end
local function square(...) local ret=0 local numbers=table.pack(...) for i=1,#numbers do ret=ret+numbers[i]*numbers[i] end return ret end
local function ps(...) local ret="" local whatever=table.pack(...) for i=1,#whatever do ret=ret.." "..tostring(whatever[i]) end return ret end

local func_Create = function(widthIn, heightIn, depthIn)
  
  widthIn  = widthIn  or 48
  heightIn = heightIn or 32
  depthIn  = depthIn  or 48
  
  local hworld = {}
  
  hworld.voxels = {}
  
  function hworld.getWidth()
    return widthIn
  end
  
  function hworld.getHeight()
    return heightIn
  end
  
  function hworld.getDepth()
    return depthIn
  end
  
  
  function hworld.inBounds(x, y, z)
    areNumericCoords(x, y, z)
    return (x>=1 and x<=hworld.getWidth()) and (y>=1 and y<=hworld.getHeight()) and (z>=1 and z<=hworld.getDepth())
  end
  
  function hworld.toIndex(x, y, z)
    areNumericCoords(x, y, z)
    x=x-1 y=y-1 z=z-1
    return (hworld.getWidth() * hworld.getDepth() * y + hworld.getWidth() * z + x) + 1
  end
  
  function hworld.reset()
    hworld.voxels = {}
  end
  
  function hworld.setVoxel(x, y, z, value)
    areNumericCoords(x, y, z)
    checkArg(4, value, "number", "nil")
    
    if not hworld.inBounds(x, y, z) then return false end
    
    if value<=0 then value = nil end
    
    local index = hworld.toIndex(x, y, z)
    local old = hworld.voxels[index]
    if value~=old then
      hworld.voxels[index] = value
      return true
    end
    return false
  end
  
  function hworld.getVoxel(x, y, z)
    areNumericCoords(x, y, z)
    if not hworld.inBounds(x, y, z) then return 0 end
    return hworld.voxels[hworld.toIndex(x, y, z)] or 0
  end
  
  function hworld.isAir(x, y, z)
    areNumericCoords(x, y, z)
    if not hworld.inBounds(x, y, z) then return true end
    return getVoxel(x, y, z)==0
  end
  
  function hworld.fcube(x, y, z, w, h, d, voxel)
    areNumericCoords(x, y, z)
    voxel = voxel or 0
    
    local xdist = x+w
    local ydist = y+h
    local zdist = z+d
    for j=y,ydist do
      for k=z,zdist do
        for i=x,xdist do
          hworld.setVoxel(i, j, k, voxel)
        end
      end
      os.sleep(0)
    end
  end
  
  function hworld.hcube(x, y, z, w, h, d, voxel)
    areNumericCoords(x, y, z)
    voxel = voxel or 0
    
    local xdist = x+w
    local ydist = y+h
    local zdist = z+d
    for j=y,ydist do
      for k=z,zdist do
        for i=x,xdist do
          if (j==y or j==ydist) or (k==z or k==zdist) or (i==x or i==xdist) then
            hworld.setVoxel(i, j, k, voxel)
          end
        end
      end
      os.sleep(0)
    end
  end
  
  function hworld.frame(x, y, z, w, h, d, voxel)
    areNumericCoords(x, y, z)
    voxel = voxel or 0
    
    local xdist = x+w
    local ydist = y+h
    local zdist = z+d
    
    for j=y,ydist do
      for k=z,zdist do
        for i=x,xdist do
          if ((i==x or i==xdist) and (k==z or k==zdist)) or ((j==y or j==ydist) and ((i==x or i==xdist) or (k==z or k==zdist)))then
            hworld.setVoxel(i, j, k, voxel)
          end
        end
      end
      os.sleep(0)
    end
  end
  
  function hworld.rtesseract(x, y, z, size)
    local it = math.ceil(size/2)-1
    local j = 0
    for i=0,it do
      local ni = size - (2*i)
      local a, b = modu(j, 3)
      hworld.frame(x+i,y+i,z+i, ni,ni,ni, b)
      j=j+1
    end
  end
  
  function hworld.tesseract(x, y, z, size, voxel)
    local it = math.ceil(size/2)-1
    for i=0,it do
      local ni = size - (2*i)
      hworld.frame(x+i,y+i,z+i, ni,ni,ni, voxel)
    end
  end
  
  function hworld.fsphere(x, y, z, radius, voxel)
    areNumericCoords(x, y, z)
    voxel = voxel or 0
    
    local ra=square(radius)
    for j=-radius,radius do
      for k=-radius,radius do
        for i=-radius,radius do
          local xa = x+i
          local ya = y+j
          local za = z+k
          
          local sqr = square(x-xa, y-ya, z-za)
          if sqr<=ra then
            hworld.setVoxel(xa, ya, za, voxel)
          end
        end
      end
      os.sleep(0)
    end
  end
  
  function hworld.hsphere(x, y, z, radius, voxel)
    areNumericCoords(x, y, z)
    voxel = voxel or 0
    
    local ra = square(radius)
    local rb = square(radius-1)
    for j=-radius,radius do
      for k=-radius,radius do
        for i=-radius,radius do
          local xa = x+i
          local ya = y+j
          local za = z+k
          
          local sqr = square(x-xa, y-ya, z-za)
          if sqr>=rb and sqr<=ra then
            hworld.setVoxel(xa, ya, za, voxel)
          end
        end
      end
      os.sleep(0)
    end
  end
  
  function hworld.applyTo(component)
    checkArg(1, component, "table")
    assert(component.type=="hologram", "Expected a hologram")
    
    local maxDepth = component.maxDepth()+1
    for y=1,hworld.getHeight() do
      for z=1,hworld.getDepth() do
        for x=1,hworld.getWidth() do
          local v = hworld.getVoxel(x,y,z)
          if v>0 then
            assert(v<=maxDepth, "Invalid value at ["..ps(x, y, z).."] -> "..tostring(v).." (0 to "..tostring(maxDepth).." allowed)")
            component.set(x, y, z, v)
          end
        end
      end
      os.sleep(0)
    end
  end
  
  function hworld.holoSync(component)
    if component and component.type=="hologram" then
      for y=1,32 do
        for z=1,48 do
          for x=1,48 do
            hworld.setVoxel(x, y, z, math.floor(component.get(x, y, z)))
          end
        end
        os.sleep(0)
      end
      return true
    end
    return false
  end
  
  return hworld
end

return { ["create"] = func_Create }
