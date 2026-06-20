--*******************************************************************************************
-- This script tests the method to assign options to an agenda object. 
-- Agenda Testing is only working if there is a successive growing of agenda numbers.
-- If single tests are executed, consider the possibility of errors.
-- THIS IS A SMOKE TEST! No cpoying and no comparison.
-- Agenda 3 - 7
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ASSIGN";
    object_name      = "AGENDA";
    pre              = 'ClearAll; cd /; cd "Agendas"; delete 3 + 4 + 5 + 6 + 7 /nc';
    version_script   = '3.2.55.2';
    exit_cmd         = 'cd /';
   
    steps =
    {
        {
            smoketest = true;
            pre  = 'store 3';
            cmd  = 'assign 3 /start=Absolute /time=00h01m02s /duration=5 /repeat=yearly';
        },
        {
            smoketest = true;
            pre  = 'store 4';
            cmd  = 'assign 4 /start=dawn /time=01h01m02s /duration=1 /repeat=weekly /CMD="fixture 1 thru '..fixturecount[2]..' at 36" /info="Agenda assign" /first=01/01/2017 /last=02/11/2024';
        },
        {
            smoketest = true;
            pre  = 'store 5';
            cmd  = 'assign 5 /start=sunrise /time=02h01m02s /duration=1 /repeat=monthly /CMD="fixture 1 thru '..fixturecount[2]..' at 50"';
        },
        {
            smoketest = true;
            pre  = 'store 6';
            cmd  = 'assign 6 /start=sunset /time=03h01m02s /duration=1 /repeat="weekly each year" /CMD="fixture 1 thru '..fixturecount[2]..' at 60"';
        },
        {
            smoketest = true;
            pre  = 'store 7';
            cmd  = 'assign 7 /start=dusk /time=04h01m02s /duration=1 /repeat="monthly each year"/CMD="fixture 1 thru '..fixturecount[2]..' at 75"';
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