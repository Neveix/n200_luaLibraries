local useful = {}
useful.numbers = {}
useful.englishAlphabet = {}

--// Token's count //--
function useful.tokencount(s,se)
    local c = 1
	local after = 0
    for i = 1,#s do
        if i>=after and s:sub(i,i+#se-1) == se
        then
            c = c+1
			after = i+#se
        end;
    end;
    return c
end;

--// Tokens at //--
function useful.tokens(s,se)
  local re = {}
  local seps = {}
  local after = 0
  for i = 1,#s do
      if i>=after and s:sub(i,i+#se-1) == se
      then
          local a = {}
          seps[#seps+1] = a
              a.start,a.finish = i,i+#se-1
              after = i+#se
      end;
  end;
	local st = 1
	for i = 1,#seps+1 do
		if i == #seps+1 then re[#re+1] = s:sub(st,#s)
		else re[#re+1] = s:sub(st,seps[i].start-1) st = seps[i].finish+1 end
	end
    return re
end;

--// Print Table //--
function useful:printT(t,n)
  if type(t)~='table' then print('t is not an a table') return end
  if type(useful)~='table' then
    error('incorrect arguments')
  end
  n = n or 0
  local function ot() for o = 1 , n*2 do io.write(' ') end end
  local function printvalue(v)
    if type(v)=="table" then
      print('table:')
      useful:printT(v,n+1)
    else
      print(v)
    end
  end
  ot()
  print('{')
  for k,v in pairs(t) do
    ot()
    io.write('['..tostring(k)..'] = ')
    printvalue(v)
  end
  ot()
  print('}')
end

-- // Useful isNumber //--
function useful:isNumber (s)
  local isnumber = true;
  for i = 1,#s do
    local c = s:sub(i,i)
    local isthisnumber = false
    for j = 1,#useful.numbers do
      if c == useful.numbers[j] then
        isthisnumber = true
        break;
      end
    end
    if not isthisnumber then
      isnumber = false
      break;
    end
  end
  return isnumber;
end

-- // Случайная последовательность символов //--
function useful:randomSymbolSeq(l,sym)
  l = l or error('length was nil') 
  sym = sym or useful.englishAlphabet
  seq = ""
  for i = 1,l do
    seq = seq .. sym[math.random(1,#sym)]
  end
  return seq
end

-- // Sleep func //--
function useful.sleep (ms)
    local s = os.clock()
    while s+ms>os.clock() do

    end
end

function useful:init()
  for i = 0,9 do
    useful.numbers[i+1]=tostring(i)
  end
  local ab = 'abcdefghijklmnopqrstuvwxyz'
  for i = 1,26 do
    useful.englishAlphabet[i] = ab:sub(i,i)
  end
  return useful
end



return useful:init()