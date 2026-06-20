--*******************************************************************************************
-- This Plugin tests the export fuction for macros. 
-- Macro a.b.c is page a. macro b. line c
-- Macro 43
--*******************************************************************************************

local test =
{
    method_name      = "EDIT";
    object_name      = "MACRO";
    pre              = 'clearall; delete macro 43 /nc';
    steps =
    {
        {
            smoketest = true;
            pre  = 'store macro 1.43;';
            cmd  = 'edit macro 43'; -- open edit window
            post = 'label Macro 43 "EDI_MAC_1"';
            cleanup= 'edit macro 43'; -- close edit window
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