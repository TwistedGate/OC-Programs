local term=require("term")
local computer=require("computer")
local component=require("component")
local holo=component.hologram

if term.isAvailable() then
  term.clear()
end

print("Generating new dram_world.")
local world = require("dhworld").create("d36")

local function ps(a, b, c)
  return tostring(a)..", "..tostring(b)..", "..tostring(c)
end

print() -- Spacer

print("Testing: \"inBounds\" Function.", "Min: 1, 1, 1", "Max: "..ps(world.getWidth(), world.getHeight(), world.getDepth()), "\n")
print("inBounds(1,1,1)") assert(world.inBounds(1,1,1), "Failed.")
print("inBounds("..ps(world.getWidth(), world.getHeight(), world.getDepth())..")") assert(world.inBounds(world.getWidth(), world.getHeight(), world.getDepth()), "Failed.")
print("inBounds(-1,1,1)") assert(not world.inBounds(-1, 1, 1), "Failed.")
print("inBounds(1,-1,1)") assert(not world.inBounds(1, -1, 1), "Failed.")
print("inBounds(1,1,-1)") assert(not world.inBounds(1, 1, -1), "Failed.")
print("inBounds("..ps(world.getWidth()+1, 1, 1)..")") assert(not world.inBounds(world.getWidth()+1, 1, 1), "Failed.")
print("inBounds("..ps(1, world.getHeight()+1, 1)..")") assert(not world.inBounds(1, world.getHeight()+1, 1), "Failed.")
print("inBounds("..ps(1, 1, world.getDepth()+1)..")") assert(not world.inBounds(1, 1, world.getDepth()+1), "Failed.")

print("\nTesting: \"reset\" function.")
world.reset()
holo.clear()
world.applyTo(holo) -- Hologram should stay empty after world.reset()

print("\nTesting: Random Access")

holo.clear()
for j=1,10 do
  for i=1,512 do
    local x=math.floor(math.random(1,world.getWidth()))
    local y=math.floor(math.random(1,world.getHeight()))
    local z=math.floor(math.random(1,world.getDepth()))
    local v=math.floor(math.random(0,3))
    world.setVoxel(x, y, z, v)
  end
  os.sleep(0)
end

print("\nTesting all Shapes")

print("fcube(3,3,3, 5,5,5, 1)")
world.fcube(3,3,3, 5,5,5, 1)

print("hcube(3,10,3, 5,5,5, 2)")
world.hcube(3,10,3, 5,5,5, 2)

print("frame(1,1,1, 47,31,47, 3)")
world.frame(1,1,1, 47,31,47, 3)

print("fsphere(24,16,24, 6, 1)")
world.fsphere(24,16,24, 6, 1)

print("hsphere(24,16,24, 15, 2)")
world.hsphere(24,16,24, 15, 2)

print("rtesseract(1,-8,1, 47)")
world.rtesseract(1,-8,1, 47)

print("Applying to Hologram.")
holo.clear()
world.applyTo(holo)

print("\nSuccessfull! Everything went according to plan.")
