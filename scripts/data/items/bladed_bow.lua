local item, super = Class(Item, "bladed_bow")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Bladed Bow"
    -- Name displayed when used in battle (optional)
    self.use_name = nil

    -- Item type (item, key, weapon, armor)
    self.type = "weapon"
    -- Item icon (for equipment)
    self.icon = "ui/menu/icon/bow"
    -- Whether this item is for the light world
    self.light = false

    -- Battle description
    self.effect = "Useless"
    -- Shop description
    self.shop = "Useless"
    -- Menu description
    self.description = "A bow with two sharp blades on it."
    -- Light world check text
    self.check = "It's useless"

    -- Default shop price (sell price is halved)
    self.price = 0
    -- Whether the item can be sold
    self.can_sell = false

    self.type = "weapon"

    -- Equip bonuses (for weapons and armor)
    self.bonuses = {
        attack  = 12,
        defense = 6,
        magic   = 8,
    }

    -- No special bonus
    self.bonus_name = nil
    self.bonus_icon = nil

    --only Cerulean can use this weapon
    self.can_equip = {"cerulean"}

    --BOLTS

    self.bolt_speed = 6
    self.bolt_acceleration = 2
    self.bolt_count = 4
    self.multibolt_variance = {{40, 50, 60}, 80, {70, 80}}
    self.calculate_multibolt_from_last_bolt = false
end

return item