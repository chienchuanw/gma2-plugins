--*******************************************************************************************
-- This script tests the method insert to a macro. 
-- Inserting a macro into a position of the macro pool.
-- Inserting a line between other lines of a macro is not possible.
-- Macro a.b.c is page a. macro b. line c
-- Macro 21+22
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "INSERT";
    object_name      = "MACRO";
    pre              = 'ClearAll; delete Macro 1.21 + 1.22 /nc';
    steps =
    {
        {
            pre='store macro 1.21; store macro 1.21.1; assign macro 1.21.1 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/2)..' at 80"; assign macro 1.21.1 /info="Macro prepared for test Insert Macro"';
            cmd  = 'Insert Macro 1.21 at macro 1.22';
            post = 'label macro 21 "INS_MAC_1"; label macro 22 "INS_MAC_2"';
            cleanup= 'off macro thru';
            test = 22; --comparing macros
            gold = 122;
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