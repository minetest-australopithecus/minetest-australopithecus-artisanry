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


--- ArtisanryUI is a static, global object that allows to replace the inventory
-- with the Artisanry one.
ArtisanryUI = {
	artisanry = nil,
	formspec = "",
	hashes = {},
	last_blueprints_cache = {}
}


--- Activates the ArtinsaryUI.
--
-- This function replaces all inventories of all currently coneccted players
-- and also registers a callback to replace the inventory of every new player.
--
-- @param artisanry The Artisanry instance to use.
-- @param interval Optional. The interval which is used by the system,
--                 the inventories and crafting tables or all players is updated
--                 in this interval.
function ArtisanryUI.activate(artisanry, interval)
	interval = interval or 0.123
	
	ArtisanryUI.artisanry = artisanry
	ArtisanryUI.formspec = ArtisanryUI.build_formspec()
	
	ArtisanryUI.replace_inventories()
	
	minetest.register_on_joinplayer(function(player)
		ArtisanryUI.replace_inventory(player)
	end)
	
	local timer = 0
	minetest.register_globalstep(function(elapsed_time)
		timer = timer + elapsed_time;
		if timer >= interval then
			timer = 0
			
			ArtisanryUI.update_inventories()
		end
	end)
end

--- Builds the formspec for the ArtisanryUI inventory.
--
-- @return The formspec for the inventory.
function ArtisanryUI.build_formspec()
	local window = "size[14,12;]"
	window = window .. "bgcolor[#00000000;true]"
	window = window .. "listcolors[#00000000;#FFFFFF33]"
	
	local input_background = ""
	local result_background = ""
	
	for y = 4, 0, -1 do
		for x = 0, 4, 1 do
			input_background = input_background .. "background[" .. x .. "," .. y .. ";3,3;artisanry_light_tile.png]"
			result_background = result_background .. "background[" .. (x + 7) .. "," .. y .. ";3,3;artisanry_dark_tile.png]"
		end
	end
	
	local inventory_background = ""
	
	for y = 9, 7, -1 do
		for x = 2, 9, 1 do
			inventory_background = inventory_background .. "background[" .. x .. "," .. y .. ";3,3;artisanry_light_tile.png]"
		end
	end
	
	for x = 2, 9, 1 do
			inventory_background = inventory_background .. "background[" .. x .. ",6;3,3;artisanry_light_tile.png]"
	end
	
	local input = "list[current_player;artisanry-input;1,1;5,5;]"
	local result = "list[current_player;artisanry-output;8,1;5,5;]"
	local inventory = "list[current_player;main;3,7;8,4;]"
	
	local formspec = window .. input_background .. result_background .. inventory_background .. input .. result .. inventory
	
	return formspec

end

--- Checks if the inventory has changed compared to the saved hash.
--
-- @param player The Player object that owns the inventory.
-- @param inventory_name The name of the inventory.
-- @return true if the inventory has changed since the last check. Also true if
--         there is no saved hash for this inventory.
function ArtisanryUI.has_changed(player, inventory_name)
	local player_name = player:get_player_name()
	local hashes = ArtisanryUI.hashes[player_name]
	
	if hashes == nil or hashes[inventory_name] == nil then
		-- Return true if we don't have a hash by now to force an update.
		return true
	end
	
	local hash = hashes[inventory_name]
	
	return not inventoryutil.equals_hash(player:get_inventory(), inventory_name, hash)
end

--- Puts the hash of the inventory, for using it later.
--
-- @param player The Player object that owns the inventory.
-- @param inventory_name The name of the inventory.
function ArtisanryUI.put_hash(player, inventory_name)
	local player_name = player:get_player_name()
	local hashes = ArtisanryUI.hashes[player_name]
	
	if hashes == nil then
		hashes = {}
		ArtisanryUI.hashes[player_name] = hashes
	end
	
	hashes[inventory_name] = inventoryutil.hash(player:get_inventory(), inventory_name)
end

--- Replaces the inventory of every currently connected player with
-- the ArtisanryUI one.
function ArtisanryUI.replace_inventories()
	for index, player in ipairs(minetest.get_connected_players()) do
		ArtisanryUI.replace_inventory(player)
	end
end

