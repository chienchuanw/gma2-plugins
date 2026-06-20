--*******************************************************************************************
--  This script tests the move operation with sequences. 
-- Seq 25 - 28
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "MOVE";
    object_name      = "SEQUENCE";
    pre              = 'ClearAll; delete sequence 25 thru 28 /nc';
    steps =
    {
        {
            --moving to an available position
            pre= 'fixture 1 thru '..math.floor(fixturecount[1]/2)..' at 100; store sequence 25 cue 1 /nc; fixture 1 thru ' .. fixturecount[2] .. ' at 50; Store sequence 25 Cue 2 /nc ';
            cmd  = 'Move sequence 25 at sequence 26 /nc';
            post= 'label sequence 25 "SEQ_MOV_1"';
            cleanup = '';
            test = 26;
            gold = 326;
        },
        {
            --moving to an occupied position
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; presettype "Color" at 50; store sequence 27 cue 1 thru 4 /nc; presettype "Gobo" at 10; store sequence 28 cue 5';
            cmd  = 'Move sequence 27 at 28 /nc';
            post = 'label sequence 27 "SEQ_MOV_2"; label sequence 27 "SEQ_MOV_2"';
            cleanup = '';
            test = {27,28};
            gold = {327,328};  --swapped
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