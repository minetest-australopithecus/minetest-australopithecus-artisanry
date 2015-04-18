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
	input_hashes = {}
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
	interval = interval or 0.3333
	
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
	
	local input = "list[current_player;input;1,1;5,5;]"
	local result = "list[current_player;result;8,1;5,5;]"
	local inventory = "list[current_player;main;3,7;8,4;]"
	
	local formspec = window .. input_background .. result_background .. inventory_background .. input .. result .. inventory
	
	return formspec
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
	player:get_inventory():set_size("input", 25)
	player:get_inventory():set_size("result", 25)
	player:set_inventory_formspec(ArtisanryUI.formspec)
end

--- Converts the given ItemStacks to a string.
--
-- @param stacks The ItemStacks to convert to a string.
-- @return The string representing the given ItemStacks.
function ArtisanryUI.stacks_to_string(stacks)
	local value = ""
	
	for index = 1, 25, 1 do
		local stack = stacks[index]
		
		if stack ~= nil and not stack:is_empty() then
			value = value .. stack:to_string() .. ";"
		end
		
		value = value .. ";"
	end
	
	return value
end

--- Updates the inventories of all connected players.
function ArtisanryUI.update_inventories()
	for index, player in ipairs(minetest.get_connected_players()) do
		ArtisanryUI.update_inventory(player)
	end
end

--- Updates the inventory of the given player.
--
-- @param player The player for which to update the inventory.
function ArtisanryUI.update_inventory(player)
	local player_name = player:get_player_name()
	
	local inventory = player:get_inventory()
	local cached_hash = ArtisanryUI.input_hashes[player_name]
	
	if inventoryutil.equals_hash(inventory, "input", cached_hash) then
		return
	end
	
	ArtisanryUI.input_hashes[player_name] = inventoryutil.hash(inventory, "input")
	
	local input = inventory:get_list("input")
	local index = 1
	
	if not artisanryutil.is_empty_stacks(input) then
		local result = minetest.get_craft_result({
			method = "normal",
			width = 5,
			items = input
		})
		
		if not result.item:is_empty() then
			inventory:set_stack("result", index, result.item)
			index = index + 1
		end
		
		input = artisanryutil.flat_to_grid(input)
		
		ArtisanryUI.artisanry:get_blueprints(input):foreach(function(value)
			inventory:set_stack("result", index, value.result)
			
			index = index + 1
		end)
	end
	
	while index <= 25 do
		inventory:set_stack("result", index, nil)
		index = index + 1
	end
end

