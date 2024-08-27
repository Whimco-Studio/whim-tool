export type Quirkymal = {
	Type: string,
	Name: string,
	Skin: string,
	Title: string,
	Pronouns: string,
	CreationDate: string,
	Pets: string,
	Accessories: {
		Hat: string,
		FaceWear: string,
		BackWear: string,
	},
	Level: number,
	Experience: number,
	Location: string,
}

export type Player = {
	Skins: {},
	Friends: {},
	Achievements: {},
	Pets: { [number]: string },
	Quirkymals: { [number]: Quirkymal },

	Currency: number,
	CharacterSlots: number, -- default number of character slots
	ActiveCharacter: number, -- index of the currently active Quirkymal
	Inventory: {
		Pets: { [number]: string },
		Skins: { [number]: string },
		Items: { [number]: string },
		Quirkymals: { [number]: string },
	},
}

local Data = {}

Data.Message = {
	Sender = "",
	Content = "",
}

Data.Player = {
	["Friends"] = {},
	["Quirkymals"] = {},
	["Achievements"] = {},

	["Currency"] = 0,
	["CharacterSlots"] = 3, -- default number of character slots
	["ActiveCharacter"] = 1, -- index of the currently active Quirkymal
	["Inventory"] = {
		["Pets"] = {},
		["Skins"] = {},
		["Items"] = {},
		["Quirkymals"] = {},
	},
}

Data.Quirkymal = {
	["Type"] = "",
	["Name"] = "",
	["Skin"] = "",
	["Title"] = "",
	["Pronouns"] = "",
	["CreationDate"] = "",
	["Pets"] = {},
	["Accessories"] = {
		["Hat"] = "",
		["FaceWear"] = "",
		["BackWear"] = "",
	},
	["Level"] = 1,
	["Experience"] = 0,
	["Location"] = "Quirky Central",
}

return Data
