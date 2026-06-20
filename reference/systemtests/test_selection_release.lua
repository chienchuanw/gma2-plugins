--*******************************************************************************************
-- This script tests the method to release a selection. 
-- Seq 174+175, DmxSnap 428, Exec 123
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "RELEASE";
    object_name      = "SELECTION";
    pre              = 'ClearAll;  delete sequence 174 + 175 /nc; delete DmxSnapshot 428 /nc; delete executor 123 /nc; ';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. ' at 100; store sequence 174 cue 1 /nc; assign sequence 174 executor 123; fixture 1 thru ' .. fixturecount[2] .. ' at 50; store sequence 175 cue 1 /nc; assign sequence 175 executor 65; select executor 65; Fixture 1 thru ' .. fixturecount[2];
            cmd  = 'release selection; store cue 2; clearall; go executor 123; goto cue 2';
            post = 'label DmxSnapshot 428 "REL_SELE_1"; label sequence 174 "REL_SELE_1"; label sequence 175 "REL_SELE_2"';
            cleanup = '';
            test_dmx = true;
            test = 428;
            gold = 728;
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