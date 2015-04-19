--[[
Copyright (c) 2015, Robert 'Bobby' Zenz
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]


--- The main Artisanry object that holds and manages all receipts.
Artisanry = {}


--- Creates a new instance of Artisanry.
--
-- @return A new instance of Artisanry.
function Artisanry:new()
	local instance = {
		blueprints = List:new()
	}
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end


--- Gets all BluePrints matching the given input.
--
-- @param input The input, a 2D of strings or ItemStacks. Might be nil to
--              retrieve all BluePrints.
-- @return All matching BluePrints.
function Artisanry:get_blueprints(input)
	if input == nil then
		return tableutil.clone(self.blueprints)
	end
	
	local reduced_input = artisanryutil.convert(input)
	
	return self.blueprints:matching(function(blueprint)
		return blueprint:match(reduced_input)
	end)
end

--- Gets all BluePrints that match the given output.
--
-- @param output The output. Can either be an ItemStack, item string or id.
-- @return The List containing all Blueprints that match the given output.
function Artisanry:get_blueprints_from_output(output)
	local comparer = function(blueprint)
		return blueprint:get_result():get_name() == output:get_name()
	end
	
	if type(output) == "number" then
		comparer = function(blueprint)
			return minetest.get_content_id(blueprint:get_result():get_name()) == output
		end
	elseif type(output) ~= "userdata" then
		output = ItemStack(output)
	end
	
	return self.blueprints:matching(comparer)
end

--- Registers the given input for the given result.
--
-- @param result The result of the input, an item string.
-- @param input The 2D array of item strings or ItemStacks.
function Artisanry:register(result, input)
	self.blueprints:add(Blueprint:new(result, input))
end

--- Registers the given BluePrint.

-- @param blueprint The BluePrint.
function Artisanry:register_blueprint(blueprint)
	self.blueprints:add(blueprint)
end

