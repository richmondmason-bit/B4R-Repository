-- CharacterData.lua - Character definitions with stats, abilities, skins
local CharacterData = {}


CharacterData.KILLERS = {}

CharacterData.KILLERS.Specter = {
	id = "",
	displayName = "",
	description = "",
	role = "Killer",
	health = 150,
	speed = 18,
	stamina = 150,
	passives = { "" },
	abilities = {
		{
			name = "Phase Shift",
			description = "Become invisible for 5 seconds",
			cooldown = 20,
			duration = 5
		},
		{
			name = "Phantom Scream",
			description = "AoE fear effect, 30 stud radius",
			cooldown = 30,
			radius = 30
		}
	},
	skins = {
		Default = { color = Color3.fromRGB(100, 100, 150) },
		Corrupted = { color = Color3.fromRGB(150, 50, 50) },
		Ethereal = { color = Color3.fromRGB(200, 200, 255) }
	}
}

CharacterData.KILLERS.Phantom = {
	id = "",
	displayName = "",
	description = "",
	role = "Killer",
	health = 140,
	speed = 20,
	stamina = 130,
	passives = { "" },
	abilities = {
		{
			name = "",
			description = "",
			cooldown = 15,
			distance = 40
		},
		{
			name = "",
			description = "",
			cooldown = 25
		}
	},
	skins = {
		Default = { color = Color3.fromRGB(20, 20, 20) },
		Crimson = { color = Color3.fromRGB(139, 0, 0) },
		Void = { color = Color3.fromRGB(10, 10, 30) }
	}
}

CharacterData.KILLERS.Wraith = {
	id = "wraith",
	displayName = "Wraith",
	description = "A cursed entity that hunts the living",
	role = "Killer",
	health = 160,
	speed = 17,
	stamina = 160,
	passives = { "Curse of the Hunt - Survivors bleed when running" },
	abilities = {
		{
			name = "Spectral Leap",
			description = "Jump to a survivor's location",
			cooldown = 30,
			maxDistance = 80
		},
		{
			name = "Death Mark",
			description = "Mark a survivor for 10 seconds",
			cooldown = 20,
			duration = 10
		}
	},
	skins = {
		Default = { color = Color3.fromRGB(80, 80, 100) },
		Ancient = { color = Color3.fromRGB(60, 40, 20) },
		Radiant = { color = Color3.fromRGB(255, 200, 0) }
	}
}

CharacterData.SURVIVORS = {}

CharacterData.SURVIVORS.Scout = {
	id = "scout",
	displayName = "Scout",
	description = "Quick and agile, excellent at evading",
	role = "Survivor",
	health = 100,
	speed = 16.5,
	stamina = 120,
	passives = { "Quick Reflexes - Faster stamina regeneration" },
	abilities = {
		{
			name = "Sprint Burst",
			description = "Temporary speed boost",
			cooldown = 20,
			duration = 3,
			speedBoost = 5
		},
		{
			name = "Evasion",
			description = "Dodge incoming attacks",
			cooldown = 15
		}
	},
	skins = {
		Default = { color = Color3.fromRGB(100, 150, 100) },
		Urban = { color = Color3.fromRGB(50, 50, 50) },
		Forest = { color = Color3.fromRGB(34, 139, 34) }
	}
}

CharacterData.SURVIVORS.Medic = {
	id = "medic",
	displayName = "Medic",
	description = "Support-focused, heals allies",
	role = "Survivor",
	health = 100,
	speed = 15.5,
	stamina = 100,
	passives = { "Healing Touch - Heal teammates faster" },
	abilities = {
		{
			name = "Self Heal",
			description = "Restore 30 HP",
			cooldown = 30,
			healAmount = 30
		},
		{
			name = "Aid Station",
			description = "Create healing zone for allies",
			cooldown = 45,
			radius = 20,
			duration = 10
		}
	},
	skins = {
		Default = { color = Color3.fromRGB(200, 100, 100) },
		Classic = { color = Color3.fromRGB(255, 255, 255) },
		Emergency = { color = Color3.fromRGB(255, 69, 0) }
	}
}

CharacterData.SURVIVORS.Slayer = {
	id = "slasher",
	displayName = "Slasher",
	description = "",
	role = "Survivor",
	health = 110,
	speed = 16,
	stamina = 110,
	passives = { "" },
	abilities = {
		{
			name = "",
			description = "",
			cooldown = 25,
			stunDuration = 2
		},
		{
			name = "",
			description = "",
			cooldown = 20
		}
	},
	skins = {
		Default = { color = Color3.fromRGB(200, 100, 50) },
		Armored = { color = Color3.fromRGB(150, 150, 150) },
		Battle = { color = Color3.fromRGB(139, 69, 19) }
	}
}

CharacterData.SURVIVORS.Hacker = {
	id = "",
	displayName = "",
	description = "",
	role = "Survivor",
	health = 95,
	speed = 16,
	stamina = 105,
	passives = { "" },
	abilities = {
		{
			name = "EMP Pulse",
			description = "",
			cooldown = 40,
			duration = 8
		},
		{
			name = "Hack Terminal",
			description = "",
			cooldown = 30
		}
	},
	skins = {
		Default = { color = Color3.fromRGB(100, 150, 200) },
		Neon = { color = Color3.fromRGB(0, 255, 255) },
		Matrix = { color = Color3.fromRGB(0, 255, 0) }
	}
}

return CharacterData