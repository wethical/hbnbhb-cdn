-- HBnbHB 保护分发：指令流 + 运行时，浏览器无法直接读出脚本源码
-- 请在执行器中运行：loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/wethical/hbnbhb-cdn@main/dist/hb7891.lua"))()
local K = {"loadstring","game","HttpGet","https://cdn.jsdelivr.net/gh/wethical/hbnbhb-cdn@main/dist/hb7891.lua"}
local P = {{p=0,v=1,s=0,u={},b={{106,{10,{10,{8,1},{{11,{8,2},3,{{2,4}}}}},{}}},{106,{10,{10,{8,1},{{11,{8,2},3,{{2,4}}}}},{}}},{106,{10,{10,{8,1},{{11,{8,2},3,{{2,4}}}}},{}}},{106,{10,{10,{8,1},{{11,{8,2},3,{{2,4}}}}},{}}}}}}
local ENV = (type(getfenv) == "function" and getfenv()) or _ENV or _G
local unpack = table.unpack or unpack
local type, select, error, math = type, select, error, math
local BREAK = {}

local function pack(...)
  return { n = select("#", ...), ... }
end

local ev
local ev1
local evalArgs
local execBlock
local execStmt
local makeClosure

ev1 = function(node, f)
  local v = ev(node, f)
  return v
end

ev = function(node, f)
  local op = node[1]

  if op == 1 then
    return node[2]
  elseif op == 2 then
    local v = node[2]
    return v and K[v] or nil
  elseif op == 3 then
    return nil
  elseif op == 4 then
    return true
  elseif op == 5 then
    return false
  elseif op == 6 then
    local cell = f.slots[node[2] + 1]
    if cell then return cell.v end
    return nil
  elseif op == 7 then
    local cell = f.upvals[node[2] + 1]
    if cell then return cell.v end
    return nil
  elseif op == 8 then
    return ENV[K[node[2]]]
  elseif op == 9 then
    local obj = ev(node[2], f)
    local key = ev(node[3], f)
    if obj == nil then error("attempt to index nil", 0) end
    return obj[key]
  elseif op == 10 then
    local fn = ev(node[2], f)
    local args = evalArgs(node[3], f)
    return fn(unpack(args, 1, args.n))
  elseif op == 11 then
    local obj = ev(node[2], f)
    if obj == nil then error("attempt to call a nil method", 0) end
    local fn = obj[K[node[3]]]
    local rest = evalArgs(node[4], f)
    local args = { n = rest.n + 1, obj }
    for i = 1, rest.n do args[i + 1] = rest[i] end
    return fn(unpack(args, 1, args.n))
  elseif op == 12 then
    local c = node[2]
    local a = ev(node[3], f)
    local b = ev(node[4], f)
    if c == 1 then return a + b
    elseif c == 2 then return a - b
    elseif c == 3 then return a * b
    elseif c == 4 then return a / b
    elseif c == 5 then return math.floor(a / b)
    elseif c == 6 then return a % b
    elseif c == 7 then return a ^ b
    elseif c == 8 then return a .. b
    elseif c == 9 then return a == b
    elseif c == 10 then return a ~= b
    elseif c == 11 then return a < b
    elseif c == 12 then return a > b
    elseif c == 13 then return a <= b
    elseif c == 14 then return a >= b
    end
    error("bad binop", 0)
  elseif op == 13 then
    local c = node[2]
    local a = ev(node[3], f)
    if c == 1 then return -a
    elseif c == 2 then return not a
    else return #a end
  elseif op == 14 then
    local t = {}
    local arr = node[2]
    local na = #arr
    local idx = 1
    for i = 1, na do
      local item = arr[i]
      if i == na and (item[1] == 10 or item[1] == 11 or item[1] == 16) then
        local p = pack(ev(item, f))
        for j = 1, p.n do
          t[idx] = p[j]
          idx = idx + 1
        end
      else
        t[idx] = ev(item, f)
        idx = idx + 1
      end
    end
    local hash = node[3]
    for i = 1, #hash do
      local pair = hash[i]
      t[ev(pair[1], f)] = ev(pair[2], f)
    end
    return t
  elseif op == 15 then
    return makeClosure(node[2], f)
  elseif op == 16 then
    local va = f.varargs
    if not va then return nil end
    return unpack(va, 1, va.n)
  elseif op == 17 then
    local a = ev(node[2], f)
    if not a then return a end
    return ev(node[3], f)
  elseif op == 18 then
    local a = ev(node[2], f)
    if a then return a end
    return ev(node[3], f)
  elseif op == 20 then
    local v = ev(node[2], f)
    return v
  end

  error("bad node op " .. tostring(op), 0)
end

