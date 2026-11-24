-- HBnbHB 加密脚本（源码不公开）
-- 浏览器里看到的是加密数据，不是脚本源码。
-- 请在 Roblox 执行器中运行：loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/wethical/hbnbhb-cdn@main/dist/hb7891.lua"))()

local hex = "454f4e87f7d8ca93b0d592978fdbf287def487c5f5ca9e96d68e9f4b4a5980c3c6424742c88c9ad5b8826109160b0302420e174351445b59434b020b0d071a4a060340571938160d4b450b0d161b1006420f7a555e5a4247455b484c404206034057101c180d49445b620700066268415d53535a0d1f454448195f5244421f021c12051d47451407060b4255420f545141420f166f1507010f0e4811585f100f161d6103161a42074255421c1e1011420d0f0a7348424e421b1740121b0f1659300c246207000662125f5b5e461e4a19001c1c4a4c1507104156121b1a0d18101444421a4c050d495719"
local key = "hbnbhb-2026-key"
local bxor = bit32 and bit32.bxor
local out = {}
for i = 1, #hex, 2 do
  local b = tonumber(hex:sub(i, i + 1), 16)
  local j = (i - 1) / 2 + 1
  local k = key:byte((j - 1) % #key + 1)
  if bxor then
    out[#out + 1] = string.char(bxor(b, k))
  else
    local r, bit, a, c = 0, 1, b, k
    while a > 0 or c > 0 do
      if a % 2 ~= c % 2 then r = r + bit end
      a = (a - a % 2) / 2
      c = (c - c % 2) / 2
      bit = bit * 2
    end
    out[#out + 1] = string.char(r)
  end
end
local src = table.concat(out)
local chunk, err = loadstring(src)
if not chunk then
  error("[HBnbHB] " .. tostring(err))
end
return chunk()
