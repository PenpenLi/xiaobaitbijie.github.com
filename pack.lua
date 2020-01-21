#!/usr/bin/env lua

local lfs = require('lfs')
local colors = require('term.colors')
local json = require('rapidjson')
local cctea = require('cctea')
local ZipWriter = require('ZipWriter')
local semver = require('semver')
require('strong')


local function popenf(fmt, ...)
  local command = fmt:format(...)
  --print(colors.cyan(command))
  return io.popen(command)
end

local git = {}
function git.modified()
  os.execute('git update-index -q --refresh')
  local h = popenf('git diff-index --name-only HEAD --')
  local mods = {}
  for l in h:lines() do
    mods[#mods+1] = l
  end
  return mods
end

function git.diff(dirs, from, to)
  local h = popenf('git diff --name-only %s %s %s', from, to or 'HEAD', table.concat(dirs, ' '))
  local files = {}
  for line in h:lines() do
    files[#files+1] = line
  end
  table.sort(files)
  return files
end

function git.ls(dirs)
  local h = popenf('git ls-files -s -m --abbrev=32 %s', table.concat(dirs, ' '))
  local files = {}
  for line in h:lines() do
    -- 100644 705cedbeadf74d3cffdeb242421f4f628484cdf9 0	res/poker/card_clubs_8.png
    -- [<tag> ]<mode> <object> <stage> <file>
    local _, object, stage, file = line:match('(%d+) ([0-9a-f]+) (%d)\t(.+)$')
    assert(stage == '0')
    files[#files+1] = {file, object}
  end
  table.sort(files, function(a, b) return a[1] < b[1] end)
  return files
end

function git.head()
  local h = popenf('git rev-parse HEAD')
  return h:read('*l')
end

function git.add(file)
  os.execute('git add "'..file..'"')
end

function git.commit(message)
  os.execute('git commit -m "'..message..'"')
end

local function hasPrefixes(s, prefixes)
  for _, p in ipairs(prefixes) do
    if s:startsWith(p) then return true end
  end
  return false
end

local ignores = {
  ['res/v.build-in'] = true,
  ['res/index.build-in'] = true,
  ['src/devconf.lua'] = true,
}

local function die_if_uncommited(dirs)
  local mods = git.modified()
  if #mods == 0 then return end

  local m = {}
  for _, f in ipairs(mods) do
    if hasPrefixes(f, dirs) and not ignores[f] then
      m[#m+1] = f
    end
  end

  if #m == 0 then return end

  print(colors.bright(colors.yellow('The following files is not committed to git:')))
  for _, f in ipairs(m) do
    print('', colors.red(f))
  end
  os.exit(1)
end


local function load_config()
  local projconf = '.cocos-project.json'
  if not lfs.attributes(projconf, 'mode') then
    print(colors.bright(colors.yellow(projconf..' not found.')))
    os.exit(1)
  end
  local config = json.load(projconf)
  if not config.luaEncryptKey then
    print(colors.bright(colors.yellow('luaEncryptKey not set in '.. projconf)))
    os.exit(1)
  end
  if not config.luaEncryptSign then
    print(colors.bright(colors.yellow('luaEncryptSign not set in '.. projconf)))
    os.exit(1)
  end
  return {key=config.luaEncryptKey, sign=config.luaEncryptSign}
end

local function make_desc(filename, data)
  return {
    istext   = false,
    isfile   = true,
    isdir    = false,
    mtime    = lfs.attributes(filename, 'modification') or os.time(),
    platform = 'unix',
    exattrib = {
      ZipWriter.NIX_FILE_ATTR.IFREG,
      ZipWriter.NIX_FILE_ATTR.IRUSR,
      ZipWriter.NIX_FILE_ATTR.IWUSR,
      ZipWriter.NIX_FILE_ATTR.IRGRP,
      ZipWriter.DOS_FILE_ATTR.ARCH,
    },
    data = data
  }
end

local function make_copy_reader(filename)
  local f = assert(io.open(filename, 'rb'))
  local chunk_size = 1024
  return function()
    local chunk = f:read(chunk_size)
    if chunk then return chunk end
    f:close()
  end
end

local function make_string_reader(strs)
  return function()
    local r = strs[1]
    if r then table.remove(strs, 1) end
    return r
  end
end


local file = {}

function file.read(filename)
  assert(lfs.attributes(filename, 'mode'))
  local f = io.open(filename, 'rb')
  local content = f:read('*a')
  f:close()
  return content
end

function file.write(filename, content)
  assert(lfs.attributes(filename, 'mode') == nil)
  local f = io.open(filename, 'wb')
  f:write(content)
  f:close()
end

local rules = {}

function rules.default(src, hash)
  --print(hash..' <- '.. src .. '...')
  return hash, make_desc(src), make_copy_reader(src)
end

function rules.lua(src, hash, config)
  --print(hash..' <= '.. src .. '...')
  local content = file.read(src)
  content = cctea.encrypt(content, config.key)
  return hash, make_desc(src), make_string_reader({config.sign, content})
end

function rules.json(src, hash, config)
  return rules.lua(src,hash,config)
end

local function extname(path)
  return (path:match('%.([^%.]+)$')) or ''
end

local function pack(files, config, version)
  local zip = ZipWriter.new()
  local basePackage = ZipWriter.new()

  local zipname = ('publish/%s.zip'):format(version)
  local basename = ('publish/base%s.zip'):format(version)

  if lfs.attributes('publish', 'mode') == nil then lfs.mkdir('publish') end
  
  zip:open_stream(assert(io.open(zipname, 'wb')), true)
  basePackage:open_stream(assert(io.open(basename, 'wb')), true)

  print(colors.green(('packing %s...'):format(version)))

  local index = {}
  for _, f in ipairs(files) do
    local src, hash = unpack(f)
    hash = hash:gsub('(%x%x)(%x+)', '%1/%2')
    if not ignores[src] then
      local ext = extname(src)
      local compile = rules[ext] or rules.default

      zip:write(compile(src, hash, config))
      local baseSrc = src
      if ext == "lua" then 
        baseSrc = baseSrc .. 'c'
      end
      basePackage:write(compile(src, baseSrc, config))

      if ext == 'lua' then src = src .. 'c' end -- .lua to .luac
      local dsrc = src
      if src:sub(1,4) == 'res/' then
        dsrc = src:sub(5,#src)
      end

      index[#index+1] = hash..': '..dsrc..'\n'
    end
  end

  print(colors.green('adding meta files...'))

  index = table.concat(index)
  zip:write('index', make_desc('index', index))
  zip:write('v', make_desc('v', version))
  zip:write('rev', make_desc('rev', git.head()))
  zip:close()
  basePackage:close()

  print(colors.green(('saved: %s'):format(zipname)))
  return index
end

local function getVersion(version)
  local v = semver(io.open('res/v.build-in'):read('*l'))
  if version == 'major' then
    return tostring(v:nextMajor())
  elseif version == 'minor' then
    return tostring(v:nextMinor())
  elseif version == 'patch' then
    return tostring(v:nextPatch())
  else
    local newv = semver(version)
    if newv < v then
      print(colors.red(('excepted version > %s, got %s'):format(v, newv)))
      os.exit(1)
    end
    return newv
  end
end


local function saveBuildIn(v, index)
  local function save(filename, conent)
    local f = assert(io.open(filename, 'wb'))
    f:write(conent)
    f:close()
  end
  save('res/v.build-in', v)
  print(colors.green('updated: res/v.build-in'))
  save('res/index.build-in', index)
  print(colors.green('updated: res/index.build-in'))
  git.add('res/v.build-in')
  git.add('res/index.build-in')
  git.commit('Prepare '..v..' release')
end

local function getArgs(arg)
  local cli = require('cliargs')
  cli:set_name('pack.lua')
  cli:splat('version', 'version to tag this release', 'patch', 1)
  cli:flag('-d, --dry-run', 'packing without save new version to repo.', false)
  local args, err = cli:parse(arg)
  if err then
    print(err)
    os.exit(1)
  end
  return args
end


local function main(args)
  local v = getVersion(args.version)

  local dirs = {'src', 'res'}
  die_if_uncommited(dirs)
  local config = load_config()
  local files = git.ls(dirs)
  local index = pack(files, config, v)

  if not args.d then
    saveBuildIn(v, index)
  end
  --print(colors.yellow('TODO: automaticlly tag with git.'))
end

main(getArgs(arg))