evalArgs = function(nodes, f)
  local out = { n = 0 }
  local count = #nodes
  for i = 1, count do
    local node = nodes[i]
    if i == count and (node[1] == 10 or node[1] == 11 or node[1] == 16) then
      local p = pack(ev(node, f))
      for j = 1, p.n do
        out.n = out.n + 1
        out[out.n] = p[j]
      end
    else
      out.n = out.n + 1
      out[out.n] = ev(node, f)
    end
  end
  return out
end

makeClosure = function(idx, parent)
  local proto = P[idx + 1]
  local ups = {}
  local desc = proto.u
  for i = 1, #desc do
    local d = desc[i]
    if d[1] == 1 then
      ups[i] = parent.slots[d[2] + 1]
    else
      ups[i] = parent.upvals[d[2] + 1]
    end
  end

  local closure
  closure = function(...)
    local frame = { slots = {}, upvals = ups, varargs = nil }
    if proto.p > 0 then
      local args = pack(...)
      for i = 1, proto.p do
        frame.slots[i] = { v = args[i] }
      end
      if proto.v == 1 then
        local extra = { n = args.n - proto.p }
        for i = 1, extra.n do extra[i] = args[proto.p + i] end
        frame.varargs = extra
      end
    elseif proto.v == 1 then
      local args = pack(...)
      frame.varargs = { n = args.n }
      for i = 1, args.n do frame.varargs[i] = args[i] end
    end

    local r = execBlock(proto.b, frame)
    if r and r.__ret then
      return unpack(r.v, 1, r.vn)
    end
    return nil
  end

  return closure
end

execBlock = function(stmts, f)
  for i = 1, #stmts do
    local r = execStmt(stmts[i], f)
    if r then return r end
  end
  return nil
end

execStmt = function(node, f)
  local op = node[1]

  if op == 101 then
    local slots = node[2]
    local vals = evalArgs(node[3], f)
    for i = 1, #slots do
      f.slots[slots[i] + 1] = { v = (i <= vals.n) and vals[i] or nil }
    end
    return nil
  elseif op == 115 then
    local slot = node[2]
    local cell = { v = false }
    f.slots[slot + 1] = cell
    cell.v = makeClosure(node[3], f)
    return nil
  elseif op == 116 then
    local targets = node[2]
    local vals = evalArgs(node[3], f)
    for i = 1, #targets do
      local t = targets[i]
      local v = (i <= vals.n) and vals[i] or nil
      local kind = t[1]
      if kind == 1 then
        f.slots[t[2] + 1].v = v
      elseif kind == 2 then
        f.upvals[t[2] + 1].v = v
      elseif kind == 3 then
        ENV[K[t[2]]] = v
      else
        local obj = ev(t[2], f)
        local key = ev(t[3], f)
        if obj == nil then error("attempt to index nil", 0) end
        obj[key] = v
      end
    end
    return nil
  elseif op == 106 then
    ev(node[2], f)
    return nil
  elseif op == 107 then
    if ev(node[2], f) then
      return execBlock(node[3], f)
    end
    local alt = node[4]
    if alt then return execBlock(alt, f) end
    return nil
  elseif op == 108 then
    while ev(node[2], f) do
      local r = execBlock(node[3], f)
      if r == BREAK then break end
      if r then return r end
    end
    return nil
  elseif op == 109 then
    repeat
      local r = execBlock(node[2], f)
      if r == BREAK then break end
      if r then return r end
    until ev(node[3], f)
    return nil
  elseif op == 110 then
    local start = ev(node[3], f)
    local limit = ev(node[4], f)
    local step = 1
    if node[5] then step = ev(node[5], f) end
    if step == 0 then error("'for' step is zero", 0) end
    local i = start
    while (step > 0 and i <= limit) or (step <= 0 and i >= limit) do
      f.slots[node[2] + 1] = { v = i }
      local r = execBlock(node[6], f)
      if r == BREAK then break end
      if r then return r end
      i = i + step
    end
    return nil
  elseif op == 111 then
    local slots = node[2]
    local vals = evalArgs(node[3], f)
    local it = vals[1]
    local state = vals[2]
    local ctrl = vals[3]
    if it == nil then error("attempt to iterate a nil value", 0) end
    while true do
      local p = pack(it(state, ctrl))
      if p.n == 0 or p[1] == nil then break end
      ctrl = p[1]
      for i = 1, #slots do
        f.slots[slots[i] + 1] = { v = p[i] }
      end
      local r = execBlock(node[4], f)
      if r == BREAK then break end
      if r then return r end
    end
    return nil
  elseif op == 112 then
    local vals = evalArgs(node[2], f)
    return { __ret = true, v = vals, vn = vals.n }
  elseif op == 113 then
    return BREAK
  elseif op == 114 then
    return execBlock(node[2], f)
  end

  error("bad stmt op " .. tostring(op), 0)
end

local main = function()
  local frame = { slots = {}, upvals = {}, varargs = { n = 0 } }
  local r = execBlock(P[1].b, frame)
  if r and r.__ret then
    return unpack(r.v, 1, r.vn)
  end
  return nil
end

return main()