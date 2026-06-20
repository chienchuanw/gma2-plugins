--*******************************************************************************************
-- This Plugin tests the call function for worlds. 
-- World 10, DmxSnap 485
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name         = "CALL";
    object_name         = "WORLD";
    pre                 = 'ClearAll; world 1; delete world 10 /nc; delete DmxSnapshot 485 /nc';
    exit_cmd            = 'world 1';
   --version_script      = '3.10.53.0';
   
    steps =
    {
        {
            pre         = 'Fixture 1 thru ' .. fixturecount[1] .. '; store world 10 /nc';
            cmd         = 'Call world 10; Fixture thru at 100';
            post        = 'label world 10 "CALL_WOR_1"; label DmxSnapshot 485 "CALL_WOR_1"';
            cleanup     = 'world 1';
            test_dmx    = true;
            test        = 485;
            gold        = 985;
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