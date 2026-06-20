--*******************************************************************************************
-- This script tests the store operation with sequences.  
-- Seq 36, DMXsnap 446
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "STORE";
    object_name      = "SEQUENCE";
    pre              = 'ClearAll; delete sequence 36 /nc, delete DMXsnapshot 446 ';
    steps =
    {
        {
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; at 80"';
            cmd  = 'store sequence 36 CUE 1 /nc; clearall; go sequence 36';
            post = 'label sequence 36 "SEQ_STO_1"; label DMXsnapshot 446 "SEQ_STO_1"';
            cleanup = '';
            test_dmx= true;
            test = 446;
            gold = 946;
        }
    }
};

RegisterTestScript(test);

--*******************************************************************************************
-- module entry point
--*******************************************************************************************

local function StartThisTest()
   StartSingleTestScript(test);
end

return StartThisTest;