--*******************************************************************************************
-- This script tests the method to copy an agenda object. 
-- Agenda Testing is only working if there is a successive growing of agenda numbers.
-- If single tests are executed, consider the possibility of errors.
-- THIS IS A SMOKE TEST! No cpoying and no comparison.
-- Agenda 8 + 9
--*******************************************************************************************
local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "COPY";
    object_name      = "AGENDA";
    pre              = 'ClearAll; cd /; cd "Agendas"; delete 8 + 9 /nc';
    version_script   = '3.2.55.2';
    exit_cmd         = 'cd /';
   
    steps =
    {
        {
            smoketest = true;
            pre  = 'store 8; assign 8 /start=Absolute /time=05h00m12s /duration=5 /repeat=yearly /CMD="fixture 1 thru '..fixturecount[2]..' at 80" /info="Agenda copy" /first=01/11/2017 /last=02/12/2024';
            cmd  = 'copy 8 at 9';
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