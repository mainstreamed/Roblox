local drawing_new = Drawing.new;
local getchildren = game.GetChildren;
local findfirstchild = game.FindFirstChild;
local getservice = game.GetService;
local vector2_new = Vector2.new;
local color3_new = Color3.new;
local color3_fromrgb = Color3.fromRGB;
local cframe_new = CFrame.new;
local instance_new = Instance.new;
local math_huge = math.huge;
local table_insert = table.insert;

local userinputservice = getservice(game, 'UserInputService');
local camera = workspace.CurrentCamera
local menuwidth = camera.ViewportSize.X / 18

local function createDrawing(type, properties, add)
	local drawing = drawing_new(type);
	if (properties) then
		for index, value in properties do
			drawing[index] = value;
		end
	end
	if (add) then
		for index, value in add do
			table_insert(value, drawing);
		end
	end
	return drawing;
end

-- main library
local library = {
	inputs = { -- all functions used for inputs (to save connections)
		Up = {},
		Down = {},
		Right = {},
		Left = {},
		Return = {},
		Backspace = {},
	},
	tabinfo = { -- all tab data here
		active = false,
		amount = 0,
		selected = 1,
		tabs = {},
	},
	alldrawings = {}, -- all drawings get stored in here
}
getgenv().flags = {}
-- library functions
do
	-- add arrow input function
	function library:dInput(key, func)
		table_insert(library.inputs[key], func);
	end
	function library:Unload()
		for _, value in library.alldrawings do
			value:Remove();
		end
		library.mainconnection:Disconect();
		library = nil;
	end
end
-- initialise
do
	-- detecting inputs (reducing connections)
	library.mainconnection = userinputservice.InputBegan:Connect(function(key)
		local funcs = library.inputs[key.KeyCode.Name];
		if (funcs) then
			for _, func in funcs do
				func();
			end
		end
	end)
	-- inputs for going up and down the tabs
	library:dInput('Up', function()
		local ti = library.tabinfo;
		if (not ti.active and ti.selected > 1) then
			ti.tabs[ti.selected]:hovered();
			ti.selected-=1;
			ti.tabs[ti.selected]:hovered();
		end
	end)
	library:dInput('Down', function()
		local ti = library.tabinfo;
		if not (not ti.active and ti.selected > 1) then
			ti.tabs[ti.selected]:hovered();
			ti.selected+=1;
			ti.tabs[ti.selected]:hovered();
		end
	end)
	library:dInput('Return', function()
		local ti = library.tabinfo;
		if (ti.active) then
			return;
		end
		ti.tabs[ti.selected]:open();
	end)
	library:dInput('Backspace', function()
		local ti = library.tabinfo;
		if (not ti.active) then
			return;
		end
		ti.tabs[ti.selected]:close();
	end)
