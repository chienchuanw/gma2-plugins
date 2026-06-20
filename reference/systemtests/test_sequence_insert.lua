--*******************************************************************************************
-- This script tests the method insert to a sequence 
-- Seq 20 - 24
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "INSERT";
    object_name      = "SEQUENCE";
    pre              = 'ClearAll; delete sequence 20 thru 24 /nc';

    steps =
    {
        {
            --inserting at an available position
            pre  = 'Channel 1 thru ' .. fixturecount[1] .. ' at 30; store sequence 20 cue 1';
            cmd  = 'Insert sequence 20 at sequence 21';
            post = 'label sequence 20 "INS_SEQ_1"; label sequence 21 "INS_SEQ_2"';
            cleanup = '';
            test = {20,21};
            gold = {-1,321};
        },
        {
            --inserting at an occupied position, means swapping
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. ' at 60; store sequence 22 cue 3; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 45; store sequence 23 cue 7 /nc';
            cmd  = 'Insert sequence 22 at 23';
            post = 'label sequence 22 "INS_SEQ_3"; label sequence 23 "INS_SEQ_4"';
            cleanup = '';
            test = {22,23};
            gold = {322,323};  --sequence 22 equls sequ 23
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