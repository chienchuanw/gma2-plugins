--*******************************************************************************************
-- This script tests the methods to 'learn' a specialmaster. 
-- 
--*******************************************************************************************

local test =
{
    method_name      = "LEARN";
    object_name      = "SPECIALMASTER";
    pre              = 'ClearAll';

    steps =
    {
        {
            smoketest = true;
            pre  = '';
            cmd  = '';
            cmd_func  = function() local i = 0; for i=0,4 do gma.cmd('Learn sm 4.1'); gma.sleep(1); end end;   --simulates the users triggering
            post = '';
            cleanup	 = 'rate1 sm 4.1';
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