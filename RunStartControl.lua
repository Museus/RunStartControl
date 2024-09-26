--[[
    RunStartControl v1.0
    Authors:
        cgull (Discord: cgull#4469)
        Museus (Discord: Museus#7777)
    Makes the first room reward offer whatever is set by the function
    RunStartControl.SetStartingReward. See function header for details
]]

ModUtil.Mod.Register("RunStartControl")

local config = {
    Enabled = true,
    Menu = "configmenu", --"prerun" for pre-pact selection, or "configmenu" for modconfigmenu
}
RunStartControl.config = config

RunStartControl.StartingData = {
    StartingReward = nil, -- "Boon" or "WeaponUpgrade"
    Hammer = {
        Aspect = nil, -- actual apsect trait name
        Trait = nil, -- actual trait name
    },
    Boon = {
        God = nil, -- god name, nothing else
        Rarity = nil,
        Trait = nil, -- actual trait name
    },
}

function IsHammerValid(hammerData, weapon, aspectTrait)
    local aspectInvalid = Contains(hammerData.RequiredFalseTraits, aspectTrait)
    local weaponMatch = hammerData.RequiredWeapon == weapon or 
                       (hammerData.RequiredWeapon == "SpearWeaponThrow" and weapon == "SpearWeapon") or 
                       (hammerData.RequiredWeapon == "BowSplitShot" and weapon == "BowWeapon")

    return weaponMatch and not aspectInvalid
end

--[[ current intention is to have actual values passed in for traits, could replace with "common" ones and 
     use mappings instead, depends on UI
 ]]
function RunStartControl.SetStartingRewards( weapon, aspectTrait, hammerReward, boonGod, boonTrait, boonRarity, forcedFirstReward )
    RunStartControl.StartingData.StartingReward = forcedFirstReward
    local hammerData = TraitData[hammerReward]
    -- needs weapon and aspect to check hammer compatibility
    if weapon and aspectTrait and hammerData and IsHammerValid(hammerData, weapon, aspectTrait) then
        RunStartControl.StartingData.Hammer = {
            Aspect = aspectTrait,
            Trait = hammerReward,
        }
    end
    -- beowulf check later??? maybe push that upstream
    if boonGod and boonTrait then
        RunStartControl.StartingData.Boon = {
            God = boonGod,
            Rarity = boonRarity,
            Trait = boonTrait
        }
    end
end

-- Reset starting rewards
function RunStartControl.ResetStartingRewards()
    RunStartControl.StartingData = {
        StartingReward = nil,
        Hammer = {
            Aspect = nil, 
            Trait = nil, 
        },
        Boon = {
            God = nil,
            Rarity = nil,
            Trait = nil, 
        },
    }
end

-- force reward type (starting, boon or hammer), only for first room if requested
ModUtil.Path.Wrap("ChooseRoomReward", function( baseFunc, run, room, rewardStoreName, previouslyChosenRewards, args )
    local startingReward = RunStartControl.StartingData.StartingReward

    if RunStartControl.config.Enabled and room.Name == "RoomOpening" and startingReward then
        -- removing reward from reward store if exists. skipping refilling since it's not
        -- relevant for a first reward
        for rewardKey, reward in pairs(run.RewardStores['RunProgress']) do
            if rewardKey == RunStartControl.StartingData.StartingReward then
                run.RewardStores['RunProgress'][rewardKey] = nil
                CollapseTable( run.RewardStores['RunProgress'] )
                break
            end
        end
        RunStartControl.StartingData.StartingReward = nil
        return startingReward
    else
        return baseFunc(run, room, rewardStoreName, previouslyChosenRewards, args)
    end
end, RunStartControl)

-- force boon type
ModUtil.Path.Wrap("ChooseLoot", function( baseFunc, excludeLootNames, forceLootName )
    -- checking if it's the first boon, and we have a god to overwrite with
    if RunStartControl.config.Enabled and RunStartControl.StartingData.Boon.God then
        return baseFunc( excludeLootNames, RunStartControl.StartingData.Boon.God .. "Upgrade" )
    else
        return baseFunc( excludeLootNames, forceLootName)
    end
end, RunStartControl)

-- force reward (if to be forced)
ModUtil.Path.Wrap("SetTraitsOnLoot", function(baseFunc, lootData, args)
    local hammerToForce = lootData.Name == "WeaponUpgrade" and RunStartControl.StartingData.Hammer.Trait
    local boonToForce = lootData.GodLoot and RunStartControl.StartingData.Boon.Trait

    -- verifying aspect
    if RunStartControl.config.Enabled and hammerToForce and HeroHasTrait(RunStartControl.StartingData.Hammer.Aspect) then
        lootData.BlockReroll = true
        lootData.UpgradeOptions = {
            { 
                ItemName = RunStartControl.StartingData.Hammer.Trait, 
                Type = "Trait",
                Rarity = "Common",
            }
        }
    elseif boonToForce and lootData.Name == RunStartControl.StartingData.Boon.God .. "Upgrade" then
        lootData.BlockReroll = true
        lootData.UpgradeOptions = {
            {
                ItemName = RunStartControl.StartingData.Boon.Trait,
                Type = 'Trait',
                Rarity = RunStartControl.StartingData.Boon.Rarity or "Common"
            }
        }
    else
        baseFunc(lootData, args)
    end
end, RunStartControl)

ModUtil.Path.Wrap("AddTraitToHero", function(baseFunc, trait)
    if ModUtil.IndexArray.Get(trait, ModUtil.Path.IndexArray("TraitData.Frame")) == "Hammer" then
        RunStartControl.StartingData.Hammer = {
            Aspect = nil,
            Trait = nil,
        }
    elseif trait.TraitData and trait.TraitData.God then
        RunStartControl.StartingData.Boon = {
            God = nil,
            Trait = nil,
            Rarity = nil
        }
    end
    baseFunc(trait)
  end, RunStartControl)