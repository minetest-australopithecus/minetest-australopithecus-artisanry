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


--- Converts the given input from strings to ItemStacks.
--
-- @param input The input to convert.
-- @return The input as ItemStacks.
function Blueprint.as_stacks(input)
	local stacks = {}
	
	for row_index = 1, #input, 1 do
		local row = input[row_index]
		local stacks_row = {}
		
		for column_index = 1, #row, 1 do
			stacks_row[column_index] = ItemStack(row[column_index])
		end
		
		stacks[row_index] = stacks_row
	end
	
	return stacks
end

--- Checks if the given item is empty. That means if it is either nil, an empty
-- string or an ItemStack that is empty.
--
-- @param item The item to check.
-- @return true If the item can be considered empty.
function Blueprint.is_empty(item)
	if item == nil or item == "" then
		return true
	end
	
	if type(item) == "userdata" then
		return item:is_empty()
	end
	
	return false
end


--- Creates a new instance of Blueprint.
--
-- @param result The result of the blueprint, an item string like "sand 5"
--               or "glass".
-- @param input The input for the blueprint, a table with 25 item strings
--              or less.
-- @return The new instance of Blueprint.
function Blueprint:new(result, input)
	local instance = {
		input = Blueprint.as_stacks(tableutil.reduce2d(input, Blueprint.is_empty)),
		result = ItemStack(result)
	}
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end


--- Gets the input for this Blueprint.
--
-- @return The input of this Blueprint, a table with 25 ItemStacks or less.
function Blueprint:get_input()
	return self.input
end

--- Gets the result for this Blueprint.
--
-- @return The result, an ItemStack.
function Blueprint:get_result()
	return self.result
end

--- Matches this blueprint against the given input.
--
-- @param input The input, a table of 25 ItemStacks or less.
-- @return true if this blueprint matches the given input.
function Blueprint:match(input)
	local reduced_input = Blueprint.as_stacks(tableutil.reduce2d(input, Blueprint.is_empty))
	
	if #self.input ~= #reduced_input then
		return false
	end
	
	for row_index = 1, #self.input, 1 do
		local blueprint_row = self.input[row_index]
		local input_row = reduced_input[row_index]
		
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

