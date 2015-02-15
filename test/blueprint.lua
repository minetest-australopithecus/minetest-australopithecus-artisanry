
-- Load the test file.
dofile("./mods/utils/test.lua")

-- Load the dummy ItemStack
dofile("./mods/utils/list.lua")
dofile("./mods/utils/stringutil.lua")
dofile("./test/dummyitemstack.lua")

-- Now load the file for testing.
dofile("./mods/artisanry/blueprint.lua")


test.start("Blueprint")

test.run("constructor", function()
	local blueprint = Blueprint:new("glass", {
		"sand 5", "test 4", "", "", "",
		"", "", "", "", "",
		"", "", "", "", "",
		"", "", "", "", "",
		"", "", "", "", "",
	})
	
end)

