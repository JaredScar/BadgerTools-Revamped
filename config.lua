--[[
	~r~ = Red
	~b~ = Blue
	~g~ = Green
	~y~ = Yellow
	~p~ = Purple
	~c~ = Grey
	~m~ = Dark Grey
	~u~ = Black
	~o~ = Orange

	Special:
	~n~ = New line
	~s~ = Reset Color
	~h~ = Bold text
]]--
Config = {
	Prefix = '^9[^5BadgerTools^9] ^3',
	RoleList = {
		{0, "~b~Civilian | "},  
		{777956259184902187, "~RGB~"},
		{759610049521254411, "~r~Staff | "},  
		{759608678407340083, "~HALLOWEEN~Owner | "}, 
		{759608678407340083, "~AMERICA~Owner | "}, 
		{759608678407340083, "~DEVIL~Owner | "}, 
		{759608678407340083, "~CHRISTMAS~Owner | "},
		{759608678407340083, "~RGB~Owner | "}, 
	},
	ColorChangeSpeed = 300,
	ColorPatterns = {
		['~CHRISTMAS~'] = {'~r~', '~g~'},
		['~AMERICA~'] = {'~r~', '~w~', '~b~'},
		['~HALLOWEEN~'] = {'~o~', '~w~', '~u~'},
		['~DEVIL~'] = {'~r~', '~c~', '~m~', '~u~'},
		['~RGB~'] = {"~g~", "~b~", "~y~", "~o~", "~r~", "~p~", "~w~"},
	},
	OOC_Prefix = '~w~[~p~OOC~w~] ',
	OOC_Messages = {
		{
		x = .5,
		y = .65,
		size = .75,
		msg = '~r~You are rendered dead... Voice chat will be considered Out Of Character'
		},
		{
		x = .5,
		y = .69,
		size = .75,
		msg = '~b~Use /me for In Character'
		},
	},
	EnableVoiceOOC = true,
}