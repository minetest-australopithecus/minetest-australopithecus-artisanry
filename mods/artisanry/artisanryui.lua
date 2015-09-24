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


--- artisanryui is a static, global object that allows to replace the inventory
-- with the Artisanry one.
artisanryui = {
	--- The Artisanry object that is used.
	artisanry = nil,
	
	--- The provider that provides the formspec for players inventory.
	formspec_provider = nil,
	
	--- The last blueprints of the players.
	last_blueprints_cache = {},
	
	--- The inventory that is used for the input and output fields.
	inventory = nil,
	
	--- The size of the output field.
	output_size = nil,
	
	--- The cache what page the players are currently looking at.
	pages = {}
}


--- Activates the ArtinsaryUI.
--
-- This function replaces all inventories of all currently connected players
-- and also registers a callback to replace the inventory of every new player.
--
-- @param artisanry The Artisanry instance to use.
-- @param formspec_provider Optional. The provider for the formspec that is
--                          to replace the inventories of the players. This is
--                          a function that accepts the Player object and
--                          returns the formspec. The important fields for
--                          the formspec are a detached inventory with the name
--                          "artisanrui" with the lists "PLAYERNAME-input" and
--                          "PLAYERNAME-output", as two buttons with the names
--                          "artisanryui-PLAYERNAME-next-page" and
--                          "artisanryui-PLAYERNAME-previous-page". Can be nil
--                          for the default one.
-- @param output_size Optional. The size of the output field in the custom
--                    formspec, as in how many single slots there are. Can be
--                    nil for the default value of 35 (7 * 5).
function artisanryui.activate(artisanry, formspec_provider, output_size)
	artisanryui.artisanry = artisanry
	artisanryui.formspec_provider = formspec_provider or artisanryui.build_formspec
	artisanryui.output_size = output_size or (7 * 5)
	artisanryui.inventory = artisanryui.create_inventory()
	
	artisanryui.replace_inventories()
	
	minetest.register_on_joinplayer(artisanryui.replace_inventory)
	minetest.register_on_player_receive_fields(artisanryui.scroll_page)
end

--- Builds the formspec for the artisanryui inventory.
--
-- @param player The player.
-- @return The formspec for the inventory.
function artisanryui.build_formspec(player)
	local window = "size[15,12;]"
	window = window .. "bgcolor[#00000000;true]"
	window = window .. "listcolors[#00000000;#FFFFFF33]"
	
	local input_background = ""
	
	for y = 4, 0, -1 do
		for x = 0, 4, 1 do
			input_background = input_background .. "background[" .. x .. "," .. y .. ";3,3;artisanry_craft_bg.png]"
		end
	end
	
	local result_background = ""
	
	for y = 4, 0, -1 do
		for x = 0, 6, 1 do
			result_background = result_background .. "background[" .. (x + 6) .. "," .. y .. ";3,3;artisanry_output_bg.png]"
		end
	end
	
	local inventory_background = ""
	
	for y = 9, 7, -1 do
		for x = 2, 9, 1 do
			inventory_background = inventory_background .. "background[" .. x .. "," .. y .. ";3,3;artisanry_inventory_bg.png]"
		end
	end
	
	for x = 2, 9, 1 do
			inventory_background = inventory_background .. "background[" .. x .. ",6;3,3;artisanry_inventory_bg.png]"
	end
	
	local input = "list[detached:artisanryui;" .. player:get_player_name() .. "-input;1,1;5,5;]"
	local result = "list[detached:artisanryui;" .. player:get_player_name() .. "-output;7,1;7,5;]"
	
	local previous_button = "button[7,6;2,1;artisanryui-" .. player:get_player_name() .. "-previous-page;<<]"
	local next_button = "button[12,6;2,1;artisanryui-" .. player:get_player_name() .. "-next-page;>>]"
	
	local inventory = "list[current_player;main;3,7;8,4;]"
	
	local ring = "listring[current_player;main]"
	ring = ring .. "listring[detached:artisanryui;" .. player:get_player_name() .. "-input]"
	ring = ring .. "listring[current_player;main]"
	ring = ring .. "listring[detached:artisanryui;" .. player:get_player_name() .. "-output]"
	ring = ring .. "listring[current_player;main]"
	
	local formspec = window
		.. input_background
		.. result_background
		.. previous_button
		.. next_button
		.. inventory_background
		.. input
		.. result
		.. inventory
		.. ring
	
	return formspec
end

