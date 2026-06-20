--*******************************************************************************************
-- This script tests the method store for an executor.
-- Exec 11, DMXsnap 121
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "STORE";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete executor 11 /nc; delete DMXsnapshot 121 /nc';
    version_script   = '3.3.0.0';

    steps =
    {
        {
            pre  = 'fixture 1 thru '..math.floor(fixturecount[2]/4)..' at 67';
            cmd  = 'store executor 11 /nc; clearall; go executor 11';  --stores any available sequence, as long as the fist availbale sequence is below 300 ok
            post = 'label executor 11 "STO_EXEC_1"; label DMXsnapshot 121 "STO_EXEC_1"';
            cleanup = '';
            test_dmx= true;
            test = 121;
            gold = 621;
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