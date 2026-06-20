--*******************************************************************************************
-- This script tests the method remove to a feature.
-- Sequ 114, DmxSnap 216
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "REMOVE";
    object_name      = "FEATURE";
    pre              = 'ClearAll; delete sequence 114 /nc; delete DmxSnapshot 216 /nc';
    steps =
    {
        {
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. math.floor((fixturecount[2]+fixturecount[3])/2) .. ' at 30; feature colorrgb at 45; store sequence 114 cue 1; ';
            cmd  = 'remove feature colorrgb; store sequence 114 cue 2; clearall; goto sequence 114 cue 2';
            post = 'label sequence 114 "REM_FEA_1"; label DmxSnapshot 216 "REM_FEA_1"';
            cleanup = '';
            test_dmx = true;
            test = 216;
            gold = 716;
        },
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