--*******************************************************************************************
-- This script test the options to delete a effect. 
-- Effect 24-28
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "DELETE";
    object_name      = "EFFECT";
    pre              = 'ClearAll; delete effect 24 thru 28 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. '; Presettype "Dimmer"; at Form "Cos"; at effectBPM 33; Store Effect 24 thru 26 /overwrite';
            cmd  = 'Delete Effect 24 /nc';
            cleanup= 'clearall; off effect thru';
            test = 24;
            gold = -1;
        },
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. '; Presettype "Dimmer"; at Form "Cos"; at effectBPM 33; Store Effect 27; go effect 27';
            cmd  = 'Delete Effect 27 /nc';
            cleanup = 'clearall; off effect thru ';
            test = 27;
            gold = -1;
        },
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. '; Presettype "Dimmer"; at Form "Cos"; at effectBPM 33; Store Effect 28; go effect 28; Label effect 28 "Fredwarda"';
            cmd  = 'Delete Effect "Fredwarda" /nc';
            cleanup = 'off effect thru; clearall';
            test = 28;
            gold = -1;
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