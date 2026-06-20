--*******************************************************************************************
-- This script tests the methods to store a preset. 
-- Preset 0.12-0.14 + 1.24+1.25 + 2.6
-- presettype.feature.attribute
-- 0 All
-- 1 Dimmer
-- 2 Position
-- 3 Gobo
-- 4 Color
-- 5 Beam
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "STORE";
    object_name      = "PRESET";
    pre              = 'ClearAll; delete Preset 0.12 thru 0.14 + 1.24 + 1.25 + 2.6 /nc';
    steps =
    {
        {  
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '  at 100';
            cmd  = 'store Preset 1.24 /ka /s /nc';
            post = 'label Preset 1.24 "STO_PRES_1"';
            cleanup='clearall';
            test = 1.24;  --comparison of presets
            gold = 1.124;
        },
        {
            cmd  = 'store Preset 1.25 /ka /s';
            post = 'label Preset 1.25 "STO_PRES_2"';
            cleanup='clearall';
            test = 1.25;
            gold = 1.125;
        },
        {
            cmd  = 'store Preset 2.6 /pf=false /s';
            post = 'label Preset 2.6 "STO_PRES_3"';
            cleanup='clearall';
            test = 2.6;
            gold = 2.106;
        },
        {
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' ; attribute "pan" at 40';
            cmd  = 'store Preset 0.13 /m /s';
            cleanup = '';
            test = 0.13;
            gold = 0.113;
        }
    };
};

RegisterTestScript(test);

--*******************************************************************************************
-- module entry point
--*******************************************************************************************

local function StartThisTest()
    StartSingleTestScript(test);
end

return StartThisTest;