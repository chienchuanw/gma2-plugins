--*******************************************************************************************
-- This script tests the method select the fixtures of a sequence 
-- Seq 34,35
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "SELFIX";
    object_name      = "SEQUENCE";
    pre              = 'ClearAll; delete sequence 34 + 35 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. ' at 45; store sequence 34 cue 1; clearall';
            cmd  = 'selfix sequence 34; at 34.5; store sequence 35 cue 1';
            post = 'label sequence 34 "SELF_SEQ_1"; label sequence 35 "SELF_SEQ_2"';
            cleanup = '';
            test = {34,35};
            gold = {334,335};
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