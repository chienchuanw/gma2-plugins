--*******************************************************************************************
-- This script test the assign method to a sequence. 
-- Seq 1, Exec 16, DMXsnap 448
--*******************************************************************************************
local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ASSIGN";
    object_name      = "SEQUENCE";
    pre              = 'ClearAll; delete sequence 1 /nc; delete executor 16 /nc; delete DMXsnapshot 448 /nc';
    steps =
    {
        {
            --assigning a sequence to an executor
            pre  = 'fixture ' ..math.floor(fixturecount[2]/2)..' thru ' ..fixturecount[2]..' at 67; store sequence 1 cue 1';
            cmd  = 'assign sequence 1 at executor 16; clearall; go executor 16';
            post = 'label sequence 1 "SEQ_ASS_1"; label executor 16 "SEQ_ASS_1"; label DMXsnapshot 448 "SEQ_ASS_1"';
            cleanup = '';
            test_dmx = true;
            test = 448;
            gold = 948;
        },
        {
            --assigning attributes to a sequence
            cmd  = 'assign sequence "SEQ_ASS_1" /track=on /cuezeroextract=on /releasefirststep=off';
            cleanup = '';
            test = 1;
            gold = 301;
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