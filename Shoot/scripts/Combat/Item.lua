Item = {}
local mt = {}
Item.__index = mt
mt.Owner = nil
mt.Entity = nil --实体
mt.Name = ""
mt.Id = 0

--叠加列表
local mItemOverlayList = {
    ["IB01"] = 0,
    ["IB02"] = 0,
    ["IB03"] = 0,
    ["IB04"] = 0,
    ["IB05"] = 0,
    ["IB06"] = 0,
    ["IB07"] = 0,
    ["I089"] = 0
}
--唯一列表
local mItemUniquenessList = {
    ["I003"] = 0,
    ["I062"] = 0,
    ["I077"] = 0,
}

function Item.HasItem(unit, itemId, list)
    local item = nil
    for i = 5, 0, -1 do
        item = UnitItemInSlot(unit.Entity, i)
        if item ~= nil and itemId == GetItemTypeId(item) and IsInTable(item, list) == -1 then
            return item
        end
    end
    return nil
end

function Item.ItemUniquenessList(unit, item)
    if (mItemUniquenessList[Misc.ID2Str(item.Id)] ~= nil) then
        unit:IterateItems(
        function(v)
            if item.Id == v.Id and v ~= item then
                DisplayTextToPlayer(unit.Player, 0, 0, "|cffffcc00该装备最多只能携带一件！|r")
                UnitRemoveItem(unit.Entity, item.Entity)
                return
            end
        end
        )
    end
end

function Item.ItemOverlay(unit, item)
    if (mItemOverlayList[Misc.ID2Str(item.Id)] ~= nil) then
        unit:IterateItems(
        function(v)
            if item.Id == v.Id and v ~= item then
                local entity = v.Entity
                local entityCount = GetItemCharges(entity)
                SetItemCharges(entity, entityCount + GetItemCharges(item.Entity))
                entityCount = GetItemCharges(entity)
                RemoveItem(item.Entity)
                if (item.Id == Misc.GetId("IB04") and entityCount >= 120) then
                    SetItemCharges(entity, entityCount - 120)
                    if entityCount == 0 then
                        RemoveItem(entity)
                    end
                    local itemAXAD = CreateItem(Misc.GetId(Card.RandomSR()), unit:X(), unit:Y())
                    DisplayTextToPlayer(unit.Player, 0, 0, "|cffffcc00合成卡片：" .. GetItemName(itemAXAD) .. "|r")
                    DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIlm\\AIlmTarget.mdl", unit.Entity, "origin"))
                    UnitAddItem(unit.Entity, itemAXAD)
                elseif (item.Id == Misc.GetId("IB05") and entityCount >= 150) then
                    SetItemCharges(entity, entityCount - 150)
                    if entityCount == 0 then
                        RemoveItem(entity)
                    end
                    local itemAXAD = CreateItem(Misc.GetId(Card.RandomSSR()), unit:X(), unit:Y())
                    DisplayTextToPlayer(unit.Player, 0, 0, "|cffffcc00合成卡片：" .. GetItemName(itemAXAD) .. "|r")
                    DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIlm\\AIlmTarget.mdl", unit.Entity, "origin"))
                    UnitAddItem(unit.Entity, itemAXAD)
                end
                return
            end
        end
        )
    end
end

function Item:New(owner, entity)
    local newItem = {}
    local name = FilterStringColor(GetItemName(entity))
    setmetatable(newItem, { __index = Items[name] })
    newItem.Owner = owner
    newItem.Entity = entity
    newItem.Id = GetItemTypeId(entity)
    return newItem
end

function Item:OnAdd()
end

function Item:OnRemove()
end

function Item:OnCast()
end

function Item:OnUse()
end

function Item:OnAttack(attactUnit, defUnit)
end

function Item:OnKill(dieUnit)
end

function Item:OnUpgrade()
end

function Item:OnRefresh()
end

function Item:SetIcon(art)
    EXSetItemDataString(self.Id, ITEM_DATA_ART, art)
end

function Item:GetCharges()
    return GetItemCharges(self.Entity)
end

function Item:SetCharges(value)
    if (value <= 0) then
        return
    end
    SetItemCharges(self.Entity, value)
end

Items = setmetatable(
{},
{
    __index = function(self, name)
        self[name] = {}
        setmetatable(self[name], { __index = Item })
        self[name].Name = name
        return self[name]
    end
}
)