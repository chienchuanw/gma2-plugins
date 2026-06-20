--*******************************************************************************************
-- This Plugin tests the export fuction for plugins. Make shure, that the commands not hit
-- the testmatrix at all!
-- plugin tests start at plugin 500
-- golden plugins start at 700
-- Plugin 500-512
--*******************************************************************************************

local test =
{
    method_name      = "EXPORT";
    object_name      = "PLUGIN";
    version_script   = "3.1.144.0";
    pre              = 'Clearall; delete plugin 500 thru 512 /nc';
    steps =
    {
        {  --step without verification
            pre  = 'store plugin 500; select plugin 500';
            cmd  = 'Export Plugin 500 "export-plugin" /nc';  --exports this plugin into folder plugins
            post = 'label Plugin 500 "EXP_PLUG_1"';
            cleanup = '';
        },
        {  --import is essential to verify the exported plugin
            cmd  = 'Import "export-plugin.xml" at Plugin 501';
            post = 'label Plugin 501 "EXP_PLUG_2"';
            cleanup = '';
            test = {500,501}; --comparison of plugins
            gold = {701,701};
        },
        {  --testing the export of many plugins, step without verification
            pre  = 'store plugin 502 thru 507; select plugin 502 thru 507';
            cmd  = 'Export Plugin 502 thru 507 "export-many-plugins" /nc';  --exports this plugin into folder plugins
            post = 'label Plugin 502 thru 507 "EXP_PLUG_1"';
            cleanup = '';
        },
        {  --import is essential to verify the exported plugins
            cmd  = 'Import "export-many-plugins.xml" at Plugin 508 thru 512 /nc'; --one plugin is imported into many positions of the plugin pool
            post = 'label Plugin 508 thru 512 "EXP_PLUG_2"';
            cleanup = 'cd /; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru';
            test = {508,509,510,511,512}; --comparison of plugins
            gold = {708,709,710,711,712};
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