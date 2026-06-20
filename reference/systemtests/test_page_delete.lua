--*******************************************************************************************
-- This script tests the methods to delete a page. 
-- Page 3, Sequ 164
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test=
{
    method_name     = "DELETE";
    object_name     = "PAGE";
    pre             = 'ClearAll; delete page 3 /nc; page 3; delete seq 164 /nc';
    steps =
    {
        {
            -- Create exec 3.1 and delete page 3
            pre  = 'Channel 1 thru ' .. fixturecount[1] .. ' at Full; Store Seq 164; Assign Seq 164 at Exec 3.1; page 2'; -- go to page 2, because otherwise it would create instantly an empty page
            cmd  = 'Delete Page 3';
            cleanup = 'delete seq 164; page 1';
            test = 3;
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