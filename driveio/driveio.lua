local component = require("component")

local driveio = {}

---------------------------------------------------------------------------------------------------------------------

local drivestream = {}

function drivestream:size()
  return self.drive.getCapacity()
end

function drivestream:marker()
  return self.index
end

function drivestream:reset()
  self.index = 1
end

function drivestream:setMarker(index)
  checkArg(1, index, "number")
  if index<1 or index>self:size() then
    return nil, "Out of Bounds!"
  end
  
  local last = self.index
  self.index = index
  
  return index, last
end

function drivestream:readByte()
  if self:marker()>self:size() then
    return nil, "End of Drive."
  end
  
  local byte = self.drive.readByte(self.index)
  self.index = self.index + 1
  return byte & 0xFF
end

function drivestream:readShort()
  local short = 0
  for i=1,0,-1 do
    local byte, reason = self:readByte()
    if not byte then
      return nil, reason
    end
    short = short | (byte<<(8*i))
  end
  
  return short & 0xFFFF
end

function drivestream:readInteger()
  local int = 0
  for i=3,0,-1 do
    local byte, reason = self:readByte()
    if not byte then
      return nil, reason
    end
    int = int | (byte<<(8*i))
  end
  
  return int & 0xFFFFFFFF
end

function drivestream:readBoolean()
  local boolean, reason = self:readByte()
  if not boolean then
    return nil, reason
  end
  
  return boolean > 0
end

function drivestream:readString()
  local len, reason = self:readShort()
  if not len then
    return nil, reason
  end
  
  local ret = ""
  if len>0 then
    for i=1,len do
      local byte = self:readByte()
      if not byte then
        return nil, reason
      end
      
      ret = ret..string.char(byte)
    end
  end
  
  return ret
end

function drivestream:writeByte(byte)
  checkArg(1, byte, "number")
  
  if self.index>self.drive.getCapacity() then
    return nil, "End of Drive Reached."
  end
  
  self.drive.writeByte(self.index, byte)
  self.index = self.index + 1
  
  return true
end

function drivestream:writeShort(short)
  checkArg(1, short, "number")
  
  for i=1,0,-1 do
    local _,reason = self:writeByte((short>>(8*i)) & 0xFF)
    if not _ then
      return nil, reason
    end
  end
  
  return true
end

function drivestream:writeInteger(int)
  checkArg(1, int, "number")
  
  for i=3,0,-1 do
    local _,reason = self:writeByte((int>>(8*i)) & 0xFF)
    if not _ then
      return nil, reason
    end
  end
  
  return true
end

function drivestream:writeBoolean(boolean)
  checkArg(1, boolean, "boolean")
  local _, reason = self:writeByte(boolean and 1 or 0)
  if not _ then
    return nil, reason
  end
  return true
end

function drivestream:writeString(str)
  checkArg(1, str, "string")
  
  local len = string.len(str)
  assert(len<=0xFFFF, "String too large, maximum of 65535 characters supported")
  assert((self:marker()+(len+2))<self:size(), "Not enough space to write string")
  
  self:writeShort(len & 0xFFFF)
  if len>0 then
    for i=1,len do
      local _, reason = self:writeByte(string.byte(string.sub(str, i, i)))
      if not _ then
        return nil, reason
      end
    end
  end
  
  return true, len
end

---------------------------------------------------------------------------------------------------------------------

function driveio.open(address)
  checkArg(1, address, "string")
  
  local fullAddress, reason = component.get(address)
  if not fullAddress then 
    return nil, reason
  end
  
  local comp = component.proxy(fullAddress)
  if comp.type~="drive" then
    return nil, "Component is not a Drive."
  end
  
  local stream = {
    drive = comp,
    index = 1,
  }
  local metatable = { __index = drivestream, __metatable = "drivestream" }
  return setmetatable(stream, metatable)
end

---------------------------------------------------------------------------------------------------------------------

return driveio
