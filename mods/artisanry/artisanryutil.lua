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


artisanryutil = {}


--- Converts the given input from strings to ItemStacks. If the values are
-- already ItemStacks, they are only copied.
--
-- @param input The input to convert.
-- @return The input as ItemStacks.
function artisanryutil.as_stacks(input)
	local stacks = {}
	
	for row_index = 1, #input, 1 do
		local row = input[row_index]
		local stacks_row = {}
		
		for column_index = 1, #row, 1 do
			if type(row[column_index]) ~= "userdata" then
				stacks_row[column_index] = ItemStack(row[column_index])
			else
				stacks_row[column_index] = row[column_index]
			end
		end
		
		stacks[row_index] = stacks_row
	end
	
	return stacks
end

--- Reduces and converts the given input to ItemStacks.
--
-- @param input The input to convert.
-- @param The converted input.
function artisanryutil.convert(input)
	return artisanryutil.as_stacks(tableutil.reduce2d(input, artisanryutil.is_empty_item))
end


--- Converts the given data from a flat array to a 2D array.
--
-- @param flat The data to convert.
-- @return The grid data.
function artisanryutil.flat_to_grid(flat)
	local grid = {}
	
	for row_index = 1, 5, 1 do
		local row = {}
		
		for column_index = 1, 5, 1 do
			row[column_index] = flat[(row_index - 1) * 5 + column_index]
		end
		
		grid[row_index] = row
	end
	
	return grid
end

--- Checks if the given item is empty. That means if it is either nil, an empty
-- string or an ItemStack that is empty.
--
-- @param item The item to check.
-- @return true if the item can be considered empty.
function artisanryutil.is_empty_item(item)
	if item == nil or item == "" then
		return true
	end
	
	if type(item) == "userdata" then
		return item:is_empty()
	end
	
	return false
end

--- Checks if the given array of ItemStacks is empty, meaning either all
-- are nil, or all are empty.
--
-- @param input The array of ItemStacks.
-- @return true if all are nil or empty.
function artisanryutil.is_empty_stacks(input)
	if input == nil then
		return true
	end
	
	for index, part in ipairs(input) do
		if part ~= nil and not part:is_empty() then
			return false
		end
	end
	
	return true
end

