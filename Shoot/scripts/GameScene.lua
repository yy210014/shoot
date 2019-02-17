require "scripts.AssetsManager"
require "scripts.MonsterRefresh"
require "scripts.Combat.Unit"
require "scripts.Combat.Attribute"
require "scripts.Combat.Items.InitItem"
require "scripts.Combat.Skills.InitSkill"
require "scripts.Combat.Emitters.InitEmitter"
require "scripts.Combat.Locomotions.InitLocomotion"

GameScene = {}
GameScene.Elapsed = 0
GameScene.DeltaTime = 0.016


local function InitPlayerResource()
    for i = 0, 7 do
        SetPlayerState(Player(i), PLAYER_STATE_RESOURCE_GOLD, 1500)
        SetPlayerState(Player(i), PLAYER_STATE_RESOURCE_LUMBER, 0)
        SetPlayerState(Player(i), PLAYER_STATE_FOOD_CAP_CEILING, 100)
        --修改了人口上限
        SetPlayerState(Player(i), PLAYER_STATE_RESOURCE_FOOD_CAP, 100)
    end
    SetPlayerState(Player(8), PLAYER_STATE_GIVES_BOUNTY, 1)
    --锁定资源交易
    SetMapFlag(MAP_LOCK_RESOURCE_TRADING, true)
end

function GameScene.OnGameStart()
    InitPlayerResource()
    DisplayTextToAll("--提示：双击选择英雄。", Color.yellow)
end


function GameScene.OnGameUpdate(dt)
    GameScene.Elapsed = GameScene.Elapsed + dt
    AssetsManager.OnGameUpdate(dt)
    MonsterRefresh.OnGameUpdate(dt)
end