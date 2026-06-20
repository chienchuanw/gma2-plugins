
-- Color Plugin v1.0
-- 功能：將 PresetType Color 的 MixColor A 的 R 屬性設為 75

-- 取得 plugin 參數
local internal_name = select(1,...)
local visible_name = select(2,...)

-- 主要執行函式
function Start()
    -- 顯示開始訊息
    gma.echo("開始執行 Color Plugin...")
    
    -- 執行設定紅色屬性的指令
    SetColorRed()
    
    -- 顯示完成訊息
    gma.echo("Color Plugin 執行完成！")
end

-- 設定紅色屬性的函式
function SetColorRed()
    -- 選取 PresetType Color
    gma.cmd('PresetType "Color"')
    
    -- 選取 MixColor A feature
    gma.cmd('Feature "MixColor A"')
    
    -- 將 R 屬性設為 75
    gma.cmd('Attribute "R" At 75')
    
    -- 提供回饋訊息
    gma.feedback("已將 MixColor A 的紅色屬性設為 75")
end

-- 清理函式（可選）
function Cleanup()
    gma.echo("Color Plugin 清理完成")
end

-- 回傳執行函式
return Start, Cleanup

