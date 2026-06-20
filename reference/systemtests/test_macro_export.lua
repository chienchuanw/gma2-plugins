--*******************************************************************************************
-- This Plugin tests the export fuction for macros. 
-- Macro a.b.c is page a. macro b. line c
-- Macro 100,101
--*******************************************************************************************
local fixturecount =get_prop_fixturecount();

local test =
{
    method_name      = "EXPORT";
    object_name      = "MACRO";
    pre              = 'clearall; delete macro 100 /nc';
    steps =
    {
        {  smoketest = true;
            pre  = 'store macro 1.100; store macro 1.100.1; assign macro 1.100.1 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/3)..' at 80"; assign macro 1.100.1 /info="Macro prepared for test export"; assign macro 1.100.2 /cmd="clearall"';
            cmd  = 'Export Macro 100 "export-macro.xml" /nc';
            post = 'label Macro 100 "EXP_MAC_1"';
            cleanup= 'off macro thru';
        },
        {
            cmd  = 'Import "export-macro.xml" at Macro 101 /nc';
            post = 'label macro 101 "EXP_MAC_2"';
            cleanup= 'off macro thru';
            --test = 101;
            --gold = 102;
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