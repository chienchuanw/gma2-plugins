--*******************************************************************************************
-- This script tests the update operation with sequences for cues.  
-- Seq 37
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "UPDATE";
    object_name      = "SEQUENCE";
    pre              = 'ClearAll; delete sequence 37 /nc';
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. ' at 100; store sequence 37 Cue 1; Fixture 1 thru ' .. fixturecount[2] .. ' at 50';
            cmd  = 'Update sequence 37 Cue 1 /nc';
            post = 'label sequence 37 "SEQ_UPD_1"';
            cleanup = '';
            test = 37;
            gold = 337; 
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