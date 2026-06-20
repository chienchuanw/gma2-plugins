--*******************************************************************************************
-- This script tests the method export to a userprofile.
-- UserProfile 2
--*******************************************************************************************

local test =
{
    method_name      = "EXPORT";
    object_name      = "USERPROFILE";
    pre              = 'ClearAll; delete userprofile thru';
    steps =
    {
        {
            -- export userprofile 2
            smoketest = true;
            pre  = 'store userprofile 2; assign userprofile 2 /info="export userprofile lua"';
            cmd  = 'export userprofile 2 "export-userprofile.xml" /nc';
            post = 'label userprofile 2 "EXP_USR_1"';
            cleanup = 'delete userprofile 2';
        },
        {
            -- import userprofile 2
            smoketest = true;
            pre  = '';
            cmd  = 'import "export-userprofile.xml" at userprofile 2';
            post = '';
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