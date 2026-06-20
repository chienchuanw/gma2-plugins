--*******************************************************************************************
-- This script tests to release a fixture 
-- Seq 172, Executor 40, DMXsnap 258
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "RELEASE";
    object_name      = "FIXTURE";
    pre              = 'ClearAll; Delete Sequence 172 /nc; delete DMXsnapshot 258 /nc; delete Executor 40 /nc';
   
    steps =
    {
        {
            pre  = 'Fixture 1 thru '.. fixturecount[2] ..' at 0 thru 100; Store sequence 172 cue 1 /nc; assign sequence 172 at Executor 40';
            cmd  = 'Release Fixture 1; Fixture 1 thru '.. fixturecount[2] ..' at 50; store sequence 172 cue 2; clearall; go executor 40';
            post = 'label sequence 172 "REL_FIX_1"; label executor 40 "REL_FIX_1"; label DMXsnapshot 258 "REL_FIX_1"';
            cleanup = '';
            test_dmx=true;
            test = 258;
            gold = 758;
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