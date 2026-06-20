--*******************************************************************************************
-- This Plugin tests the import fuction for sequences. 
-- Seq 287
--*******************************************************************************************

local test =
{
    method_name      = "IMPORT";
    object_name      = "SEQUENCE";
    pre              = 'ClearAll; delete sequence 287 /nc';
    steps =
    {
        {
            smoketest = true;
            pre  = 'Channel 1 thru at 89; store sequence 287 /nc';
            cmd  = 'Import "import-sequence.xml" at sequence 287 /nc';
            post = 'label sequence 287 "SEQ_IMP_1"';
            cleanup = '';
            --test = 287;
            --gold = 288;
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