--*******************************************************************************************
-- This script tests the possibilities of the load command to Executors. 
-- Exec 69, Seq 169, DmxSnap 138
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "LOAD";
    object_name      = "EXECUTOR";
	pre              = 'ClearAll; delete executor 69 /nc; delete sequence 169 /nc; delete DmxSnapshot 138 /nc';
    steps =
    {
		{
			pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 0 thru 95; store sequence 169 cue 1 + 3 + 5 /nc; assign sequence 169 at executor 69; fixture 1 thru ' .. fixturecount[2] .. ' at 0 thru 95; store sequence 169 cue 2+4 /nc; clearall';
            cmd  = 'load executor 69 cue 2; go executor 69';
			post = 'label executor 69 "LOD_EXEC"; label sequence 169 "LOD_EXEC_1";  label DmxSnapshot 138 "LOD_EXEC_1"';
            cleanup = '';
            test_dmx = true;
            test = 138;
            gold = 638;
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