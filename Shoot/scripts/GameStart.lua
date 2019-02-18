require "scripts.GameScene"

GameStart = {}

--游戏开始
function GameStart.OnGameStart()
    --禁用黑色阴影（开全图）
    FogMaskEnable(false)
    --禁用战争迷雾
    FogEnable(false)
    SuspendTimeOfDay(true)
    SetCameraField(CAMERA_FIELD_ZOFFSET, 200, 0)
    Game.ChooseLevel()
end

Heros = {}
local mLastSelectedTime = 0
function GameStart.AnyUnitSelected()
    local unit = GetTriggerUnit()
    local id = GetPlayerId(GetTriggerPlayer())
    if (unit == nil) then
        return
    end

    if (Heros[id + 1] == nil and IsUnitType(unit, UNIT_TYPE_HERO)) then
        if (GameScene.Elapsed - mLastSelectedTime < 0.4) then
            SetUnitOwner(unit, GetTriggerPlayer(), true)
            AssetsManager.LoadEntity(unit)
            Heros[id + 1] = unit
            SetUnitPositionLoc(unit, JumpPoints[id + 1][2][3])
            PanCameraToTimedLocForPlayer(GetTriggerPlayer(), JumpPoints[id + 1][2][3], 0)
            Battle.PushWave()
            DestroyTrigger(GetTriggeringTrigger())
        end
        mLastSelectedTime = GameScene.Elapsed
    end
end

--任意单位伤害
function GameStart.AnyUnitDamaged()
end

--任意单位死亡
function GameStart.AnyUnitDeath(killUnit, dieUnit)
    Battle.AnyUnitDeath(killUnit, dieUnit)
    AssetsManager.RemoveObject(dieUnit)
end

--任意单位学习技能
function GameStart.AnyUnitLearnedSkill()
end

--任意准备施放技能
function GameStart.AnyUnitSpellChannel()
end

--任意单位发动技能效果
function GameStart.AnyUnitSpellEffect()
end

--任意单位获得物品
function GameStart.AnyUnitPickUpItem()
end

--任意单位使用物品
function GameStart.AnyUnitUseItem()
end

--任意单位出售物品
function GameStart.AnyUnitSellItem()
end

--任意单位丢弃物品
function GameStart.AnyUnitDropItem()
end

local mEmitters = { "简单弹幕", "旋转弹幕", "圆形弹幕", "圆形弹幕-交叉", "扇形弹幕", "旋转X4", "仙女散花", "E008", "倒勾" }
local mEmitterIndex = 0
--任意玩家输入字符串
function GameStart.AnyPlayerChat()
    local player = GetTriggerPlayer()
    local playerID = GetPlayerId(player)
    local str = string.lower(GetEventPlayerChatString())

    if (str == "+") then
        AddCameraFieldForPlayer()
        return
    end

    if (str == "-") then
        MinusCameraFieldForPlayer()
        return
    end

    if (str == "dm") then
        mEmitterIndex = mEmitterIndex < #mEmitters and mEmitterIndex + 1 or 1
        Worke[playerID]:DisableEmitter()
        Worke[playerID]:AddEmitter(mEmitters[mEmitterIndex])
    end

    if (str == "cheat") then
        cheat(playerID)
        return
    end

    if (str == "up") then
        local units = GetPlayerTeamUnits(playerID)
        for i = #units, 1, -1 do
            if (IsUnitType(units[i].Entity, UNIT_TYPE_HERO)) then
                SetHeroLevel(units[i].Entity, GetHeroLevel(units[i].Entity) + 1, true)
            end
        end
        return
    end

    local index = string.find(str, "item:")
    if (index ~= nil) then
        local itemId = string.sub(str, index + 5, #str)
        if (#itemId == 4) then
            UnitAddItem(
            Worke[playerID].Entity,
            CreateItem(Misc.GetId(string.upper(itemId)), Worke[playerID]:X(), Worke[playerID]:Y())
            )
        end
        return
    end

    index = string.find(str, "up:")
    if (index ~= nil) then
        local level = tonumber(string.sub(str, index + 3, #str))
        if (level ~= nil) then
            local units = GetPlayerTeamUnits(playerID)
            for i = #units, 1, -1 do
                if (IsUnitType(units[i].Entity, UNIT_TYPE_HERO)) then
                    for j = 1, level do
                        SetHeroLevel(units[i].Entity, GetHeroLevel(units[i].Entity) + 1, true)
                    end
                end
            end
        end
        return
    end

    index = string.find(str, "speed:")
    if (index ~= nil) then
        local speed = tonumber(string.sub(str, index + 6, #str))
        if (speed ~= nil) then
            Game.SetSpeed(speed)
        end
        return
    end

    index = string.find(str, "wave:")
    if (index ~= nil) then
        local waveIndex = tonumber(string.sub(str, index + 5, #str))
        if (waveIndex ~= nil) then
            MonsterRefresh.SetWaveIndex(waveIndex)
        end
        return
    end
end