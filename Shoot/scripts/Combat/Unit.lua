Unit = {}
local mt = {}
Unit.__index = mt
Unit.Locomotion = nil
--Unit.__index = mt
mt.Entity = nil --实体
mt.Attribute = nil
mt.Skills = nil
mt.Buffs = nil
mt.Items = nil
mt.Player = nil
mt.Name = "name"
mt.Id = 0
mt.LastFightTime = 0


JumpPoints = {
    [1] = {
        [1] = { GetRectCenter(Jglobals.gg_rct_rect_1_00), GetRectCenter(Jglobals.gg_rct_rect_1_01), GetRectCenter(Jglobals.gg_rct_rect_1_02), GetRectCenter(Jglobals.gg_rct_rect_1_03) },
        [2] = { GetRectCenter(Jglobals.gg_rct_rect_1_10), GetRectCenter(Jglobals.gg_rct_rect_1_11), GetRectCenter(Jglobals.gg_rct_rect_1_12), GetRectCenter(Jglobals.gg_rct_rect_1_13) },
        [3] = { GetRectCenter(Jglobals.gg_rct_rect_1_20), GetRectCenter(Jglobals.gg_rct_rect_1_21), GetRectCenter(Jglobals.gg_rct_rect_1_22), GetRectCenter(Jglobals.gg_rct_rect_1_23) },
        [4] = { GetRectCenter(Jglobals.gg_rct_rect_1_30), GetRectCenter(Jglobals.gg_rct_rect_1_31), GetRectCenter(Jglobals.gg_rct_rect_1_32), GetRectCenter(Jglobals.gg_rct_rect_1_33) },
        [5] = { GetRectCenter(Jglobals.gg_rct_rect_1_40), GetRectCenter(Jglobals.gg_rct_rect_1_41), GetRectCenter(Jglobals.gg_rct_rect_1_42), GetRectCenter(Jglobals.gg_rct_rect_1_43) },
        [6] = { GetRectCenter(Jglobals.gg_rct_rect_1_50), GetRectCenter(Jglobals.gg_rct_rect_1_51), GetRectCenter(Jglobals.gg_rct_rect_1_52), GetRectCenter(Jglobals.gg_rct_rect_1_53) },
        [7] = { GetRectCenter(Jglobals.gg_rct_rect_1_60), GetRectCenter(Jglobals.gg_rct_rect_1_61), GetRectCenter(Jglobals.gg_rct_rect_1_62), GetRectCenter(Jglobals.gg_rct_rect_1_63) },
        [8] = { GetRectCenter(Jglobals.gg_rct_rect_1_70), GetRectCenter(Jglobals.gg_rct_rect_1_71), GetRectCenter(Jglobals.gg_rct_rect_1_72), GetRectCenter(Jglobals.gg_rct_rect_1_73) },
    },
}


function Unit:New(entity)
    if (entity == nil) then
        Game.LogError("单位为null")
        return nil
    end
    local newUnit = {}
    setmetatable(newUnit, { __index = Unit })
    newUnit.Entity = entity
    newUnit.Attribute = Attribute:New(newUnit)
    newUnit.Player = GetOwningPlayer(entity)
    newUnit.Name = GetUnitName(entity)
    newUnit.Id = GetUnitTypeId(entity)
    newUnit.FactionId = GetPlayerId(newUnit.Player) < 8 and 0 or 1
    newUnit.IsDying = false
    newUnit.LastFightTime = 0
    newUnit.DieTime = 5
    newUnit.LifeDt = 0
    newUnit.TextDt = 0
    newUnit.Skills = {}
    newUnit.Buffs = {}
    newUnit.Items = {}
    newUnit.Emitters = {}
    newUnit.Combs = {}
    newUnit.CombEnableCount = 0
    newUnit.Texts = {}

    newUnit:AddEmitter("简单弹幕")
    newUnit.Jump = newUnit:AddLocomotion("跳跃")
    newUnit.x = 2
    newUnit.y = 3

    local trg = CreateTrigger()
    TriggerRegisterUnitEvent(trg, entity, EVENT_UNIT_ISSUED_POINT_ORDER)
    TriggerAddAction(trg, function()
        if ((GetIssuedOrderIdBJ() == OrderId("smart"))) then
            IssueImmediateOrder(entity, "stop")
            local x = GetOrderPointX()
            local y = GetOrderPointY()
            local dist = DistanceBetweenPoint(newUnit:X(), x, newUnit:Y(), y)
            if (dist < 100) then
                return
            end
            local angle = AngleBetweenPoint(newUnit:X(), x, newUnit:Y(), y)
            if (angle > 120 and angle <= 150) then
                newUnit:Move(1)
            elseif (angle > 60 and angle <= 120) then
                newUnit:Move(2)
            elseif (angle > 30 and angle <= 60) then
                newUnit:Move(3)
            elseif (angle > -30 and angle <= 30) then
                newUnit:Move(4)
            elseif (angle > -60 and angle <= -30) then
                newUnit:Move(5)
            elseif (angle > -120 and angle <= -60) then
                newUnit:Move(6)
            elseif (angle > -150 and angle <= -120) then
                newUnit:Move(7)
            else
                newUnit:Move(0)
            end
        end
    end)
    return newUnit
