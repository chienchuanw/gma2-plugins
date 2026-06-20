--*******************************************************************************************
-- This script tests the method off to a DmxUniverse for the GMA DMX Tester Output.
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "OFF";
    object_name      = "DMXUNIVERSE";
    pre              = 'ClearAll; delete DmxSnapshot 63 /nc';
    version_script   = '3.2.53.0';
    --test_type        = 'function';
   
    steps =
    {
        {
            pre  = 'Fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 100; On DmxUniverse 1';
            cmd  = 'Off DmxUniverse 1';
            --result = function() for i= 1, 512 do local h = gma.show.getobj.handle("DMX 1."..i); if(gma.show.property.get(h,7) == "true") then return false end end return true end;
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