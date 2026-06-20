--*******************************************************************************************
-- This script tests the methods to move a DmxUniverse 
-- set to destructive
-- DmxSnap 92
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "MOVE";
    object_name      = "DMXUNIVERSE";
    pre              = 'ClearAll; delete DmxSnapshot 92 /nc';
    version_script   = '3.2.53.0';
    yield = true;
   
    steps =
    {
        {
            pre  = 'Fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 100';
            cmd  = 'Move DMXUniverse 1 at 3';
            post = 'label DmxSnapshot 92 "MOV_DMXU"';
            cleanup = 'Move DMXUniverse 3 at 1;clearall; cd /; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru';
            test_dmx = true;
            test = 92;
            gold = 592;
            destructivetest= true;
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