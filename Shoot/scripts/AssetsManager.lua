AssetsManager = {}

local mPlayerTeamUnits = {}
local mEnemyTeamUnits = {}
local mDefUnitFacing = 270
local mDyingUnits = {}


function GetJ_PlayerUnits(entity)
    for i = #mPlayerTeamUnits, 1, -1 do
        if (mPlayerTeamUnits[i].Entity == entity) then
            return mPlayerTeamUnits[i]
        end
    end
    return nil
end

function GetJ_EnemyUnits(entity)
    for i = #mEnemyTeamUnits, 1, -1 do
        if (mEnemyTeamUnits[i].Entity == entity) then
            return mEnemyTeamUnits[i]
        end
    end
    return nil
end

function GetJ_DyingUnits()
    return mDyingUnits
end

function AssetsManager.LoadUnit(player, id, x, y)
    local entity = CreateUnit(player, Misc.GetId(id), x, y, mDefUnitFacing)
    local unit = Unit:New(entity)
    if (unit.FactionId == 0) then
        mPlayerTeamUnits[#mPlayerTeamUnits + 1] = unit
    else
        mEnemyTeamUnits[#mEnemyTeamUnits + 1] = unit
    end

    local trig = CreateTrigger()
    TriggerRegisterUnitEvent(trig, entity, EVENT_UNIT_DAMAGED)
    TriggerAddAction(trig, GameStart.AnyUnitDamaged)
    unit.Trigger = trig
    return unit
end

function AssetsManager.LoadUnitAtLoc(player, id, point)
    local entity = CreateUnitAtLoc(player, Misc.GetId(id), point, mDefUnitFacing)
    if (entity == nil) then
        Game.Log("LoadUnitAtLoc id: " .. id)
    end
    local unit = Unit:New(entity)
    if (unit.FactionId == 0) then
        mPlayerTeamUnits[#mPlayerTeamUnits + 1] = unit
    else
        mEnemyTeamUnits[#mEnemyTeamUnits + 1] = unit
    end
    local trig = CreateTrigger()
    TriggerRegisterUnitEvent(trig, entity, EVENT_UNIT_DAMAGED)
    TriggerAddAction(trig, GameStart.AnyUnitDamaged)
    unit.Trigger = trig
    return unit
end

function AssetsManager.LoadEntity(entity)
    local unit = Unit:New(entity)
    if (unit.FactionId == 0) then
        mPlayerTeamUnits[#mPlayerTeamUnits + 1] = unit
    else
        mEnemyTeamUnits[#mEnemyTeamUnits + 1] = unit
    end
    local trig = CreateTrigger()
    TriggerRegisterUnitEvent(trig, entity, EVENT_UNIT_DAMAGED)
    TriggerAddAction(trig, GameStart.AnyUnitDamaged)
    unit.Trigger = trig
    return unit
end

local function DestroyPlayerObject(unit, destroy)
    if (unit.Trigger ~= nil) then
        DestroyTrigger(unit.Trigger)
        unit.Trigger = nil
    end

    for i = #mPlayerTeamUnits, 1, -1 do
        if (mPlayerTeamUnits[i] == unit) then
            table.remove(mPlayerTeamUnits, i)
            break
        end
    end
    unit:Destroy(destroy)
    if (destroy == false) then
        mDyingUnits[#mDyingUnits + 1] = unit
    else
        unit = nil
    end
end

local function DestroyEnemyObject(unit, destroy)
    if (unit.Trigger ~= nil) then
        DestroyTrigger(unit.Trigger)
        unit.Trigger = nil
    end
    for i = #mEnemyTeamUnits, 1, -1 do
        if (mEnemyTeamUnits[i] == unit) then
            table.remove(mEnemyTeamUnits, i)
            break
        end
    end
    unit:Destroy(destroy)
    if (destroy == false) then
        mDyingUnits[#mDyingUnits + 1] = unit
    else
        unit = nil
    end
end

function AssetsManager.RemoveObject(unit)
    if (unit.FactionId == 0) then
        DestroyPlayerObject(unit, false)
    else
        DestroyEnemyObject(unit, false)
    end
end

function AssetsManager.DestroyObject(unit)
    if (unit.FactionId == 0) then
        DestroyPlayerObject(unit, true)
    else
        DestroyEnemyObject(unit, true)
    end
end

function AssetsManager.OnGameUpdate(dt)
    for i = #mPlayerTeamUnits, 1, -1 do
        if (mPlayerTeamUnits[i] ~= nil) then
            mPlayerTeamUnits[i]:OnGameUpdate(dt)
        end
    end

    for i = #mEnemyTeamUnits, 1, -1 do
        if (mEnemyTeamUnits[i] ~= nil) then
            mEnemyTeamUnits[i]:OnGameUpdate(dt)
        end
    end

    for i = #mDyingUnits, 1, -1 do
        if (mDyingUnits[i] ~= nil) then
            mDyingUnits[i]:OnDyingUpdate(dt)
            mDyingUnits[i].LifeDt = mDyingUnits[i].LifeDt + dt
            if (mDyingUnits[i].LifeDt >= mDyingUnits[i].DieTime) then
                mDyingUnits[i]:Destroy(true)
                table.remove(mDyingUnits, i)
            end
        end
    end
end

function AssetsManager.IteratePlayerUnits(call)
    for i = #mPlayerTeamUnits, 1, -1 do
        if (mPlayerTeamUnits[i] ~= nil) then
            if (mPlayerTeamUnits[i].IsDying == false) then
                call(mPlayerTeamUnits[i])
            end
        end
    end
end

function AssetsManager.IterateEnemyUnits(call)
    for i = #mEnemyTeamUnits, 1, -1 do
        if (mEnemyTeamUnits[i] ~= nil) then
            if (mEnemyTeamUnits[i].IsDying == false) then
                call(mEnemyTeamUnits[i])
            end
        end
    end
end

function AssetsManager.OverlapLine(x1, y1, dis, rng, angle, call)
    for j = #mEnemyTeamUnits, 1, -1 do
        if (mEnemyTeamUnits[j] ~= nil and mEnemyTeamUnits[j].IsDying == false) then
            local x2 = x1 + dis * math.cos(math.rad(angle))
            local y2 = y1 + dis * math.sin(math.rad(angle))
            local x, y = (x1 + x2) / 2, (y1 + y2) / 2
            local r = dis / 2
            local dist1 = DistanceBetweenPoint(x, mEnemyTeamUnits[j]:X(), y, mEnemyTeamUnits[j]:Y())
            if (dist1 < r) then --先选一个圆
                local a, b = y1 - y2, x2 - x1
                local c = -a * x1 - b * y1
                local l = (a * a + b * b) ^ 0.5
                local w = rng / 2
                local dist2 = math.abs(a * mEnemyTeamUnits[j]:X() + b * mEnemyTeamUnits[j]:Y() + c) / l
                if (dist2 <= w) then
                    call(mEnemyTeamUnits[j])
                end
            end
        end
    end
end

function AssetsManager.OverlapCircle(x1, y1, radius, call)
    for j = #mEnemyTeamUnits, 1, -1 do
        if (mEnemyTeamUnits[j] ~= nil and mEnemyTeamUnits[j].IsDying == false) then
            local dist = DistanceBetweenPoint(x1, mEnemyTeamUnits[j]:X(), y1, mEnemyTeamUnits[j]:Y())
            if (dist < radius) then
                call(mEnemyTeamUnits[j])
            end
        end
    end
end
