local thread = require("thread")
local term = require("term")
local computer = require("computer")
local driveio = require("driveio")

term.clear()

local names = {"9b5", "4e4", "e78"}

local function time2String(seconds)
  checkArg(1, seconds, "number")
  return string.format("%04i Days %02i:%02i:%02i", math.floor(seconds / 86400), math.floor(seconds / 3600) % 24, math.floor(seconds / 60) % 60, math.floor(seconds) % 60)
end

local streams = {}
for i=1,#names do
  local stream, reason = driveio.open(names[i])
  if not stream then error(nil, reason) end
  
  streams[i] = stream
end

local startTime = computer.uptime()
local t = computer.uptime()

local writeThread = thread.create(function()
  while true do
    local eofs = 1
    for i=1,#streams do
      if streams[i]:marker() >= streams[i]:size() then
        eofs = eofs + 1
      else
        for j=1,8 do
          local a, b = streams[i]:writeInteger(math.random(0, 0xFFFFFFFFF) & 0xFFFFFFFF)
          if not a then
            print("Drive: "..streams[i].drive.address.." reached EndOfDrive?", b)
          end
        end
      end
      
      if eofs>=#streams then
        break
      end
      
      os.sleep(0)
    end
  end
end)

local tmp = {}
local offset = 4
while writeThread:status()=="running" do
  if (computer.uptime() - t)>=1 then
    t = t + 1
    term.setCursor(1, 1)
    
    for i=0,(#streams-1) do
      local stream = streams[i+1]
      
      local bps  = stream.index - (tmp[offset * i + 0] or 0)
      tmp[offset * i + 0] = stream.index
      
      local eta = math.floor((stream:size()-stream:marker())/bps)
      
      do
        eta = time2String(eta)
        print(names[1+i]..": "..stream:marker().."/"..math.floor(stream:size()).." | "..bps.."b/s | ETA: "..eta.."    ")
      end
    end
    
    do
      local passed = computer.uptime() - startTime
      passed = time2String(passed)
      print("PASSED: "..passed.."    ")
    end
  end
  os.sleep(0)
end
