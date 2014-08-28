dofile("urlcode.lua")
dofile("table_show.lua")
JSON = (loadfile "JSON.lua")()

local url_count = 0
local tries = 0


read_file = function(file)
  if file then
    local f = assert(io.open(file))
    local data = f:read("*all")
    f:close()
    return data
  else
    return ""
  end
end

-- wget.callbacks.download_child_p = function(urlpos, parent, depth, start_url_parsed, iri, verdict, reason)
--   local url = urlpos["url"]["url"]
--   
--   -- Don't download the favicon over and over again
--   if url == "http://wallbase.cc/fav.gif" then
--     return false
--   
--   else
--     return verdict
--   end
-- end

wget.callbacks.get_urls = function(file, url, is_css, iri)
  local urls = {}
  local html = nil
  
  --example url: http://wallbase.cc/wallpaper/2816669
  if string.match(url, "wallbase%.cc/wallpaper/") then
    if not html then
      html = read_file(file)
    end
    
    --example line: <a href="http://wallbase.cc/wallpaper/go/2816669/prev?ref=aHR0cDovL3dhbGxiYXNlLmNjL2NvbGxlY3Rpb24vMjkwNTUv" class="prev-wall"><span class="icn">&#x2190;</span> PREV</a>
    --url to extract from example line: http://wallbase.cc/wallpaper/go/2816669/prev?ref=aHR0cDovL3dhbGxiYXNlLmNjL2NvbGxlY3Rpb24vMjkwNTUv
    local prev_url = string.match(html, '<a href="(http://wallbase%.cc/wallpaper/go/[0-9]+/prev%?ref%=[a-x0-9A-X]+)" class="prev-wall">')
    if prev_url then
      table.insert(urls, { url=prev_url })
    end
    
    --example line: <a href="http://wallbase.cc/wallpaper/go/2816669/next?ref=aHR0cDovL3dhbGxiYXNlLmNjL2NvbGxlY3Rpb24vMjkwNTUv" class="next-wall">NEXT <span class="icn">&#x2192;</span></a>
    --url to extract from example line: http://wallbase.cc/wallpaper/go/2816669/next?ref=aHR0cDovL3dhbGxiYXNlLmNjL2NvbGxlY3Rpb24vMjkwNTUv
    local next_url = string.match(html, '<a href="(http://wallbase%.cc/wallpaper/go/[0-9]+/next%?ref%=[a-z0-9A-Z]+)" class="prev-wall">')
    if next_url then
      table.insert(urls, { url=next_url })
    end
  end
  
  --example url: http://wallbase.cc/search?tag=8179
  if string.match(url, "wallbase%.cc/search%?tag=[0-9]+") then
    if not html then
      html = read_file(file)
    end
    
    if not string.match(html, '<div class="title">The End</div>') and
      string.match(html, '<div class="subtitle">There seems to be nothing here%. Move along%.%.%.</div>') then
      local tag_number = string.match(url, "wallbase%.cc/search%?tag=([0-9]+)")
      
      tag_wallpaper_number_zero = 0
      tag_wallpaper_number_new_url1 = "http://wallbase.cc/search/"..tag_wallpaper_number_zero.."?tag="..tag_number
      tag_wallpaper_number_new_url2 = "http://wallbase.cc/search/index/"..tag_wallpaper_number_zero.."?tag="..tag_number
      
      table.insert(urls, { url=tag_wallpaper_number_new_url1 })
      table.insert(urls, { url=tag_wallpaper_number_new_url2 })
    end
  --example url: http://wallbase.cc/search?q==%28fate%20stay%20night%29&color=&section=wallpapers&q==%28fate%20stay%20night%29&res_opt=eqeq&res=0x0&order_mode=desc&thpp=32&purity=100&board=21&aspect=0.00
  elseif string.match(url, "wallbase%.cc/search%?tag==.+") then
    if not html then
      html = read_file(file)
    end
    
    if not string.match(html, '<div class="title">The End</div>') and
      string.match(html, '<div class="subtitle">There seems to be nothing here%. Move along%.%.%.</div>') then
      local tag_string = string.match(url, "wallbase%.cc/search%?tag==(.+)")
      
      tag_wallpaper_number_zero = 0
      tag_wallpaper_number_new_url = "http://wallbase.cc/search/index/"..tag_wallpaper_number_zero.."?q=="..tag_string
      
      table.insert(urls, { url=tag_wallpaper_number_new_url })
    end
  end
  
  --example url: http://wallbase.cc/search/60?tag=8179
  if string.match(url, "wallbase%.cc/search/[0-9]+%?tag=[0-9]+") then
    if not html then
      html = read_file(file)
    end
    
    if not string.match(html, '<div class="title">The End</div>') and
      string.match(html, '<div class="subtitle">There seems to be nothing here%. Move along%.%.%.</div>') then
      local tag_wallpaper_number = string.match(url, "wallbase%.cc/search/([0-9]+)%?tag=[0-9]+")
      local tag_number = string.match(url, "wallbase%.cc/search/[0-9]+%?tag=([0-9]+)")
      
      tag_wallpaper_number_new = tag_wallpaper_number + 60
      tag_wallpaper_number_new_url = "http://wallbase.cc/search/"..tag_wallpaper_number_new.."?tag="..tag_number
      
      table.insert(urls, { url=tag_wallpaper_number_new_url })
    end
  end
  
  --example url: http://wallbase.cc/search/index/0?tag=8179
  if string.match(url, "wallbase%.cc/search/index/[0-9]+%?tag=[0-9]+") then
    if not html then
      html = read_file(file)
    end
    
    if not string.match(html, '<div class="title">The End</div>') and
      string.match(html, '<div class="subtitle">There seems to be nothing here%. Move along%.%.%.</div>') then
      local tag_wallpaper_number = string.match(url, "wallbase%.cc/search/index/([0-9]+)%?tag=[0-9]+")
      local tag_number = string.match(url, "wallbase%.cc/search/index/[0-9]+%?tag=([0-9]+)")
      
      tag_wallpaper_number_new = tag_wallpaper_number + 32
      tag_wallpaper_number_new_url = "http://wallbase.cc/search/index/"..tag_wallpaper_number_new.."?tag="..tag_number
      
      table.insert(urls, { url=tag_wallpaper_number_new_url })
    end
  end
  
  --example url: http://wallbase.cc/search/index/64?q==%28fate%20stay%20night%29&color=&section=wallpapers&q==%28fate%20stay%20night%29&res_opt=eqeq&res=0x0&order_mode=desc&thpp=32&purity=100&board=21&aspect=0.00
  if string.match(url, "wallbase%.cc/search/index/[0-9]+%?q==.+") then
    if not html then
      html = read_file(file)
    end
    
    if not string.match(html, '<div class="title">The End</div>') and
      string.match(html, '<div class="subtitle">There seems to be nothing here%. Move along%.%.%.</div>') then
      local tag_wallpaper_number = string.match(url, "wallbase%.cc/search/index/([0-9]+)%?q==.+")
      local tag_string = string.match(url, "wallbase%.cc/search/index/[0-9]+%?q==(.+)")
      
      tag_wallpaper_number_new = tag_wallpaper_number + 32
      tag_wallpaper_number_new_url = "http://wallbase.cc/search/index/"..tag_wallpaper_number_new.."?q=="..tag_string
      
      table.insert(urls, { url=tag_wallpaper_number_new_url })
    end
  end
  
  --example url: http://wallbase.cc/search?q==%28fate%20stay%20night%29&color=&section=wallpapers&q==%28fate%20stay%20night%29&res_opt=eqeq&res=0x0&order_mode=desc&thpp=32&purity=100&board=21&aspect=0.00
  if string.match(url, )
