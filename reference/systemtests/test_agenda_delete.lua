--*******************************************************************************************
-- This script tests the method to delete an agenda object. 
-- Agenda Testing is only working if there is a successive growing of agenda numbers.
-- If single tests are executed, consider the possibility of errors.
-- Deleting Agenda 1 should cause the movment of agenda 2 at the fist place, for example.
-- Agenda 9
--*******************************************************************************************
local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "DELETE";
    object_name      = "AGENDA";
    pre              = 'ClearAll; cd /; cd "Agendas"';
    version_script   = '3.2.55.2';
    exit_cmd         = 'cd /';
   
    steps =
    {
        {
            cmd  = 'delete agenda 9 /nc';
            cleanup = '';
            test = 9;
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