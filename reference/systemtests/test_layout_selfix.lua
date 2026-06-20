--*******************************************************************************************
-- This script tests the selfix operation for layouts. 
-- Layout 35, DMXsnap 295
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "SELFIX";
    object_name      = "LAYOUT";
    pre              = 'ClearAll; delete layout 35 /nc; delete sequence 355 /nc; delete DMXsnapshot 295 /nc'; 

    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. math.floor(fixturecount[2]/2)..'; store layout 35; ClearAll';
            cmd  = 'selfix layout 35; at 80';  
            post = 'label layout 35 "SFX_LAY_1"; label DMXsnapshot 295 "SFX_LAY_1" ';
            cleanup = '';
            test_dmx= true;
            test = 295;
            gold = 795;
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