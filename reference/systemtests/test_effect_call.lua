--*******************************************************************************************
-- This script tests the methods to call a effect 
-- Effect 32, DmxSnap 101
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "CALL";
    object_name      = "EFFECT";
    pre              = 'ClearAll; delete effect 32 /nc; delete DmxSnapshot 101 /nc';
    steps =
    {
        {
            pre  = 'Fixture 1 thru; Presettype "Dimmer"; at form "PWM"; at effectBPM 100; store Effect 32; clearall';
            cmd  = 'Call Effect 32';
            post = 'label effect 32 "CALL_EFF_1"; label DmxSnapshot 101 "CAL_EFF_1"';
            cleanup = 'off effect thru; clearall; cd /; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru';
            test_dmx = true;
            test = 101;
            gold = 601;
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