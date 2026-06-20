--*******************************************************************************************
-- This script tests the method to remove a sequence. 
-- Seq 33
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "REMOVE";
    object_name      = "SEQUENCE";
    pre              = 'ClearAll; delete sequence 33 /nc';
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. ' at 100; store sequence 33 cue 1 /nc';
            cmd  = 'remove sequence 33; store sequence 33 cue 2 /nc';
            post = 'label sequence 33 "REM_SEQ_1"';
            cleanup = '';
            test = 33;
            gold = 333;
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