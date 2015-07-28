local APOSTROPHE = '\''
local COLON      =  ':'
local LINE_BREAK = '\n'
local TAB        = '  '

local PREFIX = APOSTROPHE .. 'prefix' .. APOSTROPHE .. COLON .. ' ';
local BODY   = APOSTROPHE .. 'body' .. APOSTROPHE .. COLON .. '   ';
local PARAM  = '${%d:%s (%s)}';

local OUTPUT_FILE = 'love-snippets.cson';

local function createPlugin()
    print('Generating LOVE snippets ... ');

    local file = io.open(OUTPUT_FILE, 'w');

    -- Load the LÖVE api files.
    local api = require('love_api');

    -- Create file header.
    file:write('# Make the love snippets available for all .lua files.\n\r')
    file:write(APOSTROPHE .. '.source.lua' .. APOSTROPHE .. COLON .. LINE_BREAK);

    -- Generate snippets for LÖVE callback functions.
    for i, f in ipairs(api.callbacks) do
        -- Create snippet header.
        file:write(TAB .. APOSTROPHE .. 'love.' .. f.name .. APOSTROPHE .. COLON .. LINE_BREAK);

        -- Prefix.
        file:write(TAB .. TAB .. PREFIX .. APOSTROPHE .. 'love' .. f.name .. APOSTROPHE .. LINE_BREAK);

        -- Body.
        file:write(TAB .. TAB .. BODY);
        -- Generate the arguments.
        -- Here we generate a list of parameters in the format ${index:name (type)}.
        local arguments = f.variants[1].arguments; -- Only use the first variant.
        local params = '';
        if arguments then
            for i, args in ipairs(arguments) do
                -- Generate a parameter in the format ${index:name (type)}. This will be
                -- used by atom to automatically mark parameters and allows the user to
                -- insert his custom parameters and switch to the next one by pressing TAB.
                params = params .. string.format(PARAM, i, args.name, args.type);

                -- Add a separator unless we are dealing with the last argument of the function.
                if i ~= #arguments then
                    params = params .. ', ';
                end
            end
        end
        file:write(APOSTROPHE .. 'love.' .. string.format(f.name .. '(%s)', params) .. APOSTROPHE .. LINE_BREAK)
    end

    -- Generate the snippets for all LÖVE modules.
    for _, module in ipairs(api.modules) do
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
            local arguments = f.variants[1].arguments; -- Only use the first variant.
            local params = '';
            if arguments then
                for i, args in ipairs(arguments) do
                    -- Generate a parameter in the format ${index:name (type)}. This will be
                    -- used by atom to automatically mark parameters and allows the user to
                    -- insert his custom parameters and switch to the next one by pressing TAB.
                    params = params .. string.format(PARAM, i, args.name, args.type);

                    -- Add a separator unless we are dealing with the last argument of the function.
                    if i ~= #arguments then
                        params = params .. ', ';
                    end
                end
            end

            -- Write the function body to the snippet file.
            file:write(APOSTROPHE .. string.format(realName .. '(%s)', params) .. APOSTROPHE .. LINE_BREAK);
        end
    end

    file:close();

    print('DONE!');
end

createPlugin();
