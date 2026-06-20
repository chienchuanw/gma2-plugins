--*******************************************************************************************
-- This script tests the method at to a feature.
--Sequ 111, Exec 203, DmxSnap 211
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "AT";
    object_name      = "FEATURE";
    pre              = 'ClearAll; delete sequence 111 /nc; delete executor 203 /nc; delete DmxSnapshot 211 /nc';
    steps =
    {
        {
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 80'; --must have feature gobo1, otherwise nothing happens
            cmd  = 'feature gobo1 at gobo1; store sequence 111 cue 1; assign sequence 111 at executor 203; clearall; go executor 203';
            post = 'label sequence 111 "AT_FEA_1"; label executor 203 "AT_FEA_2"; label DmxSnapshot 211 "AT_FEA_1" ';
            cleanup = '';
            test_dmx = true;
            test = 211;
            gold = 711;
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