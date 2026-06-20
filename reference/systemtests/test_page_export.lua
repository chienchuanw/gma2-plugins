--*******************************************************************************************
-- This script tests the method to export a page.
-- Page 95+96, Seq 188
--*******************************************************************************************

local test=
{
    method_name     = "EXPORT";
    object_name     = "PAGE";
    pre             = 'ClearAll; delete page 95 + 96 /nc; store page 95 + 96; page 95; ';
    steps =
    {
        {
            -- Export Page 95
            pre  = 'fixture 1 thru 5 at 42; store seq 188 /o; assign seq 188 at exec 95.1';
            cmd  = 'export page 95 "export-page.xml" /nc; go exec 95.1';
            post = 'label dmxsnap 400 "EXP_PAG_1"; label page 95 "EXP_PAG_1"; label exec 95.1 "EXP_PAG_1"; label seq 188 "EXP_PAG_1"';
            cleanup = 'off exec 95.1';
            test_dmx = true;
            test = 400;
            gold = 402;
        },
        {
            -- Import at Page 96
            pre  = 'page 96';
            cmd  = 'Import "export-page.xml" at page 96 /nc; go exec 96.1';
            post = 'label dmxsnap 401 "EXP_PAG_2"; label page 96 "EXP_PAG_2"; label exec 96.1 "EXP_PAG_2";';
            cleanup = 'off exec 96.1; page 1';
            test_dmx = true;
            test = 401;
            gold = 403;
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