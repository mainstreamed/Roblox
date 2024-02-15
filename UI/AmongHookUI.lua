local drawing_new = Drawing.new;
local getchildren = game.GetChildren;
local findfirstchild = game.FindFirstChild;
local getservice = game.GetService;
local vector2_new = Vector2.new;
local color3_new = Color3.new;
local color3_fromrgb = Color3.fromRGB;
local cframe_new = CFrame.new;
local userinputservice = getservice(game, 'UserInputService');
local instance_new = Instance.new;
local math_huge = math.huge;
local table_insert = table.insert;

local camera = workspace.CurrentCamera
local screensize = camera.ViewportSize
local globalwidth = screensize.X / 18

local library = {
	tabamount = 0,
	tabselected = 1,
    tabopened = false,
	inputfunctions = {
		Up = {},
		Down = {},
		Right = {},
		Left = {},
		Return = {},
		Backspace = {},
	},
	tabs = {},
	alldrawings = {},
};

local function createDrawing(type, properties, add)
	local drawing = drawing_new(type)
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

do
    userinputservice.InputBegan:Connect(function(key)
        local funcs = library.inputfunctions[key.KeyCode.Name];
        if (funcs) then
            for index, value in funcs do
                value()
            end
        end
    end)
    table_insert(library.inputfunctions.Up, function()
        if (not library.tabopened and library.tabselected > 1) then
            library.tabs[library.tabselected]:Toggle()
            library.tabselected-=1
            library.tabs[library.tabselected]:Toggle()
        end
    end)
    table_insert(library.inputfunctions.Down, function()
        if (not library.tabopened and library.tabselected < library.tabamount) then
            library.tabs[library.tabselected]:Toggle()
            library.tabselected+=1
            library.tabs[library.tabselected]:Toggle()
        end
    end)
end

