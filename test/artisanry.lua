
-- Load the test file.
dofile("./mods/utils/test.lua")

-- Load the dummy ItemStack
dofile("./mods/utils/stringutil.lua")
dofile("./test/dummyitemstack.lua")

-- Now load the file for testing.
dofile("./mods/artisanry/artisanry.lua")
dofile("./mods/artisanry/blueprint.lua")


test.start("Artisanry")

