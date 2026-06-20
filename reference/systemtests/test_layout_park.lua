--*******************************************************************************************
-- This script tests the operation park for layouts. 
-- Layout 25, DMXsnap 293
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "PARK";
    object_name      = "LAYOUT";
    pre              = 'ClearAll; delete layout 25 /nc; delete DMXsnapshot 293 /nc ';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' ..math.floor(fixturecount[2]/4).. '; store layout 25';
            cmd  = 'park layout 25; selfix layout 25 at 68';  
            post = ' label layout 25 "PA_LAY_1"';
            cleanup = 'unpark layout 25';
            test_dmx= true;
            test = 293;
            gold = 793;
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