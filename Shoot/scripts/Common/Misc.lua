Misc = {}
Misc.PI = 3.14159274

function Misc.Clamp(value, min, max)
    if (value > max) then
        return max
    end
    if (value < min) then
        return min
    end
    return value
end

function Misc.GetId(strName)
    if (strName == nil) then
        Game.LogError("字符串为空")
        return
    end
    local i = string.byte(strName, 1)
    i = i * 256 + string.byte(strName, 2)
    i = i * 256 + string.byte(strName, 3)
    i = i * 256 + string.byte(strName, 4)
    return i
end

function Misc.ID2Str(id)
    local s1, s2, s3, s4
    local i, j = math.modf(id / 256)
    s4 = string.char(j * 256)
    i, j = math.modf(i / 256)
    s3 = string.char(j * 256)
    i, j = math.modf(i / 256)
    s2 = string.char(j * 256)
    i, j = math.modf(i / 256)
    s1 = string.char(j * 256)
    return s1 .. s2 .. s3 .. s4
end

function Misc.GetGuid()
    local seed = { "e", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f" }
    local tb = {}
    for i = 1, 32 do
        table.insert(tb, seed[math.random(1, #seed)])
    end
    local sid = table.concat(tb)
    return string.format(
    "%s-%s-%s-%s-%s",
    string.sub(sid, 1, 8),
    string.sub(sid, 9, 12),
    string.sub(sid, 13, 16),
    string.sub(sid, 17, 20),
    string.sub(sid, 21, 32)
    )
end

--镜头+
function AddCameraFieldForPlayer()
    local player = GetTriggerPlayer()
    local nowCameraField = GetCameraTargetPositionZ()
    nowCameraField = nowCameraField + 100
    if (nowCameraField > 600) then
        nowCameraField = 600
    end
    SetCameraFieldForPlayer(player, CAMERA_FIELD_ZOFFSET, nowCameraField, 0)
end

--镜头-
function MinusCameraFieldForPlayer()
    local player = GetTriggerPlayer()
    local nowCameraField = GetCameraTargetPositionZ()
    nowCameraField = nowCameraField - 50
    if (nowCameraField < 150) then
        nowCameraField = 150
    end
    SetCameraFieldForPlayer(player, CAMERA_FIELD_ZOFFSET, nowCameraField, 0)
end