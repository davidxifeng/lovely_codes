--- June 29, 2015
-- Author: davidxifeng@gmail.com
-- a small script to decompile lua byte code files unzip from game.zip in
-- quick cocos project in apk

local input_file_list = {
    'app.util.test',
    'main',
}

-- get file path
-- a.lua
-- b/c.lua
local function dropFileName(full_path)
    local vs = string.reverse(full_path)
    local path = string.gsub(vs, '^[^%.]*%.', '')
    path = string.reverse(path)
    if string.find(path, '%.') then
        return true, string.gsub(path, '%.', '/')
    else
        return false, path
    end
end

local function process(v)
    local jar_cmd = 'java -jar /Users/quinn/bin/unluac_2015_03_10b.jar '
    local need_mkdir, output_dir = dropFileName(v)
    local output_file = string.gsub(v, '%.', '/') .. '.lua'
    if need_mkdir then
        print('mkdir: ' .. output_dir)
        local md = 'mkdir -p ' .. output_dir .. ' ; '
        print('output: ', output_file)
        os.execute(md .. jar_cmd .. v .. ' > ' .. output_file)
    else
        print('output: ', output_file)
        os.execute(jar_cmd .. v .. ' > ' .. output_file)
    end
    os.execute('rm ' .. v)
end

for _, v in ipairs(input_file_list) do
    process(v)
end
