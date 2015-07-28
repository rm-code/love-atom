-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local APOSTROPHE = '\''
local COLON      =  ':'
local LINE_BREAK = '\n'
local TAB        = '  '

local PREFIX = APOSTROPHE .. 'prefix' .. APOSTROPHE .. COLON .. ' ';
local BODY   = APOSTROPHE .. 'body' .. APOSTROPHE .. COLON .. '   ';
local PARAM  = '${%d:%s (%s)}';

local OUTPUT_FILE = 'love-snippets.cson';

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Generates the arguments string for a function.
-- Each argument will use the format ${index:name (type)}. This will be used by
-- Atom to automatically generate arguments when the snippet-code is generated
-- in the user's file.
-- The user can then replace each of the pre-generated arguments with a specific
-- value and jump to the next argument in line by pressing TAB.
--
local function generateArguments(arguments)
    local params = '';
    if arguments then
        for i, args in ipairs(arguments) do
            params = params .. string.format(PARAM, i, args.name, args.type);

            -- Add a separator unless we are dealing with the last argument of the function.
            if i ~= #arguments then
                params = params .. ', ';
            end
        end
    end
    return params;
end

---
-- The main function which generates the snippet file used in the atom package.
-- It will create a new .cson file (OUTPUT_FILE) and automatically fill it with
-- the snippet-code needed by Atom.
--
local function createPlugin()
    print('Generating LOVE snippets ... ');

    local file = io.open(OUTPUT_FILE, 'w');
    assert(file, "ERROR: Can't write file: " .. OUTPUT_FILE);

    -- Load the LÖVE api files.
    local api = require('love_api');

    -- Create file header.
    file:write('# Make the love snippets available for all .lua files.\n\r')
    file:write(APOSTROPHE .. '.source.lua' .. APOSTROPHE .. COLON .. LINE_BREAK);

    -- Generate snippets for LÖVE callback functions.
    print('  Writing callbacks');
    for i, f in ipairs(api.callbacks) do
        -- Create snippet header.
        file:write(TAB .. APOSTROPHE .. 'love.' .. f.name .. APOSTROPHE .. COLON .. LINE_BREAK);

        -- Prefix.
        file:write(TAB .. TAB .. PREFIX .. APOSTROPHE .. 'love' .. f.name .. APOSTROPHE .. LINE_BREAK);

        -- Body.
        file:write(TAB .. TAB .. BODY);
        -- Generate the arguments.
        -- Here we generate a list of parameters in the format ${index:name (type)}.
        local arguments = generateArguments(f.variants[1].arguments);
        file:write(APOSTROPHE .. 'love.' .. string.format(f.name .. '(%s)', arguments) .. APOSTROPHE .. LINE_BREAK)
    end

    -- Generate the snippets for all LÖVE modules.
    print(TAB .. 'Writing Modules');
    for _, module in ipairs(api.modules) do
        print(TAB .. TAB .. module.name);
        file:write('\n# ' .. string.upper(module.name) .. LINE_BREAK);

        for _, f in ipairs(module.functions) do
            local realName = 'love.' .. module.name .. '.' .. f.name;
            local identifier = 'love' .. module.name .. f.name;

            -- Create snippet header.
            file:write(TAB .. APOSTROPHE .. realName .. APOSTROPHE .. COLON .. LINE_BREAK);

            -- Prefix.
            file:write(TAB .. TAB .. PREFIX .. APOSTROPHE .. identifier .. APOSTROPHE .. LINE_BREAK);

            -- Body.
            -- This is where we generate the actual code which will later be created in the user's file.
            file:write(TAB .. TAB .. BODY);

            -- Generate the arguments.
            -- Here we generate a list of parameters in the format ${index:name (type)}.
            local arguments = generateArguments(f.variants[1].arguments);
            file:write(APOSTROPHE .. string.format(realName .. '(%s)', arguments) .. APOSTROPHE .. LINE_BREAK);
        end
    end

    file:close();

    print('DONE!');
end

createPlugin();
