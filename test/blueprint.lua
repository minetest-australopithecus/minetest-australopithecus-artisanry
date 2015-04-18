
-- Load the test file.
dofile("./mods/utils/list.lua")
dofile("./mods/utils/tableutil.lua")
dofile("./mods/utils/test.lua")

-- Load the dummy ItemStack
dofile("./mods/utils/list.lua")
dofile("./mods/utils/mathutil.lua")
dofile("./mods/utils/stringutil.lua")
dofile("./mods/utils/tableutil.lua")
dofile("./test/dummyitemstack.lua")

dofile("./mods/artisanry/artisanryutil.lua")

-- Now load the file for testing.
dofile("./mods/artisanry/blueprint.lua")


test.start("Blueprint")


test.run("match", function()
	local blueprint = Blueprint:new("item", {
		{ "ingredient 5", "other 4" },
		{ "", "coal 7" },
	})
	
	test.equals(true, blueprint:match(artisanryutil.convert({
		{ "", "", "", "", "" },
		{ "", "", "", "", "" },
		{ "ingredient 5", "other 4", "", "", "" },
		{ "", "coal 7", "", "", "" },
		{ "", "", "", "", "" }
	})))
end)