end

function Unit:Move(angle)
    if (IsUnitPaused(self.Entity)) then
        return
    end
    if (angle == 0) then
        self.x = Misc.Clamp(self.x - 1, 1, 8)
    elseif (angle == 1) then
        self.x = Misc.Clamp(self.x - 1, 1, 8)
        self.y = Misc.Clamp(self.y - 1, 1, 4)
    elseif (angle == 2) then
        self.y = Misc.Clamp(self.y - 1, 1, 4)
    elseif (angle == 3) then
        self.x = Misc.Clamp(self.x + 1, 1, 8)
        self.y = Misc.Clamp(self.y - 1, 1, 4)
    elseif (angle == 4) then
        self.x = Misc.Clamp(self.x + 1, 1, 8)
    elseif (angle == 5) then
        self.x = Misc.Clamp(self.x + 1, 1, 8)
        self.y = Misc.Clamp(self.y + 1, 1, 4)
    elseif (angle == 6) then
        self.y = Misc.Clamp(self.y + 1, 1, 4)
    else
        self.x = Misc.Clamp(self.x - 1, 1, 8)
        self.y = Misc.Clamp(self.y + 1, 1, 4)
    end
    local pos = JumpPoints[GetPlayerId(self.Player) + 1][self.x][self.y]

    local angle = AngleBetweenPoint(self:X(), GetLocationX(pos), self:Y(), GetLocationY(pos))
    local dist = DistanceBetweenPoint(self:X(), GetLocationX(pos), self:Y(), GetLocationY(pos))
    self.Jump:Start(angle, dist, 0.3, 280)
end

function Unit:CreateDummy(modelName, x, y)
    local unit = CreateUnit(self.Player, Misc.GetId("uq00"), x, y, self:Facing())
    if (unit == nil) then
        Game.LogError("单位为null")
        return nil
    end
    if (modelName ~= "") then
        AddSpecialEffectTarget(modelName, unit, "origin")
    end
    return unit
end

function Unit:OnKill(killer)
--[[   local tim = CreateTimer()
    TimerStart(
        tim,
        0.01,
        false,
        function()
            AssetsManager.RemoveObject(self)
            GameStart.AnyUnitDeath(killer, self)
            DestroyTimer(GetExpiredTimer())
        end
    )]]
end

