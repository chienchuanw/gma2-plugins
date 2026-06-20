-- Presets to Offsets
-- v1.2.3

-- Created by Jason Giaffo
-- Last updated Oct 3, 2019
-- Contact: http://giaffodesigns.com/contact/
                                                                                                                                                                                                                                                                                                                                                                                                        local CONFIG = {}
-- All copies and revisions of this code are copyright property of Giaffo Designs and may not be used, in any part or in entirety, without written consent of Jason Giaffo and credit where used. This plugin is only approved for usage by persons who have directly purchased it from GiaffoDesigns.
-- TL;DR: don't be a dick; don't steal people's work; give credit to people




---- USER CONFIG SETTINGS ----
CONFIG.OFFSET_PAN  = true           -- use presets for offestting pan   (true:enabled, false:disabled)
CONFIG.OFFSET_TILT = true           -- use presets for offestting tilt












--------------------------------------------------------------------------------------------
------------------------------ DO NOT EDIT BELOW THIS POINT --------------------------------
--------------------------------------------------------------------------------------------
CONFIG.VERBOSE = false                                  -- print extra info to the System Monitor about what's happening in the background

local DEBUG_FILE = 'DebugFile_PresetsToOffsets.txt'     -- Debug file name in /gma2/reports/
local DEBUG_FILE_ENABLE = true
local SAVE_DEBUGFILE_IF_SUCCESSFUL = false

---- Dependencies ----

