--*******************************************************************************************
-- This script shows up the methods to store a world. 
-- World 4-7, DMXsnap 481-484
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "STORE";
    object_name      = "WORLD";
    pre              = 'ClearAll; world 1; delete world 4 thru 7 /nc; delete DMXsnapshot 481 thru 484 /nc';
    exit_cmd         = 'world 1';
    steps =
    {
        {
            pre  = 'channel 1 thru ' .. fixturecount[1] .. '; fixture 1 thru ' .. math.floor(fixturecount[2]/2) ;
            cmd  = 'store world 4 ; clearall; world 4 at 50 ';
            post = 'label world 4 "STORE_WOR_1"; label DMXsnapshot 481 "STORE_WOR_1"';
            cleanup= 'clearall; off page thru; world 1';
            test_dmx =true;
            test = 481;
            gold = 981;
        },
        {   -- by merging
            pre  = 'channel 1 thru ' .. (fixturecount[1]*2) .. '; fixture 1 thru ' .. math.floor(fixturecount[2]/4) ..'; store world 5; clearall; world 1; fixture 1 thru ' .. math.floor(fixturecount[2]/3) ..'; attribute colorrgb1 at 30' ;
            cmd  = 'store world 5 /merge; clearall; world 5 full';
            post = 'label world 5 "STORE_WOR_1"; label DMXsnapshot 482 "STORE_WOR_2"';
            cleanup= 'clearall; off page thru; world 1';
            test_dmx =true;
            test = 482;
            gold = 982;
        },
        {   --by removing
            pre  = 'fixture ' .. math.floor(fixturecount[2]/2)+1 .. ' thru ' .. fixturecount[2]..'; store world 6; clearall; world 1; fixture ' .. math.floor(fixturecount[2]/2)+1 ;
            cmd  = 'store world 6 /remove; clearall; world 6; world 6 full'; --removes these fixture from world 6
            post ='label world 6 "STORE_WOR_3"; label DMXsnapshot 483 "STORE_WOR_3"';
            cleanup ='clearall; off page thru; world 1';
            test_dmx= true;
            test = 483;
            gold = 983;
        },
        {   --by overwriting
            pre  = 'fixture ' .. math.floor(fixturecount[2]/2)+1 .. ' thru ' .. fixturecount[2]..' store world 7; clearall; world 1; fixture ' .. math.floor(fixturecount[2]/2)+1 ;
            cmd  = 'store world 7 /overwrite; clearall; world 7 full';
            post = 'label world 7 "STORE_WOR_3"; label DMXsnapshot 484 "STORE_WOR_3"';
            cleanup	 = 'world 1';
            test_dmx= true;
            test = 484;
            gold = 984;
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