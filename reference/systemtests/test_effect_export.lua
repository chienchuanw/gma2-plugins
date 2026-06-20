--*******************************************************************************************
-- This Plugin tests the export fuction for effects. 
-- Effect 301,302
--*******************************************************************************************

local test =
{
    method_name      = "EXPORT";
    object_name      = "EFFECT";
    pre              = 'ClearAll; delete effect 301 + 302 /nc' ;
    steps =
    {
        {
            smoketest =true;
            pre  = 'store effect 301 /nc';
            cmd  = 'Export Effect 301 "export-effect.xml" /nc';  --into folder effects
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 301 "EXP_EFF_1"';
            cleanup = 'off effect thru; clearall; ';
        },
        {
            --Import is essentailessary to verify the export
            cmd  = 'Import "export-effect.xml" at Effect 302';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 302 "EXP_EFF_2"';
            cleanup = 'off effect thru';
            test = 302;
            gold = 402;
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