# Battle For Robloxia 

A complete game framework:
- **Round System**: Intermission → Role Assignment → Active Round → Round End
- **Character Morph System**: Selectable Killers and Survivors with unique abilities
- **Malice System**: Role assignment based on Survivor performance
- **Objectives**: Generator repair minigames with timer reduction
- **Persistence**: Saves selected characters and skins
- **In-Game Shop**: Buy characters and skins with Player Points

## Quick Start

### 1. Project Structure

ServerScriptService/ ├── GameManager.server.lua └── CharacterSystem.server.lua

ServerStorage/ ├── Modules/ │ ├── CharacterData.lua │ ├── RoundConfig.lua │ ├── MapManager.lua │ └── PlayerData.lua └── Maps/ ├── BeachHouse (Model) ├── Horror Hotel (Model) └── ... (Add your maps here)

ReplicatedStorage/ └── Modules/ └── Shared.lua

StarterPlayer/ ├── StarterCharacterScripts/ │ └── CharacterHandler.localscript └── StarterPlayerScripts/ └── CharacterSelectUI.localscript


### 2. Setup Instructions

#### Step 1: Create Folder Structure
1. In **ServerScriptService**, create folders if they don't exist
2. In **ServerStorage**, create:
   - `Modules` folder → Add all `.lua` module scripts
   - `Maps` folder → Add your map models here
3. In **ReplicatedStorage**, create:
   - `Modules` folder → Add `Shared.lua`
4. In **StarterPlayer**, create:
   - `StarterCharacterScripts` folder → Add `CharacterHandler.localscript`
   - `StarterPlayerScripts` folder → Add `CharacterSelectUI.localscript`

#### Step 2: Add Your Maps
Place map models in `ServerStorage > Maps`

Each map should be a **Model** with:
- Name: `BeachHouse`, `HorrorHotel`, etc.
- **SurvivorSpawns** (Folder with spawn parts inside)
- **KillerSpawn** (Single part for killer spawn)
- **Generators** (Model with 5 parts named Generator1-5) - Optional

**Map Structure Example:**
BeachHouse (Model) ├── SurvivorSpawns (Folder) │ ├── Spawn1 (Part) │ ├── Spawn2 (Part) │ └── ... ├── KillerSpawn (Part) ├── Generators (Model) [OPTIONAL] │ ├── Generator1 (Part) │ ├── Generator2 (Part) │ └── ... └── MapGeometry (everything else)


#### Step 3: Configure Characters
Edit `ServerStorage > Modules > CharacterData.lua`:
- Add/modify Killer characters
- Add/modify Survivor characters
- Set prices for characters and skins

#### Step 4: Configure Round Settings
Edit `ServerStorage > Modules > RoundConfig.lua`:
- `INTERMISSION_LENGTH` - Lobby wait time
- `ROUND_LENGTH` - Round duration
- `KILL_TIME_ADD` - Time added per kill
- `MIN_PLAYERS_TO_START` - Minimum players
- `CURRENCY.START_POINTS` - Starting player points

#### Step 5: Test
1. Run the game in Studio
2. Players see character selection UI in lobby
3. Players can buy characters/skins with points
4. UI hides when round starts
5. After intermission, round begins with random map

## Features

✅ **Character Selection UI**
- Tab between Survivors and Killers
- Buy characters with Player Points
- Buy skins for characters
- Select which character to play as

✅ **Blank Humanoid Rigs**
- Players spawn with blank humanoid model
- Get morphed into selected character when round starts
- Colored by skin selection

✅ **UI Auto-Hide**
- Shows during intermission (lobby phase)
- Hides when round starts (preparing phase)
- Reappears after round ends

✅ **Persistence System**
- Saves owned characters
- Saves owned skins
- Saves selected characters
- Tracks Player Points and EXP

✅ **Malice System**
- Highest malice player becomes killer
- Incentivizes survivor objectives

## Customization

### Adding a Character
1. Edit `CharacterData.lua`
2. Add to `KILLERS` or `SURVIVORS` table:
```lua
CharacterData.KILLERS.MyKiller = {
    id = "myKiller",
    displayName = "My Killer",
    description = "Description here",
    role = "Killer",
    price = 300,
    health = 150,
    speed = 18,
    stamina = 150,
    passives = { "Passive name" },
    abilities = {
        { name = "Ability 1", cooldown = 20 }
    },
    skins = {
        Default = { name = "Default", price = 0, color = Color3.fromRGB(100, 100, 150) },
        Custom = { name = "Custom", price = 250, color = Color3.fromRGB(200, 50, 50) }
    }
}