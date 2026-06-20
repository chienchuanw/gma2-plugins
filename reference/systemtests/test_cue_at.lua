--*******************************************************************************************
-- This script tests the methods to go at a cue. 
-- Seq 73, DMXsnap 51, 52
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "AT";
    object_name      = "CUE";
    pre              = 'ClearAll; delete sequence 73 /nc; delete DMXsnapshot 51 + 52 /nc';
    steps=
    {
        {
            pre  = 'fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. ' at 50; store sequence 73 cue 1 /use=active /nc; fixture ' .. math.floor(fixturecount[2]/2)+1 .. ' thru ' .. fixturecount[2] .. ' at 25; store sequence 73 cue 2 /nc';
            cmd  = 'fixture 1 thru ' .. fixturecount[2] .. ' at sequence 73 cue 2; store sequence 73 cue 3 /nc; clearall; goto sequence 73 cue 3';
            post = 'label sequence 73 "CUE_AT_1"; label sequence 73 cue 1 "CUE_AT_1"; label sequence 73 cue 2 "CUE_AT_2"; label sequence 73 cue 3 "CUE_AT_3"; label DMXsnapshot 51 "CUE_AT_1"';
            cleanup = '';
            test_dmx = true;
            test = 51;
            gold = 551;
        },
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. ' at 25; attribute colorrgb1 at 50; attribute colorrgb2 at 75; store sequence 73 cue 4 /overwrite';
            cmd  = 'fixture 1 thru ' .. fixturecount[2] .. ' at sequence 73 cue 4 if presettype COLOR; store sequence 73 cue 5 /nc; clearall; goto sequence 73 cue 5';
            post = 'label sequence 73 cue 4 "CUE_AT_4"; label sequence 73 cue 5 "CUE_AT_5"; label DMXsnapshot 52 "CUE_AT_1"';
            cleanup = '';
            test_dmx = true; 
            test = 52;
            gold = 552;
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