end
-- user functions
do
	function library:AddTab(text)
		-- tab startup
		local hovered = false;
		if (library.tabinfo.amount == 0) then
			hovered = true;
		end
		library.tabinfo.amount += 1;
		-- creating tab
		local tab = {
			hovered = false,
			opened = false,
			selected = 1,
			drawings = {},
			options = {
				amount = 0,
				stored = {},
			},
		}
		-- creating drawings
		do
			tab.drawings.base = createDrawing('Square', {
				Visible = true,
				Color = color3_fromrgb(0, 0, 0),
				Transparency = 0.5,
				Filled = true,
				Position = vector2_new(0, 40 + (library.tabinfo.amount * 15)),
				Size = vector2_new(menuwidth, 15),
			}, {library.alldrawings})
			tab.drawings.text = createDrawing('Text', {
				Visible = true,
				Color = color3_fromrgb(255, 255, 255),
				Font = 2,
				Position = tab.drawings.base.Position,
				Size = 13,
				Text = text,
			}, {library.alldrawings})
			tab.drawings.arrow = createDrawing('Text', {
				Visible = true,
				Color = color3_fromrgb(255, 255, 255),
				Text = '>',
				Font = 2,
				Position = tab.drawings.base.Position + vector2_new(menuwidth-10, 0),
				Size = 13,
			}, {library.alldrawings})

		end
		-- functions
		do
			function tab:hovered(boolean)
				if (boolean == nil) then
					boolean = not tab.opened;
				end
				tab.hovered = boolean;
				if (boolean) then
					tab.drawings.base.Color = color3_fromrgb(255, 0, 0);
					return;
				end
				tab.drawings.base.Color = color3_fromrgb(0, 0, 0);
			end
			function tab:open()
				if (tab.opened) then
					return;
				end
				library.tabinfo.active = true;
				tab.opened = true;
				tab.drawings.arrow.Text = '>';
				for _, option in tab.options do
					for _, drawing in option.drawings do
						drawing.Visible = true;
					end
				end
			end
			function tab:close()
				if (not tab.opened) then
					return;
				end
				library.tabinfo.active = false;
				tab.opened = false;
				tab.drawings.arrow.Text = '<';
				for _, option in tab.options do
					for _, drawing in option.drawings do
						drawing.Visible = false;
					end
				end
			end
			tab.navUp = function()
				if (tab.opened and tab.selected < tab.options.amount) then
					local current = tab.options.stored[tab.selected];
					current.hovered = false;
					current.drawings.base.Color = color3_fromrgb(0, 0, 0);
					tab.selected -= 1;
					local current = tab.options.stored[tab.selected];
					current.hovered = true;
					current.drawings.base.Color = color3_fromrgb(255, 0, 0);
				end
			end
			tab.navDown = function()
				if (tab.opened and tab.selected > 1) then
					local current = tab.options.stored[tab.selected];
					current.hovered = false;
					current.drawings.base.Color = color3_fromrgb(0, 0, 0);
					tab.selected += 1;
					local current = tab.options.stored[tab.selected];
					current.hovered = true;
					current.drawings.base.Color = color3_fromrgb(255, 0, 0);
				end
			end
			function tab:AddToggle(prop)
				tab.options.amount += 1;
				local toggle = {
					hovered = false,
					enabled = prop.default or false,
					flag = {
						value = prop.default or false,
					},
					drawings = {},
				}
				-- flags
				do
					toggle.flag.Changed = function() end
					if (prop.flag) then
						function toggle.flag:OnChanged(func)
							toggle.flag.Changed = func;
							func()
						end
						flags[prop.flag] = toggle.flag
					end
				end
				-- drawings
				do
					toggle.drawings.base = createDrawing('Square', {
						Transparency = 0.5,
						Filled = true,
						Position = tab.drawings.base.Position + vector2_new(menuwidth + 10, tab.options.amount*15),
						Size = vector2_new(menuwidth, 15),
					}, {library.alldrawings})
					toggle.drawings.text = createDrawing('Text', {
						Color = color3_fromrgb(255, 255, 255),
						Visible = true,
						Font = 2,
						Position = toggle.drawings.base.Position,
						Size = 13,
						Text = prop.text or 'Toggle',
					}, {library.alldrawings})
				end
				--functions 
				do
					toggle.toggle = function(boolean)
						if (not toggle.hovered) then
							return;
						end
						if (boolean == nil) then
							boolean = not toggle.enabled;
						end
						toggle.enabled = boolean;
						if (boolean) then
							toggle.drawings.text.Color = color3_fromrgb(255, 255, 255);
							return; 
						end
						toggle.drawings.text.Color = color3_fromrgb(79, 79, 79);
					end
				end
				-- functionality / cleanup
				do
					library:dInput('Return', toggle.toggle)
					if (toggle.enabled) then
						toggle.drawings.textmain.Color = color3_fromrgb(255, 255, 255); 
					else
						toggle.drawing.textmain.Color = color3_fromrgb(79, 79, 79);
					end
					if (tab.options.amount == 1) then
						toggle.hovered = true;
						toggle.drawings.base.Color = color3_fromrgb(255, 0, 0);
					end

				end
				table_insert(tab.options.stored, toggle)
			end
			function tab:AddSlider(prop)
				tab.options.amount += 1
				local slider = {
					hovered = false,
					text = prop.text or 'Slider',
					value = prop.default or prop.min,
					suffix = prop.suffix or '',
					flag = {
						value = prop.default or prop.min,
					},
					drawings = {},
				}
				-- flags
				do
					slider.flag.Changed = function() end
					if (prop.flag) then
						function slider.flag:OnChanged(func)
							slider.flag.Changed = func;
							func()
						end
						flags[prop.flag] = slider.flag
					end
				end
				-- drawings
				do
					slider.drawings.base = createDrawing('Square', {
						Transparency = 0.5,
						Filled = true,
						Position = tab.drawings.base.Position + vector2_new(menuwidth + 10, tab.options.amount*15),
						Size = vector2_new(menuwidth, 15),
					}, {library.alldrawings})
					slider.drawings.text = createDrawing('Text', {
						Color = color3_fromrgb(255, 255, 255),
						Visible = true,
						Font = 2,
						Position = slider.drawings.base.Position,
						Size = 13,
					}, {library.alldrawings})
				end
				--functions 
				do
					slider.updatetext = function()
						slider.drawings.textmain.Text = slider..': '..slider.value..slider.suffix;
					end
					slider.increase = function()
						if (not slider.hovered) then
							return;
						end
						local val = slider.value + 1;
						if (val <= prop.max) then
							slider.value = val;
							slider.updatetext();
						end
					end
					slider.decrease = function()
						if (not slider.hovered) then
							return;
						end
						local val = slider.value - 1;
						if (val >= prop.min) then
							slider.value = val;
							slider.updatetext();
						end
					end
				end
				-- functionality / cleanup
				do
					slider.updatetext()

					library:dInput('Right', slider.increase);
					library:dInput('Left', slider.decrease);

					if (tab.options.amount == 1) then
						slider.hovered = true;
						slider.drawings.base.Color = color3_fromrgb(255, 0, 0);
					end
				end

				table_insert(tab.options.stored, slider)
			end
		end
		-- functionality / cleanup
		do
			tab:hovered(hovered);
			library:dInput('Up', tab.navUp);
			library:dInput('Down', tab.navDown);
		end
		table_insert(library.tabinfo.tabs, tab);
	end
end

return library;
