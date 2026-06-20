--*******************************************************************************************
-- This script tests the method copy to a userprofile.
-- UserProfile 2+3
--*******************************************************************************************

local test =
{
    method_name      = "COPY";
    object_name      = "USERPROFILE";
    pre              = 'ClearAll; delete userprofile thru';
    steps =
    {
        {
            smoketest = true;
            pre  = 'store userprofile 2';
            cmd  = 'copy userprofile 2 at 3';
            post = 'label userprofile 2 + 3 "STO_USR_1"';
            cleanup= '';
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