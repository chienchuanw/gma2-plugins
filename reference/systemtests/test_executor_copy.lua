--*******************************************************************************************
-- This script tests the possibilities of the copy command to Executors 
-- Exec 22-29, Seq 131, DmxSnap 127-129
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "COPY";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete sequence 131 /nc; delete executor 22 thru 30 /nc; delete DMXsnapshot 127 thru 129 /nc';
    steps =
    {
        {   --copying a single executor
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. ' at 10 thru 22; store sequence 131 cue 1; Assign sequence 131 at executor 22';
            cmd  = 'copy executor 22 at 23 /nc; clearall; go executor 23';
            post = 'label executor 22 + 23 "CPY_EXEC_1"; label sequence 131 "CPY_EXEC_1"; label DMXsnapshot 127 "CPY_EXEC_1"';
            cleanup = '';
            test_dmx= true;
            test = 127;
            gold = 627;
        },
        {   --copying a single executor to many executors
            cmd  = 'copy executor 22 at 24 thru 26 /nc; clearall; go executor 24 thru 26';
            post = 'label executor 24 thru 26 "CPY_EXEC_2"; label DMXsnapshot 128 "CPY_EXEC_1"';
            cleanup = '';
            test_dmx= true;
            test = 128;
            gold = 628;
        },
        {   --copying many executors to many executors
            cmd  = 'copy executor 22 thru 25 at 26 thru 29 /nc; clearall; go executor 26 thru 29';
            post = 'label executor 26 thru 29 "CPY_EXEC_3"; label DMXsnapshot 129 "CPY_EXEC_1"';
            cleanup = '';
            test_dmx= true;
            test = 129;
            gold = 629;
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