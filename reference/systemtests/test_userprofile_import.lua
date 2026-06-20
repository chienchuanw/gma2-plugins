--*******************************************************************************************
-- This script tests the method import to a userprofile.
-- UserProfile 2
--*******************************************************************************************

local test =
{
    method_name      = "IMPORT";
    object_name      = "USERPROFILE";
    pre              = 'ClearAll; delete userprofile thru';
    steps =
    {
        {
            -- import userprofile 2 (auto generated)
            smoketest = true;
            pre  = '';
            cmd  = 'import "import-userprofile.xml" at userprofile 2 /nc';
            post = 'label userprofile 2 "IMP_USR_1"';
            cleanup = '';
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