-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local APOSTROPHE =  '"'
local COMMA      =  ','
local LINE_BREAK = '\n'
local TAB        = '  '

local PARAM  = '${%d:%s (%s)}';

local OUTPUT_FILE = 'love-completions.json';

local WIKI_URL = 'https://love2d.org/wiki/';

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

local function generateArguments( arguments )
    local params = '';
    local index = 0;

    if arguments then
        for i, args in ipairs( arguments ) do
            params = params .. string.format( PARAM, i, args.name, args.type );

            -- Add a separator unless we are dealing with the last argument of the function.
            if i ~= #arguments then
                params = params .. ', ';
            end
        end
        index = #arguments;
    end

    return params, index;
end

local function cleanUpString( str )
    return str:gsub( '\n\n', ' ' ):gsub( '\"', '\\"' ):gsub( '\0', '' );
end

local function buildCallbackCompletion( f )
    local arguments, _ = generateArguments( f.variants[1].arguments );
    return {
        TAB .. '{' .. LINE_BREAK,
        TAB .. TAB .. '"displayText": "love.' .. f.name .. APOSTROPHE .. COMMA .. LINE_BREAK,
        TAB .. TAB .. '"type": "function"' .. COMMA .. LINE_BREAK,
        TAB .. TAB .. '"description": ' .. APOSTROPHE .. cleanUpString( f.description ) .. APOSTROPHE .. COMMA .. LINE_BREAK,
        TAB .. TAB .. '"descriptionMoreURL": ' .. APOSTROPHE .. WIKI_URL .. 'love.' .. f.name .. APOSTROPHE .. COMMA .. LINE_BREAK,
        TAB .. TAB .. '"snippet": ',
        APOSTROPHE .. 'love.' .. string.format( f.name .. '(%s)', arguments ) .. APOSTROPHE .. LINE_BREAK,
        TAB .. '},' .. LINE_BREAK
    };
end

local function buildModuleFunctionCompletion( f, module, closing )
    local arguments = generateArguments( f.variants[1].arguments );
    return {
        TAB .. '{' .. LINE_BREAK,
        TAB .. TAB .. '"displayText": "love.' .. module.name .. '.' .. f.name .. APOSTROPHE .. COMMA .. LINE_BREAK,
        TAB .. TAB .. '"type": "function"' .. COMMA .. LINE_BREAK,
        TAB .. TAB .. '"description": ' .. APOSTROPHE .. cleanUpString( f.description ) .. APOSTROPHE .. COMMA .. LINE_BREAK,
        TAB .. TAB .. '"descriptionMoreURL": ' .. APOSTROPHE .. WIKI_URL .. string.format( 'love.%s.%s', module.name, f.name ) .. APOSTROPHE .. COMMA .. LINE_BREAK,
        TAB .. TAB .. '"snippet": ',
        APOSTROPHE .. string.format( 'love.%s.%s(%s)', module.name, f.name, arguments ) .. APOSTROPHE .. LINE_BREAK,
        TAB .. (  closing and '}' or '},'  ) .. LINE_BREAK
    };
end

local function buildTypeFunctionCompletion( f, type, closing )
    local arguments = generateArguments( f.variants[1].arguments );
    return {
        TAB .. '{' .. LINE_BREAK,
        TAB .. TAB .. '"displayText": "' .. type.name .. ':' .. f.name .. APOSTROPHE .. COMMA .. LINE_BREAK,
        TAB .. TAB .. '"type": "function"' .. COMMA .. LINE_BREAK,
        TAB .. TAB .. '"description": ' .. APOSTROPHE .. cleanUpString( f.description ) .. APOSTROPHE .. COMMA .. LINE_BREAK,
        TAB .. TAB .. '"descriptionMoreURL": ' .. APOSTROPHE .. WIKI_URL .. string.format( '%s:%s', type.name, f.name ) .. APOSTROPHE .. COMMA .. LINE_BREAK,
        TAB .. TAB .. '"snippet": ',
        -- TODO: Wait for fix of https://github.com/atom/autocomplete-plus/issues/635
        -- APOSTROPHE .. string.format( '${%d:%s}:%s(%s)', index, type.name, f.name, arguments ) .. APOSTROPHE .. LINE_BREAK,
        APOSTROPHE .. string.format( '%s:%s(%s)', type.name, f.name, arguments ) .. APOSTROPHE .. LINE_BREAK,
        TAB .. (  closing and '}' or '},'  ) .. LINE_BREAK
    };
end

local function createJSON()
    print( 'Generating LOVE snippets ... ' );

    local file = io.open( OUTPUT_FILE, 'w' );
    assert( file, "ERROR: Can't write file: " .. OUTPUT_FILE );

    -- Load the LÖVE api files.
    local api = require( 'api.love_api' );

    -- Create file header.
    file:write( '[' .. LINE_BREAK );

    -- Create completions for LÖVE callbacks.
    print( TAB .. 'Writing callbacks' );
    for _, f in ipairs( api.callbacks ) do
        local str = buildCallbackCompletion( f );
        for i = 1, #str do
            file:write( str[i] );
        end
    end

    -- Generate the snippets for all LÖVE modules.
    print( TAB .. 'Writing modules' );
    for i, module in ipairs( api.modules ) do
        print( TAB .. TAB .. '- ' .. module.name );

        if module.types then
            for _, type in ipairs( module.types ) do
                print( TAB .. TAB .. TAB .. '-> ' .. type.name );

                for _, f in ipairs( type.functions ) do
                    local str = buildTypeFunctionCompletion( f, type );
                    for l = 1, #str do
                        file:write( str[l] );
                    end
                end
            end
        end

        for j, f in ipairs( module.functions ) do
            local str = buildModuleFunctionCompletion( f, module, ( i == #api.modules and j == #module.functions )  );
            for k = 1, #str do
                file:write( str[k] );
            end
        end
    end

    file:write( ']' );
    file:close();

    print( 'DONE!' );
end

createJSON();
