
local print = print
local tconcat = table.concat
local tinsert = table.insert
local srep = string.rep
local type = type
local pairs = pairs
local tostring = tostring
local next = next

local print_r = function (root)
    local s = ("--- %s ----"):format(tostring(root))
    print(s)
    local cache = {  [root] = "." }
    local function _dump(t,space,name)
        local temp = {}
        for k,v in pairs(t) do
            local key = tostring(k)
            if cache[v] then
                tinsert(temp,"+ " .. key .. " : {" .. cache[v].."}")
            elseif type(v) == "table" then
                local new_key = name .. "." .. key
                cache[v] = new_key
                tinsert(temp,"+ " .. key .. " : " .. _dump(v,space .. (next(t,k)
                     and "|" or " " ).. srep(" ",#key),new_key))
            else
                tinsert(temp,"+ " .. key .. " : [" .. tostring(v).."]")
            end
        end
        return tconcat(temp,"\n"..space)
    end
    print(_dump(root, "",""))
    print(("-"):rep(# s))
end


--print_r { 1, 2, 3, hello = 'world', {'I', 'Love', 'U'} }