end

wget.callbacks.httploop_result = function(url, err, http_stat)
  -- NEW for 2014: Slightly more verbose messages because people keep
  -- complaining that it's not moving or not working
  local status_code = http_stat["statcode"]
  
  url_count = url_count + 1
  io.stdout:write(url_count .. "=" .. status_code .. " " .. url["url"] .. ".  \r")
  io.stdout:flush()
  
  if status_code >= 500 or
    (status_code >= 400 and status_code ~= 404) or
    status_code == 0 then
    io.stdout:write("\nServer returned "..http_stat.statcode..". Sleeping.\n")
    io.stdout:flush()

    os.execute("sleep 10")

    tries = tries + 1

    if tries >= 5 then
      io.stdout:write("\nI give up...\n")
      io.stdout:flush()
      return wget.actions.ABORT
    else
      return wget.actions.CONTINUE
    end
  end

  tries = 0

  -- We're okay; sleep a bit (if we have to) and continue
  local sleep_time = 0.1 * (math.random(75, 1000) / 100.0)

  --  if string.match(url["host"], "cdn") or string.match(url["host"], "media") then
  --    -- We should be able to go fast on images since that's what a web browser does
  --    sleep_time = 0
  --  end

  if sleep_time > 0.001 then
    os.execute("sleep " .. sleep_time)
  end

  return wget.actions.NOTHING
end
