local ip = {}
local tok = require "tokens"
local uf = require "n200_useful2"

-- For Lua >= 5.3
--- VERSION 7.0

local tostr = tostring
local tonum = tonumber
local floor = math.floor
ip.self = ip
ip.iplevel = 0 --ip stack current size
ip.cmds = {} -- current cmds
ip.ips = {} -- all interpreters
ip.ipsA = {} -- active interpreters
ip.isExit = false

ip.flags = {}
ip.flags.printStarted = 1
ip.flags.writeTypeSymbol = 2
ip.flags.printClosed = 4
ip.flags.printActions = 5
ip.flags.printAll = 7

-- функция списка команд.
function ip:help()
    for k,v in pairs (ip.cmds) do
      if k ~= "cmd" then
        print (k.." ("..tostr(v.args)..")",v.des)
      end
    end
end

-- простейшая функция, вызывающая выход из интерпретатора
function ip.back()
    return "__back"
end

function ip.exit()
  ip.isExit = true
end

-- простейшая функция, добавляющая команду в интерпретатор
function ip.newcmd(func,args,des,settings)
    local a = {}
    a.f = func
    a.args = args
    a.des = des
    if settings and settings & 1 then
      a.needIPargument = true
    end
    return a
end

-- функция, создающая пустой набор команд
function ip.cmds_empty()
    local a = {}
    a.cmd = function (self,ind,func,arg,des,settings)
      if type(ind) ~= "string" then error("incorrect name") end
      --if type(func) ~= "function" then print("incorrect function type. 'func' argument type was "..type(func)) end
      arg = arg or ""
      des = des or ""
      self[ind] = ip.newcmd(func,arg,des,settings)
      return self
    end
    return a
end

-- функция, создающая стандартный набор команд
function ip:cmds_default()
    local a = ip.cmds_empty()
    a:cmd("help",ip.help,"","Helps you",1)
    :cmd("b",ip.back,"","Close Interpreter")
    :cmd("exit",ip.exit,"","Exit program")
    return a
end

function ip:newcmds()
  return ip:cmds_default()
end

-- функция, создающая новый интерпретатор
function ip:newIp(name,cmds,settings)
  local a = {}
  if type(name)=='string' then 
    a.name = name 
  else error("incorrect name") end
  --if type(cmds) == "function" then cmds:
  a.typesymbol = '>'
  a.readsep = ' ' --tok.tok(io.read) separator
  a.settings = settings or 0
  a.fNum = nil --numeric function
  a.fUnknown = nil
  a.cmds = cmds or {}
  a.name = name
  a.previousIS = {''}
  a.nextIpr = nil
  a.nextIprSet = 0
  a.fReturn = nil --function that is called after input with the return value of the input function as the first argument
  a.fAfterInput = nil
  a.fBeforeInput = nil
  a.fExit = nil
  a.interprete = function(self) ip:interprete(self) end
  a.ip = ip
  ip.ips[#ip.ips+1] = a
  ip.ips[name] = a
  return a
end

ip.newTextInterpreter = ip.newIp

-- функция интерпретатора
function ip:interprete(ipr)
  -- защита от багов
  if type(ipr)=='string' then
    if ip.ips[ipr] then
      ipr = ip.ips[ipr]
    else
      error("incorrect name '"..ipr.."'")
    end
  elseif type(ipr)~='table' then
    error('unknown type of name ('..type(ipr)..')')
  end
  -- переназначение предыдущих команд
  local oldcmds = ip.cmds
  ip.cmds = ipr.cmds
  
  if not ip.cmds then error('ip.cmds == nil') end
  -- счётчик стека интерпретаторов
  ip.iplevel = ip.iplevel + 1
  ip.ipsA[ip.iplevel] = ipr.name
  
  --пишет 'started ..' если имеет этот флаг
  if ipr.settings & 1 == 1 then
    print ("Started "..ipr.name)
  end
  -- главный цикл интерпретатора,в котором он считывает команды с клавиатуры
  while true do
      -- если есть функция beforeInput, вызываем её:
      if ipr.fBeforeInput then ipr:fBeforeInput() end --function x(ipr)
      -- если указано в настройках, пишем символ перед вводом (обычно это '>')
      if ipr.settings & 2 == 2 then
        io.write(ipr.typesymbol)
      end
      -- считываем с клавиатуры 
      local s = io.read()
      -- разделяем строку на таблицу через разделитель
      s = tok.tok(s,ipr.readsep)
      -- сохраняем предыдущую введённую команду
      ipr.previousIS = s
      
      -- если введённая команда не число
      if not uf:isNumber(s[1]) or s[1]=='' then
        local founded = false
        -- проверяем все команды
        for k,v in pairs (ipr.cmds) do
          -- если одна из них совпала с введённым текстом
          if s[1]==k then
            -- вызываем функцию и записываем результат в r
            if ipr.cmds[k].needIPargument then
              r=ipr.cmds[k].f(ip,s,ipr) --function x(ip,s,ipr)
            else
              r=ipr.cmds[k].f(s,ipr) --function x(s,ipr)
            end
            founded = true
            break
          end
        end
        -- если команда не была найдена
        if not founded and ipr.fUnknown then
          -- вызываем специальную функцию (если она задана)
          r = ipr:fUnknown(s) --function x(ipr,s)
        end
      -- если введённая команда - число
      elseif ipr.fNum then
        -- смещаем все аргументы вперёд
        for i = 1,#s do
          s[i+1] = s[i]
        end
        s[1] = ""
        -- вызываем специальную функцию
        r=ipr:fNum(s) --function x(ipr,s)
      end
      -- проверяем, есть ли функция для возвращаемого значения 
      if ipr.fReturn then ipr:fReturn(r) end --function x(ipr,r)
      -- если возвращаемое значение == '__back',
      if r == '__back' or ipr.nextIpr then
        -- проверяем по настройкам, нужно ли писать 'closed'
        if (ipr.settings & 4 == 4) or ((ipr.nextIprSet or 0 ) & 1 == 1)  then
          print ("Closed "..ipr.name)
        end
        -- если есть функция выхода, вызываем её.
        if ipr.fExit then
          if ipr.nextIpr then
            if ((ipr.nextIprSet or 0) & 2 == 2) then
              ipr:fExit(ipr) --function x(ipr)
            end
          else
            ipr:fExit(ipr) --function x(ipr)
          end
        end
        -- выходим из интерпретатора
        break
      else
        -- проверяем, есть ли функция afterinput, и вызываем её
        if ipr.fAfterInput then ipr:fAfterInput() end --function x(ipr)
      end
      if ip.isExit then break end

  end
  
  -- возвращаем всё на свои места
  
  ip.ipsA[ip.iplevel] = nil
  ip.iplevel = ip.iplevel - 1
  
  ip.cmds = oldcmds
  
  if ipr.nextIpr then
    local a = ipr.nextIpr
    ipr.nextIpr = nil
    ipr.nextIprSet = nil
    ip:interprete(a)
  end
  
end

function ip:changeIpr(ipr,set)
  if not ipr then error('incorrect ipr') end
  local lastipr = ip.ips[ip.ipsA[ip.iplevel]]
  lastipr.nextIpr = ipr
  lastipr.nextIprSet = set or 0
end

return ip