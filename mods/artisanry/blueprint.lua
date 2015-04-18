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
-- @param result The result of the blueprint, an item string like "sand 5"
--               or "glass".
-- @param input The input for the blueprint, a 2D array with 5 rows and columns.
-- @return The new instance of Blueprint.
function Blueprint:new(result, input)
	local instance = {
		input = artisanryutil.convert(input),
		result = ItemStack(result)
	}
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end


--- Gets the input for this Blueprint.
--
-- @return The input of this Blueprint, a 2D array with 5 rows and columns.
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

