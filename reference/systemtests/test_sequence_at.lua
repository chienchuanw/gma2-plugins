--*******************************************************************************************
-- This script tests the method at to a sequence 
-- Seq 2, 3, DmxSnap 449
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "AT";
    object_name      = "SEQUENCE";
    pre              = 'ClearAll; delete sequence 2+3 /nc; delete DmxSnapshot 449 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {  -- setting the values of sequence 3 equal to sequence 2
            pre  = 'Fixture 1 at 100; store sequence 2 cue 1 /nc; Fixture 1 at 74; store sequence 3 cue 1 /nc';
            cmd  = 'sequence 2 at sequence 3';
            post = 'label sequence 2 "AT_SEQ_1"; label DmxSnapshot 447 "AT_SEQ_1"';
            cleanup = ''; 
            test_dmx = true;
            test = 449;
            gold = 949;
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