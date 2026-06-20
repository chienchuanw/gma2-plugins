--*******************************************************************************************
-- This script tests the operation on for layouts. 
-- Layout 20, Sequence 193, Exec 93; DMXsnap 292
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ON";
    object_name      = "LAYOUT";
    pre              = 'ClearAll; delete layout 20 /nc; delete sequence 193 /nc; delete executor 93 /nc; delete DMXsnapshot 292 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' ..math.floor(fixturecount[2]/2).. '; store sequence 193 cue 1; store layout 20';
            cmd  = 'on layout 20 at 70'; 
            post = 'label layout 20 "ON_LAY_1"; label sequence 193 "ON_LAY_1"';
            cleanup = '';
            test_dmx = true;
            test = 292;
            gold = 792;
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