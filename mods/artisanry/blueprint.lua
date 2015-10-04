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


--- The Blueprint is a receipt used by Artisanry.
Blueprint = {}


--- Creates a new instance of Blueprint.
--
-- @param group The name of the group of the blueprint.
-- @param result The result of the blueprint, an item string like "sand 5"
--               or "glass".
-- @param input The input for the blueprint, a 2D array with 5 rows and columns.
-- @return The new instance of Blueprint.
function Blueprint:new(group, result, input)
	local instance = {
		group = group,
		input = artisanryutil.convert(input),
		result = ItemStack(result)
	}
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end


--- Gets the count how often this output can be produced from the given
-- input. The input must match.
--
-- @param input The input, already matched against this Blueprint.
-- @return The count how often this output can be produced.
function Blueprint:count(input)
	local count = 999
	
	local reduced_input = artisanryutil.convert(input)
	
	for row_index = 1, #self.input, 1 do
		local blueprint_row = self.input[row_index]
		local input_row = reduced_input[row_index]
		
		for column_index = 1, #blueprint_row, 1 do
			local blueprint_part = blueprint_row[column_index]
			local input_part = input_row[column_index]
			
			local item_count = input_part:get_count() / blueprint_part:get_count()
			item_count = math.floor(item_count)
			
			if item_count < count then
				count = item_count
			end
		end
	end
	
	return count
end

--- Gets the group of this Blueprint.
--
-- @return The name of the group.
function Blueprint:get_group()
	return self.group
end

--- Gets the input for this Blueprint.
--
-- @return The input of this Blueprint, a 2D array..
function Blueprint:get_input()
	return self.input
end

--- Gets the result for this Blueprint.
--
-- @param input Optional. The input stack, will be used to determine
--              the count of the result.
-- @return The result, an ItemStack.
function Blueprint:get_result(input)
	local cloned_result = ItemStack(self.result)
	
	if input ~= nil then
		cloned_result:set_count(self:count(input))
	end
	
	return cloned_result
end

--- Matches this blueprint against the given input.
--
-- @param input The input, already reduced and converted to ItemStacks.
-- @return true if this blueprint matches the given input.
function Blueprint:match(input)
	if #self.input ~= #input then
		return false
	end
	
	for row_index = 1, #self.input, 1 do
		local blueprint_row = self.input[row_index]
		local input_row = input[row_index]
		
		if #blueprint_row ~= #input_row then
			return false
		end
		
		for column_index = 1, #blueprint_row, 1 do
			local blueprint_part = blueprint_row[column_index]
			local input_part = input_row[column_index]
			
			if blueprint_part:get_count() > input_part:get_count() or
			 blueprint_part:get_name() ~= input_part:get_name() then
				
				return false
			end
		end
	end
	
	return true
end