local GDFstr = [==========[
-- v1.5.5



--[[CLASSES:
class.SuperTable
class.Macro
class.CmdSeq
class.ProgressBar
class.MsgBox
class.Queue
class.Layout
class.DebugStream
]]

local _M = {}
local unpack = table.unpack

-- local function shortcuts
local function cmd(...)
    gma.cmd(string.format(...))
end

local function echo(...)
    gma.echo(string.format(...))
end

local function feedback(...)
    gma.feedback(string.format(...))
end


-- GD = GD or {}


---- "Object" Classes
_M.internal = {
    counter = function()
        GD.internal.ct = GD.internal.ct or 0
        GD.internal.ct = GD.internal.ct + 1
        
        return GD.internal.ct

        -- TEST
        -- for i = 1, 10 do
        --     gma.echo('GD COUNTER: '..GD.internal.counter())
        -- end
    end
}



_M.class = { --sub-module v1.1.0
    SuperTable = {
        append = function(self, v)
            self[#self + 1] = v
        end,

        concat = function(self, sep, i, j)
            return table.concat(self, sep, i, j)
        end,
        
        new = function(self, o)
            o = o or {}
            setmetatable(o, self)
            self.__index = self
            return o
        end,

        shuffle = function(list)
            local iterations = #list
            for x = 1, 4 do                                --repeat process, else last number ends up the same
                for i = iterations, 1, -1 do
                    j = math.random(i)
                    list[i], list[j] = list[j], list[i]
                end
            end
        end
    }
}

local ST = _M.class.SuperTable

_M.class.ObjSet = ST:new{
    __tostring = function(self)
        local t = ST:new{}
        for _, v in pairs(self) do
            t:append(v)
        end
        
        return(table.concat(t, ' + '))
    end
}

_M.class.Queue = ST:new{
    enqueue = function(self, data)
        self:append(data)
    end,

    dequeue = function(self)
        local t = self[1]
        table.remove(self, 1)
        return t
    end,

    peek = function(self)
        return(self[1])
    end

    --[[     -- TEST
        local q = class.Queue:new{}
        
        for i = 1, 5 do
            q:enqueue(i*5)
        end



        while #q > 1 do
            gma.echo(#q..' remaining, value: '..q:dequeue())
            gma.echo('next up: '..q:peek())
            gma.echo('')
        end

        gma.echo(#q..' remaining, value: '..q:dequeue()) ]]
}


_M.class.DebugStream = ST:new{
    -- stores log to /gma/reports/ of internal drive
    -- TESTED 2019.04.29
    
    -- methods: 
        -- DebugStream:new()
        -- DebugStream:initialize(str:filename, [str:filepath])

        -- DebugStream:setIndent(int:value, [bool:relative])

        -- DebugStream:writeLine(str)
        -- DebugStream:write(str)
        -- DebugStream:startLine(str)
        -- DebugStream:lineBreak()

        -- DebugStream:close()
        -- DebugStream:delete()

        -- DebugStream:getFile()

    -- public fields:
        -- path
        -- filename
        -- verbose

    -- private:
        -- tab
        -- indent_level
        -- spacer

    filename = 'DEBUG_Default.txt',
    path = gma.show.getvar('path')..'/reports/',
    file = nil,
    verbose = false,

    tab = "    ",
    indent_level = 0,
    spacer = string.rep('-', 70),

    initialize = function(self, filename, path)
        --[=[ call: class.DebugStream:initialize(filename, [path])
            
        sample calls:
            local d_log = class.DebugStream:new(); -- before either of the below options

            d_log:initialize('GridDebugLog.txt')
            -- OR --
            d_log:initialize('MacrosDebug.txt', [[C:\Users\Jason\Desktop\]])

        --]=]
        if path then self.path = path
        else self.path = gma.show.getvar('path')..'/reports/' end
        
        if filename then self.filename = filename end
        self.file = assert(io.open(self.path..self.filename, 'w'))

        return o
    end,

    setIndent = function(self, val, rel)
        -- input:        DebugStream:setIndent(int:value, bool:rel);
        -- output:       (void)

        -- sample calls: DebugStream:setIndent(1, true);     -- increase indent-level by 1   (relative mode)
        --               DebugStream:setIndent(3);           -- set indent-level to 3        (absolute mode)

        if (rel) then self.indent_level = self.indent_level + val;
        else self.indent_level = val; end;

        if (self.indent_level < 0) then self.indent_level = 0; end;
    end,


    close = function(self)
        if (self.file) then
            self.file:close();
            self.file = nil;
        end
    end,

    delete = function(self)
        if (self.file) then
            self.file:close();
            os.remove(self.path..self.filename);
            self.file = nil;
        end
    end,


    write = function(self, ...)
        if (self.file) then self.file:write(string.format(...)); end
        if self.verbose then gma.echo(string.format(...)); end;
    end,

    startLine = function(self, ...)
        if (self.file) then self.file:write(self.tab:rep(self.indent_level) .. string.format(...)); end
        if self.verbose then gma.echo(string.format(...)); end;
    end,

    writeLine = function(self, ...)
        if (self.file) then self.file:write(self.tab:rep(self.indent_level) .. string.format(...) .. '\n'); end;
        if self.verbose then gma.echo(string.format(...)); end;
    end,

    lineBreak = function(self)
        if (self.file) then self.file:write(self.spacer..'\n'); end
    end,


    getFile = function(self)
        return self.path..self.filename
    end
}


_M.class.Macro = _M.class.SuperTable:new{        -- obj v2.1.0
    -- create new macro with line:
    -- mymacro = class.macro:new{num = num, name = name, info = info}
    
    import = function(self, ref)
        if not _M.get.verify('Macro '..ref) then return nil, 'Error: requested macro does not exist' end
        
        local script = _M.get.script('Macro '..ref, 'macros')
    
        self.name = _M.get.name('Macro '..ref)
        self.num = _M.get.number('Macro '..ref)

        for match in script:gmatch('<Macroline index=.-</Macroline>') do
            local t = {}
            
            local num = match:match('Macroline index="(%d+)"')    -- extract macro number
            t.num = tonumber(num) + 1
            if not self.lines then self.lines = ST:new() end
            while t.num > #self.lines do                        -- offset for empty lines
                self:newline({})
            end
            
            local cmd = match:match('<text>(.-)</text>')        -- extract command
            if cmd then t.cmd = cmd:gsub('&quot;', '"') end
            
            
            local info = match:match('<info>(.-)</info>')        -- extract info
            if info then t.info = info:gsub('&quot;', '"') end
            
            local wait = match:match('delay = \"(.-)\"')        -- extract wait time
            if wait then t.wait = tonumber(wait) end    
        
            self:newline(t)                                    -- add line to macro array
        end
    end,
    
    newline = function(self, list)                -- create function for appending new lines to macro
    -- macro:newline{cmd = [[]], wait = 0, info = [[]], disabled = false}
        if not self.lines then self.lines = _M.class.SuperTable:new() end
        self.lines:append{                                        -- list keys: cmd, wait, info, disabled
            cmd = list.cmd,                -- type: str
            wait = list.wait,            -- type: num
            info = list.info,            -- type: str
            disabled = list.disabled    -- type: bool
}
    end,

    write = function(self, force_overwrite)        -- function to write macro to showfile
        local num = self.num
        local name = self.name or 'Macro '..tonumber(num)
        local macInfo = self.info
        if macInfo then
            macInfo = macInfo:gsub([["]], [[&quot;]]);
            macInfo = macInfo:gsub([[<]], [[&lt;]]);
            macInfo = macInfo:gsub([[>]], [[&gt;]]);
            macInfo = macInfo:gsub('%%', '%%%%');
        end
        local script = [[
<?xml version="1.0" encoding="utf-8"?>
<MA xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.malighting.de/grandma2/xml/MA" xsi:schemaLocation="http://schemas.malighting.de/grandma2/xml/MA http://schemas.malighting.de/grandma2/xml/3.2.2/MA.xsd" major_vers="3" minor_vers="0" stream_vers="0">
    <Info datetime="2017-01-07T23:39:00" showfile="Ye Olde Bag O Phallus" />
    <Macro index="1" name="]]..name..[[">]]..'\n'
    if macInfo then script = script..[[
        <InfoItems>
            <Info date="2019-06-23T16:20:45">]]..macInfo..[[</Info>
        </InfoItems>]]..'\n'
    end
    
        
        for i, v in ipairs(self.lines) do
            local cmd    = self.lines[i].cmd
            local wait    = self.lines[i].wait
            local info    = self.lines[i].info
            local disabled    = self.lines[i].disabled
            
          if cmd  then cmd    = cmd:gsub([["]], [[&quot;]]) end
          if info then info = info:gsub([["]], [[&quot;]]) end

          --build XML script to append to master script
          local t = [[
        <Macroline index="]]..tostring(i-1)..[["]]
          
          if type(wait) == 'string' and wait:upper() == 'GO' then
            t = t..[[ delay="-1" ]]
          elseif wait then
            t = t..[[ delay="]]..wait..[["]] end
            
          if disabled then t = t..[[ disabled="true"]] end
          
          --command and info lines
          if (not cmd) and (not info) then t = t..[[ />]]..'\n'
          else
            t = t..[[>]]..'\n'
            
            if cmd then t  = t..[[
            <text>]]..cmd..[[</text>]]..'\n' end
            
            if info then t = t..[[
            <info>]]..info..[[</info>]]..'\n' end
            
            
            --close out script for macro line
            t = t..[[
                </Macroline>]]..'\n'
                
            --append new XML text to master script
            script = script..t
          end
        end
        
        --close out script for entire macro
          script = script..[[
    </Macro>
</MA>]]
        
        local macFile = {}
        macFile.name        = 'tempFile_createMacro.xml'
        macFile.dir            = gma.show.getvar('PATH')..'/'..'macros/'
        macFile.fullpath    = macFile.dir..macFile.name  

        local writeFile = io.open(macFile.fullpath, 'w')
        writeFile:write(script)
        writeFile:close()

        local importcmd = 'Import \"'..macFile.name..'\" Macro '..num        -- build string for import
        if force_overwrite then importcmd = importcmd..' /o /nc' end        -- (if force-overwrite enabled)
        gma.cmd('SelectDrive 1')    
        gma.cmd(importcmd)
        os.remove(macFile.fullpath)

        gma.cmd('Label Macro '..num..' \"'..name..'\"')
    end,
    
    
}


_M.class.CmdSeq = ST:new{
    -- sequence colors are supported; cue colors are not (currently)
    -- class.CmdSeq:new{num=num, name=name, (appearance='rrggbb')}
    
    name = '',
    num = '',

    newline = function(self, list)                -- create function for appending new lines to macro
    -- seq:newline{name=name, cue=cuenum, part=part, cmd=cmd}
        if not self.lines then self.lines = _M.class.SuperTable:new() end
        if not self.line_ref then self.line_ref = {} end
        
        local current
        if (not self.line_ref[list.cue]) then                       -- self.line_ref[cue] == corresponding parts-table from self.lines
            self.lines:append{num = list.cue}
            current = self.lines[#self.lines]
            self.line_ref[list.cue] = current
        else
            current = self.line_ref[list.cue]
        end

        local part = list.part or 0
        current[part] = {                                        
            cmd = list.cmd,                -- type:str
            name = list.name or 'Cue'   -- type:str
        }
    end,

    write = function(self, force_overwrite)
        local script = {
            header = [[
<?xml version="1.0" encoding="utf-8"?>
<?xml-stylesheet type="text/xsl" href="styles/sequ@html@default.xsl"?>
<?xml-stylesheet type="text/xsl" href="styles/sequ@executorsheet.xsl" alternate="yes"?>
<?xml-stylesheet type="text/xsl" href="styles/sequ@trackingsheet.xsl" alternate="yes"?>
<MA xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.malighting.de/grandma2/xml/MA" xsi:schemaLocation="http://schemas.malighting.de/grandma2/xml/MA http://schemas.malighting.de/grandma2/xml/3.5.0/MA.xsd" major_vers="3" minor_vers="0" stream_vers="0">
    <Info datetime="2019-03-17T17:15:00" showfile="poopie" />
    <Sequ index="]]..(self.num - 1)..[[" name="]]..self.name..[[">
]],

            footer = [[
    </Sequ>
</MA>
]],
            cue_header = [[
        <Cue index="<!index>">
            <Number number="<!cuenum>" sub_number="<!decimal>" />
]],

            cue_footer = [[
        </Cue>
]],
            cue_part = [[
            <CuePart index="<!part>" name="<!partname>">
                <macro_text><!cmd></macro_text>
            </CuePart>
]],

}
        -- addition of appeaerance line
        if self.appearance then script.header = script.header..[[
        <Appearance Color="]]..self.appearance..[[" />
]] end
        -- close out sequence header
        script.header = script.header..[[
        <Cue xsi:nil="true" />
]]
        
        -- sort self.lines in order of represented cue number
        local sort_cues = function(a, b)
            return (a.num < b.num)
        end
        table.sort(self.lines, sort_cues)

        -- format strings, build script
        script.list = ST:new{script.header}
        for index, cue in pairs(self.lines) do
            -- cue information
            local whole = math.floor(cue.num)
            local rem = "0"

            -- set remainder value: must be '0' or 3 digits w/o preceding decimal
            if whole ~= cue.num then
                rem = tostring(_M.data.round(cue.num - whole, 0.001))
                rem = rem:sub(3, -1)
                while #rem < 3 do
                    rem = rem..'0'
                end
            end

            -- create cue header
            local sub_cue = {
                index = index,
                cuenum = whole,
                decimal = rem
            }
            script.list:append(_M.xml.sub(script.cue_header, sub_cue))

            -- cuepart script
            for part = 0, #cue do
                local name = tostring(cue[part].name)
                name = name:gsub('%%', '%%%%')

                local cmd = cue[part].cmd
                if cmd then
                    cmd = cmd:gsub([["]], [[&quot;]])
                    cmd = cmd:gsub([[<]], [[&lt;]])
                    cmd = cmd:gsub([[>]], [[&gt;]])
                    cmd = cmd:gsub('%%', '%%%%')
                end


                    
                local sub_cp = {
                    partname = name,
                    part = part,
                    cmd = cmd
                }

                script.list:append(_M.xml.sub(script.cue_part, sub_cp))
            end
            
            -- cue footer script
            script.list:append(script.cue_footer)
        end

        -- sequence footer script
        script.list:append(script.footer)

        -- concatenate and import list
        script.print = script.list:concat('')

        gma.cmd('Delete /nc Sequence '..self.num)
        _M.poolitem.generate('Sequence '..self.num, script.print)


        -- TEST
        -- local s = class.CmdSeq:new{num=576, name="My Command Sequence"}
        -- s:newline{cue=0.25, name='Quarter Rate',    cmd=[[LUA "ColFX{param1='A', /param2='B'}"]]}
        -- s:newline{cue=0.25, part=1, name='Q Rate 2',       cmd=[[LUA "ColFX{param1='A', /param2='B'}"]]}
        -- s:newline{cue=0.5, name='Empty'}
        -- s:newline{cue=2.27, name='Awkward Rate', cmd=[[Go Executor "Fuck This"]]}
        -- s:write()
    end
}



_M.class.MsgBox = ST:new{
    -- myMsgObj = class.msgBox:new{title = 'Title of my message'}

    new = function(self, o)
        local tbl = {}
        if type(o) == 'string' then tbl.title = o;
        else tbl = o; end;
        
        setmetatable(tbl, self)
        self.__index = self
        return tbl
    end,

    title = '',

    confirm = function(self)
        return gma.gui.confirm(self.title, table.concat(self, '\n'))
    end,

    msgbox = function(self)
        return gma.gui.msgbox(self.title, table.concat(self, '\n'))
    end,

    print = function(self)
        for _, v in ipairs(self) do
            gma.echo(v)
            gma.feedback(v)
        end
    end,

    ToString = function(self)
        return table.concat(self, '\n')
    end,

    --[[]
    -- MsgBox Test
    local testTitle = 'MsgBox Title'
    local box = class.MsgBox:new{title = testTitle}
    box:append('This is my message box object.')
    box:append('');
    box:append('This is my text.')

    box:confirm()
    box:print()
    box:msgbox()
    



    ]]


}


_M.class.ProgressBar = ST:new{
    value = 0,

    new = function(self, name)
        o = {handle = gma.gui.progress.start(name)}

        setmetatable(o, self)
        self.__index = self
        return o
    end,
    
    set = function(self, num, add)
        if add then num = self.value + num end
        
        num = math.floor(num)
        gma.gui.progress.set(self.handle, num)
        self.value = num
    end,
    
    setrange = function(self, bottom, top)
        if not bottom or not top then return nil end
        gma.gui.progress.setrange(self.handle, bottom, top)
        self.range = {top = top, bottom = bottom}
    end,
    
    settext = function(self, text)
        gma.gui.progress.settext(self.handle, text)
    end,
    
    rename = function(self, name)
        gma.gui.progress.stop(self.handle)
        self.handle = gma.gui.progress.start(name)
        if self.range then gma.gui.progress.setrange(self.handle, self.range.bottom, self.range.top) end
    end,
    
    stop = function(self)
        gma.gui.progress.stop(self.handle)
    end,
    
    time_move = function(self, target, time, add, ignore_top)
        if add then target = self.value + target end
        local start = self.value
        local finish = math.floor(target)
        
        local sleepPeriod
        if math.abs(time) ~= time then sleepPeriod = (1 / time)                                            --allow for negative time values to trigger a "rate" function
        else sleepPeriod = time / (math.abs(finish - start)) end
        
        if not ignore_top and self.range and finish > self.range.top then finish = self.range.top end    --set finish point to top of progress-bar range unless specified to ignore
        
        local dir = 1
        if start > finish then dir = -1 end
        
        for i = start, finish, dir do
            self:set(i)
            gma.sleep(sleepPeriod)
        end    
    end
}
    
---- Layouts
_M.lo = {
    layout = ST:new{
        -- new: lo.layout:new{name=name, num=num}
        -- properties:
        --    .size = .x .y
        --    .bound .x .y
            -- .min .max


        name = nil,    -- string value: name of layout when imported
        num = nil,    -- number value: number where layout will be imported
        bg_col = '000000',        -- hex rrggbb string
        grid = {0, 0},
        snap_grid = {0.5, 0.5},
        
        size  = {x = 0, y = 0},
        bound = {x = {}, y = {}},
        --\\ format: bound.(x/y).(min/max)
        
        rebound = function(self, obj)
            local size = {obj.size.x or obj.size[1], obj.size.y or obj.size[2]}
            local coord = {obj.coord.x or obj.coord[1], obj.coord.y or obj.coord[2]}
            if not obj.bound then obj.bound = {
                x = {
                    min = coord[1] - (size[1]/2),
                    max = coord[1] + (size[1]/2),
                },
                y = {
                    min = coord[2] - (size[2]/2),
                    max = coord[2] + (size[2]/2),
                }
            }
            end
            
            -- adjust master layout bound values
            if not self.bound.x.min then            -- create bounds for layout if first object
                self.bound = obj.bound
            else                                    -- modify bounds for new objects added
                for k, v in pairs(self.bound) do
                    -- set maximums
                    self.bound[k].max = math.max(v.max, obj.bound[k].max)

                    -- set minimums
                    self.bound[k].min = math.min(v.min, obj.bound[k].min)
                end
            end
        
            -- reset size values
            for k, v in pairs(self.bound) do
                self.size[k] = math.abs(self.bound[k].max - self.bound[k].min)
            end
            
            -- gma.echo('CURRENT LAYOUT BOUNDS:')                                                    -- TROUBLESHOOT
            -- gma.echo(self.bound.x.min, ' ', self.bound.x.max)
            -- gma.echo(self.bound.y.min, ' ', self.bound.y.max)
            -- gma.echo('')
        end,
        
        -- Layout Object Types
        obj = ST:new{        
            id = 'obj',                -- object default. Do not change.
            
            obj = {
                type = nil,            -- string. Examples 'plugin', 'macro', 'group'
                num    = nil            -- number. Example: for [Macro 501], enter 501 here.
            },
            
            img = nil,                -- number.
            
            coord = {
                x = 0,
                y = 0,
            },
            
            size = {
                x = 0.95,
                y = 0.95
            },

            icon = {
                vis = 'Simple',        -- valid options: 'pool icon', 'simple' (groups, pool items), filled, spot (groups, fixtures). Use 'simple' for images
                bg = '3c3c3c',        
                border = '5a5a5a',    -- rrggbb hex string
                icon = 'None',        -- enter icon number if icon is being used
            },
            
            text = {
                text = '',            -- string
                size = 2,            -- options: 1, 2, 3. Does not apply to text in "text" field above, but to name only.
                color = nil,        -- enter hex string if color is applicable
                show_id = false,    -- bool
                show_name = false,    -- bool
                show_type = false,    -- bool
            }
            
            
        },
            
        box = ST:new{
            id = 'box',
            
            bg = '00000000',
            border = 'ffffff',
            
            img = nil,    -- number value
            
            coord = {
                x = 0,
                y = 0,
            },
            
            size = {
                x = 0.95,
                y = 0.95,
            },
            
            text = {
                text = '',
                show_id = true,
                show_name = true,
                show_type = true,
            },
            
            active = {
                show_dVal = false,
                show_dBar = false,
                select_grp = false,
            },
        
        
        },
        
        -- function for adding new object to layout
        addobj = function(self, config)    
            if not self.collection then self.collection = ST:new{
                obj = ST:new(),
                box = ST:new(),
            }
          end

            local t = self.obj:new(config)
            self.collection.obj:append(t)
            self:rebound(t)
            return t
        end,
        
        addbox = function(self, config)
            -- if box entered as bounds, convert to coord+size values
            if config.bounds then
                local d = config.bounds                -- "local directory"
                config.size = {
                    x = math.abs(d.x[2] - d.x[1]),
                    y = math.abs(d.y[2] - d.y[1])
                }
                
                config.coord = {
                    x = (d.x[1] + d.x[2])/2,
                    y = (d.y[1] + d.y[2])/2,
                }
            end
            
            if not self.collection then self.collection = ST:new{
                obj = ST:new(),
                box = ST:new(),
            } end

            local t = self.box:new(config)
            self.collection.box:append(t)
            self:rebound(t)
            return t
        end,
        
        -- layout transform methods
        shift = function(self, x, y)
            if x and y and type(x) == 'number' and type(y) == 'number' then
                -- translate objects inside collection
                for _, v in pairs(self.collection) do
                    for _, obj in ipairs(v) do
                        obj.coord.x = obj.coord.x + x
                        obj.coord.y = obj.coord.y + y
                    end
                end
                
                -- translate master x boundaries
                for k, v in pairs(self.bound.x) do
                    self.bound.x[k] = v + x
                end
                
                -- translate master y boundaries
                for k, v in pairs(self.bound.y) do
                    self.bound.y[k] = v + y
                end
            else
                return nil, 'error: invalid data for LO-shift'
            end
        end,
        
        scale = function(self, x, y)
            local scl = {
                x = x or 1,
                y = y or 1,
            }
            
            local avg = function(a, b)
                if type(a) == 'table' and (not b) then
                    return ((a.min + a.max)/2)
                elseif type(a) == 'table' and type(b) == 'table' then
                    return ((a + b)/2)
                end
            end
            
            ---- Reset master boundaries of object ----
            -- master center info
            local mast = {
                cent = {
                    x = avg(self.bound.x),
                    y = avg(self.bound.y),
                },
                
                size = {
                    x = (self.bound.x.max - self.bound.x.min) * scl.x,
                    y = (self.bound.y.max - self.bound.y.min) * scl.y
                }
            }
            
            for k, v in self.bound do
                self.bound[k].min = mast.cent[k] - (mast.size[k]/2)
                self.bound[k].max = mast.cent[k] + (mast.size[k]/2)
            end
            
            ---- Reset Individual items position + size ----
            for type, v in pairs(self.collection) do
                for i, obj in ipairs(v) do
                    local l = self.collection[type][i]    -- local "directory" = layout object
                        l.coord.x = (l.coord.x or l.coord[1]) + (((l.coord.x or l.coord[1]) - mast.cent.x) * scl.x)
                        l.coord.y = (l.coord.y or l.coord[2]) + (((l.coord.y or l.coord[2]) - mast.cent.y) * scl.y)
                        
                        l.size.x = l.size.x * scl.x
                        l.size.y = l.size.y * scl.y
                end
            end
        end,
        
        merge = function(self, other)
        self:rebound(other)                -- merge boundaries
        
        for type, table in pairs(other.collection) do    -- merge other's object tables into self
            for i, v in ipairs(table) do
                self.collection[type]:append(v)
            end
        end
    end,
    
        -- write, import into showfile
        write = function(self, config)
            local config = config or {}            -- currently only used for debug option
            
            local trunc = _M.data.trunc
        
            local scr = ST:new()
            -- still need
            --\\ name
            --\\ number
        
        
            local function write_obj(scr, obj_table)
                -- header for "objects" section
                scr:append([[
            <CObjects>
]])

                -- body for "objects"
                for _, v in ipairs(obj_table) do
                    ---- Process object information ----
                    local x = trunc(v.coord.x or v.coord[1], 0.001)
                    local y = trunc(v.coord.y or v.coord[2], 0.001)
                    local size_x = trunc(v.size.x or v.size[1], 0.001)
                    local size_y = trunc(v.size.y or v.size[2], 0.001)
                    
        
                    local show_id, show_name, show_type, font_size, font_color
                    if v.text.show_id == true then show_id = [[show_id="1" ]]; else show_id = ''; end;
                    if v.text.show_name == true then show_name = [[show_name="1" ]]; else show_name = ''; end;
                    if v.text.show_type == true then show_type = [[show_type="1" ]]; else show_type = ''; end;
                    local fSizeTbl = {'font_size="Small" ', '', 'font_size="Big" '}
                    font_size = fSizeTbl[v.text.size] or ''
                    if v.text.color then font_color = 'text_color="'..v.text.color..'" '; else font_color = ''; end
                
                
                    ---- Object header ----
                    scr:append([[
                <LayoutCObject ]]..font_size..[[ center_x="]]..x..[[" center_y="]]..y..[[" size_h="]]..size_y..[[" size_w="]]..size_x..[[
" background_color="]]..v.icon.bg..[[" border_color="]]..v.icon.border..[[" ]]..font_color..[[icon="]]..v.icon.icon..[[" ]]..show_id..show_name..show_type..[[function_type="]]..v.icon.vis..[[" select_group="1">
]]);
                
                
                
                    ---- Image Information ----
                    --if v.img.name and v.img.rootnum then    -- if valid entry provided for image information
                    if tonumber(v.img) and tonumber(v.img) > 0 and _M.get.verify('Image '..v.img) then
                        local rootnum = _M.get.rootnum('Image', v.img)
                        local name = _M.get.label('Image '..v.img)
                        scr:append([[
                    <image name="]]..name..[[">
                        <No>]]..rootnum[1]..[[</No>
                        <No>]]..rootnum[2]..[[</No>
                    </image>
]]);
                    else                                    -- append string for "no image"
                        scr:append([[
                    <image />
]])
                    end
                
                
                    ---- Object Information ----
                    -- head/name
                    for k, v in pairs(v.obj) do                                                                        -- TROUBLESHOOT
                        gma.echo(k, ' - ', type(v), ' - ', v)
                    end
                    
                    local w_obj = {                                    -- create write-object data
                        name = _M.get.label(v.obj.type..' '..v.obj.num),
                        rootnum = _M.get.rootnum(v.obj.type, v.obj.num)
                    }

                    -- gma.echo('object type: '..(v.obj.type))                    -- TROUBLESHOOT
                    -- gma.echo('object number: '..(v.obj.num))
                    -- gma.echo(_M.get.label(v.obj.type..' '..v.obj.num))
                    -- gma.echo('')

                    scr:append([[
                    <CObject name="]]..w_obj.name..[[">
]]);

                    -- object root number
                    for i = 1, #w_obj.rootnum do
                        scr:append([[
                        <No>]]..w_obj.rootnum[i]..[[</No>
]]);
                    end
            
                    -- close
                    scr:append([[
                    </CObject>
]]);                
                
                    ---- Object Footer ----
                    scr:append([[
                </LayoutCObject>
]]);
                end
            
            
                -- footer for "objects" section
                scr:append([[
            </CObjects>
]])
            end
            
            local function write_box(scr, box_table)
                ---- Rectangles Header ----
                scr:append([[
            <Rectangles>
]]);

                ---- Rectangles Body ----
                for _, v in ipairs(box_table) do
                    ---- Process object information ----
                    local x = trunc(v.coord.x, 0.001)
                    local y = trunc(v.coord.y, 0.001)
                    local size_x = trunc(v.size.x, 0.001)
                    local size_y = trunc(v.size.y, 0.001)

                    local show_id, show_name, show_type, show_dVal, show_dBar
                    if v.text.show_id == true then show_id = [[show_id="1" ]]; else show_id = ''; end;
                    if v.text.show_name == true then show_name = [[show_name="1" ]]; else show_name = ''; end;
                    if v.text.show_type == true then show_type = [[show_type="1" ]]; else show_type = ''; end;

                    local show_dimmerVal; if v.active.show_dVal then show_dimmerVal = [[show_dimmer_value="Off" ]]; else show_dimmerVal = ''; end;
                    local show_dimmerBar; if v.active.show_dBar then show_dimmerBar = [[show_dimmer_bar="Off" ]]; else show_dimmerBar = ''; end;
                    local select_grp; if v.active.select_grp then select_grp = [[select_group="1" ]]; else select_grp = ''; end;
                    
                    -- start rectangle object
                    scr:append([[
                <LayoutElement font_size="Small" center_x="]]..x..[[" center_y="]]..y..[[" size_h="]]..size_y..[[" size_w="]]..size_x..[[
" background_color="]]..v.bg..[[" border_color="]]..v.border..[[" icon="None" text="]]..v.text.text..[[" ]]..show_id..show_name..show_type..show_dimmerBar..show_dimmerVal..select_grp..[[>
]]);

                    -- Image Information
                    if tonumber(v.img) and tonumber(v.img) > 0 and _M.get.verify('Image '..v.img) then        -- if image info provided
                        local rootnum = _M.get.rootnum('Image', v.img)
                        local name = _M.get.label('Image '..v.img)
                        scr:append([[
                    <image name="]]..name..[[">
                        <No>]]..rootnum[1]..[[</No>
                        <No>]]..rootnum[2]..[[</No>
                    </image>
]]);
                    else                                        -- if no image
                        scr:append([[
                    <image />
]]);
                    end
                
                    -- end rectangle object
                    scr:append([[
                </LayoutElement>
]])

                end
            
                ---- Rectangles Footer ----
                scr:append([[
            </Rectangles>
]])                
            end




            -- write file header
            scr:append([[
<?xml version="1.0" encoding="utf-8"?>
<MA xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.malighting.de/grandma2/xml/MA" xsi:schemaLocation="http://schemas.malighting.de/grandma2/xml/MA http://schemas.malighting.de/grandma2/xml/3.2.2/MA.xsd" major_vers="3" minor_vers="1" stream_vers="2">
    <Info datetime="2016-10-18T14:28:09" showfile="xml_scripting" />
    <Group index="0" name="]]..self.name..[[">
        <LayoutData index="0" marker_visible="true" background_color="]]..self.bg_col..[[" visible_grid_h="]]..self.grid[2]..[[" visible_grid_w="]]..self.grid[1]..[[" snap_grid_h="]]..self.snap_grid[2]..[[" snap_grid_w="]]..self.snap_grid[2]..[[" default_gauge="Filled &amp; Symbol" subfixture_view_mode="DMX Layer">
]]);

            -- write layout objects
            if #self.collection.obj > 0 then
                write_obj(scr, self.collection.obj)
            end
        
            -- write boxes
            if #self.collection.box > 0 then
                write_box(scr, self.collection.box)
            end
        
                
            ---- write file footer
            scr:append([[
        </LayoutData>
    </Group>
</MA>]]);

            ---- Filesystem Info ----
            local fn = {temp = 'temp_layoutgen.xml'}
            local dir = {}
                dir.main = gma.show.getvar('PATH')..'/'
                dir.imex = dir.main..'importexport/'
            local file = {temp = dir.imex..fn.temp}
            
            local wf = io.open(file.temp, 'w')
            wf:write(scr:concat())                    -- concatenate script lines and write
            wf:close()
        
            -- Import Layout to designated slot
            gma.cmd('Import \"'..fn.temp..'\" Layout '..self.num)
            
            -- remove temp file
            if not config.debug then
                os.remove(file.temp)
            end
            
        end    --end of write method

    },
    




    spacingTable = function(tbl)
        --[==[\\ input: {
            dim = {cols, rows}, --(number of objects on x-axis, on y-axis)
            space = {x, y},    -- distance between BOUNDARIES of objects
            size = {x, y},    -- size of objects
            start = {x, y},    -- reference point for generated coordinates
            iscent = {true, true},        -- set to true for POS entry to reference center of generated grid, instead of top/left
            first = {x = true},        -- set to {y = true} to traverse y-axis first
        }
        ]==]
        --\\ output: spacingtable[i] = {xvalue, yvalue}
        --assimilate data
        local x = {
            ct        = tbl.dim[1]                        or 1,
            int        = tbl.space[1] + tbl.size[1]        or 1,
        }
        if tbl.iscent[1] then    x.start = tbl.start[1] - ((x.ct-1) * x.int * 0.5)
        else x.start = tbl.start[1] end
        x.pos = x.start
        
        local y = {
            ct        = tbl.dim[2]                        or 1,
            int        = tbl.space[2] + tbl.size[2]        or 1,
        }
        if tbl.iscent[2] then y.start = tbl.start[2] - ((y.ct-1) * y.int * 0.5)
        else y.start = tbl.start[1] end
        y.pos = y.start


        -- create output table
        local t = ST:new{}
        local loops = 1
        
        -- there's a better way to do this if I had more coffee
        if tbl.first.y then                        ---- process for y-first
            for col = 1, x.ct do
                for row = 1, y.ct do
                    t[loops] = {x.pos, y.pos}    -- add position to table
                    y.pos = y.pos + y.int        -- advance y position
                    loops = loops + 1            -- advance loop count
                end
                
                x.pos = x.pos + x.int            -- advance column position
                y.pos = y.start                    -- reset row position
            end    
        else                                    ---- process for x-first (default)
            for row = 1, y.ct do
                for col = 1, x.ct do
                    t[loops] = {x.pos, y.pos}    -- add position to table
                    x.pos = x.pos + x.int        -- advance x position
                    loops = loops + 1            -- advance loop count
                end
                
                y.pos = y.pos + y.int            -- advance row position
                x.pos = x.start                    -- reset column position
            end
        end
        
        -- allow access as {x, y} or .x .y
        for i, v in ipairs(t) do
            t[i].x = t[i][1]
            t[i].y = t[i][2]
        end


        t.index = 0
        t.next = function(self)
            self.index = self.index + 1
            local i = self.index
            if self.index <= #self then
                return {x = self[i][1], y = self[i][2]}
            else
                return nil, 'error: final index passed'
            end
        end
        return t        
    end,

}


    
---- UI Functions

_M.gui = {    --sub-module version 1.1.0
    tcol = {
        black = '[30m',
        red = '[31m',
        green = '[32m',
        yellow = '[33m',
        blue = '[34m',
        cyan = '[35m',
        magenta = '[36m',
        white = '[37m'
    },

    col = function(string, new, orig)
        local orig = orig or 'cyan'
        return _M.gui.tcol[new]..string.._M.gui.tcol[orig]
    end,



    debugprint = function(str)
        gma.echo(_M.gui.tcol.green..str)
    end,

    
    
    
    input = function(title, body, opt_tbl, opt_legacy)
        -- input: gui.input(str:title, str:body, tbl:options{nomatch:bool, num:bool, match_escape:bool})
        -- old input (still valid): gui.input(str:title, str:body, bool:toggle_nomatch, bool:toggle_num)
        
        -- title: title of gma.textinput box
        -- body: default text of gma.textinput box
        -- toggle_nomatch: if set to true, does not accept input that matches default text
        -- toggle_num: if set to true, does not accept inputs that do not convert to a number type
        local toggle_nomatch, toggle_num, match_escape

        -- correction from previous version used in show builder plugin
        if not opt_tbl then
            opt_tbl = {}
        elseif type(opt_tbl) == 'string' then
            toggle_nomatch = opt_tbl
            toggle_num = opt_legacy
        elseif type(opt_tbl) == 'table' then
            toggle_nomatch = opt_tbl.nomatch
            toggle_num = opt_tbl.num
            match_escape = opt_tbl.match_escape
        end


        local t
        while true do
            t = gma.textinput(title, body)
            if (t == body) and match_escape == true then                                                                                                -- if empty-input is triggering release
                return nil, nil, true
            elseif ((not t) or (#t == 0) or (t == body and toggle_nomatch)) then                                                                        -- if no input
                local trig = _M.gui.confirm("NO INPUT PROVIDED: "..title, "Press [OK] to provide input\nPress [CANCEL] or X to terminate plugin.")
                if not trig then
                    return nil, "Plugin terminated by user.", true
                end
            elseif toggle_num then                                                                                                                      -- if NUMBER input called
                local start, finish = t:lower():match('(%d+)%s*thru%s*(%d+)')                       -- check if a range of "X Thru Y" was entered 

                if tonumber(t) then return tonumber(t)                                              -- return number if number was input
                elseif (start and finish) then return {tonumber(start), tonumber(finish)}           -- return start and end of range (as numbers) if range was input
                else 
                    local trig = _M.gui.confirm("INVALID INPUT: "..title, "Number input required.\nYour input: "..t.."\nPress [OK] to provide input\nPress [CANCEL] or X to terminate plugin.")
                    if not trig then
                        return nil, "Plugin terminated by user.", true
                    end
                end
            else
                return t                            -- otherwise return string form of input
            end
        end
        
        
        --[[
        ---- FUNCTION TEST ----
        local input1, input2, input3
        local error1, error2, error3
        input1, error1 = gui.input("Basic input", "I accept default text")
        input2, error2 = gui.input("Text input", "I do NOT accept default text", true)
        input3, error3 = gui.input("Accepts defaults, must be number", "5", false, true)
        
        gma.echo('INPUTS:')
        gma.echo(input1)
        gma.echo(input2)
        gma.echo(input3)
        gma.echo('ERRORS:')
        gma.echo(error1)
        gma.echo(error2)
        gma.echo(error3)
        --]]
    end,
    
    
    msgbox = function(title, message_box, message_text)
      -- v. 1.0
      -- function avoids using confirmation box function with version 3.1.2.5, where it doesn't exist
      local confirm_method
      
      local version = gma.show.getvar('version')
      
      if version:find('3.1.2') == 1 then 
        confirm_method = 'textinput'
      else 
        confirm_method = 'box' end
      
      if confirm_method == 'box' then
        gma.gui.msgbox(title, message_box)
      elseif confirm_method == 'textinput' then
        gma.textinput(title, message_text)
      end
    end,
    
    
    confirm = function(title, message_box, message_text)
      -- v. 1.0
      -- function avoids using confirmation box function with version 3.1.2.5, which crashes the software
      local confirm_method
      
      local version = gma.show.getvar('version')
      
      if version:find('3.1.2') == 1 then 
        confirm_method = 'textinput'
      else 
        confirm_method = 'box' end
      
      if confirm_method == 'box' then
        return gma.gui.confirm(title, message_box)
      elseif confirm_method == 'textinput' then
        local t = gma.textinput(title, message_text)
        if t then t = true end
        return t
      end
    end,
    
    
    print = function(str)
        str = tostring(str)
        for line in str:gmatch('[^\n]+') do
            gma.echo(line)
            gma.feedback(line)
        end
    end,
    
    
    windowSize = function(ct, maxwidth)
        local t = {}

        if ct <= (maxwidth - 1) then
            t.y = 1
            t.x = ct
            return t
        else
            local testnum = math.ceil(ct/maxwidth)
            if ((maxwidth * testnum) - 1) < ct then t.y = testnum + 1
            else t.y = testnum end


            local capacity = (maxwidth * t.y - 1)
            local excess = capacity - ct

            t.x = maxwidth - math.floor(excess/t.y)

            return t
        end
    end,
    
    view_lib = {
        cmd = [[
<?xml version="1.0" encoding="utf-8"?>
<MA xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.malighting.de/grandma2/xml/MA" xsi:schemaLocation="http://schemas.malighting.de/grandma2/xml/MA http://schemas.malighting.de/grandma2/xml/3.2.2/MA.xsd" major_vers="3" minor_vers="2" stream_vers="2">
    <Info datetime="2017-06-06T19:11:55" showfile="some shit" />
    <View index="899" name="CMD/Sys" display_mask="2">
        <Widget index="0" type="434f4e53" display_nr="1" y="4" anz_rows="4" anz_cols="16">
            <Data>
                <Data>13</Data>
                <Data>3</Data>
                <Data>0</Data>
                <Data>0</Data>
            </Data>
        </Widget>
        <Widget index="1" type="44425547" display_nr="1" has_focus="true" has_scrollfocus="true" anz_rows="4" anz_cols="16">
            <Data>
                <Data>0</Data>
                <Data>0</Data>
                <Data>0</Data>
                <Data>0</Data>
            </Data>
        </Widget>
    </View>
</MA>]],
        sysmon = [[
<?xml version="1.0" encoding="utf-8"?>
<MA xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.malighting.de/grandma2/xml/MA" xsi:schemaLocation="http://schemas.malighting.de/grandma2/xml/MA http://schemas.malighting.de/grandma2/xml/3.3.4/MA.xsd" major_vers="3" minor_vers="3" stream_vers="4">
    <Info datetime="2018-09-23T12:41:41" showfile="showfile" />
    <View index="68" name="SYSMON" display_mask="2">
        <Widget index="0" type="44425547" display_nr="1" anz_rows="8" anz_cols="16">
            <Data>
                <Data>0</Data>
                <Data>0</Data>
                <Data>0</Data>
                <Data>0</Data>
            </Data>
        </Widget>
    </View>
</MA>]],
    },

    callview = function(config)
        -- config: key:str('cmd', 'sysmon'), screen:num OR screen:tbl, view:num
        -- ex: gui.callview{key = 'sysmon', screen = {1, 2, 3, 4, 5, 6}, view=8500}


        -- input configuration
        local view_num = config.view

        local screen = config.screen
        if type(screen) == 'number' then screen = {screen} end

        local key = config.key
        if (not key) or (not _M.gui.view_lib[key]) then return nil, 'error: GDF.gui.callview: invalid key provided' end

        local cmd_script = _M.gui.view_lib[key]
        


        -- File configuration
        local dir = {}
        dir.main = gma.show.getvar('PATH')..'/'
        dir.importexport = dir.main..'importexport/'
        
        fn = {}
        fn.temp = [[_templ_view.xml]]
        
        file = {}
        file.temp = dir.importexport..fn.temp
        
        -- Write temp file
        local writefile = io.open(file.temp, 'w')
        writefile:write(cmd_script)
        writefile:close()
    
        -- Import and call view
        local view_orig = _M.poolitem.advanceSpace('View', view_num, 2, 0, 0)
        local view_temp = view_orig + 1
        gma.cmd('Store View '..view_orig..' /screen=all')

        gma.cmd('SelectDrive 1')
        gma.cmd('Import "'..fn.temp..'" View '..view_temp)
        for i = 1, #screen do
            gma.cmd('View '..view_temp..' /screen='..tostring(screen[i])) 
        end
        
        -- Cleanup
        os.remove(file.temp)
        gma.cmd('Delete View '..view_temp)

        -- Return view number of original screen status
        return view_orig
    end,




    cmdview = function(screen)
        -- adapted call to gui.callview() for pre-GDF_1.1.5 plugins
        if not screen then screen = 2 end
        _M.gui.callview{key = 'cmd', screen = {screen}, view = 1}

    end
} --end of gui table





---- Console Status
-- _M.class.DmxAddress = ST:new{
--     -- METHODS:
--         -- :Print(num:opt)
--     -- FIELDS:
--         -- ch
--         -- univ
--     ch = 1,
--     univ = 1,


-- }


_M.dmx = {        --sub-module v1.0
    --split a string to two table values
    split_addr = function(str, numindex)
      if type(str) == 'number' then str = tostring(str) end
      local index = str:find(':')
      if not index then
        index = str:find('[.]')
      end
      local t = {}

      if index then
        if numindex then
            t[1] = tonumber(str:sub(1, index-1))
            t[2] = tonumber(str:sub(index+1, #str))
            return t
        else
            t.univ    = tonumber(str:sub(1, index-1))
            t.ch    = tonumber(str:sub(index+1, #str))
        end
      else
          error('invalid address provided; no separator found')
      end
      
      return t
    end,


    merge_addr = function(list, seperator)
        seperator = seperator or '.'
        
        univ = list.univ or list[1]
        ch = list.ch or list[2]
        univ, ch = tostring(univ), tostring(ch)
        
        --make ch 3 digits long
        while #ch < 3 do
            ch = '0'..ch
        end
        
        --join strings
        local t = univ..seperator..ch
        return t
    end,

    univ = {},

    univ_add = function(self, univ_num)
        if not _M.csv.objToArray then error('Required function not found: csv.objToArray(str:obj)') end
        if not _M.gui.superBar then error ('Required module not found: gui.superBar') end
        
        --import new universe to CSV with progress bar displayed
        pBar_add = _M.gui.superBar:new('Importing Universe '..univ_num)
        pBar_add:setrange(0, 512)
        self.univ[univ_num] = _M.csv.objToArray('DmxUniverse '..univ_num..'.*', pBar_add)    --import new universe
        pBar_add:stop()
        
        --[[
        for i = 1, 512 do
            self.univ[univ_num][i].addr = self.split_addr(self.univ[univ_num][i].addr, true)
        end
        --]]
    end,
    
    check_space = function(self, addr_start, spaces, flush_cache)
        -- if address provided in string format, convert to table object
        if spaces > 512 then spaces = 512 end    --idiot-protection
        if type(addr_start) == 'string' then addr_start = self.split_addr(addr_start) end    
        local addr_current = {univ = addr_start.univ or addr_start[1], ch = addr_start.ch or addr_start[2]}
        
        
        local confirmed = false
        local t = {ct = 0}
        
        while (not confirmed) do
            -- if the universe to be checked is not currently in memory, import it
            if ((not self.univ[addr_current.univ]) or (flush_cache)) then
                self:univ_add(addr_current.univ)
                --self.univ[addr_current.univ] = self:univ_add(addr_current.univ)
            end
            

            -- scan for empty channels
            for i = addr_current.ch, 512 do
                if #tostring(self.univ[addr_current.univ][i].fixture) == 0 then                    --if the line has no fixture assigned
                    t.ct = t.ct + 1
                    if not t.addr then
                        t.addr = {univ = addr_current.univ, ch = addr_current.ch}
                    end
                    if t.ct == spaces then
                        confirmed = true
                        break
                    end
                    addr_current.ch = i + 1
                else                                                                            --if the line DOES have a fixture assigned
                    t.ct = 0
                    t.addr = nil
                    addr_current.ch = i + 1
                end
            end
            
            -- if not found in that universe, reset parameters and start again at next universe number
            if not confirmed then 
                addr_current = {univ = addr_current.univ + 1, ch = 1}
                t.ct = 0
                t.addr = nil
            end        --if end of universe is reached with no match for spaces
        end

        return t.addr
    end


}
--[[ ----TEST----
---- TEST ----
return function()
    gma.echo('final result: '..dmx.merge_addr(dmx:check_space('50.1', 2)))
end
--]]


_M.env = {        -- environment module v1.0.0
    getprog = function() 
        --returns 'live', 'blind', or 'preview'

      local file = {}
      file.name = 'tempfile_programmercheck.csv'
      file.directory = gma.show.getvar('PATH')..'/reports/'
      file.fullpath = file.directory..file.name
      
      gma.cmd('SelectDrive 1')                             --select internal drive
      gma.cmd('List Programmer /f=\"'..file.name..'\"') --create temp file
      
      local prog
      for line in io.lines(file.fullpath) do        --check line for status as live, blind, or preview programmer
        if     line:find('Programmer') == 1   then prog = 'live'
        elseif line:find('BlindProgrammer')   then prog = 'blind'
        elseif line:find('PreviewProgrammer') then prog = 'preview' end
      end
      os.remove(file.fullpath)                         --delete temp file
      
      return prog
    end,
    
    self_id = function(self_table)    -- function v1.2.0
        -- takes self table (table captured by {...}) and returns pool item number where executing plugin is currently stored
        
        -- self_table has to be extracted before "return" portion of plugin.
        -- (i.e. it must be generated on plugin load)
        
        local unpack = table.unpack

        local self = self_table[2]
        local indices = {0, 0}

        repeat
            indices = {self:find('%d+', indices[2] + 1)}
        until indices[2] == #self

        local self_id = tonumber(self:sub(unpack(indices)))
        return self_id
    end,

    rootnum = function(str) -- function v1.0.0
    -- retrieves directory number for a given object-type string (i.e. '8' for images)
    -- CAREFUL WHAT STRING YOU SUPPLY
        
        local unpack = table.unpack
        str = str:lower()                                                                --set string to find to lowercase to avoid case errors
        
        -- tempfile info
        local temp = {}
        temp.fn = 'tempfile_getroot'.._M.internal.counter()..'.csv'
        temp.dir = gma.show.getvar('PATH')..'/reports/'
        temp.file = temp.dir..temp.fn
        
        -- retrieve info from showfile
        gma.cmd('SelectDrive 1')
        gma.cmd('List /f=\"'..temp.fn..'\"')
        
        local line_locate = 0
        for line in io.lines(temp.file) do
            if line:lower():find(str) then                                                --if there is a lowercase match 
                line_locate = tonumber(line:sub(unpack({line:find('%d+')})))            --retrieve the number following it, converted to number format
                break
            end
        end
        
        os.remove(temp.file)                                                            --remove temp file from system
        
        -- return result
        if line_locate == 0 then
            return false, 'string not found'
        else
            return line_locate
        end    
    end,
    
    }





---- File/Data Manipulation ----


_M.data = {
    SaveFile = ST:new{-- SaveFile module v0.0.1
        -- initialization blocks:
        --\\ load from number
        --\\ load by name
        --\\ create new
        new = function(self, o)                -- initialization method for new object and new file
            -- CALL: myfile = data.SaveFile:new{name = name, num = num}

            if o.name and o.num then        -- create savefile if name and number both povided
                setmetatable(o, self)
                self.__index = self
                o:write({})
            elseif (not o.name) then
                return nil, 'ERROR: NO NAME PROVIDED FOR NEW SAVEFILE.'
            elseif (not o.num) then
                return nil, 'ERROR: NO NUMBER PROVIDED FOR NEW SAVEFILE.'
            end

            return o
        end,

        load = function(self, o)            -- initialization method for new object from existing file
            
            if (o.name and _M.get.verify('Plugin \"'..o.name..'\"')) then
                o.num = _M.get.number('Plugin \"'..o.name..'\"')
            elseif (o.num and _M.get.verify('Plugin '..o.num)) then
                o.name = _M.get.label('Plugin '..o.num)
            else
                local msg = 'ERROR: NO SAVEFILE FOUND MATCHING PROVIDED NAME OR NUMBER.'

                gma.echo(_M.gui.tcol.magenta .. msg)
                gma.echo(_M.gui.tcol.magenta .. 'Provided name: [['..tostring(o.name)..']]')
                gma.echo(_M.gui.tcol.magenta .. 'Provided number: '..tostring(o.num))
                return nil, msg
            end

            setmetatable(o, self)
            self.__index = self

            return o
        end,

        num = 0,
        name = '',
    
        header = '--[============[',
        footer = '--]============]',
        

        write = function(self, data)
            local script = table.concat({self.header, _M.table.tostring(data), self.footer}, '\n')
            
            gma.cmd('Unlock Plugin '..self.num)
            _M.plugin.write({name = self.name, num = self.num, script = script}, true)
            gma.cmd('Lock Plugin '..self.num)
        end,
        
        
        read = function(self)

            -- function to prep header/footer tags for search
            local function s_prep(str)    -- string search prep function
                return (str:gsub('(%W)', '%%%1'))
            end
            
            local script = _M.plugin.read(self.num)                                                    -- extract script from plugin
            local script_tbl = script:gsub(s_prep(self.header)..'(.+)'..s_prep(self.footer), '%1')    -- extract actual content
            

            
            local data = _M.table.fromstring(script_tbl)

            return data
        end,


        delete = function(self)
            gma.cmd('Unlock Plugin '..self.num)
            gma.cmd('Delete Plugin '..self.num)
        end
    },
    
    getDrive = function()
        -- only enter DEBUG:bool if looking for print feedback
        -- otherwise function take no arguments

        -- returns: current plugin filepath

        local testPath = function(path, fn, DEBUG)
            local file_xml = path..fn..'.xml'
            local file_lua = path..fn..'.lua'

            local testfile, err = io.open(file_lua)
            if DEBUG then gma.echo('CHECKING FOR FILE: '..file_lua) end
            if testfile then
                testfile:close()
                os.remove(file_lua)
                os.remove(file_xml)
                return path:match('(.*)plugins')
            else
                return nil, err
            end
        end

        local alphabet = 'abcdefghijklmnopqrstuvwxyz'

        local fn = '__FINDME'
        gma.cmd('Export /nc /o Plugin 1 "'..fn..'"')

        local fpath = gma.show.getvar('pluginpath')..'/'
        local file_lua = fpath..fn..'.lua'
        local file_xml = fpath..fn..'.xml'

        local testfile, err = io.open(file_lua)
        if testfile then
            testfile:close()
            os.remove(file_lua)
            os.remove(file_xml)
            return fpath:match('(.*)plugins')
        else
            ---- if running in OnPC ----
            if gma.show.getvar('hostsubtype'):lower() == 'onpc' then        

                for i = 1, #alphabet do
                    local fpath = alphabet:sub(i,i):upper()..[[:\gma2\plugins\]]
                    local t = testPath(fpath, fn, true)
                    if t then return t end                                    -- return if match found, otherwise loops continue
                end

                error('NO FILEPATH FOUND FOR CURRENT DRIVE')                 -- error if path not found  

            ---- if running on console ----
            else                                                          
                for i = 1, #alphabet do
                    local fpath = {
                        [[/media/sd]]..alphabet:sub(i,i)..[[1/plugins/]],
                        [[/media/sd]]..alphabet:sub(i,i)..[[/plugins/]]
                    }

                    for _, v in ipairs(fpath) do
                        local t = testPath(v, fn, true)
                        if t then return t end                                -- return if match found, otherwise loops continue
                    end
                end

                error('NO FILEPATH FOUND FOR CURRENT DRIVE')                 -- error if path not found  

            end
        end
        

        ---- TEST ----
        -- local t = data.getDrive()
        -- if not t then t = 'ERROR: FILEPATH NOT FOUND'
        -- gma.gui.confirm('RESULTS', t)
    end,
    
    parseColon = function(info_raw)
    -- takes raw string in [key: value] format with one entry pair per line and returns as table

        local t = {}

        for i in info_raw:gmatch('.-%:.-[\n]') do
            local k, v = i:match('%s*([^\n]+)%s*%:%s*([^\n]+)[%s\n]*')
            if k and v then
                t[k] = v
            end
        end

        -- local finish = info_raw:match('[\n][^\n]-%:[^\n]-$')
            -- local k, v = finish:match('%s*(.+)%s*%:%s*(.+)[%s\n]*')
            -- t[k] = v

        return t
    end,

    trunc = function(num, modulus)
        return (num - num%modulus)
    end,
    
    round = function(num, modulus)
        local trunc = _M.data.trunc(num, modulus)
        local under = math.abs(trunc - num)
        local over = math.abs((trunc + modulus) - num)

        if under < over then return trunc
        else return (trunc + modulus) end
    end,
    
    sr_ct = 1,    -- _M.data.sr_ct
    
    setrange = function(config)
        -- config input:
        --\\ .size .start .loops .direct
        -- output format
        --\\ .size (.start): {.start .finish}
        --\\ \\ +.direct: start, finish
        --\\ .size .loops:   start1, start2, start3, ...
        
        
        local l = _M.data
        
        if config.start then l.sr_ct = config.start end

        if (not config.loops) then
            local start = l.sr_ct
            local finish = l.sr_ct + config.size - 1
            l.sr_ct = l.sr_ct + config.size
            
            if config.direct then return start, finish
            else return {start = start, finish = finish} end
        
        elseif config.loops then
            local results = {}
            for i = 1, config.loops do
                results[i] = l.sr_ct
                l.sr_ct = l.sr_ct + range
            end
            return unpack(results)
        end
        
    end,

    GDpath = function(...)
        GD = GD or {}
        local path = GD
        local path_str = 'GD'

        local tbl = {...}
        if type(tbl[1]) == 'table' then tbl = tbl[1]; end;

        for i, v in ipairs(tbl) do
            -- create path table, change directory to new path
            if not path[v] then path[v] = {} end
            path = path[v]

            -- update path string
            if type(v) == 'number' then path_str = path_str..'['..v..']'
            elseif type(v) == 'string' then path_str = path_str..'.'..v end
        end

        
        gma.echo(_M.gui.tcol.blue..'PATH CREATED: '..path_str)                     -- feedback
        return path
    end,

    BinaryToHex = function(bin)
        local tbl = {}
        for i = 1, #bin do
            table.insert(tbl, string.format("%.2X", string.byte(bin:sub(i,i))))
        end
    
        return table.concat(tbl, '')
    end,
    
    HexToBinary = function(hex_str)
        local tbl = {}
        for i = 1, #hex_str, 2 do
            table.insert(tbl, tonumber('0x'..hex_str:sub(i, i+1)))
        end
    
        return string.char(unpack(tbl))
    end,
}



_M.table = {    -- table storage/loading Module v1.0.0
    tostring = function(tbl)
      -- function found online at http://lua-users.org/wiki/SaveTableToFile
      local function exportstring( s )
        return string.format("%q", s)
      end

      local charS,charE = "   ","\n"                -- space char, newline char
      local build_t,err = _M.class.SuperTable:new()        -- define "build_t" to append to

      -- initiate variables for save procedure
      local tables,lookup = { tbl },{ [tbl] = 1 }    
      build_t:append( "return {"..charE )

      for idx,t in ipairs(tables) do
         build_t:append( "-- Table: {"..idx.."}"..charE )
         build_t:append( "{"..charE )
         local thandled = {}

         -- handle sequence
         for i,v in ipairs( t ) do
            thandled[i] = true
            local stype = type( v )
            -- only handle value
            if stype == "table" then
               if (not lookup[v]) then
                  table.insert( tables, v )
                  lookup[v] = #tables
               end
               build_t:append( charS.."{"..lookup[v].."},"..charE )
            elseif stype == "string" then
               build_t:append(  charS..exportstring( v )..","..charE )
            elseif (stype == "number") or (stype == "boolean") then
               build_t:append(  charS..tostring( v )..","..charE )
            end
         end

         -- handle key,value pairs
         for i,v in pairs( t ) do
            -- escape handled values
            if (not thandled[i]) then

               local str = ""
               local stype = type( i )
               -- handle index
               if stype == "table" then
                  if not lookup[i] then
                     table.insert( tables,i )
                     lookup[i] = #tables
                  end
                  str = charS.."[{"..lookup[i].."}]="
               elseif (stype == "string") then
                  str = charS.."["..exportstring( i ).."]="
               elseif (stype == "number") or (stype == "boolean") then
                  str = charS.."["..tostring( i ).."]="
                elseif stype == "" then
               end

               if str ~= "" then                -- if something was appended...
                  stype = type( v )
                  -- handle value
                  if stype == "table" then
                     if not lookup[v] then
                        table.insert( tables,v )
                        lookup[v] = #tables
                     end
                     build_t:append( str.."{"..lookup[v].."},"..charE )
                  elseif stype == "string" then
                     build_t:append( str..exportstring( v )..","..charE )
                  elseif (stype == "number") or (stype == "boolean") then
                     build_t:append( str..tostring( v )..","..charE )
                  else gma.echo('unhandled value: '..v)
                  end
               end
            end
         end
         build_t:append( "},"..charE )
      end
      build_t:append("}")
      
      return build_t:concat()
    end,

    fromstring = function(tbl_string)
      -- -- function found online at http://lua-users.org/wiki/SaveTableToFile
      local ftables,err = load(tbl_string)    -- load string
      if err then return _,err end            -- return error if present
      local tables = ftables()                -- execute string
      if ftables == nil then return {} end
      for idx = 1,#tables do
         local tolinki = {}
         for i,v in pairs( tables[idx] ) do
            if type( v ) == "table" then
               tables[idx][i] = tables[v[1]]
            end
            if type( i ) == "table" and tables[i[1]] then
               table.insert( tolinki,{ i,tables[i[1]] } )
            end
         end
         -- link indices
         for _,v in ipairs( tolinki ) do
            tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
         end
      end
      return tables[1]
    end,

    buildpath = function(master, list)
        local dir_c = master
        for _, v in ipairs(list) do
            if not dir_c[v] then
                dir_c[v] = {}
                dir_c = dir_c[v]
            end
        end
        
        return dir_c
    end,
    
    keyswap = function(tbl)        -- takes table of keys set to true and returns list with those keys as values
        -- call: mytable = tbl.keyswap(mytable)
        local t = ST:new()
        for k, _ in pairs(tbl) do
            t:append(k)
        end
        
        return t
    end,
    
    keycheck = function(tbl, keys_tbl)
        -- inputs: tbl (table being checked), keys_tbl(table of keys to check for)
        -- output: bool
        for _, v in ipairs(keys_tbl) do
            if type(tbl[v]) == 'nil' then return false end
        end
        
        return true
    end,
    
    copy = function(obj)
        if type(obj) ~= 'table' then return obj end
        local t = {}
        for k, v in pairs(obj) do t[k] = _M.table.copy(v) end
        return t
    end,

    matchLength = function(...)
        -- makes all tables entered the same length as the longest table of the set
        -- ex: tbl.matchLength({1, 2, 3},    {'one', 'two', 'three', 'four', 'five'})
        -- final (no return, direct mod to existing tables):
            -- {1, 2, 3, 1, 2},    {'one', 'two', 'three', 'four', 'five'}

        -- Edited+Tested: 8/27/18
        
        local tables = {...}
    
        local lengths = {}
        local max = 0
        local adj = 0
        for i, v in ipairs(tables) do
            lengths[i] = #v
            if #v > max then
                max = #v
                adj = adj + 1
            end
        end 
    
        if adj > 1 then     -- only process tables if not already matching lengths
            for i = 1, #tables do
                if #tables[i] < max then
                    local pos = 1
    
                    for j = #tables[i] + 1, max do              -- traverse current table and repeat elements in order until same length as largest table
                        tables[i][j] = tables[i][pos]
                        if pos == #tables[i] then pos = 1 
                        else pos = pos + 1 end
                    end
                end
            end
        end
    
    end
}



_M.xml = {    --sub-module v1.0
    sub = function(script, sublist)
        --sub format = list.(substitution variable) = (substitution value)
        -- replaces <!(substitution variable> with value in script
        
        for k, v in pairs(sublist) do
            script = script:gsub('<!'..k..'>', v)
        end
        
        return script
    end,
    

    extract_vartags = function(script)
        local t = {}
        local indices = {0, 0}
        local remaining = true
        while remaining do
            indices = {script:find('<![^-].->', (indices[2] + 1))}
            if not indices[2] then break
            elseif indices[2] == #script then remaining = false end
            t[#t+1] = script:sub(indices[1] + 2, indices[2] - 1)
        end

        return t
    end
}



_M.csv = {    --sub-module version 1.1.0
        ---- converts a CSV line to a number-indexed array ----
    lineToArray = function(str)
          local t = {}
          local indices = {1, 1}
          local remaining = true
          local restart = 1
          while remaining == true do
            local pt = {str:find(',', restart)}        --find next comma at or after restart point
            if pt[1] then
              t[#t+1] = str:sub(restart, pt[1]-1)    --extract string from restart point to one position before comma
              restart = pt[2] + 1                     --reset restart point for one position after most recent found comma
            else
              remaining = false
              t[#t+1] = str:sub(restart, str[-1])
            end
          end

          return t
    end,


    ---- Converts a CSV line to an array using the indices of an input header table ----
    subheaderToArray = function(str, header)
      local t = {}
      local indices = {1, 1}
      local remaining = true
      local restart = 1
      local index = 1
      while remaining == true do
        local pt = {str:find(',', restart)}        --find next comma at or after restart point
        if pt[1] then
          t[header[index]] = str:sub(restart, pt[1]-1)    --extract string from restart point to one position before comma
          restart = pt[2] + 1                     --reset restart point for one position after most recent found comma
          index = index + 1
        else
          remaining = false
          t[header[index]] = str:sub(restart, str[-1])
        end
      end

      return t
    end,

    ---- takes a CSV file, uses the first row as the headers , and indexes the contents into a table using those headers 
    fileToArray = function(file, pBar)
        local header = {}
        local results = {}

        local firstLine = true
        for line in io.lines(file) do
          if firstLine then
            header = _M.csv.lineToArray(line)
            for k, v in pairs(header) do header[k] = v:lower() end
            firstLine = false
          else
            results[#results+1] = _M.csv.subheaderToArray(line, header)
            if pBar then pBar:set(1, true) end
          end
        end

        return results
    end,
    
        
    objToArray = function(obj, pBar)        
        ---- main function ----
        -- filepaths
        local dir    = {temp = gma.show.getvar('PATH')..'/reports/'}
        local fn     = {temp = 'export_csvobject'.._M.internal.counter()..'.csv'}
        local file    = {temp = dir.temp..fn.temp}
        
        -- export object
        gma.cmd('SelectDrive 1')
        if obj then    gma.cmd('List '..obj..' /f=\"'..fn.temp..'\"')
        else gma.cmd('List /f=\"'..fn.temp..'\"') end
        
        local t        --declare before if statement
        -- check if file exists; if not, no object was found for export
        local test = io.open(file.temp)
        if test then                                    --if file is present
            test:close()                                --close test file
            
            -- convert into table
            t = _M.csv.fileToArray(file.temp, pBar)
                
            -- delete temp file
            os.remove(file.temp)
        else
            t = {}
        end

        
        -- return result
        return t
    end,
    

    
    ---- function to take a two-dimensional table and convert it to a CSV text string
    write_table = function(list)
        local t = ''
        for i = 1, #list do
          t = t..table.concat(list[i], ',')..'\n'
        end

        return t
    end
}


_M.lua = {
    sub = function(script, sublist)
        -- end-tag
        -- <!end-replacements> --
        
        
        --sub format = list.(substitution variable) = (substitution value)
        -- replaces <!(substitution variable> with value in script
        -- auto-formats strings and places between double quotes

        -- for strings, use {yourstring, true} to use literal-brackets
        -- or {yourstring} or {yourstring, nil, true} to have a string implemented directly as is,
        -- with no quote formatting or brackets

        local function s_prep(str)    -- format string for search
            return (str:gsub('(%W)', '%%%1'))
        end

        -- nested function to determine appropriate number of brackets to use on quoted
        -- strings containing brackets themselves
        local function literal_bracket(str)
            local tbl = {}
            for match in str:gmatch('%[[=]*%[') do
                tbl[#match-2] = true
            end

            local x = 0
            while true do
                if not tbl[x] then break end
                x = x + 1
            end
            print(x)

            local rep = string.rep('=', x)

            return '['..rep..'[', ']'..rep..']'
        end

        local end_tag = '<!end-replacements>'
        end_tag = s_prep(end_tag)

        local head, body = script:match('(.-'..end_tag..')(.*)') --separate replacement zone from rest of script

        for k, v in pairs(sublist) do
            local value = v
            if type(v) == 'string' then value = string.format("%q", v)
            elseif type(v) == 'table' then
                if v[2] and (type(v[1]) == 'string') then
                    local b = {literal_bracket(v[1])}
                    value = b[1]..v[1]..b[2]
                else
                    value = v[1]
                end
            end

            head = head:gsub('<!'..k..'>', value)
        end

        return head..body
    end
}


    
---- Object Properties
    
_M.get = {
    handle = gma.show.getobj.handle
    ,
    class = function(obj, silent)
        if (not silent) then gma.echo('ignore potential "error: returns string:classname" message below') end
        return gma.show.getobj.class(_M.get.handle(obj))
    end
    ,
    label = function(obj)
        return gma.show.getobj.label(_M.get.handle(obj))
    end
    ,
    name = function(obj)
        local t = gma.show.getobj.name(_M.get.handle(obj))
        if not t then t = gma.show.getobj.label(_M.get.handle(obj)) end
        return t
    end
    ,
    verify = function(obj, silent)
        if (not silent) then gma.echo('ignore potential "error: returns bool:result" message below') end
        return gma.show.getobj.verify(_M.get.handle(obj))
    end
    ,
    amount = function(obj)
        return gma.show.getobj.amount(_M.get.handle(obj))
    end
    ,
    parent = function(obj)
        return gma.show.getobj.amount(_M.get.handle(obj))
    end
    ,
    number = function(obj)
        return gma.show.getobj.number(_M.get.handle(obj))
    end
    ,
    index = function(obj)
        return gma.show.getobj.index(_M.get.handle(obj))
    end
    ,
    child = function(obj, index)
        return gma.show.getobj.child(_M.get.handle(obj), index)
    end,

    prop_amount = function(obj)
        -- gma.echo('GET_PROP_AMOUNT FUNCTION CALLED')                                                                    -- TROUBLESHOOT
        -- local h = _M.get.handle(obj)
        -- gma.echo(h)
        -- return gma.show.property.amount(h)
        return gma.show.property.amount(_M.get.handle(obj))
    end,
        
    prop_name = function(obj, index)
        return gma.show.property.name(_M.get.handle(obj), index)
    end,
        
    prop = function(obj, ref)    
    -- ref can be str:name or num:index)
        return gma.show.property.get(_M.get.handle(obj), ref)
    end,
    
    ---- more involved than MA shortcuts ----
    
    appearance = function(obj)
    -- input - obj:str
    
    -- output:tbl{
        -- .decimal = {r, g, b}; 0-255
        -- .percent = {r, g, b}; 0-100
        -- .hex     = {r, g, b}; 00-ff
        -- .str
        --     .hex = 'rrggbb'
        --     .appearance = '/r=rr /g=gg /b=bb'
    -- }
    
    
    
        local l_dir = _M.get        -- local "directory"
    
        ---- Nested Functions ----
        function math.round(num)
          if num - num%1 < 0.5 then
            return math.floor(num)
          else
            return math.ceil(num)
          end
        end

        function match(a, b) --checks to see if a and b match or (if strings) if one contains the other
            if a == b then return true;
            elseif type(a) == 'string' and type(b) == 'string' then
                if a:lower():find(b:lower()) or b:lower():find(a:lower()) then return true
                else return false end
            else return false
            end
        end

        function table.find(t, target, i, j)  --searches table for target text using user-defined [match] function
            local i = i or 1
            local j = j or #t
          

            for n = i, j do
                if match(t[n], target) == true then    return n end
            end
            return nil
        end


        ---- Filesystem Info ----
        local folder_options = {'effects', 'macros', 'masks', 'matricks', 'user_profile', 'plugins'}
        local poolType
        local t = table.find(folder_options, obj:lower():sub(1,4))  --check if argument has a predefined export folder in MA (search using first 4 letters of input)
        if t then poolType = folder_options[t]
        else poolType = 'importexport' end
        
      
        gma.cmd('SelectDrive 1')        -- select internal drive
      
        local fn = {}
            fn.temp = '_tempfile_getappearance'.._M.internal.counter()
        local dir = {}
            dir.main = gma.show.getvar('PATH')..'/'
            dir.obj  = dir.main..poolType..'/'
        local file = {}
            file.xml = dir.obj..fn.temp..'.xml'
            file.lua = dir.obj..fn.temp..'.lua'
        
      
        ---- Main Function ----
      
        --check if object actualy exists
        local verified = _M.get.verify(obj)
        if not verified then
            return nil, 'Error: object does not exist.' end
            
        -- export object
        gma.cmd('Export '..obj..' \"'..fn.temp..'\"')

        -- convert XML file into a table
        local t = {}  
        for line in io.lines(file.xml) do
            t[#t + 1] = line
        end
      
        -- remove temp file(s)
        os.remove(file.xml)
        if poolType == 'plugins' then  -- delete LUA file if export item was a plugin
            os.remove(file.lua)
        end

        local colorHex
        for i = 1, #t do
            if t[i]:find('Appearance Color') then
                local indices
                while true do
                    local j = j
                    indices = {t[i]:find('\"%x+\"')}      --find color hex code
                    if indices[2]-indices[1]-1 == 6 then  --if length matches hex color code length
                        indices[1], indices[2] = indices[1] + 1, indices[2] - 1 --reset index values to start and end of actual hex string
                        break
                    elseif indices then
                        j = indices[2]
                    else
                        gma.echo('error: appearance function triggered, not found')
                        return nil
                    end
                end
                colorHex = t[i]:sub(indices[1], indices[2])
                break
            end
        end
      
        local colors = ST:new{}  --convert string pairs into numbers in a table - red, green, then blue
        if colorHex then
            colors.hex = {colorHex:sub(1,2),colorHex:sub(3,4),colorHex:sub(5,6)}
            

            colors.percent, colors.decimal = {}, {}
            for i = 1, 3 do
                colors.decimal[i] = tonumber('0x'..colors.hex[i])
                colors.percent[i] = math.round(colors.decimal[i]/2.55)
            end

            colors.str = {
                hex = colorHex,
                appearance = '/r='..colors.percent[1]..' /g='..colors.percent[2]..' /b='..colors.percent[3]
            }
        else
            return nil, 'object appearance not assigned'
        end

        return colors


        ---- TEST ----
        -- local obj = gma.textinput('Object to get appearance of?', '')
        -- local app, error = get.appearance(obj)
    
        -- local m = class.MsgBox:new{title = "RESULTS"}
        -- if error then
        --     m:append(error)
        -- else
        --     m:append('PERCENT: {'..table.concat(app.percent, ',')..'}')
        --     m:append('DECIMAL: {'..table.concat(app.decimal, ',')..'}')
        --     m:append('HEX: {'..table.concat(app.hex, ',')..'}')
        --     m:append('')
        --     m:append('HEX STRING: '..app.str.hex)
        --     m:append('APPEARANCE STRING: '..app.str.appearance)
        -- end
        
        -- m:confirm()
    end,

    list = function(object)
        -- filepath info --
        local location = 'reports'
        
        local fn = {temp = 'temp_generatepoolobject'.._M.internal.counter()..'.csv'}
        
        local dir = {}
            dir.main = gma.show.getvar('PATH')..'/'
            dir.temp = dir.main..location..'/'

        local file = {temp = dir.temp..fn.temp}

        
        -- get script --
        gma.cmd('SelectDrive 1')
        gma.cmd('List '..object..' /f="'..fn.temp..'"')            -- export object

        local readFile = io.open(file.temp, 'r')
        local script = readFile:read('*a')                                -- load full script as string
        readFile:close()
        
        os.remove(file.temp)                                        -- delete temp file (does not appear to be working currently)
        
        
        -- return --
        return script
    end,
    
    execlist = function(timecode)                                            -- returns list of executors contained in timecode pool item(s)
       
        local list = _M.csv.objToArray('Timecode '..timecode..'.*')
        local e_list = ST:new{}


        for i, v in ipairs(list) do
            e_list[i] = v.exec:match('(%d+%.%d+)$')
        end

        e_list.numstr = e_list:concat(' + ')
        e_list.str = 'Executor '..e_list.numstr
        
        
        return e_list
    end,
    
    seqlist = function(execs)
        -- input ex: 'Executor 15'; 'Page 1 thru 4 Executor 1 + 13 Thru 15'
        if execs:lower():find('^%s*page') == 0 and execs:lower():find('^%s*executor') == 0 then
            execs = 'Executor '..execs end
        local scr = _M.get.list(execs)
        local seq_list = {}
        for match in scr:gmatch('Sequence=Seq %d+') do
            seq_list[match:match('%d+')] = true
        end
        seq_list = _M.table.keyswap(seq_list)
        seq_list.numstr = seq_list:concat(' + ')
        seq_list.str = 'Sequence '..seq_list:concat(' + ')
        
        return seq_list
    end,
    
    script = function(object, tbl_opt)
        -- input: get.script(str:MA2 Object, [str:alternate_location, tbl:
        -- tbl_opt: {str:alternate_location (if object export folder isn't importexport),
                  -- DebugStream:debug}
        local debug_stream, alternate_location;
        if tbl_opt then
            debug_stream = tbl_opt.debug;
            alternate_location = tbl_opt.alternate_location;
        else
            debug_stream = _M.class.DebugStream:new();          -- create without initializing if none provided
        end;

        -- debug stream handling
        debug_stream:setIndent(1, true);

        -- filepath info --
        local location = alternate_location or 'importexport'
        local fn = {temp = 'temp_generatepoolobject'.._M.internal.counter()..'.xml'};
        local dir = {}
            dir.main = gma.show.getvar('PATH')..'/'
            dir.temp = dir.main..location..'/'
        local file = {temp = dir.temp..fn.temp}

        
        -- get script --
        gma.cmd('SelectDrive 1')
            debug_stream:writeLine(string.format('Current memory usage: %.3fKB', collectgarbage("count")))
            debug_stream:startLine('Exporting '..object..' for XML script at '..file.temp..'...');
            gma.sleep(0.05);                                                                                                                        -- TROUBLESHOOT
        gma.cmd('Export '..object..' "'..fn.temp..'" /nc')          -- export object
            debug_stream:write('OK\n');

        local readfile = io.open(file.temp, 'r');                       -- open generated script in read mode
        local script = readfile:read('*a');                             -- read script
        readfile:close();                                               -- close temp file
        
        os.remove(file.temp)                                            -- delete temp file (does not appear to be working currently)
        -- check for file deletion
        local test, err = io.open(file.temp, 'r');
        if (test) then
            test:close();
            debug_stream:writeLine('WARNING: '..file.temp..' COULD NOT BE DELETED.');
        elseif (err) then
            debug_stream:writeLine('Temp file deleted');
        end
        
        -- finish and return --
        debug_stream:setIndent(-1, true);
        return script
    end,
    
    group = function(grpNum)    --function v1.2.0
        -- call: get.grpfixt(num:grpNum)
        -- return: tbl{}
            -- .fixt{}
                -- [i]={fixtNum, subFixtNum, .full=fixtNum.subFixtNum}
            -- .chan[i]=(same)
      
      
        -- filepath handling
        gma.cmd('SelectDrive 1') --select the internal drive

        local file = {}
        file.name = 'tempfile.xml' 
        file.directory = gma.show.getvar('PATH')..'/'..'importexport'..'/'
        file.fullpath = file.directory..file.name
        
        -- export to XML file
        gma.cmd('Export Group ' .. grpNum .. ' \"' .. file.name .. '\"')
        
        -- read XML file
        local t = {} 
        local readFile = io.open(file.fullpath, 'r')
        local script = readFile:read('*a')
        readFile:close()
        os.remove(file.fullpath) --delete temporary file
        
        -- populate into list
        local groupList = {fixt=ST:new(), chan=ST:new()}

        for match in script:gmatch('<Subfixture (.-) />') do
            -- matches for channel, fixture, and/or sub-fixture
            local ch = match:match('cha_id="(%d+)"')
            local fixt = match:match('fix_id="(%d+)"')
            local sub = match:match('sub_index="(%d+)"')

            -- first table entry: channel/fixture number
            local t = {}
            if ch then t[1] = tonumber(ch)
            else t[1] = tonumber(fixt) end

            -- subfixture entry, full channel/fixture number w/ subfixture
            if sub then
                t[2] = sub
                t.full = string.format('%d.%d', t[1], t[2])
            else
                t.full = string.format('%d', t[1])
            end

            -- append to master list
            if (ch) then groupList.chan:append(t)
            else groupList.fixt:append(t) end
        end
      
      return groupList
    end,
    
    final = function(obj, dist)
        -- provides number of very last object of a provided type.
        -- input: object type
        -- output: number
        
        local t = _M.csv.objToArray(obj..' Thru')
        return tonumber(t[#t]['no.'])
    end,
    
    -- replace this archaic bullshit. info is a lua-extractable property
    info = function(object, alternate_location)
        -- filepath info
        local location = alternate_location or 'importexport'
        
        local fn = {temp = 'temp_infoinject'.._M.internal.counter()..'.xml'}
        
        local dir = {}
            dir.main = gma.show.getvar('PATH')..'/'
            dir.temp = dir.main..location..'/'

        local file = {temp = dir.temp..fn.temp}
        
        
        -- function
        gma.cmd('SelectDrive 1')                                        -- select internal drive
        gma.cmd('Export '..object..' "'..fn.temp..'" /nc')                -- export object script

        local readFile = io.open(file.temp, 'r')
        local script = readFile:read('*a')
        readFile:close()

        local index = {}
        index.infoitems = {script:find('<InfoItems>', 1)}                -- find start of InfoItems
        index.start = {script:find('<Info[^>]*>', index.infoitems[2])}    -- find start of info field within InfoItems
        index.start = index.start[2] + 1                                -- make index.start a singular number one position after <Info> tag

        index.finish = script:find('</Info>', index.start) - 1            -- find end of info field within InfoItems

        
        local info = script:sub(index.start, index.finish)                -- extract text within tags


        return info..'\n'                                                -- return extracted string
    end,
    
    rootnum_list = ST:new(),
    rootnum = function(str, objnum)
    -- CAREFUL WHAT STRING YOU SUPPLY
        local unpack = table.unpack
        str = str:lower()                                                                --set string to find to lowercase to avoid case errors
        if not _M.get.rootnum_list[str] then 
            -- tempfile info
            local temp = {}
            temp.fn = 'tempfile_getroot'.._M.internal.counter()..'.csv'
            temp.dir = gma.show.getvar('PATH')..'/reports/'
            temp.file = temp.dir..temp.fn
            
            -- retrieve info from showfile
            gma.cmd('SelectDrive 1')
            gma.cmd('List /f=\"'..temp.fn..'\"')
            
            local line_locate = 0
            for line in io.lines(temp.file) do
                if line:lower():find(str) then                                                --if there is a lowercase match 
                    line_locate = tonumber(line:sub(unpack({line:find('%d+')})))            --retrieve the number following it, converted to number format
                    break
                end
            end
            
            os.remove(temp.file)        --remove temp file from system
            
            local global = false
            if line_locate and line_locate ~= 0 then
                gma.cmd('CD '..line_locate)
                gma.cmd('List /f=\"'..temp.fn..'\"')
                for line in io.lines(temp.file) do
                    if line:lower():find('global') then
                        global = true
                        break
                    end
                end
            end

            os.remove(temp.file)        --remove temp file from system
            gma.cmd('CD /')                -- return to home directory
            
            -- return result
            if line_locate == 0 then
                return false, 'string not found'
            else
                local t = ST:new()
                --if global then t = {line_locate, 1, tonumber(objnum)}
                if global then t = {line_locate, 1}
                else t = {line_locate} end
                
                _M.get.rootnum_list[str] = t
            end    
        end
        
        local t1 = _M.get.rootnum_list[str]
        local t2 = ST:new()
        for _, v in ipairs(t1) do
            t2:append(v)
        end
        t2:append(tonumber(objnum))
        gma.echo(t2:concat(', '))                            -- TROUBLESHOOT
        return t2
        
--[==[ get.rootnum test
-- require modules
local GDF = GDF_1_1_4

local class    = GDF.class
local gui    = GDF.gui
local dmx    = GDF.dmx
local env    = GDF.env
local data    = GDF.data
local tbl    = GDF.table
local xml    = GDF.xml
local csv    = GDF.csv
local lua    = GDF.lua
local get    = GDF.get
local set    = GDF.set
local pi    = GDF.poolitem
local plugin= GDF.plugin
local exec    = GDF.exec

local self_table = {...}



function test()
    local tprint = function(tbl)
        for i, v in ipairs(tbl) do
            gma.echo(i..'   '..v)
        end
    end
    
    local pnum = get.rootnum('plugin', 100)
    local mnum = get.rootnum('macro', 100)
    local inum = get.rootnum('image', 100)
    local lnum = get.rootnum('layout', 100)
    local enum = get.rootnum('effect', 40)
    
    tprint(pnum)
    tprint(mnum)
    tprint(inum)
    tprint(lnum)
    tprint(enum)
end



return test
--]==]
    end,
    
}


_M.set = {
    info = function(object, info, alternate_location)
        local location = alternate_location or 'importexport'
        
        -- filepath info
        local fn = {temp = 'temp_infoinject'.._M.internal.counter()..'.xml'}
        
        local dir = {}
            dir.main = gma.show.getvar('PATH')..'/'
            dir.temp = dir.main..location..'/'

        local file = {temp = dir.temp..fn.temp}
        
        
        -- select internal drive
        gma.cmd('SelectDrive 1')
        
        -- insert marker
        gma.cmd('Unlock '..object)
        gma.cmd('Assign '..object..' /info="<SET>"')
        
        -- export object script
        gma.cmd('Export '..object..' "'..fn.temp..'" /nc')    
        
        local readFile = io.open(file.temp, 'r')
        local script_src = readFile:read('*a')
        readFile:close()

        info = info:gsub([["]], [[&quot;]]);
        info = info:gsub([[<]], [[&lt;]]);
        info = info:gsub([[>]], [[&gt;]]);
        info = info:gsub('%%', '%%%%');

        local script_output = script_src:gsub('&lt;SET&gt;', info)    --sub with actual info script
        
        -- write subbed script to original file location
        local writefile = io.open(file.temp, 'w')
        writefile:write(script_output)
        writefile:close()
        
        gma.cmd('Import "'..fn.temp..'" '..object..' /nc')    -- import over original object
        
        os.remove(file.temp)    -- remove temp file
    end,

}





---- Object-Specific Functions

_M.poolitem = { --sub-module v1.0
    generate = function(object, script, alternate_location)
        -- filepath info
        local location = alternate_location or 'importexport'
        
        local fn = {temp = 'temp_generatepoolobject'.._M.internal.counter()..'.xml'}
        
        local dir = {}
            dir.main = gma.show.getvar('PATH')..'/'
            dir.temp = dir.main..location..'/'

        local file = {temp = dir.temp..fn.temp}
        
        -- generate file --
        local writefile = io.open(file.temp, 'w')
        writefile:write(script)
        writefile:close()
        
        -- import generated object --
        gma.cmd('SelectDrive 1')
        gma.cmd('Import "'..fn.temp..'" '..object)
        
        -- cleanup --
        os.remove(file.temp)
    end,
    
    checkSpace = function(poolType, start, length, exceptions)
    -- checks if range of pool spaces is empty
        -- exceptions must be in table format {}
      local finish = start + length - 1 --set our finishing point
      local emptyStatus = true
      local failpoint
      local exceptions = exceptions or {}

      for i = start, finish do
        local obj_str = poolType..' '..tostring(i)
        if _M.get.verify(obj_str) then --if space is not empty
            local exc = false                            -- exception trigger
            for _, v in ipairs(exceptions) do
                if _M.get.name(obj_str):find(v) then    -- set True if string match to exception found
                    exc = true
                    break
                end
            end
            if not exc then                             -- if not empty and no exception string found
                emptyStatus = false
                failpoint = i
                break
            end
        end
      end
      return emptyStatus, failpoint
    end,
    
    -- advanceSpace = function(poolType, start, length, pad_before, pad_after, exceptions)
    advanceSpace = function(poolType, start, length, arg1, arg2, arg3)
        -- Tested OK 2019.04.29 with new argument calls and debug_log support

        -- input: (str:poolType, num:start, num:length(num), OPT:{pad={num:before, num:after}, DebugStream:debug, str:exceptions})
        -- example calls: pi.advanceSpace('Sequence', 1, 20, {pad={1,1}, debug=d_log, exceptions='My_Sequence'})
        --                pi.advanceSpace('Macro', 1000, 15)
        --                pi.advanceSpace('Image', 1, 30, {debug=d_log})



        local pad_before, pad_after, exceptions, debug_stream

        -- assimilate and support for old calling system
        if ((arg1) and (type(arg1) ~= 'table')) then                    -- support for old calling system
            pad_before = arg1;
            pad_after = arg2;
            exceptions = arg3;
        elseif ((arg1) and (type(arg1) == 'table')) then                -- breakdown of table inputs
            if (arg1.pad) then 
                pad_before, pad_after = arg1.pad[1], arg1.pad[2]; end;
            exceptions = arg1.exceptions;
            debug_stream = arg1.debug
        end

        start, length = tonumber(start), tonumber(length)
        
        -- adjust values for checkSpace to account for padding before/after
        local pad_before    = pad_before or 0                            --set for 0 if not provided
        local pad_after     = pad_after  or 0                            --set for 0 if not provided
        pad_before, pad_after = math.abs(pad_before), math.abs(pad_after)
        local length_actual = length + pad_before + pad_after            --length that will be used in space check
        local exceptions = exceptions or {}                              -- names of objects that can be overlooked (I think - come back to this)



        -- create dummy debug_stream if none provided
        if (not debug_stream) then debug_stream = _M.class.DebugStream:new() end; -- create but don't initialize

        -- debug_stream info: list information provided
        debug_stream:setIndent(1, true)                                                                             -- increase indent in log file
        debug_stream:writeLine('Checking for '..poolType..' space:')
        debug_stream:writeLine('Start: '..start..'; Length:'..length..'; Pads: '..pad_before..', '..pad_after)
        if (#exceptions > 0) then debug_stream:writeLine('Exceptions: '..table.concat(exceptions, ', ')) end;
        debug_stream:setIndent(1, true);

        -- handle inputs with a pad_before without enough room for pad before
        local finalStart = start;
        local preroll = 0;                       -- used for calculating final returned value
        local start_border = true;
        -- if (start - pad_before) > 0 then
        --     preroll = pad_before;
        --     finalStart = start - pad_before;
        -- else
        --     finalStart = 1;
        --     preroll = start - 1;                
        --     length_actual = preroll + length + pad_after;
        -- end

        while true do
            if (start_border) then
                if (finalStart - pad_before > 0) then
                    start_border = false;
                    preroll = pad_before;
                    length_actual = length + pad_before + pad_after;
                else
                    preroll = finalStart - 1;                       -- preroll = distance from first object
                    length_actual = length + preroll + pad_after;
                end
            end

            local test, failpoint = _M.poolitem.checkSpace(poolType, finalStart, length_actual, exceptions)
            
            if failpoint then
                finalStart = failpoint + 1;
                debug_stream:writeLine('Restarting check at '..finalStart);


            else break end
        end
        -- while _M.poolitem.checkSpace(poolType, finalStart, length_actual, exceptions) == false do
            -- finalStart = finalStart + 1
        -- end
      
        finalStart = finalStart + preroll                                -- offset returned answer for pre-padding
        debug_stream:setIndent(-1, true);
        debug_stream:writeLine('OUTPUT: '..poolType..' '..tonumber(finalStart))    -- write output to debug stream
        debug_stream:setIndent(-1, true)                                 -- restore previous indent
        
        return finalStart


        -- ---- TEST ---
        -- local type = 'Sequence';
        -- local pad = {1, 1}

        -- local log = class.DebugStream:new()
        -- log:initialize("AdvanceSpace Test", [[C:\Users\Jason\Desktop\]]);


        -- local function main()
        --     local start = gma.textinput('Starting '..type..' Number?', 'ENTER NUMBER');
        --     local quantity = gma.textinput('Number of spaces?', 'ENTER NUMBER');
        --     local final = pi.advanceSpace(type, start, quantity, {pad=pad, debug=log})

        --     local m = class.MsgBox:new{title='RESULTS'};
        --     m:append("New starting piont: "..final);
        --     m:msgbox();
        -- end

        -- local function cleanup()
        --     log:close()
        -- end

        -- return main, cleanup

    end,

    infoMatch = function(poolType, header, pbar, opt)
        local verbose; if (opt and opt.verbose) then verbose=true; end;
        local list;    if (opt and opt.list)    then list=true;    end;

        local header = '^'..header:lower()
        local MATCH = ST:new{}
        local capture = ST:new{}

        if (not list) then                                                      -- for pool-type objects (macros, sequences, presets, etc.)
            local raw = _M.csv.objToArray(poolType..' *')
                if verbose then echo('#raw: '..#raw); end;
            
            for i, v in ipairs(raw) do
                local num = v['no.']
                if (num and tonumber(num)) then capture:append(num) end
            end

        else                                                                    -- for list-type objects (remotes, patch layers, etc.)
            for i = 1, math.huge do
                if ( not _M.get.verify(poolType..tostring(i)) ) then break;
                else capture:append(i); end;
            end
        end

        if pbar then pbar:settext('Matching '..poolType..'s:'); end;
        
        for _, v in ipairs(capture) do
            local value = v;
            local obj = poolType..' '..v;

            if (poolType:lower():find('^preset')) then
                value = v:match('%d+%.(%d+)');
                obj = 'Preset '..v;
            end
            
            if verbose then echo('CHECKING OBJECT: '..obj); end;
            
            local info = _M.get.prop(obj, 'Info'):lower()
            if verbose then echo('INFO FOUND: '..info) end
            if info:find(header) then
                local key = info:match('id:%s*([%w%_]+)')
                if key then
                    if pbar then pbar:set(1, true); end;
                    local val = info:match('val:%s*([%d%.]+)')
                    if val then
                        val = tonumber(val)
                        if (not MATCH[key]) then MATCH[key] = _M.class.ObjSet:new{} end
                        MATCH[key][val] = value
                    else
                        MATCH[key] = value
                    end
                end
            end
        end

        if pbar then pbar:stop(); end;

        return MATCH;
    end,
}


_M.plugin = { -- plugin read/write functions v0.0.1
    -- config = {num = num, name = name, script = script, (EOL = true)}
    
    write = function(config, force_overwrite)
      local EOLnum
      if config.EOL then EOLnum = 1 
      else EOLnum = 0 end
      
      -- Establish filepath --
      local plugin = {}
      plugin.name = 'tempFile_createPlugin'
      plugin.directory = gma.show.getvar('PLUGINPATH')..'/'
      plugin.fullpathLUA = plugin.directory..plugin.name..'.lua'
      plugin.fullpathXML = plugin.directory..plugin.name..'.xml'


      -- Create text for plugin XML file --
      local xmlText = [[
<?xml version="1.0" encoding="utf-8"?>
<MA xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.malighting.de/grandma2/xml/MA" xsi:schemaLocation="http://schemas.malighting.de/grandma2/xml/MA http://schemas.malighting.de/grandma2/xml/3.2.2/MA.xsd" major_vers="3" minor_vers="2" stream_vers="2">
    <Info datetime="2016-09-26T20:40:54" showfile="dummyfile" />
    <Plugin index="1" execute_on_load="]]..EOLnum..[[" name="]]..config.name..[[" luafile="]]..plugin.name..[[.lua" />
</MA>]]

      -- Write XML file to disk --
      local fileXML = assert(io.open(plugin.fullpathXML, 'w'))
      fileXML:write(xmlText)
      fileXML:close()
      
      -- Write LUA file to disk --
      local fileLUA = assert(io.open(plugin.fullpathLUA, 'w'))
      fileLUA:write(config.script)
      fileLUA:close()

      -- import plugin --
      local importcmd = 'Import \"'..plugin.name..'\" Plugin '..tostring(config.num)        -- build string for import
      if force_overwrite then importcmd = importcmd..' /o /nc' end        -- (if force-overwrite enabled)
      gma.cmd('SelectDrive 1') --select the internal drive as default read path
      gma.cmd(importcmd) --load new plugin into showfile

      -- delete temp files --
      os.remove(plugin.fullpathXML)
      os.remove(plugin.fullpathLUA)
    end,
    
    read = function(num)
        -- revised and tested v1.1.4

        -- File Config
        local fn = {}
            fn.temp = '_plugintemp'.._M.internal.counter()
        local dir = {}
            dir.plugins = gma.show.getvar('PLUGINPATH')..'/'
        local file = {}
            file.xml = dir.plugins..fn.temp..'.xml'
            file.lua = dir.plugins..fn.temp..'.lua'
            
        -- export plugin
        gma.cmd('SelectDrive 1')
        gma.cmd('Export Plugin '..num..' \"'..fn.temp..'\"')
        
        local readfile = io.open(file.lua, 'r')    -- open file for reading
        local script = readfile:read('*a')        -- extract script to memory
        readfile:close()                        -- close file

        local XMLread = io.open(file.xml, 'r')
        local XMLscript = XMLread:read('*a')
        XMLread:close()

        local EOL = XMLscript:match('execute_on_load=\"(%d)\"')
        if tonumber(EOL) == 1 then EOL = true
        else EOL = false end
    
        -- delete temp files
        os.remove(file.xml)    
        os.remove(file.lua)
        
        -- return lua script, EOL-status
        return script, EOL
    end,


}


_M.exec = {    
    advance = function(page, exec, ct, minExec)
        -- returns table
        --\\.page .exec .str('x.xxx' format)
        
        -- advance to first available solid block of executors from provided start position
        -- if the executor number hits 100, 199, or 210, and there still are more to go, then
        -- the count restarts on the next page at the minimum executor number.
        -- if there is not enough space to pull this off on any page, the function returns nil and an error message
            
        ---- nested functions ----
        
        local function checkPass(exec, ct)
            local limits = {100, 199, 210}
            local status_pass = true
            for i = 1, #limits do
                if exec <= limits[i] and (exec+ct-1) > limits[i] then 
                    status_pass = false 
                    break
                end      
            end
            
            return status_pass
        end
        
        local function checkNum(num)
            local limits = {100, 199, 210}
            local status_pass = true
            for i = 1, #limits do
                if num == limits[i] then status_pass = false; break; end;
            end
            
            return status_pass
        end

        local error_msg = 'Error: minExec set too high'
        local page = tonumber(page)
        local exec = tonumber(exec)
        local ct; if not ct then ct = 1 end
        ct = tonumber(ct)

        -- set minimum restart executor for a new page
        local minExec = minExec
        if not minExec then 
            local starts = {1, 101, 201}                        --base off location of provided desired executor position
            for i = 1, #starts do
                if exec >= starts[i] then minExec = starts[i] end
            end
        end

        local addPage = true
        if not checkPass(minExec, ct) then addPage = false end
        
        local pageCurrent = tonumber(page)
        local execCurrent = tonumber(exec)
        local pass = false

        while pass == false do
            if checkPass(execCurrent, ct) then
                for i = 1, ct do
                    if _M.exec.getstatus(pageCurrent, execCurrent+i-1) == 'EMPTY' then
                        if i == ct then pass = true end
                    else
                        if checkNum(execCurrent+i) then
                            execCurrent = execCurrent + i
                            break
                        else
                            if addPage then
                                pageCurrent = pageCurrent + 1
                                execCurrent = minExec
                                break
                            else
                                return nil, error_msg
                            end
                        end
                    end
                end
            else
                if addPage then
                    pageCurrent = pageCurrent + 1
                    execCurrent = minExec
                else
                    return nil, error_msg
                end
            end
        end
        
        
        return {page = pageCurrent, exec = execCurrent, str = tostring(pageCurrent)..'.'..tostring(execCurrent)}
        
        -- ---- TEST ----
        -- local page = gma.textinput('Page?', 'PG NUM')
        -- local exec = gma.textinput('Exec?', 'EXEC NUM')
        -- local ct = gma.textinput('Total Execs?', 'NUMBER OF EXECS')
        -- local t = exec.advance(page, exec, ct)
        -- gma.gui.msgbox('RESULTS', t.str)

    end,
        
    getstatus = function(page, executor)
        -- returns 'OFF', 'ON', 'NON-SEQ', and 'EMPTY'
        local slotStatus = _M.get.handle('Executor '..page..'.'..executor); --determine if slot is empty
                    
        if slotStatus then                                --return value based on executor handle
            if _M.get.handle('Executor '..page..'.'..executor..' Cue') then
                local c = _M.get.class('Executor '..page..'.'..executor..' Cue');
                if c == "CMD_SEQUENCE" then
                    return 'OFF' --response for non-active executor
                elseif c == "CMD_CUE" then
                    return 'ON' --response for active executor
                end
            else
                return 'NON-SEQ' --response for non-sequence executors
            end
        else
            return 'EMPTY' --response for empty executor slots
        end
    end,
        
    propstr_assign = function(str)
        -- takes the List of executor properties spit out by MA
        -- returns a string to assign those same properties to another executor
        
        -- input format example:
        ---- [[PlaybackMaster=Pb None, Width=1, SwopProtect=off]]
        -- output format example
        ---- [[/PlaybackMaster="Pb None", /width=1 /SwopProtect=off]]
            
            
        local props = {}

        -- populate props{}
        local indices = {1, 1}
        while indices[2] < #str do
        indices = {str:find('%s[^=]+[=][^,]+', indices[2])}    -- look for a pair "property=value"
        if (not indices[1]) then break end                    -- terminate loop if no comma found (end of list)
        indices[1] = indices[1] + 1                            -- reset starting point for next search

        local t = str:sub(unpack(indices))                    -- extract substring
        local key = t:sub(t:find('[^=]+'))                    -- extract portion before '=' as the key (property)

        local indices2 = {t:find('[=][^=]+')}                    -- find portion following '='
        indices2[1] = indices2[1] + 1                            -- change starting index to start AFTER '='
        local value = t:sub(unpack(indices2))                    -- extract as value

        props[key] = value                                    -- add to props list
        end

        -- turn list into string used to assign to other execs
        local str_props = ''
        for k, v in pairs(props) do
            if v:find('%s') then v = '\"'..v..'\"' end            -- use quotes around value if there is a space in it
            str_props = str_props..[[ /]]..k..[[=]]..v            -- append to final string
        end

        return str_props
    end
    
}


-- network functions
_M.net = {                            
    getsessioninfo = function()
        local t = ST:new{
            type         = gma.network.gethosttype(),
            subtype         = gma.network.gethostsubtype(),
            primary_ip     = gma.network.getprimaryip(),
            secondary_ip = gma.network.getsecondaryip(),
            status          = gma.network.getstatus(),
            sessionnum   = gma.network.getsessionnumber(),
            sessionname  = gma.network.getsessionname(),
            slot         = gma.network.getslot(),
        }
        
        return t
    end,
    
    gethostdata = gma.network.gethostdata,
}

-- Legacy class access
_M.class.superTable = _M.class.SuperTable
_M.class.queue = _M.class.Queue
_M.class.macro = _M.class.Macro
_M.gui.superBar = _M.class.ProgressBar
_M.class.Layout = _M.lo.layout

-- early end, if no images needed
return _M
]==========]

local GDF = load(GDFstr)()


local class  = GDF.class
local lo     = GDF.lo
local gui    = GDF.gui
local dmx    = GDF.dmx
local env    = GDF.env
local data   = GDF.data
local tbl    = GDF.table
local xml    = GDF.xml
local csv    = GDF.csv
local lua    = GDF.lua
local get    = GDF.get
local set    = GDF.set
local pi     = GDF.poolitem
local plugin = GDF.plugin
local exec   = GDF.exec
local imgpack= GDF.img
local net    = GDF.net

---- Data Management ----
local self_table = {...}
data.GDpath{'internal'}


---- Local Shortcuts ----
local gma = gma
local ST = class.superTable
local print = gui.print
local text = gma.textinput






---- Local Functions ----
local function cmd(...)
    gma.cmd(string.format(...))
end

local function echo(...)
    gma.echo(string.format(...))
end

local function feedback(...)
    gma.feedback(string.format(...))
end

-- local function v_print(...)
--     if CONFIG.VERBOSE then
--         local str = string.format(...)
--         gma.echo(str)
--         gma.feedback(str)
--     end
-- end


---- Non-Local Shared Objects ----
local pBars = ST:new()
local cleanup_cmd = ST:new()
local DebugLog = class.DebugStream:new();
local install_log = ST:new{'INSTALL LOG:'};


---- Local Objects ----






---------------------------------------
------------ MAIN FUNCTION ------------
---------------------------------------
local PLUGIN_COMPLETE = false;
local function Main()
    if DEBUG_FILE_ENABLE then
        DebugLog:initialize(DEBUG_FILE);
        if CONFIG.VERBOSE then DebugLog.verbose = true; end;
    end
    
    if (not CONFIG.OFFSET_PAN) and (not CONFIG.OFFSET_TILT) then
        local m = class.MsgBox:new('You broke it.')
        m:append("Please enable one of the attributes in the")
        m:append("user-config settings.")
        m:append('')
        m:append('Pan and Tilt are both disabled currently.')
        m:confirm();

        local m = class.MsgBox:new('For real')
        m:append('Stop breaking things.')
        m:confirm();

        PLUGIN_COMPLETE = true;
        goto EOF
    end
    
    -- Container Objects --
    local Input = ST:new();

    local Data  = ST:new();

    local Fixtures = ST:new();
    Fixtures.fixt = ST:new();
    Fixtures.chan = ST:new();


    ---- Collect User Input ----
    Input.orig, _, esc = gui.input('Original preset number?', '1', {num=true})
    if esc then goto EOF; end;
    Input.corrected, _, esc = gui.input('Corrected preset number?', '1', {num=true})
    if esc then goto EOF; end;

    -- Verify that input numbers link to existent objects
    if (not get.verify('Preset 2.'..tostring(Input.orig))) then
        install_log:append('Requested position preset does not exist. Plugin terminated.');
        goto EOF;
    end

    DebugLog:writeLine('Inputs provided:')
    DebugLog:setIndent(1, true);
    DebugLog:writeLine('Original preset: %d', Input.orig)
    DebugLog:writeLine('Corrected preset: %d', Input.corrected)
    DebugLog:setIndent(-1, true);
    DebugLog:lineBreak();


    -- DATA STRUCTURE:
    -- Data{}
    --     .pan{}
    --         .fixt{}
    --             .orig      = f.fff
    --             .corrected = f.fff
    --         .chan{}
    --     .tilt{}
    --         .fixt{}
    --         .chan{}

        


    -- Collect Original Preset Data
    local keys = {'orig', 'corrected'}
    if CONFIG.OFFSET_PAN  then
        Data.pan  = ST:new{fixt = {}, chan = {}};
        DebugLog:writeLine('PAN OFFSETS ENABLED'); end;
    if CONFIG.OFFSET_TILT then
        Data.tilt = ST:new{fixt = {}, chan = {}};
        DebugLog:writeLine('TILT OFFSETS ENABLED'); end;
    DebugLog:lineBreak();

    local match_ct = 0;
    for _, key in ipairs(keys) do
        local script = get.script('Preset 2.'..Input[key])              -- export script for each preset
        DebugLog:writeLine('#SCRIPT %s: %d', key, #script)                         -- (debug info)

        for match in script:gmatch([[<PresetValue Value=.-<Channel .-</PresetValue>]]) do
            
            local attrib = match:match('attribute_name="(.-)"'):lower();
            if Data[attrib] then
                local t = {};
                local id_type = 'fixt'
                local pset_val = tonumber(match:match('PresetValue Value="([%d%.%-]+)"'));      -- capture preset value
                local id_num = match:match('fixture_id="([%d%.%-]+)"');                         -- look for FixID
                if (not id_num) then                                                          -- if not found, use ChanID
                    id_type = 'chan';
                    id_num = match:match('channel_id="([%d%.%-]+)"');
                end;
                if id_num then id_num = tonumber(id_num); end;                                -- convert to number value

                -- append if a value and an ID are present...
                if (pset_val and id_num) then
                    local L = Data[attrib][id_type]
                    if not L[id_num] then L[id_num] = {}; end;
                    L[id_num][key] = pset_val;                                      -- index in data structure by fixture or channel ID
                    match_ct = match_ct + 1;
                    DebugLog:writeLine('ADDING FIXTURE - id_type: %s   id_num: %d  %s value: %.3f', id_type, id_num, attrib, pset_val)
                elseif (not id_num) then
                    DebugLog:writeLine('NO FIXTURE OR CHANNEL ID NUMBER FOUND IN MATCH')
                    DebugLog:setIndent(1, true);
                    DebugLog:writeLine('MATCH CONTENTS:')
                    DebugLog:writeLine(match)
                    DebugLog:setIndent(-1, true);
                elseif (not pset_val) then
                    DebugLog:writeLine('NO PRESET VALUE EXTRACTED FROM MATCH')
                    DebugLog:setIndent(1, true);
                    DebugLog:writeLine('MATCH CONTENTS:')
                    DebugLog:writeLine(match)
                    DebugLog:setIndent(-1, true);
                end
            end
        end
    end


    -- Combine Common Data
    local fixture_ct = 0;
    pBars.offsets = class.ProgressBar:new('Adding + Assigning Offsets...')
    for a_name, attrib in pairs(Data) do                              -- iterating attributes in main Data structure
        for id_type, fixture in pairs(attrib) do                      -- iterating fixtures in attributes table
            for obj_id, data in pairs(fixture) do                     -- iterating value sets in fixture/channel
                if (data.orig and data.corrected) then                -- if information is present from both presets...
                    local obj_str = id_type..' '..obj_id
                    
                    data.offset_amount  = data.corrected - data.orig

                    local tstr = {chan='Channel', fixt='Fixture'}                       -- for reference in next line
                    local id = string.format('%s %d.1', id_type, tostring(obj_id))      -- string referencing sub-instance #1 of fixture
                    local valProp = a_name..'offset'                                    -- 'panoffset' / 'tiltoffset'
                    -- local invProp = a_name..'dmxinvert'                                 -- 'PanDMXInvert' / 'TiltDMXInvert'
        
                    data.current_offset = get.prop(id, valProp);                        -- assign current and final offsets to table 
                    local dir_mult = 1
                    -- if (get.prop(id, invProp):lower() == 'on') then dir_mult = -1; end; -- subtract offset if pan invert is enabled
                    data.final = data.current_offset + (dir_mult * data.offset_amount);              -- calculate final offset value
        
                    cmd('Assign %s /%s=%.3f', id, valProp, data.final)                     -- assign through command line

                    fixture_ct = fixture_ct + 1
                    pBars.offsets:set(1, true)                                          -- increment progress bar
                end
            end
        end
    end
    pBars.offsets:stop()



    local types = ST:new();
    for k, v in pairs(Data) do types:append(k); end;

    local m = class.MsgBox:new{title = 'PLUGIN COMPLETE'}
    
    m:append('Offset types applied: '..types:concat(' + '))
    m:append('Original Position preset: 2.'..Input.orig)
    m:append('Corrected Position preset: 2.'..Input.corrected)
    m:append('Offsets processed: '..fixture_ct)
    m:append('')
    m:append('See System Monitor for Install Log details')

    m:msgbox();     -- pop-up box
    m:print();      -- print to SysMon/CmdLine


    PLUGIN_COMPLETE = true;
    ::EOF::
end






------------------------------------------
------------ CLEANUP FUNCTION ------------
------------------------------------------
local function Cleanup()
    if (not PLUGIN_COMPLETE) then
        gma.gui.msgbox('PLUGIN FAILED', 'Plugin did not finish successfully.\nPlease see System Monitor for details.')
    end
    PLUGIN_COMPLETE = false
    
    for _, v in pairs(pBars) do
        v:stop()
    end
    
    for _, v in ipairs(cleanup_cmd) do
        gma.cmd(v)
    end

    if ((SAVE_DEBUGFILE_IF_SUCCESSFUL) or (not PLUGIN_COMPLETE)) then
        DebugLog:close();
    else
        DebugLog:delete();
    end


    -- Print debug log to Command Line Feedback and System Monitor
    for _, v in ipairs(install_log) do
        gma.echo(gui.tcol.cyan..v)
        gma.feedback(gui.tcol.cyan..v)
    end
    
    install_log = ST:new{'INSTALL LOG:'};
    pBars = ST:new()            -- reset tables
    cleanup_cmd = ST:new()
end



return Main, Cleanup