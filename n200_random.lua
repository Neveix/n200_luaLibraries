local ran = {}

ran.path = ''

ran.rfn = 'random.txt' --random filename

function ran.guide()
  print([[random = require'n200_random'

print(random.i(3))

print(random.choose{4,7,9,14,23})

random.saverandom()]])
end

function handle_randomsystem()
  ::start::
  print('настройка системы рандома. Введите путь до будущего файла рандома :')
  print('вы можете воспользоваться пресетом: 1=компьютер , 2=телефон/qlua5 ')
  local s = io.read()
  if s == '1' then ran.path = ''
  elseif s == '2' then ran.path = '//storage//emulated//0//qlua5//'
  else print('ошибка') goto start end
  
  local rndfile = io.open(ran.path..ran.rfn,'w')
  rndfile:write(math.random(999999))
  rndfile:close()
end

-- load random
function ran:loadrandom()
  local file = io.open(ran.rfn,'r')
  local readed = ''
  if not file then
    file = io.open('//storage//emulated//0//qlua5//'..ran.rfn,'r')
    if not file then
      handle_randomsystem()
    else
      readed = file:read()
    end
  else
    readed = file:read()
  end
  file:close()
  math.randomseed(tonumber(readed) or 0)
  return ran
end

-- save random
function ran.saverandom()
  local file = io.open(ran.path..ran.rfn,'w')
  file:write(math.random(999999))
  file:close()
end

ran.i = math.random --random integer

function ran.r(a,b)
  local res;
  if b then
    res = math.random(a,b-1)+math.random()
  else
    if a then
      res = math.random(a-1)+math.random()
    else
      res=math.random()
    end
  end
  return res
end

function ran.choose(s)
  s = s or {1,2}
  return s[math.random(1,#s)]
end

return ran:loadrandom()