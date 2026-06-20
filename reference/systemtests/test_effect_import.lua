--*******************************************************************************************
-- This Plugin tests the export fuction for effects. 
-- Effect 303
--*******************************************************************************************

local test =
{
    method_name      = "IMPORT";
    object_name      = "EFFECT";
    pre              = 'ClearAll; delete effect 303 /nc';

    steps =
    {
        {
            smoketest = true;
            cmd  = 'Import "import-effect.xml" at Effect 303';  --from folder effects
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 303 "IMP_EFF_1"';
            cleanup = 'off effect thru';
            test = 303;
            gold = 403;
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