--- Creates a detached inventory that is used.
--
-- @return The detached inventory.
function artisanryui.create_inventory()
	return minetest.create_detached_inventory("artisanryui", {
		allow_move = function(inventory, from_list, from_index, to_list, to_index, count, player)
			-- Disallow putting if this is an output inventory.
			if stringutil.endswith(to_list, "-output") then
				return 0
			else
				return count
			end
		end,
		
		allow_put = function(inventory, listname, index, stack, player)
			-- Disallow putting if this is an output inventory.
			if stringutil.endswith(listname, "-output") then
				return 0
			else
				return stack:get_count()
			end
		end,
		
		allow_take = function(inventory, listname, index, stack, player)
			return stack:get_count()
		end,
		
		on_move = function(inventory, from_list, from_index, to_list, to_index, count, player)
			if stringutil.endswith(from_list, "-output") then
				artisanryui.update_player_inventory(player, inventory:get_stack(to_list, to_index))
			end
			
			artisanryui.update_from_input_inventory(player)
		end,
		
		on_put = function(inventory, listname, index, stack, player)
			artisanryui.update_from_input_inventory(player)
		end,
		
		on_take = function(inventory, listname, index, stack, player)
			if stringutil.endswith(listname, "-output") then
				artisanryui.update_player_inventory(player, stack)
			end
			
			artisanryui.update_from_input_inventory(player)
		end
	})
end

--- Replaces the inventory of every currently connected player with
-- the artisanryui one.
function artisanryui.replace_inventories()
	for index, player in ipairs(minetest.get_connected_players()) do
		artisanryui.replace_inventory(player)
	end
end

--- Replaces the inventory of the given player with the artisanryui one.
--
-- @param player The player for which to replace the inventory.
function artisanryui.replace_inventory(player)
	artisanryui.inventory:set_size(player:get_player_name() .. "-input", 5 * 5)
	artisanryui.inventory:set_size(player:get_player_name() .. "-output", artisanryui.output_size)
	
	player:set_inventory_formspec(artisanryui.formspec_provider(player))
	
	artisanryui.last_blueprints_cache[player:get_player_name()] = List:new()
	
	artisanryui.pages[player:get_player_name()] = {
		current = 1,
		max = 1
	}
	
	artisanryui.update_from_input_inventory(player)
end

--- Callback for when the scroll buttons are pressed.
--
-- @param player The Player object from which the event originated.
-- @param formname The name of the form.
-- @param fields The fields.
function artisanryui.scroll_page(player, formname, fields)
	if fields["artisanryui-" .. player:get_player_name() .. "-next-page"] ~= nil then
		local pages = artisanryui.pages[player:get_player_name()]
		pages.current = math.min(pages.current + 1, pages.max)
		
		artisanryui.update_from_input_inventory(player)
	elseif fields["artisanryui-" .. player:get_player_name() .. "-previous-page"] ~= nil then
		local pages = artisanryui.pages[player:get_player_name()]
		pages.current = math.max(pages.current - 1, 1)
		
		artisanryui.update_from_input_inventory(player)
	end
end

--- Updates from the input inventory of the given player.
--
-- @param player The player for which to update the inventories.
function artisanryui.update_from_input_inventory(player)
	local input = artisanryui.inventory:get_list(player:get_player_name() .. "-input")
	local index = 1
	
	local blueprints = artisanryui.last_blueprints_cache[player:get_player_name()]
	blueprints:clear()
	
	local page = artisanryui.pages[player:get_player_name()]
	local result, decremented_input = minetest.get_craft_result({
		method = "normal",
		width = 5,
		items = input
	})
	
	if not result.item:is_empty() and page.current == 1 then
		artisanryui.inventory:set_stack(player:get_player_name() .. "-output", index, result.item)
		blueprints:add({
			decremented_input = decremented_input,
			result = result
		})
		
		index = index + 1
	end
	
	input = artisanryutil.flat_to_grid(input)
	
	local start_index = (page.current - 1) * artisanryui.output_size + 1
	local output_blueprints = artisanryui.artisanry:get_blueprints(input)
	
	page.max = math.ceil(output_blueprints:size() / artisanryui.output_size)
	
	output_blueprints:sub_list(start_index, artisanryui.output_size):foreach(function(blueprint)
		artisanryui.inventory:set_stack(player:get_player_name() .. "-output", index, blueprint:get_result())
		blueprints:add(blueprint)
		
		index = index + 1
	end)
	
	while index <= artisanryui.output_size do
		artisanryui.inventory:set_stack(player:get_player_name() .. "-output", index, nil)
		index = index + 1
	end
end

--- Updates the players inventory based on the taken stack.
--
-- @param player The player for which to update the inventories.
-- @param taken_stack The ItemStack that was taken.
function artisanryui.update_player_inventory(player, taken_stack)
	local input = artisanryui.inventory:get_list(player:get_player_name() .. "-input")
	local input_grid = artisanryutil.flat_to_grid(input)
	
	local blueprints = artisanryui.last_blueprints_cache[player:get_player_name()]
	
	blueprints:foreach(function(blueprint)
		if blueprint:get_result():get_name() == taken_stack:get_name() then
			if blueprint.decremented_input ~= nil then
				-- This is an item registered with the default Minetest system.
				artisanryui.inventory:set_list(player:get_player_name() .. "-input", blueprint.decremented_input.items)
			else
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
						
						artisanryui.inventory:set_stack(player:get_player_name() .. "-input", inventory_index, current_stack)
					end
				end
			end
			
			return true
		end
	end)
end

