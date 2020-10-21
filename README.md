# My OC-Programs
This is a collection of programs i've created while playing with OpenComputers

---

### HoloWorld
Gives a way for simple hologram manipulation.

**`hworld/hworld.lua`**  
Using built-in computer RAM.  
*It's fast and quiet, but requires frequent clearing due to high ram usage. Specialy with huge virtual worlds.*

**`hworld/dhworld.lua`**  
Using a Drive (HDD or Floppy in Unmanaged Mode) as "Virtual RAM". (I call it Drive-RAM, or `DRAM` for short)  
*It's slow and noisy, but doesnt require frequent clearing and is only limited by the size of the storage medium used*

**`hworld/hworld_test.lua`** and **`hworld/dhworld_test.lua`** are used for debugging/testing purposes  
Both were also used to check operation speed of hworld and dhworld.

**`hworld/hworld_test.lua`**  
Takes around 55.650s Real and 0m40.133s CPU.

**`hworld/dhworld_test.lua`** (Timed using the openos `time` program)
Using a Floppy: Takes around 1m56.150s Real and 0m20.982s CPU.  
Using a 1MB Drive: Takes around 1m34.500s Real and 0m21.326s CPU.

**Times may vary, and are only give a rough idea at best!**

Both are limited in how big one can make the virtual worlds by the available (D)RAM

---

I plan on adding more over programs time.