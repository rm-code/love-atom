local json = require 'dkjson'

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local OUTPUT_FILE = 'love-completions.json'
local WIKI_URL = 'https://love2d.org/wiki/'

local LOVE_MODULE_STRING = 'love.'

-- JSON Output control
local DEBUG = false
local KEY_ORDER = {
    'luaVersion',
    'packagePath',
    'global',
    'namedTypes',
    'type',
    'description',
    'fields',
    'args',
    'returnTypes',
    'link'
}

local NOARGS = {}

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Generates a sequence containing subtables of all the arguments
--
local function createArguments( args, isMethod )
    local arguments = {}

    -- Include a "self" argument for methods, since autocomplete-lua and Lua itself
    -- omits the first argument of methods preceeded by the : operator
    if isMethod then
        arguments[#arguments + 1] = {}
        arguments[#arguments].name = 'self'
    end

    for _, v in ipairs( args or NOARGS ) do
        arguments[#arguments + 1] = {}
        arguments[#arguments].name = v.name

        -- Use [foo] notation as display name for optional arguments.
        if v.default then
            arguments[#arguments].displayName = string.format( '[%s]', v.name )
        end
    end
    return arguments
end

local function getType( type )
    if type == 'string'
    or type == 'number'
    or type == 'table'
    or type == 'boolean'
    or type == 'function' then
        return { type = type }
    end
    return { type = 'ref', name = type }
end

local function createReturnTypes( returns )
    local returnTypes = {}
    for i, v in ipairs( returns ) do
        returnTypes[i] = getType( v.type )
    end
    return returnTypes
end

-- TODO handle functions with neither args nor return variables.
local function createVariant( vdef, isMethod )
    local variant = {}

    variant.description = vdef.description
    variant.args = createArguments( vdef.arguments, isMethod )

    return variant
end

local function createFunction( f, parent, moduleString, isMethod )
    local name = f.name
    parent[name] = {}
    parent[name].type = 'function'
    parent[name].link = string.format( "%s%s%s", WIKI_URL, moduleString, name )

    -- NOTE Currently atom-autocomplete-lua doesn't support return types which
    --      have been defined inside of variants. So for now we only use the
    --      return types of the first variant.
    -- @see https://github.com/dapetcu21/atom-autocomplete-lua/issues/15
    if f.variants[1].returns then
        parent[name].returnTypes = createReturnTypes( f.variants[1].returns )
    end

    -- Create normal function if there is just one variant.
    if #f.variants == 1 then
        local v = createVariant( f.variants[1], isMethod )
        parent[name].description = f.description
        parent[name].args = v.args
        return
    end

    -- Generate multiple variants.
    parent[name].variants = {}
    for i, v in ipairs( f.variants ) do
        local variant = createVariant( v, isMethod )

        -- Use default description if there is no specific variant description.
        if not variant.description then
            variant.description = f.description
        end

        parent[name].variants[i] = variant
    end
end

local function createLoveFunctions( functions, parent )
    for _, f in pairs( functions ) do
        createFunction( f, parent, LOVE_MODULE_STRING )
    end
end

local function createLoveModuleFunctions( modules, parent )
    for _, m in pairs( modules ) do
        local name = m.name
        parent[name] = {}
        parent[name].type = 'table'

        parent[name].description = m.description
        parent[name].link = string.format( "%s%s%s", WIKI_URL, LOVE_MODULE_STRING, name )

        parent[name].fields = {}

        for _, f in pairs( m.functions ) do
            createFunction( f, parent[name].fields, string.format( '%s%s.', LOVE_MODULE_STRING, name ))
        end
    end
end

local function createGlobals( api, global )
    global.type = 'table'
    global.fields = {}
    global.fields.love = {}
    global.fields.love.type = 'table'
    global.fields.love.fields = {}

    createLoveFunctions( api.functions, global.fields.love.fields )
    createLoveFunctions( api.callbacks, global.fields.love.fields )
    createLoveModuleFunctions( api.modules, global.fields.love.fields )
end

-- ------------------------------------------------
-- Creation methods for named types
-- ------------------------------------------------


local function collectTypes( api )
    local types = {}

    for _, type in pairs( api.types ) do
        assert( not types[type.name] )
        types[type.name] = type
    end

    for _, module in pairs( api.modules ) do
        if module.types then -- Not all modules define types.
            for _, type in pairs( module.types ) do
                assert( not types[type.name] )
                types[type.name] = type
            end
        end
    end

    return types
end

local function createTypes( types, namedTypes )
    for name, type in pairs( types ) do
        print( '  ' .. name )
        namedTypes[name] = {}
        namedTypes[name].type = 'table'
        namedTypes[name].fields = {}

        if type.functions then
            for _, f in pairs( type.functions ) do
                createFunction( f, namedTypes[name].fields, name .. ':', true )
            end
        end

        if type.supertypes then
            namedTypes[name].metatable = {}
            namedTypes[name].metatable.type = 'table'
            namedTypes[name].metatable.fields = {
                __index = {
                    type = 'ref',
                    name = type.parenttype
                }
            }
        end
    end
end

local function createJSON()
    print( 'Generating LOVE snippets ... ' )

    -- Load the LÖVE api files.
    local api = require( 'api.love_api' )
    assert( api, 'No api file found!' )
    print( 'Found API file for LÖVE version ' .. api.version )

    -- Create main table.
    local output = {
        global = {},
        namedTypes = {},
        packagePath = "./?.lua,./?/init.lua"
    }

    print( 'Generating functions ...' )
    createGlobals( api, output.global )

    print( 'Generating types ...' )
    local types = collectTypes( api )
    createTypes( types, output.namedTypes )

    local jsonString = json.encode( output, { indent = DEBUG, keyorder = KEY_ORDER })
    local file = io.open( OUTPUT_FILE, 'w' )
    assert( file, "ERROR: Can't write file: " .. OUTPUT_FILE )
    file:write( jsonString )

    print( 'DONE!' )
end

createJSON()
