--*******************************************************************************************
-- This script tests the methods to store a macro. 
-- Macro 6-7, DMXsnap 301
--*******************************************************************************************
local fixturecount= get_prop_fixturecount();

local test =
{
    method_name      = "STORE";
    object_name      = "MACRO";
    pre              = 'ClearAll; delete macro 6 thru 7 /nc; delete DMXsnapshot 301 /nc';
    steps =
    {
        {
            version_step = "3.1.0.0";
            pre  = '';
            cmd  = 'store macro 1.6; store macro 1.6.1; assign macro 1.6.1 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/2)..' at 25" /info="testing the comparison" /wait="Go"';
            post = 'label macro 1.6 "STO_MACR_1"';
            cleanup= 'off macro thru';
            test = 6; --comparison of macros
            gold = 106;
        },
        {
            version_step = "3.1.0.0";
            pre  = '';
            cmd  = 'store macro 1.7; store macro 1.7.1; assign macro 1.7.1 /cmd="fixture 1 thru 26 at 57" /info="store"; go macro 1.7';
            post = 'label macro 1.7 "STO_MACR_2"; label DMXsnapshot 301 "STO_MACR_2"';
            cleanup= 'off macro thru';
            test_dmx= true;
            test = 301;
            gold = 801;
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