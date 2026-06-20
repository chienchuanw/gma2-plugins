--*******************************************************************************************
-- This script tests the method assign to a userprofile.
-- UserProfile 2, World 26
--*******************************************************************************************

local test =
{
    method_name      = "ASSIGN";
    object_name      = "USERPROFILE";
    pre              = 'ClearAll; delete userprofile thru; delete world 26';
    steps =
    {
        {
            -- assign userprofile 2 at world 3
            smoketest = true;
            pre  = 'store userprofile 2; fixture thru; store world 26; clearall';
            cmd  = 'assign userprofile 2 at world 26';
            post = 'label userprofile 2 "ASS_USR_1"; label world 26 "ASS_USR_1"';
            cleanup = '';
        },
        {
            -- assign userprofile 2 at user X
            smoketest = true;
            pre  = 'store user "ASS_USR_2";';
            cmd  = 'assign userprofile 2 at user "ASS_USR_2"';
            post = 'label userprofile 2 "ASS_USR_2"; label world 26 "ASS_USR_2"';
            cleanup = 'delete user "ASS_USR_2"';
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