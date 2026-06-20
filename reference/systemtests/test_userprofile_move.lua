--*******************************************************************************************
-- This script tests the method move to a userprofile.
-- UserProfile 2-4
--*******************************************************************************************

local test =
{
    method_name      = "MOVE";
    object_name      = "USERPROFILE";
    pre              = 'ClearAll; delete userprofile thru';
    steps =
    {
        {
            -- move userprofile 2 at 3 (occupied)
            smoketest = true;
            pre  = 'store userprofile 2; store userprofile 3; assign userprofile 2 /info="nr. 2"; assign userprofile 3 /info="nr. 3"';
            cmd  = 'move userprofile 2 at 3'; -- nothing happens
            post = 'label userprofile 2 "STO_USR_1"; label userprofile 3 "STO_USR_1"';
        },
        {
            -- move userprofile 2 at 4 (available)
            smoketest = true;
            pre  = '';
            cmd  = 'move userprofile 2 at 4'; -- profiles are now switched
            post = 'label userprofile 2 "STO_USR_2"; label userprofile 3 "STO_USR_2"';
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