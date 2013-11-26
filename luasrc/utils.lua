local stringx = require 'pl.stringx'
local path = require 'pl.path'

--[[ Return true if x is an instance of the given class ]]
function dokx._is_a(x, className)
    return torch.typename(x) == className
end

--[[ Create a temporary directory and return its path ]]
function dokx._mkTemp()
    local file = io.popen("mktemp -d -t dokx_XXXXXX")
    local name = stringx.strip(file:read("*all"))
    file:close()
    return name
end

--[[ Read the whole of the given file's contents, and return it as a string.

Args:
 * `inputPath` - path to a file

Returns: string containing the contents of the file

--]]
function dokx._readFile(inputPath)
    if not path.isfile(inputPath) then
        error("Not a file: " .. tostring(inputPath))
    end
    dokx.logger:debug("Opening " .. tostring(inputPath))
    local inputFile = io.open(inputPath, "rb")
    if not inputFile then
        error("Could not open: " .. tostring(inputPath))
    end
    local content = inputFile:read("*all")
    inputFile:close()
    return content
end


--[[ Given the path to a directory, return the name of the last component ]]
function dokx._getLastDirName(dirPath)
    local split = tablex.filter(stringx.split(path.normpath(path.abspath(dirPath)), "/"), function(x) return x ~= '' end)
    local packageName = split[#split]
    if stringx.strip(packageName) == '' then
        error("malformed package name for " .. dirPath)
    end
    return packageName
end


--[[ Given a comment string, remove extraneous symbols and spacing ]]
function dokx._normalizeComment(text)
    text = stringx.strip(tostring(text))
    if stringx.startswith(text, "[[") then
        text = stringx.strip(text:sub(3))
    end
    if stringx.endswith(text, "]]") then
        text = stringx.strip(text:sub(1, -3))
    end
    local lines = stringx.splitlines(text)
    tablex.transform(function(line)
        if stringx.startswith(line, "--") then
            local chopIndex = 3
            if stringx.startswith(line, "-- ") then
                chopIndex = 4
            end
            return line:sub(chopIndex)
        end
        return line
    end, lines)
    text = stringx.join("\n", lines)

    -- Ensure we end with a new line
    if text[#text] ~= '\n' then
        text = text .. "\n"
    end
    return text
end