function Unit:AddSkill(abilityid)
    abilityid = Misc.GetId(abilityid)
    UnitAddAbility(self.Entity, abilityid)
    UnitMakeAbilityPermanent(self.Entity, true, abilityid)
    local skill = Skill:New(self, abilityid)
    self.Skills[#self.Skills + 1] = skill
    return skill
end

function Unit:LearnedSkill(abilityid)
    local skill = self:GetSkill(abilityid)
    if (skill == nil) then
        skill = Skill:New(self, abilityid)
        self.Skills[#self.Skills + 1] = skill
    end
    skill:OnLearned()
    skill:SetStack(skill.Stack)
    return skill
end

function Unit:AddItem(entity)
    local item = Item:New(self, entity)
    self.Items[#self.Items + 1] = item
    Item.ItemUniquenessList(self, item)
    Item.ItemOverlay(self, item)
    item:OnAdd()
    return item
end

function Unit:AddEmitter(name)
    local emitter = Emitter:New(self, name)
    self.Emitters[#self.Emitters + 1] = emitter
    emitter:Init()
    return emitter
end

function Unit:AddLocomotion(name)
    if (self.Attribute:get("生命") <= 0 or self.IsDying) then
        return
    end
    if (self.Locomotion ~= nil) then
        self:RemoveLocomotion()
    end
    self.Locomotion = Locomotion:New(self, name)
    return self.Locomotion
end

function Unit:AddDamageText(damage, isCritDamage, color)
    self.Texts[#self.Texts + 1] = { damage, isCritDamage, color }
end

function Unit:AddBuff(name, level)
    if (self.Attribute:get("生命") <= 0 or self.IsDying) then
        return
    end

    local buff = self:GetBuff(name)
    if (buff ~= nil) then
        if (buff.MaxStack > 1) then
            buff:AddStack()
            return buff
        end
        self:RemoveBuff(name)
    end
    buff = Buff:New(self, name, level or 1)
    self.Buffs[#self.Buffs + 1] = buff
    buff:OnAdd()
    return buff
end

function Unit:ContainBuff(name)
    for i, v in ipairs(self.Buffs) do
        if (v.Name == name) then
            return true
        end
    end
    return false
end

function Unit:ContainSkill(abilityid)
    for i, v in ipairs(self.Skills) do
        if (v.Id == abilityid) then
            return true
        end
    end
    return false
end

function Unit:ContainItem(entity)
    for i = 1, #self.Items do
        if (self.Items[i].Entity == entity) then
            return true
        end
    end
    return false
end

function Unit:ContainItemId(itemId)
    for i = 1, #self.Items do
        if (self.Items[i].Id == itemId) then
            return true
        end
    end
    return false
end

function Unit:GetBuff(name)
    for i = 1, #self.Buffs do
        if (self.Buffs[i].Name == name) then
            return self.Buffs[i]
        end
    end
    return nil
end

function Unit:GetSkill(abilityid)
    for i = 1, #self.Skills do
        if (self.Skills[i].Id == abilityid) then
            return self.Skills[i]
        end
    end
    return nil
end

function Unit:GetItem(entity)
    for i = 1, #self.Items do
        if (self.Items[i].Entity == entity) then
            return self.Items[i]
        end
    end
    return nil
end

function Unit:RemoveSkill(abilityid)
    for i = #self.Skills, 1, -1 do
        if (self.Skills[i].Id == abilityid) then
            UnitRemoveAbility(self.Entity, abilityid)
            table.remove(self.Skills, i)
            break
        end
    end
end

function Unit:RemoveBuff(name)
    for i = #self.Buffs, 1, -1 do
        if (self.Buffs[i].Name == name) then
            self.Buffs[i]:OnRemove()
            table.remove(self.Buffs, i)
            break
        end
    end
end

function Unit:DisableEmitter()
    for i = #self.Emitters, 1, -1 do
        self.Emitters[i]:Disable()
        table.remove(self.Emitters, i)
    end
end

function Unit:_RemoveItem(entity)
    for i = #self.Items, 1, -1 do
        if (self.Items[i].Entity == entity) then
            self.Items[i]:OnRemove()
            table.remove(self.Items, i)
            break
        end
    end
end

function Unit:RemoveLocomotion()
    if (self.Locomotion ~= nil) then
        self.Locomotion = nil
    end
end

function Unit:DestroyItem(entity)
    self:_RemoveItem(entity)
    RemoveItem(entity)
end

--走AssetsManager.DestroyObject(unit)删除逻辑，不要直接从这删除
--运动中的单位中途死亡也要让运动继续下去，死亡单位5秒后销毁，并释放相关内存
function Unit:Destroy(destroy)
    self.IsDying = true
    if (destroy) then
        --释放内存
        for i = #self.Buffs, 1, -1 do
            table.remove(self.Buffs, i)
        end
        self.Buffs = nil
        for i = #self.Skills, 1, -1 do
            self.Skills[i]:OnFinish()
            table.remove(self.Skills, i)
        end
        self.Skills = nil
        for i = #self.Items, 1, -1 do
            self.Items[i]:OnRemove()
            table.remove(self.Items, i)
        end
        self.Items = nil
        for i = #self.Emitters, 1, -1 do
            self.Emitters[i]:Disable()
            table.remove(self.Emitters, i)
        end
        self.Emitters = nil

        for i = #self.Texts, 1, -1 do
            table.remove(self.Texts, i)
        end
        self.Texts = nil
        for i = #self.Combs, 1, -1 do
            table.remove(self.Combs, i)
        end
        self.Combs = nil
        for i = #self.Attribute, 1, -1 do
            table.remove(self.Attribute, i)
        end
        self.Locomotion = nil
        self.Attribute = nil
        self.Player = nil
        self.Effect = nil
        if (self.Entity ~= nil) then
            RemoveUnit(self.Entity)
        end
        self.Entity = nil
        self = nil
    else
        for i = #self.Buffs, 1, -1 do
            if (self.Buffs[i] ~= nil) then
                self.Buffs[i]:OnRemove()
            end
        end
        if (self.Effect ~= nil) then
            DestroyEffect(self.Effect)
        end
    end
end

function Unit:UpdateSkillCD()
    if (self.Skills ~= nil) then
        for i = #self.Skills, 1, -1 do
            if (self.Skills[i] ~= nil) then
                self.Skills[i]:UpdateCD()
            else
                Game.LogError(self.Name .. "丢失Skill")
            end
        end
    end
end

function Unit:Fighting()
    return GameScene.Elapsed - self.LastFightTime <= 5
end

function Unit:X()
    return GetUnitX(self.Entity)
end

function Unit:Y()
    return GetUnitY(self.Entity)
end

function Unit:Z()
    return GetUnitFlyHeight(self.Entity)
end

--面向角度采用角度制,0正东方向,90度正北方向
function Unit:Facing()
    return GetUnitFacing(self.Entity)
end

function Unit:SetPosition(x, y, z)
    SetUnitX(self.Entity, x)
    SetUnitY(self.Entity, y)
    if (z ~= nil) then
        SetUnitFlyHeight(self.Entity, z, 0)
    end
end

function Unit:SetScale(scaleX, scaleY, scaleZ)
    SetUnitScale(self.Entity, scaleX, scaleY, scaleZ)
end

function Unit:SetUnitRotation(zAngle)
    local i = zAngle * 0.7 + 0.5
    if i > 0 then
        SetUnitAnimationByIndex(self.Entity, i)
    else
        SetUnitAnimationByIndex(self.Entity, i + 252)
    end
end

--面向角度采用角度制,0正东方向,90度正北方向
function Unit:SetUnitFacing(facingAngle)
    EXSetUnitFacing(self.Entity, facingAngle)
end

function Unit:SetUnitOwner(Player)
    SetUnitOwner(self.Entity, Player, true)
    self.Player = Player
end

function Unit:SetActive(value)
    PauseUnit(self.Entity, value)
end

function Unit:OnLevelUp()
    if (self.onLevelUp ~= nil) then
        self.onLevelUp(self)
    end
end

function Unit:OnGameUpdate(dt)
    if (self.Attribute:get("生命") <= 0 or self.IsDying) then
        return
    end
    if (self.Buffs ~= nil) then
        for i = #self.Buffs, 1, -1 do
            if (self.Buffs[i] ~= nil) then
                self.Buffs[i]:OnGameUpdate(dt)
            else
                Game.LogError(self.Name .. "丢失Buff")
            end
        end
    end

    if (self.Skills ~= nil) then
        for i = #self.Skills, 1, -1 do
            if (self.Skills[i] ~= nil) then
                self.Skills[i]:OnGameUpdate(dt)
            else
                Game.LogError(self.Name .. "丢失Skill")
            end
        end
    end

    if (self.Emitters ~= nil) then
        for i = #self.Emitters, 1, -1 do
            if (self.Emitters[i] ~= nil) then
                self.Emitters[i]:OnGameUpdate(dt)
            else
                Game.LogError(self.Name .. "丢失Emitters")
            end
        end
    end

    if (self.Locomotion ~= nil) then
        self.Locomotion:OnGameUpdate(dt)
    end

    if (self.Attribute ~= nil) then
        local regenMana = self.Attribute:get("魔法恢复")
        if (regenMana ~= 0) then
            self.Attribute:add("魔法值", regenMana * dt)
        end
    end

    if (self.Texts ~= nil and #self.Texts > 0) then
        self.TextDt = self.TextDt - dt
        if (self.TextDt <= 0) then
            self.TextDt = #self.Texts >= 5 and 0.04 or 0.16
            local text = self.Texts[#self.Texts]
            CreateDamageText(text[1], self.Entity, text[2], text[3])
            table.remove(self.Texts, #self.Texts)
            text = nil
        end
    end
end

--死亡后还会调用的更新
function Unit:OnDyingUpdate(dt)
    if (self.Locomotion ~= nil) then
        self.Locomotion:OnGameUpdate(dt)
    end
    if (self.Skills ~= nil) then
        for i = #self.Skills, 1, -1 do
            if (self.Skills[i] ~= nil) then
                self.Skills[i]:OnGameUpdate(dt)
            else
                Game.LogError(self.Name .. "丢失Skill")
            end
        end
    end
    if (self.Texts ~= nil and #self.Texts > 0) then
        self.TextDt = self.TextDt - dt
        if (self.TextDt <= 0) then
            self.TextDt = #self.Texts >= 5 and 0.08 or 0.16
            local text = self.Texts[#self.Texts]
            CreateDamageText(text[1], self.Entity, text[2], text[3])
            table.remove(self.Texts, #self.Texts)
            text = nil
        end
    end
end

function Unit:IterateSkills(call)
    if (self.Skills ~= nil) then
        for i = #self.Skills, 1, -1 do
            if (self.Skills[i] ~= nil) then
                call(self.Skills[i])
            else
                Game.LogError(self.Name .. "丢失Skill")
            end
        end
    end
end

function Unit:IterateBuffs(call)
    if (self.Buffs ~= nil) then
        for i = #self.Buffs, 1, -1 do
            if (self.Buffs[i] ~= nil) then
                call(self.Buffs[i])
            else
                Game.LogError(self.Name .. "丢失Buff")
            end
        end
    end
end

function Unit:IterateItems(call)
    if (self.Items ~= nil) then
        for i = #self.Items, 1, -1 do
            if (self.Items[i] ~= nil) then
                call(self.Items[i])
            else
                Game.LogError(self.Name .. "丢失道具")
            end
        end
    end
end