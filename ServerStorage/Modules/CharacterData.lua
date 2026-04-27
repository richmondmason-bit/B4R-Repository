-- CharacterData.lua - Character definitions with stats, abilities, skins
local CharacterData = {}

-- ============ KILLERS ============
CharacterData.KILLERS = {}

CharacterData.KILLERS.Specter = {
	id = "specter",
	displayName = "Specter",
	description = "A ghostly entity with phasing abilities",
	role = "Killer",
	price = 0, -- 0 = free/default
	health = 150,
	speed = 18,
	stamina = 150,
	passives = { "Ethereal Presence - Survivors within 20 studs hear haunting whispers" },
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
		Default = { name = "Default", price = 0, color = Color3.fromRGB(100, 100, 150) },
		Corrupted = { name = "Corrupted", price = 250, color = Color3.fromRGB(150, 50, 50) },
		Ethereal = { name = "Ethereal", price = 500, color = Color3.fromRGB(200, 200, 255) }
	}
}

CharacterData.KILLERS.Phantom = {
	id = "phantom",
	displayName = "Phantom",
	description = "Swift and deadly, a master of ambush",
	role = "Killer",
	price = 300,
	health = 140,
	speed = 20,
	stamina = 130,
	passives = { "Swift Reflexes - 10% faster attack speed" },
	abilities = {
		{
			name = "Shadow Strike",
			description = "Dash forward and strike",
			cooldown = 15,
			distance = 40
		},
		{
			name = "Decoy",
			description = "Create a fake trail",
			cooldown = 25
		}
	},
	skins = {
		Default = { name = "Default", price = 0, color = Color3.fromRGB(20, 20, 20) },
		Crimson = { name = "Crimson", price = 250, color = Color3.fromRGB(139, 0, 0) },
		Void = { name = "Void", price = 500, color = Color3.fromRGB(10, 10, 30) }
	}
}

CharacterData.KILLERS.Wraith = {
	id = "wraith",
	displayName = "Wraith",
	description = "A cursed entity that hunts the living",
	role = "Killer",
	price = 300,
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
		Default = { name = "Default", price = 0, color = Color3.fromRGB(80, 80, 100) },
		Ancient = { name = "Ancient", price = 250, color = Color3.fromRGB(60, 40, 20) },
		Radiant = { name = "Radiant", price = 500, color = Color3.fromRGB(255, 200, 0) }
	}
}

-- ============ SURVIVORS ============
CharacterData.SURVIVORS = {}

CharacterData.SURVIVORS.Scout = {
	id = "scout",
	displayName = "Scout",
	description = "Quick and agile, excellent at evading",
	role = "Survivor",
	price = 0, -- free/default
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
		Default = { name = "Default", price = 0, color = Color3.fromRGB(100, 150, 100) },
		Urban = { name = "Urban", price = 200, color = Color3.fromRGB(50, 50, 50) },
		Forest = { name = "Forest", price = 400, color = Color3.fromRGB(34, 139, 34) }
	}
}

CharacterData.SURVIVORS.Medic = {
	id = "medic",
	displayName = "Medic",
	description = "Support-focused, heals allies",
	role = "Survivor",
	price = 300,
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
		Default = { name = "Default", price = 0, color = Color3.fromRGB(200, 100, 100) },
		Classic = { name = "Classic", price = 200, color = Color3.fromRGB(255, 255, 255) },
		Emergency = { name = "Emergency", price = 400, color = Color3.fromRGB(255, 69, 0) }
	}
}

CharacterData.SURVIVORS.Slayer = {
	id = "slayer",
	displayName = "Slayer",
	description = "Aggressive fighter, can stun killers",
	role = "Survivor",
	price = 300,
	health = 110,
	speed = 16,
	stamina = 110,
	passives = { "Fighter's Spirit - Bonus damage on counterattacks" },
	abilities = {
		{
			name = "Stun Strike",
			description = "Stun the killer for 2 seconds",
			cooldown = 25,
			stunDuration = 2
		},
		{
			name = "Counterattack",
			description = "Dodge and strike back",
			cooldown = 20
		}
	},
	skins = {
		Default = { name = "Default", price = 0, color = Color3.fromRGB(200, 100, 50) },
		Armored = { name = "Armored", price = 250, color = Color3.fromRGB(150, 150, 150) },
		Battle = { name = "Battle", price = 500, color = Color3.fromRGB(139, 69, 19) }
	}
}

CharacterData.SURVIVORS.Hacker = {
	id = "hacker",
	displayName = "Hacker",
	description = "Tech-savvy, can disable killer abilities",
	role = "Survivor",
	price = 300,
	health = 95,
	speed = 16,
	stamina = 105,
	passives = { "Tech Genius - Repair generators 20% faster" },
	abilities = {
		{
			name = "EMP Pulse",
			description = "Disable killer abilities for 8 seconds",
			cooldown = 40,
			duration = 8
		},
		{
			name = "Hack Terminal",
			description = "Access secret passages",
			cooldown = 30
		}
	},
	skins = {
		Default = { name = "Default", price = 0, color = Color3.fromRGB(100, 150, 200) },
		Neon = { name = "Neon", price = 250, color = Color3.fromRGB(0, 255, 255) },
		Matrix = { name = "Matrix", price = 500, color = Color3.fromRGB(0, 255, 0) }
	}
}

return CharacterData