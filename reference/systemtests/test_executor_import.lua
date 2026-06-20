--*******************************************************************************************
-- This script tests the method import to an executor 
-- Exec 27 + 28
--*******************************************************************************************

local test =
{
    method_name      = "IMPORT";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete executor 27 + 28 /nc';
    steps=
    {
        {
            smoketest = true;
            pre  = 'assign specialmaster 2.1 at executor 27; Assign Toggle ExecButton1 1.27; Assign ToZero ExecButton2 1.27; Assign ToFull ExecButton3 1.27';
            cmd  = 'import "import-executor.xml" at executor 28';
            post = 'label executor 27 "IMP_EXEC_1"; executor 28 "IMP_EXEC_2"';
            cleanup = '';
            test = 27;
            gold = 28;
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