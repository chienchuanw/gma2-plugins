--*******************************************************************************************
-- This script tests the method store to a userprofile.
-- UserProfile 2
--*******************************************************************************************

local test =
{
    method_name      = "STORE";
    object_name      = "USERPROFILE";
    pre              = 'ClearAll; delete userprofile thru';
    steps =
    {
        {
            smoketest = true; -- golden sample test not possible?
            pre  = '';
            cmd  = 'store userprofile 2';
            post = '';
            cleanup= 'label userprofile 2 "STO_USE_1"';
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