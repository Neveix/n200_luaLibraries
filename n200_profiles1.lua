local Module = {}
nw = require 'Nw'
uf = require 'n200_useful2'

Module.path = '' --Example: '\\neveix_Feb2021\\Planet Shelter 1\\'


function Module:loadProfiles()
  local file = tostring(nw.read(Module.path..'profiles.txt'))
  if not file or file == '' or file=='nil' then
    return 'error occursion when load profiles'
  end
  profs = {}
  file = uf.tokens(file,string.char(13))
  local mode = 'd'
  for i = 1, #file do
    if file[i] == 'profilesID' then
      mode = 'id'
    elseif file[i]=='profilesData' then
      mode = 'dat'
    else
      local inp = uf.tokens(file[i],'=')
      if mode=='id' then
        profs[tonumber(inp[1])] = {name=inp[2],data = {}}
      elseif mode=='dat' then
        if inp[2]=='n' then
          profs[tonumber(inp[1])].data[inp[3]] = tonumber(inp[4]) or 0
        elseif inp[2]=='s' then
          profs[tonumber(inp[1])].data[inp[3]] = inp[4]
        elseif inp[2]=='b' then
          local ew;
          if inp[4]=='1' then
            ew = true
          else
            ew = false
          end
          profs[tonumber(inp[1])].data[inp[3]] = ew
        end
      end
    end
  end
  return profs
end

function Module:saveProfiles(path,profs)
  nw.write(path,'profilesID'..string.char(13))
  for i = 1,#profs do
    nw.append(path,i..'='..profs[i].name..string.char(13))
  end
  nw.append(path,'profilesData'..string.char(13))
  for i = 1,#profiles do
    for k,v in pairs(profs[i].data) do
      local typ = type(v):sub(1,1) or error('typ error')
      if typ == 'b' then
        if v then v=1 else v=0 end
      end
      nw.append(path,i..'='..typ..'='..k..'='..v..string.char(13))
    end
  end
end

function Module:Init(path)
  if not path then error('path not set') end
  Module.path = path
  
  return Module
end

return Module