function library:AddTab(name)
	local selected = false;
	if (library.tabamount == 0) then
		selected = true;
	end
	library.tabamount += 1;
	local tab = {
		selected = selected,
		opened = false,
        selected_option = 1,
		drawings = {},
        option = {},
		options = 0,
	}
	-- drawings
	do
		tab.drawings.base = createDrawing('Square', {
			Visible = true,
			Transparency = 0.5,
			Filled = true,
			Position = vector2_new(0, 40 + (library.tabamount * 15)),
			Size = vector2_new(globalwidth, 15),
		}, {library.alldrawings})
		tab.drawings.textmain = createDrawing('Text', {
			Color = color3_new(1, 1, 1),
			Visible = true,
			Font = 2,
			Position = tab.drawings.base.Position,
			Size = 13,
			Text = name,
		}, {library.alldrawings})
		tab.drawings.arrow = createDrawing('Text', {
			Color = color3_new(1, 1, 1),
			Visible = true,
			Text = '>',
			Font = 2,
			Position = tab.drawings.base.Position + vector2_new(globalwidth-10, 0),
			Size = 13,
		}, {library.alldrawings})
	end
	-- functions
	do
		function tab:AddToggle(properties)
			tab.options += 1;
			local toggle = {
                hovered = false,
				enabled = properties.default or false,
				drawings = {},
			}
			-- drawings
			do
				toggle.drawings.base = createDrawing('Square', {
					Transparency = 0.5,
					Filled = true,
					Position = tab.drawings.base.Position + vector2_new(globalwidth + 10, 0),
					Size = vector2_new(globalwidth, 15),
				}, {library.alldrawings})
				toggle.drawings.textmain = createDrawing('Text', {
					Color = color3_new(1, 1, 1),
					Visible = true,
					Font = 2,
					Position = toggle.drawings.base.Position,
					Size = 13,
					Text = properties.text or 'Toggle',
				}, {library.alldrawings})
			end
			-- functions
			do
				toggle.toggle = function(boolean)
                    if (toggle.hovered) then
                        if (boolean == nil) then
                            boolean = not toggle.enabled;
                        end
                        toggle.enabled = boolean
                        if (boolean) then
                            toggle.drawings.textmain.Color = color3_new(1, 1, 1); 
                        else
                            toggle.drawing.textmain.Color = color3_fromrgb(79, 79, 79);
                        end
                    end
				end
			end
            -- functionality
            do
                table_insert(library.inputfunctions.Return, toggle.toggle)
                if (toggle.enabled) then
                    toggle.drawings.textmain.Color = color3_new(1, 1, 1); 
                else
                    toggle.drawing.textmain.Color = color3_fromrgb(79, 79, 79);
                end
            end
            table_insert(tab.option, toggle)
		end
		function tab:AddSlider(properties)
			tab.options += 1;
			local slider = {
				hovered = false,
				value = properties.default or properties.min,
				drawings = {},
			}
			-- drawings
			do
				slider.drawings.base = createDrawing('Square', {
					Transparency = 0.5,
					Filled = true,
					Position = tab.drawings.base.Position + vector2_new(globalwidth + 10, 0),
					Size = vector2_new(globalwidth, 15),
				}, {library.alldrawings})
				slider.drawings.textmain = createDrawing('Text', {
					Color = color3_new(1, 1, 1),
					Visible = true,
					Font = 2,
					Position = slider.drawings.base.Position,
					Size = 13,
					Text = (properties.text or 'Slider')..': '..slider.value,
				}, {library.alldrawings})
			end
			-- functions
			do
				function slider:updateValue()
					slider.drawings.textmain.Text = (properties.text or 'Slider')..': '..slider.value;
				end
				slider.increase = function()
                    if (slider.hovered) then
                        local val = slider.value + 1;
                        if (val <= properties.max) then
                            slider.value = val;
                            slider:updateValue();
                        end
                    end
				end
				slider.decrease = function()
                    if (slider.hovered) then
                        local val = slider.value - 1;
                        if (val >= properties.min) then
                            slider.value = val;
                            slider:updateValue();
                        end
                    end
				end
			end
			-- hook
			do
                table_insert(library.inputfunctions.Right, slider.increase)
                table_insert(library.inputfunctions.Left, slider.decrease)
			end
            table_insert(tab.option, slider)
		end
		function tab:Toggle(boolean)
			if (boolean == nil) then
				boolean = not tab.selected
			end
			if (boolean) then
				tab.drawings.base.Color = color3_new(1, 0, 0);
			else
				tab.drawings.base.Color = color3_new(0, 0, 0);
			end
            tab.selected = boolean
		end
        tab.open = function()
            if (not tab.opened) then
                tab.drawings.arrow.Text = '>'
                library.tabopened = true;
                tab.opened = true;
                for index, value in option do
                    for index, value in value.drawings do
                        value.Visible = true;
                    end
                end
            end
        end
        tab.close = function()
            if (tab.opened) then
                tab.drawings.arrow.Text = '<'
                library.tabopened = false;
                tab.opened = false;
                for index, value in option do
                    for index, value in value.drawings do
                        value.Visible = false;
                    end
                end
            end
        end
        tab.navigateDown = function()
            if (tab.opened and tab.selected_option < tab.options) then
                local old = tab.option[tab.selected_option]
                old.hovered = false
                old.drawings.base.Color = color3_new(1, 0, 0);
                tab.selected_option+=1
                local new = tab.option[tab.selected_option]
                new.hovered = true
                new.drawings.base.Color = color3_new(0, 0, 0);
            end
        end
        tab.navigateUp = function()
            if (tab.opened and tab.selected_option > 1) then
                local old = tab.option[tab.selected_option]
                old.hovered = false
                old.drawings.base.Color = color3_new(1, 0, 0);
                tab.selected_option-=1
                local new = tab.option[tab.selected_option]
                new.hovered = true
                new.drawings.base.Color = color3_new(0, 0, 0);
            end
        end
	end
	-- functionality
	do
		tab:Toggle(tab.selected)

        table_insert(library.inputfunctions.Return, tab.open)
        table_insert(library.inputfunctions.Backspace, tab.close)

        table_insert(library.inputfunctions.Up, tab.navigateUp)
        table_insert(library.inputfunctions.Down, tab.navigateDown)
	end

	table_insert(library.tabs, tab)
end

return library;
