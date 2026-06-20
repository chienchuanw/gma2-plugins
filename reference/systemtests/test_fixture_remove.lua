--*******************************************************************************************
-- This script tests to remove a fixture 
-- Seq 173, Executor 41, DMXsnap 259
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "REMOVE";
    object_name      = "FIXTURE";
    pre              = 'ClearAll; Delete Sequence 173 /nc; delete Executor 41 /nc; delete DMXsnapshot 259 /nc';
   
    steps =
    {
        {
            pre  = 'Fixture 1 thru '.. fixturecount[2] ..' at 0 thru 100; Store sequence 173 cue 1 /nc; assign sequence 173 at executor 41; Fixture 1 thru '.. fixturecount[2] ..' at 0 thru 90';
            cmd  = 'Remove Fixture 1; Store sequence 173 cue 2 /nc; clearall; go executor 41; go executor 41';
            post = 'label sequence 173 "REM_FIX_1"; label executor 41 "REM_FIX_1"; label DMXsnapshot 259 "REM_FIX_1"';
            cleanup = '';
            test_dmx= true;
            test = 259;
            gold = 759;
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