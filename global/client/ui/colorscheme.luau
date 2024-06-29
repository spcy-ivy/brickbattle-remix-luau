--[[
	colorscheme.luau

	just having global colorscheme variables is useful in case you want to make like the tiniest adjustment and not take a week on it

	gonna be based on the [base16 styling guide](https://github.com/chriskempson/base16/blob/main/styling.md)
]]

-- sorry that i make a type for everything im paranoid
type Colorscheme = {
	background: Color3,
	lighter_background: Color3,
	selection_background: Color3,
	comments: Color3,
	dark_text: Color3,
	text: Color3,
	light_text: Color3,
	light_background: Color3,
	red: Color3,
	orange: Color3,
	yellow: Color3,
	green: Color3,
	teal: Color3,
	blue: Color3,
	purple: Color3,
	pink: Color3,
}

type ColorschemeModule = {
	scheme: Colorscheme,
	font: Font,
}

local catppuccin_macchiato: Colorscheme = {
	background = Color3.fromHex("#24273a"),
	lighter_background = Color3.fromHex("#1e2030"),
	selection_background = Color3.fromHex("#363a4f"),
	comments = Color3.fromHex("#494d64"),
	dark_text = Color3.fromHex("#5b6078"),
	text = Color3.fromHex("#cad3f5"),
	light_text = Color3.fromHex("#f4dbd6"),
	light_background = Color3.fromHex("#b7bdf8"),
	red = Color3.fromHex("#ed8796"),
	orange = Color3.fromHex("#f5a97f"),
	yellow = Color3.fromHex("#eed49f"),
	green = Color3.fromHex("#a6da95"),
	teal = Color3.fromHex("#8bd5ca"),
	blue = Color3.fromHex("#8aadf4"),
	purple = Color3.fromHex("#c6a0f6"),
	pink = Color3.fromHex("#f0c6c6"),
}

local font = Font.new(
	"rbxasset://fonts/families/BuilderSans.json",
	Enum.FontWeight.Regular,
	Enum.FontStyle.Normal
)

-- since im a basic bitch we're going to be using catppuccin macchiato (the basic bitch flavor [the layers of basic bitch is crazy])
local colorscheme_module: ColorschemeModule = {
	scheme = catppuccin_macchiato,
	font = font,
}

return colorscheme_module
