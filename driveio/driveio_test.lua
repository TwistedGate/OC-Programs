local thread = require("thread")
local term = require("term")
local computer = require("computer")
local driveio = require("driveio")

term.clear()

local toTest = "e78"

-- Write test
do
  local stream, reason = driveio.open(toTest)
  if not stream then
    error(reason)
  end
  
  print(" - Write Test - ")
  print(stream:writeByte(0xAF))
  print(stream:writeShort(0xDEAD))
  print(stream:writeInteger(0x12DEAF34))
  print(stream:writeBoolean(true))
  print(stream:writeBoolean(false))
  print(stream:writeString("Hello World!"))
end

-- Read test
do
  local stream, reason = driveio.open(toTest)
  if not stream then
    error(reason)
  end
  
  print(" - Read Test - ")
  print(stream:readByte()==0xAF)
  print(stream:readShort()==0xDEAD)
  print(stream:readInteger()==0x12DEAF34)
  print(stream:readBoolean()==true)
  print(stream:readBoolean()==false)
  print(stream:readString()=="Hello World!")
end

-- Error Test
do
  local stream, reason = driveio.open(toTest)
  if not stream then
    error(reason)
  end
  
  print(" - Error Test - ")
  
  local writeThread = thread.create(function()
    local running = true
    while running do
      for i=1,8 do
        local a, b = stream:writeInteger(math.random(0x0, 0xFFFFFFFF))
        if not a then
          print("Task Failed Successfully!", b)
          running = false
        end
      end
      
      os.sleep(0)
    end
    
    print("Write thread terminated.")
  end)
  
  local x, y = term.getCursor()
  local lastIndex = 0
  local t, l = computer.uptime(), computer.uptime()
  while writeThread:status()~="dead" do
    term.setCursor(x, y)
    print(stream:marker().."/"..stream:size().." ("..tostring(math.floor(100*(stream:marker()/stream:size()))).."%)    ")
    
    if (computer.uptime() - t)>=1 then
      t = t + 1
      term.setCursor(x, y+2)
      local written = stream:marker()-lastIndex
      lastIndex = stream:marker()
      
      local passed = computer.uptime() - l
      local eta = math.floor((stream:size() - stream:marker()) / written)
      print("Speed: "..tostring(written).."b/s    ")
      
      do
        local a = math.floor(passed / 60)
        local b = math.floor(passed % 60)
        if a<10 then a = "0"..tostring(a) end
        if b<10 then b = "0"..tostring(b) end
        print("PAS: "..a..":"..b.."    ")
      end
      
      do
        local a = math.floor(eta / 60)
        local b = math.floor(eta % 60)
        if a<10 then a = "0"..tostring(a) end
        if b<10 then b = "0"..tostring(b) end
        print("ETA: "..a..":"..b.."    ")
      end
    end
    os.sleep(0)
  end
  
end
