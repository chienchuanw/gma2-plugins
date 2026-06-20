--*******************************************************************************************
--
--*******************************************************************************************

local test =
{
    method_name     = "REPLACE";
    object_name     = "VALUE";
    gs_name         = "CUE";
    pre             = 'Delete Sequence 80 /nc; CHANNEL 1 THRU 5 AT 50';
    steps =
    {
        {
            cmd  = 'STORE SEQUENCE 80 CUE 1 /nc';
            test = 1;
            gold = 101.1;
        },
        {
            pre  = 'SEARCH CHANNEL 1 IF SEQUENCE 80 /nc';
            cmd  = 'REPLACE VALUE 50 WITH 100 IF SEARCHRESULT /nc';
            test = 1;
            gold = 101.2;
        },
        {
            pre  = 'SEARCH CHANNEL 3 IF SEQUENCE 80 /nc';
            cmd  = 'REPLACE VALUE 50 WITH 100 IF SEARCHRESULT /nc';
            test = 1;
            gold = 101.3;
        },
        {
            pre  = 'SEARCH CHANNEL 1+3 IF SEQUENCE 80 /nc';
            cmd  = 'REPLACE VALUE 100 WITH 50 IF SEARCHRESULT /nc';
            test = 1;
            gold = 101.1;
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
