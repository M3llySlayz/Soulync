local character, super = Class(PartyMember, "cerulean")

function character:init()
    super.init(self)

    local function discoveredSelf()
    if Game:getFlag("self_discovery") == 2 then
        return true
    else
        return false
    end
end

local colorofCerulean = discoveredSelf() and {0, 1, 0.8} or {0.5, 0.5, 0.5}

     -- Display name
    self.name = "Cerulean"

    -- Actor (handles overworld/battle sprites)
    self:setActor("cerulean")
    self:setLightActor("cerulean_lw")

    -- Display level (saved to the save file)
    self.level = Game.chapter
    -- Default title / class (saved to the save file)
    self.title = "Nerd\nA girl trying to\nfind her lost love."

    -- Determines which character the soul comes from (higher number = higher priority)
    self.soul_priority = 1
    -- The color of this character's soul (optional, defaults to red)
    self.soul_color = colorofCerulean

    -- Whether the party member can act / use spells
    self.has_act = true
    self.has_spells = true


    self.attack_sound = nil

    -- Whether the party member can use their X-Action
    self.has_xact = false
    -- X-Action name (displayed in this character's spell menu)
    self.xact_name = "C-Action"

    -- Spells
    self:addSpell("heal_prayer")

    -- Current health (saved to the save file)
    self.health = 90

    -- Base stats (saved to the save file)
    self.stats = {
        health = 90,
        attack = 4,
        defense = 1,
        magic = 14
    }

    -- Max stats from level-ups
    self.max_stats = {
        health = 120
    }

    -- Weapon icon in equip menu
    self.weapon_icon = "ui/menu/equip/bow"

    -- Equipment (saved to the save file)
    self:setWeapon("bladed_bow")
    self:setArmor(1, "amber_card")
    --self:setArmor(2, "amber_card")

    -- Default light world equipment item IDs (saves current equipment)
    self.lw_weapon_default = "light/bow"
    self.lw_armor_default = "light/bandage"

    -- Character color (for action box outline and hp bar)
    self.color = colorofCerulean
    -- Damage color (for the number when attacking enemies) (defaults to the main color)
    self.dmg_color = colorofCerulean
    -- Attack bar color (for the target bar used in attack mode) (defaults to the main color)
    self.attack_bar_color = colorofCerulean
    -- Attack box color (for the attack area in attack mode) (defaults to darkened main color)
    self.attack_box_color = discoveredSelf() and {0, 0.5, 0.3} or {0.3, 0.3, 0.3}
    -- X-Action color (for the color of X-Action menu items) (defaults to the main color)
    self.xact_color = colorofCerulean

    -- Head icon in the equip / power menu
    self.menu_icon = "party/cerulean/head"
    -- Path to head icons used in battle
    self.head_icons = "party/cerulean/icon"
    -- Name sprite
    self.name_sprite = "party/cerulean/name"

    -- Effect shown above enemy after attacking it
    self.attack_sprite = "effects/attack/shot"
    -- Sound played when this character attacks
    self.attack_sound = nil
    -- Pitch of the attack sound
    self.attack_pitch = 1

    -- Battle position offset (optional)
    self.battle_offset = {2, 1}
    -- Head icon position offset (optional)
    self.head_icon_offset = nil
    -- Menu icon position offset (optional)
    self.menu_icon_offset = nil

    -- Message shown on gameover (optional)
    self.gameover_message = nil
end

return character