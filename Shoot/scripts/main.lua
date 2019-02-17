require "scripts.Common.utility"
require "scripts.Api.common"
require "scripts.Api.blizzard"
require "scripts.Api.japi"
Jglobals = require "jass.globals"
Slk = require "jass.slk"
require "scripts.Common.Misc"
require "scripts.Common.Color"
require "scripts.Game"
require "scripts.GameStart"

function main()
    local PlayerCount = 3
    local trig = CreateTrigger()
    TriggerRegisterTimerEvent(trig, 0, false)
    TriggerAddAction(trig, GameStart.OnGameStart)

    trig = CreateTrigger()
    TriggerRegisterTimerEvent(trig, 0.016, true)
    TriggerAddAction(trig, Game.OnGameUpdate)

    for i = 0, 7 do
        trig = CreateTrigger()
        TriggerRegisterPlayerUnitEvent(trig, Player(i), EVENT_PLAYER_UNIT_SELECTED, nil)
        TriggerAddAction(trig, GameStart.AnyUnitSelected)
    end

    trig = CreateTrigger()
    for i = 0, 8 do
        TriggerRegisterPlayerUnitEvent(trig, Player(i), EVENT_PLAYER_UNIT_DEATH, nil)
    end
    TriggerAddAction(
    trig,
    function()
        local killUnit = GetJ_PlayerUnits(GetKillingUnit())
        local dieUnit = GetJ_EnemyUnits(GetDyingUnit())
        if (killUnit == nil or dieUnit == nil) then
            return
        end
        GameStart.AnyUnitDeath(killUnit, dieUnit)
    end
    )

    trig = CreateTrigger()
    for i = 0, 7 do
        TriggerRegisterPlayerUnitEvent(trig, Player(i), EVENT_PLAYER_HERO_SKILL, nil)
    end
    TriggerAddAction(trig, GameStart.AnyUnitLearnedSkill)

    --[[   trig = CreateTrigger()
    for i = 0, 7 do
        TriggerRegisterPlayerUnitEvent(trig, Player(i), EVENT_PLAYER_UNIT_SPELL_CHANNEL, nil)
    end
    TriggerAddAction(trig, GameStart.AnyUnitSpellChannel)]]
    trig = CreateTrigger()
    for i = 0, 7 do
        TriggerRegisterPlayerUnitEvent(trig, Player(i), EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
    end
    TriggerAddAction(trig, GameStart.AnyUnitSpellEffect)

    trig = CreateTrigger()
    for i = 0, 7 do
        TriggerRegisterPlayerUnitEvent(trig, Player(i), EVENT_PLAYER_UNIT_USE_ITEM, nil)
    end
    TriggerAddAction(trig, GameStart.AnyUnitUseItem)

    trig = CreateTrigger()
    for i = 0, 7 do
        TriggerRegisterPlayerUnitEvent(trig, Player(i), EVENT_PLAYER_UNIT_PICKUP_ITEM, nil)
    end
    TriggerAddAction(trig, GameStart.AnyUnitPickUpItem)

    trig = CreateTrigger()
    for i = 0, 7 do
        TriggerRegisterPlayerUnitEvent(trig, Player(i), EVENT_PLAYER_UNIT_SELL_ITEM, nil)
    end
    TriggerAddAction(trig, GameStart.AnyUnitSellItem)

    trig = CreateTrigger()
    for i = 0, 7 do
        TriggerRegisterPlayerUnitEvent(trig, Player(i), EVENT_PLAYER_UNIT_DROP_ITEM, nil)
    end
    TriggerAddAction(trig, GameStart.AnyUnitDropItem)

    trig = CreateTrigger()
    for i = 0, 7 do
        TriggerRegisterPlayerChatEvent(trig, Player(i), "", true)
    end
    TriggerAddAction(trig, GameStart.AnyPlayerChat)

    trig = CreateTrigger()
    for i = 0, 7 do
        TriggerRegisterPlayerEvent(trig, Player(i), EVENT_PLAYER_LEAVE)
    end
    TriggerAddAction(
    trig,
    function()
    end
    )
    trig = nil
end

main()