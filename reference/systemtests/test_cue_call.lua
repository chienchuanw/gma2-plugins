--*******************************************************************************************
-- This script tests the methods to call a cue. 
-- for comparing cues an executor is needed
-- Seq 74, Exec 206 
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "CALL";
    object_name      = "CUE";
    pre              = 'ClearAll; delete executor 206 /nc; delete sequence 74 cue 1 thru cue 99 /nc '; --do not delete the golden cues 101..
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. ' at 50; store sequence 74 cue 1 /use=active /nc; store sequence 74 cue 101 /nc; assign sequence 74 at executor 206; select executor 206 ';
            cmd  = 'call sequence 74 cue 1; store sequence 74 cue 2 /nc;';
            post = 'label sequence 74 "CUE_CALL"; label executor 206 "CUE_CALL_1"; label sequence 74 cue 101 "golden cue list from here"';
            cleanup = '';
            test = 2;  --comparing cues
            gold = 101.1;
        },
        {
            pre  = 'fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. ' at 60; store sequence 74 cue 3 /use=active /nc'; 
            cmd  = 'call sequence 74 cue 3 /s; store sequence 74 cue 4 /nc';
            cleanup = '';
            test = 4;  --comparing cues
            gold = 102.1;
        },
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. ' at 25; attribute colorrgb1 at 50; attribute colorrgb2 at 75; store sequence 74 cue 5 /nc';
            cmd  = 'call sequence 74 cue 5 if presettype color; store sequence 74 cue 6 /nc';
            cleanup = '';
            test = 6;  --comparing cues
            gold = 103.1;
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