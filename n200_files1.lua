local nw = {}

function nw.read(path)
	local file = io.open(path,"r")
  local s = ''
	if file==nil then
	    s = nil
	else
    	s = file:read('*a')
	end
  file:close()
  return s
end

function nw.write(path,value)
	local file = io.open(path,"w")
	file:write(value)
	file:close()
end

function nw.append(path,value)
	local file = io.open(path,"a")
	file:write(value)
	file:close()
end

return nw