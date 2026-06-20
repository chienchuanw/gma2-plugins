--*******************************************************************************************
-- This script tests the methods to delete a sequence 
-- Seq 10, 11, 12, DMXsnap 447
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "DELETE";
    object_name      = "SEQUENCE";
    pre              = 'ClearAll; delete sequence 10 thru 12 /nc; delete DMXsnapshot 447 /nc';
    steps =
    {
        {  --comparison with empty object
            pre= 'fixture 1 thru '..fixturecount[2]..' at 80; store sequence 10 cue 1 /nc';
            cmd  = 'Delete sequence 10 /nc';
            post= 'label sequence 10 "DEL_SEQ_1"';
            cleanup = '';
            test = 10;
            gold = -1;
        },
        {  --comparison with dmx
            pre  = 'fixture 1 thru '..fixturecount[2]..' at 80; store sequence 11 cue 1; go sequence 11';
            cmd  = 'Delete sequence 11 /nc';
            post= 'label sequence 11 "DEL_SEQ_1"; label dmxsnap 447 "DEL_SEQ_1"';
            cleanup = '';
            test_dmx= true;
            test = 447;
            gold = 947;
        },
        { --deleting by label, comparison with sequence
            pre ='fixture 1 thru '..fixturecount[2]..' at 80; store sequence 12 cue 1; label sequence 12 "DEL_SEQ_1"';
            cmd= 'delete sequence "DEL_SEQ_1"';
            post = 'label sequence 12 "DEL_SEQ_1"';
            cleanup = '';
            test = 12;
            gold= 312;
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