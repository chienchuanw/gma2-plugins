--*******************************************************************************************
-- This Plugin tests the export fuction for macros.
-- Macro 103
--*******************************************************************************************

local test =
{
    method_name      = "IMPORT";
    object_name      = "MACRO";
    pre              = 'Clearall; delete macro 103 /nc';

    steps =
    {
        {  smoketest = true;
            pre  = '';
            cmd  = 'Import "import-macro.xml" at macro 103 /nc';
            post = 'label macro 103 "IMP_MAC_1"';
            cleanup= 'off macro thru';
            --test = 103;
            --gold = 104;
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