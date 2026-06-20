--*******************************************************************************************
-- This Plugin tests the export fuction for sequences. 
-- Seq 284,285
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "EXPORT";
    object_name      = "SEQUENCE";
    pre              = 'ClearAll; delete Sequence 284 /nc';
    steps =
    {
        {
            smoketest = true;
            pre  = 'Channel 1 thru at 65; store Sequence 284 cue 1 thru 20 + 30 /nc; Fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. ' a 0 thru 100; store Sequence 284 cue 21 thru 29 /nc';
            cmd  = 'Export Sequence 284 "export-sequence.xml" /nc';
            post = 'label Sequence 284 "SEQ_EXP_1"';
            cleanup='off page thru; off sequence thru ';
        },
        {
            cmd  = 'Import "export-sequence.xml" at Sequence 285 /nc';
            post = 'label Sequence 285 "SEQ_EXP_2"';
            cleanup = '';
            --test = 285;
            --gold = 286;
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