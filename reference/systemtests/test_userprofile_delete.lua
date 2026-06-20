--*******************************************************************************************
-- This script tests the method delete to a userprofile.
-- UserProfile 2
--*******************************************************************************************

local test =
{
    method_name      = "DELETE";
    object_name      = "USERPROFILE";
    pre              = 'ClearAll; delete userprofile thru';
    steps =
    {
        {
            pre  = 'store userprofile 2';
            cmd  = 'delete userprofile 2';
            post = '';
            cleanup= '';
            test = 2;
            gold = -1;
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