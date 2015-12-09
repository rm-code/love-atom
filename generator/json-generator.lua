-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local APOSTROPHE =  '"'
local COLON      =  ':'
local COMMA      =  ','
local LINE_BREAK = '\n'
local TAB        = '  '

local PREFIX = APOSTROPHE .. 'prefix' .. APOSTROPHE .. COLON .. ' ';
local BODY   = APOSTROPHE .. 'body' .. APOSTROPHE .. COLON .. '   ';
local PARAM  = '${%d:%s (%s)}';

local OUTPUT_FILE = 'love-completions.json';

local WIKI_URL = 'https://love2d.org/wiki/';

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

local function generateArguments(arguments)
    local params = '';
    local index = 0;

    if arguments then
        for i, args in ipairs(arguments) do
            params = params .. string.format(PARAM, i, args.name, args.type);

            -- Add a separator unless we are dealing with the last argument of the function.
            if i ~= #arguments then
                params = params .. ', ';
            end
        end
        index = #arguments;
    end

    return params, index;
end

local function cleanUpString(str)
    return str:gsub('\n\n', ' '):gsub('\"', '\\"');
end

local function createJSON()
    print('Generating LOVE snippets ... ');

    local file = io.open(OUTPUT_FILE, 'w');
    assert(file, "ERROR: Can't write file: " .. OUTPUT_FILE);

    -- Load the LÖVE api files.
    local api = require('love_api');

    -- Create file header.
    file:write('[' .. LINE_BREAK);

    for i, f in ipairs(api.callbacks) do
        file:write(TAB .. '{' .. LINE_BREAK)

        -- The displayText will be shown in the autocomplete menu.
        file:write(TAB .. TAB .. '"displayText": "love.' .. f.name .. APOSTROPHE .. COMMA .. LINE_BREAK);

        -- The type field determines which symbol to display in the autocomplete menu.
        file:write(TAB .. TAB .. '"type": "function"' .. COMMA .. LINE_BREAK);

        -- The description field will cause the suggestion menu to display the function's description.
        file:write(TAB .. TAB .. '"description": ' .. APOSTROPHE .. cleanUpString(f.description) .. APOSTROPHE .. COMMA .. LINE_BREAK);

        --
        file:write(TAB .. TAB .. '"descriptionMoreURL": ' .. APOSTROPHE .. WIKI_URL .. 'love.' .. f.name .. APOSTROPHE .. COMMA .. LINE_BREAK);

        -- The snippet will determine what the prefix will be replaced with.
        file:write(TAB .. TAB .. '"snippet": ');
        local arguments, index = generateArguments(f.variants[1].arguments);
        file:write(APOSTROPHE .. 'love.' .. string.format(f.name .. '(%s)', arguments) .. APOSTROPHE .. LINE_BREAK);

        local closing = i ~= #api.callbacks and '},' or '}';
        file:write(TAB .. closing .. LINE_BREAK);
    end

    file:write(']');
    file:close();

    print('DONE!');
end

createJSON();
