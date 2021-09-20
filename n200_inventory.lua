--================--
--==VERSION==0.1==--
--================--


local invm = {} 

function invm.item(id,c)
    return {id=id,c=c}
end

function invm.inv_print(inv)
    print("The Inventory: {")
    for i = 1,inv. slots do
        if inv [i].id~="void" and inv [i].c~=0 then
            print("["..i.."] "..inv[i].id.." "..inv[i].c)
        end
    end
    print("}")
end
function invm.inv_add(inv,item)
    local found = false
    for i = 1, inv.slots do
        if inv[i].id==item.id then
            inv[i].c=inv [i].c+item.c
            found=true
            break
        end
    end
    if not found then 
        for i = 1, inv.slots do
            if inv [i].c==0 or inv [i].id=="void" then
                inv[i].id=item.id
                inv[i].c=item.c
                found=true
                break
            end
        end
    end
    if not found then
        return 2 
    end
    return 0
end
function invm.inv_sub(inv,item)
    local r =0
    local found = false
    for i = 1, inv.slots do
        if inv[i].id==item.id then
            inv[i].c=inv [i].c-item.c
            if inv[i].c<0 then r=1 end
            found=true
            break
        end
    end
    if not found then return 2 end
    return  r
end
function invm.inv_sub2(inv,item)
    local r =0
    local found = false
    for i =1,  inv.slots do
        if inv[i].id==item.id then
            inv[i].c=inv [i].c-item.c
            if inv[i].c<0 then 
                r=1 
                item.c=item.c+inv[i].c
            else
                item.c=0
            end
            found = true
            break
        end
    end
    if not found then return 2 end
    return item
end



function invm:newinv(slots)
    local a ={}
    for i = 1,(slots or 1) do
        a[i]=invm.item("void",0)
    end
    a.slots=slots
    a.add=invm.inv_add
    a.sub =invm.inv_sub
    a.sub2=invm.inv_sub2
    a.print=invm.inv_print
    return a
end
function invm.init()
  print('Inventory loading complete...')
  
  return invm
end

return invm.init()