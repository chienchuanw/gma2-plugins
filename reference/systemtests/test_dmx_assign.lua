--*******************************************************************************************
-- This script tests the method to assign (patch) a fixture to a dmx-value.
-- The dmx tester has highest priority. Make sure to reset!!
-- set on destructive table
-- DmxSnap 78+79
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ASSIGN";
    object_name      = "DMX";
    pre              = 'ClearAll; delete DmxSnapshot 78 + 79 /nc';
    version_script   = '3.2.53.0';
    yield = true;
   
    steps =
    {
        {  destructivetest= true;
            cmd  = 'Channel 1 thru ' .. fixturecount[1] .. ' at 100; Channel 1; channel delete /nc';
            test = nil;
            gold = nil;
        },
        {
            cmd  = 'assign DMX 1.1 at channel 1 /nc; Channel 1 at 100';
            post = 'label DmxSnapshot 78 "ASS_DMX_1"';
            test_dmx = true;
            test = 78;
            gold = 578;
        },
        {
            cmd  = 'Fixture 1 thru ' .. fixturecount[2] .. ' at 100; Fixture 1; Fixture delete /nc';
            test = nil;
            gold = nil;
        },
        {
            cmd  = 'assign DMX 1.' .. fixturecount[1]+1 .. ' at Fixture 1 /nc; Fixture 1 at 100';
            post = 'label DmxSnapshot 79 "ASS_DMX_2"';
            cleanup = '';
            test_dmx = true;
            test = 79;
            gold = 579;
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