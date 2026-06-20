--*******************************************************************************************
-- This Plugin tests the import fuction for plugins. Make shure, that the commands not hit
-- the testmatrix at all!
-- Plugin 513, 515-520
-- Plugin 514 is reserved for generated plugin in generate_import_files.lua
--*******************************************************************************************

local test =
{
    method_name      = "IMPORT";
    object_name      = "PLUGIN";
    version_script   = "3.1.144.0";
    pre              = 'Clearall; delete plugin 513 /nc' ;
    steps =
    {
        {
            cmd  = 'Import "import-plugin.xml" at Plugin 513';
            post = 'label plugin 513 "IMP_PLUG_1"';
            cleanup = '';
            test = 513;   --comparison of plugins
            gold = 713;
        },
        {  --import many plugins, one plugin is imported into many positions of the plugin pool
            cmd  = 'Import "import-plugin.xml" at Plugin 515 thru 520 /overwrite /nc';
            post = 'label plugin 515 thru 520 "IMP_PLUG_M"';    
            cleanup = '';
            test = {515,516,517,518,519,520};   --comparison of plugins
            gold = {715,716,717,718,719,720};
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