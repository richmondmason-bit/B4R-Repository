-- RoundConfig.lua - Centralized game configuration
local RoundConfig = {}

-- Game Phases
RoundConfig.PHASES = {
	INTERMISSION = "Intermission",
	PREPARING = "Preparing",
	PLAYING = "Playing",
	ENDING = "Ending"
}

-- Timing (in seconds)
RoundConfig.INTERMISSION_LENGTH = 30
RoundConfig.PREPARING_LENGTH = 5
RoundConfig.ROUND_LENGTH = 300 -- 5 minutes
RoundConfig.ENDING_LENGTH = 10

-- Game Rules
RoundConfig.MIN_PLAYERS_TO_START = 2
RoundConfig.KILL_TIME_ADD = 40 -- seconds added to timer per survivor kill
RoundConfig.GEN_TIME_REDUCTION = 3 -- seconds removed per generator layer

-- Default Character Stats
RoundConfig.DEFAULT_SURVIVOR_STATS = {
	Health = 100,
	MaxHealth = 100,
	Speed = 16,
	Stamina = 100,
	MaxStamina = 100
}

RoundConfig.DEFAULT_KILLER_STATS = {
	Health = 150,
	MaxHealth = 150,
	Speed = 18,
	Stamina = 150,
	MaxStamina = 150
}

-- Rewards
RoundConfig.REWARDS = {
	SURVIVOR_WIN = { exp = 100, points = 50 },
	KILLER_WIN = { exp = 150, points = 75 },
	SURVIVAL_BONUS = { exp = 20, points = 10 } -- per 30 seconds survived
}

-- Malice Settings
RoundConfig.MALICE = {
	GEN_LAYER_COMPLETION = 0.5,
	SURVIVOR_DODGE = 1.0,
	KILLER_STUN = 2.0
}

return RoundConfig