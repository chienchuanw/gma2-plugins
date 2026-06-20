--*******************************************************************************************
-- This script tests the method unpark to a fixture 
-- DmxSnap 255+256
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "UNPARK";
    object_name      = "FIXTURE";
    pre              = 'ClearAll; delete DmxSnapshot 255+256 /nc';
   
    steps =
    {
        {
            pre  = 'Park Fixture 1 thru ' ..fixturecount[2];
            cmd  = 'Unpark Fixture 1 thru ' ..math.floor(fixturecount[2]/2)..'; Fixture 1 Thru ' ..fixturecount[2]..'At 50';
            post = 'label DmxSnapshot 255 "UNPA_FIX_1"';
            cleanup = '';
            test_dmx = true;
            test = 255;
            gold = 755;
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