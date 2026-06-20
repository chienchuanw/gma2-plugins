--*******************************************************************************************
-- This script tests the method on to a DmxUniverse for the GMA DMX Tester Output.
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ON";
    object_name      = "DMXUNIVERSE";
    pre              = 'ClearAll; delete DmxSnapshot 63 /nc';
    version_script   = '3.2.53.0';
    --test_type        = 'function';
   
    steps =
    {
        {
            cmd  = 'On DmxUniverse 1';
            --result = function() for i= 1, 512 do local h = gma.show.getobj.handle("DMX 1."..i); if(gma.show.property.get(h,7) == "false") then return false end end return true end;
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