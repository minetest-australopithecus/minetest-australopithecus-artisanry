
-- Load the test file.
dofile("./mods/utils/test.lua")

-- Load the dummy ItemStack
dofile("./mods/utils/list.lua")
dofile("./mods/utils/mathutil.lua")
dofile("./mods/utils/stringutil.lua")
dofile("./mods/utils/tableutil.lua")
dofile("./test/dummyitemstack.lua")

-- Now load the file for testing.
dofile("./mods/artisanry/artisanry.lua")
dofile("./mods/artisanry/blueprint.lua")


test.start("Artisanry")

test.run("simple", function()
	local artisanry = Artisanry:new()
	
	test.equals(0, artisanry:get_blueprints():size())
	
	artisanry:register("result", {
		"item", "", "", "", "",
		"", "", "", "", "",
		"", "", "", "", "",
		"", "", "", "", "",
		"", "", "", "", ""
	})
	
end)

