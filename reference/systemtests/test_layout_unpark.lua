--*******************************************************************************************
-- This script tests the operation unpark for layouts. 
-- Layout 26, DMXsnap 296
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "UNPARK";
    object_name      = "LAYOUT";
    pre              = 'ClearAll; delete layout 26 /nc; delete DMXsnapshot 296 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' ..math.floor(fixturecount[2]/3).. '; store layout 26; park layout 26';
            cmd  = 'unpark layout 26; fixture 1 thru ' ..math.floor(fixturecount[2]/3).. ' at 30';
            post = 'label layout 26 "UNPA_LAY_1"; label DMXsnapshot 296 "UNPA_LAY_1"';
            cleanup = '';
            test_dmx= true;
            test = 296;
            gold = 796;
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