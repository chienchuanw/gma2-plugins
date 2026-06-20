--*******************************************************************************************
-- This script tests the methods to copy a sequence. 
-- Seq 6-9
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "COPY";
    object_name      = "SEQUENCE";
    pre              = 'ClearAll; delete sequence 6 thru 9 /nc';
    steps =
    {
        {  --comparing sequences        
            --copying to an available Position
            pre  ='fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. ' at 36; store sequence 6 cue 10 /nc';
            cmd  = 'Copy sequence 6 at 7 /nc';
            post = 'label sequence 6 "SEQ_COPY_1"; label sequence 7 "SEQ_COPY_2"';
            cleanup = '';
            test = {6,7};
            gold = {306,307};
        },
        {
            --copying to an occupied position
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; presettype "Position" at 33; store sequence 8 cue 10 /nc; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; presettype "Position" at 33; store sequence 9 cue 4c /nc';
            cmd  = 'Copy sequence 8 at sequence 9 /m';
            post = 'label sequence 8 "CPY_SEQ_3"; label sequence 7 "CPY_SEQ_4"';
            cleanup = '';
            test = {8,9};
            gold = {308,309};
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