--- Replaces the inventory of the given player with the ArtisanryUI one.
--
-- @param player The player for which to replace the inventory.
function ArtisanryUI.replace_inventory(player)
	player:get_inventory():set_size("artisanry-input", 25)
	player:get_inventory():set_size("artisanry-output", 25)
	player:set_inventory_formspec(ArtisanryUI.formspec)
	
	ArtisanryUI.last_blueprints_cache[player:get_player_name()] = List:new()
end

--- Updates the inventories of all connected players.
function ArtisanryUI.update_inventories()
	for index, player in ipairs(minetest.get_connected_players()) do
		ArtisanryUI.update_inventory(player)
	end
end

--- Updates from the input inventory of the given player.
--
-- @param player The player for which to update the inventories.
function ArtisanryUI.update_from_input_inventory(player)
	local inventory = player:get_inventory()
	
	local input = inventory:get_list("artisanry-input")
	local index = 1
	
	if not artisanryutil.is_empty_stacks(input) then	
		local blueprints = ArtisanryUI.last_blueprints_cache[player:get_player_name()]
		blueprints:clear()
		
		local result, decremented_input = minetest.get_craft_result({
			method = "normal",
			width = 5,
			items = input
		})
		
		if not result.item:is_empty() then
			inventory:set_stack("artisanry-output", index, result.item)
			blueprints:add({
				decremented_input = decremented_input,
				result = result
			})
			
			index = index + 1
		end
		
		input = artisanryutil.flat_to_grid(input)
		
		ArtisanryUI.artisanry:get_blueprints(input):foreach(function(blueprint)
			inventory:set_stack("artisanry-output", index, blueprint.result)
			blueprints:add(blueprint)
			
			index = index + 1
		end)
	end
	
	while index <= 25 do
		inventory:set_stack("artisanry-output", index, nil)
		index = index + 1
	end
end

--- Updates the inventory of the given player.
--
-- @param player The player for which to update the inventory.
function ArtisanryUI.update_inventory(player)
	if ArtisanryUI.has_changed(player, "artisanry-input") then
		ArtisanryUI.update_from_input_inventory(player)
	
		ArtisanryUI.put_hash(player, "artisanry-input")
		ArtisanryUI.put_hash(player, "artisanry-output")
	end
	
	if ArtisanryUI.has_changed(player, "artisanry-output") then
		ArtisanryUI.update_from_output_inventory(player)
		
		ArtisanryUI.put_hash(player, "artisanry-output")
	end
end

--- Updates from the output inventory of the given player.
--
-- @param player The player for which to update the inventories.
function ArtisanryUI.update_from_output_inventory(player)
	local output_hash = ArtisanryUI.hashes[player:get_player_name()]["artisanry-output"]
	local difference = inventoryutil.difference_hash(player:get_inventory(), "artisanry-output", output_hash)
	
	local inventory = player:get_inventory()
	local input = inventory:get_list("artisanry-input")
	local input_grid = artisanryutil.flat_to_grid(input)
	local converted_input = artisanryutil.convert(input_grid)
	
	for index = 1, 25, 1 do
		local item_difference = difference[index]
		
		if item_difference.count < 0 then
			local blueprints = ArtisanryUI.last_blueprints_cache[player:get_player_name()]
			
			blueprints:foreach(function(blueprint)
				if blueprint.decremented_input ~= nil then
					inventory:set_list("artisanry-input", blueprint.decremented_input.items)
					return
				elseif minetest.get_content_id(blueprint:get_result():get_name()) == item_difference.id then
					local start_row = arrayutil.next_matching_row(input_grid, nil, function(item)
						return not artisanryutil.is_empty_item(item)
					end)
					local start_column = arrayutil.next_matching_column(input_grid, nil, function(item)
						return not artisanryutil.is_empty_item(item)
					end)
					
					local blueprint_input = blueprint:get_input()
					
					for row_index = start_row, start_row + #blueprint_input - 1, 1 do
						local blueprint_row = blueprint_input[row_index - start_row + 1]
						
						for column_index = start_column, start_column + #blueprint_row - 1, 1 do
							local inventory_index = (row_index - 1) * 5 + column_index
							
							local current_stack = input_grid[row_index][column_index]
							local blueprint_stack = blueprint_row[column_index - start_column + 1]
							
							current_stack:set_count(current_stack:get_count() - blueprint_stack:get_count())
							
							inventory:set_stack("artisanry-input", inventory_index, current_stack)
						end
					end
					
					return
				end
			end)
		end
	end
end

