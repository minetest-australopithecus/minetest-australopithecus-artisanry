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


function ItemStack(value)
	local stack = {
		count = 0,
		name = "",
		
		add_item = function(self, item)
		end,
		
		add_wear = function(self, amount)
		end,
		
		clear = function(self)
			self.count = 0
			self.name = ""
		end,
		
		get_count = function(self)
			return self.count
		end,
		
		get_definition = function(self)
		end,
		
		get_free_space = function(self)
		end,
		
		get_metadata = function(self)
		end,
		
		get_name = function(self)
			return self.name
		end,
		
		get_stack_max = function(self)
		end,
		
		get_tool_capabilities = function(self)
		end,
		
		get_wear = function(self)
		end,
		
		is_empty = function(self)
			return self.count == 0
		end,
		
		is_known = function(self)
			return true
		end,
		
		items_fits = function(self, item)
		end,
		
		peek_item = function(self, n)
		end,
		
		replace = function(self, item)
		end,
		
		set_count = function(self, count)
			self.count = count
		end,
		
		set_name = function(self, item_name)
			self.name = item_name
		end,
		
		set_metadata = function(self)
		end,
		
		set_wear = function(self, wear)
		end,
		
		take_item = function(self, n)
		end,
		
		to_string = function(self)
			if stack.is_empty() then
				return ""
			else
				local value = stack.name
				
				if stack.count > 1 then
					value = value .. " " .. stack.count
				end
				
				return value
			end
		end,
		
		to_table = function(self)
		end
	}
	
	if value ~= nil and value ~= "" then
		local splitted = stringutil.split(value, " ")
		
		stack:set_name(splitted:get(0))
		
		if splitted:size() > 1 then
			stack:set_count(splitted:get(1))
		end
	end
	
	return stack
end

