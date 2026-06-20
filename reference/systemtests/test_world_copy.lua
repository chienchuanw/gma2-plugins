--*******************************************************************************************
-- This script shows up the methods to copy a world. 
-- World 11-16, DmxSnap 486-488
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "COPY";
    object_name      = "WORLD";
    pre              = 'ClearAll; world 1; delete world 11 thru 16; delete DMXsnapshot 486 thru 488 /nc';
    exit_cmd	     = 'world 1';
    steps =
    {
        {   --copying at an avilable position
            pre  = 'fixture 1 thru '..math.floor(fixturecount[2]/3)..'; attribute colorrgb1 at 87; store world 11 /nc; clearall; world 1';
            cmd  = 'copy world 11 at 12; world 12 at full';
            post = 'label world 12 "WOR_CPY_1"; label DMXsnapshot 486 "WOR_CPY_2"';
            cleanup= 'clearall; off page thru; world 1';
            test_dmx= true;
            test = 486;
            gold = 986;
        },
        {   --copying at an occupied position by merging
            pre  = 'fixture 1 thru '..math.floor(fixturecount[2]/3)..'; attribute colorrgb1 at 60; store world 13 /nc; clearall; world 1; fixture 1 thru '..fixturecount[2]..'; attribute colorrgb1 at 60; store world 14 /nc; clearall; world 1';
            cmd  = 'copy world 13 at 14 /merge; world 14 at full';   --fixtures of world 13 and world 14 are now in world 14
            post = 'label world 14 "WOR_CPY_2"; label DMXsnapshot 487 "WOR_CPY_2"';
            cleanup= 'clearall; off page thru; world 1';
            test_dmx= true;
            test = 487;
            gold = 987;
        },
        {   --copying at an occupied position by overwriting
            pre  = 'fixture 1 thru '..math.floor(fixturecount[2]/3)..' at 60; store world 15 /nc; clearall; world 1; fixture 1 thru '..fixturecount[2]..'; store world 16 /nc; clearall; world 1';
            cmd  = 'copy world 15 at 16 /overwrite; world 16 at full';   --only fixtures of world 16 are now in world 16
            post = 'label world 16 "WOR_CPY_3"; label DMXsnapshot 488 "WOR_CPY_3"';
            cleanup	 = 'world 1';
            test_dmx= true;
            test = 488;
            gold = 988;
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