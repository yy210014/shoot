local console = require "jass.console"
local debug = debug
Game = {}

IsDebug = true
local mIsPause = false
console.enable = IsDebug
function Game.Log(text)
    if (IsDebug) then
        console.write("------------------" .. text .. "---------------------")
        for i = 0, 3 do
            DisplayTextToPlayer(Player(i), 0, 0, "|cffffcc00" .. text .. "|r")
        end
    end
end

function Game.LogError(text)
    if (IsDebug) then
        console.write("---------------------------------------")
        console.write("              LUA ERROR!!              ")
        console.write("---------------------------------------")
        console.write(tostring(text) .. "\n")
        console.write(tostring(debug.traceback()) .. "\n")
        console.write("---------------------------------------")
        --Game.Pause(true)
        for i = 0, 3, 1 do
            --DisplayTextToPlayer(Player(i), 0, 0, "|cffff0000" .. text .. "|r")
        end
    end
end

function DisplayTextToAll(text, color)
    color = color or Color.white
    for i = 0, 3 do
        DisplayTextToPlayer(Player(i), 0, 0, "|c" .. color .. text .. "|r")
    end
end

--更新
function Game.OnGameUpdate()
    if (mIsPause) then
        return
    end
    GameScene.OnGameUpdate(GameScene.DeltaTime)
end

function Game.ChooseLevel()
    GameScene.OnGameStart()
end

function Game.Win()
end

function Game.Fail()
end