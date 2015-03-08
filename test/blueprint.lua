
-- Load the test file.
dofile("./mods/utils/test.lua")

-- Load the dummy ItemStack
dofile("./mods/utils/list.lua")
dofile("./mods/utils/mathutil.lua")
dofile("./mods/utils/stringutil.lua")
dofile("./mods/utils/tableutil.lua")
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

test.run("constructor_padding", function()
	local blueprint = Blueprint:new("glass", {
		"sand 5", "secret 4"
	})
	
	local input = blueprint:get_input()
	
	test.equals(false, input[3] == nil)
	test.equals(false, input[5] == nil)
	test.equals(false, input[25] == nil)
end)
