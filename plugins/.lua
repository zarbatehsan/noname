do
function run_bash(str)
    local cmd = io.popen(str)
    local result = cmd:read('*all')
    return result
end
local api_key = nil
local base_api = "https://maps.googleapis.com/maps/api"
function get_latlong(area)
  local api      = base_api .. "/geocode/json?"
  local parameters = "address=".. (URL.escape(area) or "")
  if api_key ~= nil then
    parameters = parameters .. "&key="..api_key
  end
  local res, code = https.request(api..parameters)
  if code ~=200 then return nil  end
  local data = json:decode(res)
 
  if (data.status == "ZERO_RESULTS") then
    return nil
  end
  if (data.status == "OK") then
    lat  = data.results[1].geometry.location.lat
    lng  = data.results[1].geometry.location.lng
    acc  = data.results[1].geometry.location_type
    types= data.results[1].types
    return lat,lng,acc,types
  end
end
function get_staticmap(area)
  local api        = base_api .. "/staticmap?"
  local lat,lng,acc,types = get_latlong(area)

  local scale = types[1]
  if     scale=="locality" then zoom=8
  elseif scale=="country"  then zoom=4
  else zoom = 13 end
    
  local parameters =
    "size=600x300" ..
    "&zoom="  .. zoom ..
    "&center=" .. URL.escape(area) ..
    "&markers=color:red"..URL.escape("|"..area)

  if api_key ~=nil and api_key ~= "" then
    parameters = parameters .. "&key="..api_key
  end
  return lat, lng, api..parameters
end


function run(msg, matches)
	local hash = 'usecommands:'..msg.from.id..':'..msg.to.id
	redis:incr(hash)
	local receiver	= get_receiver(msg)
	local city = matches[1]
	if matches[1] == 'praytime' then
	city = 'Tehran'
	end
	local lat,lng,url	= get_staticmap(city)

	local dumptime = run_bash('date +%s')
	local code = http.request('http://api.aladhan.com/timings/'..dumptime..'?latitude='..lat..'&longitude='..lng..'&timezonestring=Asia/Tehran&method=7')
	local jdat = json:decode(code)
	local data = jdat.data.timings
	local text = 'ط´ظ‡ط±: '..city
	  text = text..'\nط§ط°ط§ظ† طµط¨ط­: '..data.Fajr
	  text = text..'\nط·ظ„ظˆط¹ ط¢ظپطھط§ط¨: '..data.Sunrise
	  text = text..'\nط§ط°ط§ظ† ط¸ظ‡ط±: '..data.Dhuhr
	  text = text..'\nط؛ط±ظˆط¨ ط¢ظپطھط§ط¨: '..data.Sunset
	  text = text..'\nط§ط°ط§ظ† ظ…ط؛ط±ط¨: '..data.Maghrib
	  text = text..'\nط¹ط´ط§ط، : '..data.Isha
	  text = text..'\n\n@GPMod Team'
	if string.match(text, '0') then text = string.gsub(text, '0', 'غ°') end
	if string.match(text, '1') then text = string.gsub(text, '1', 'غ±') end
	if string.match(text, '2') then text = string.gsub(text, '2', 'غ²') end
	if string.match(text, '3') then text = string.gsub(text, '3', 'غ³') end
	if string.match(text, '4') then text = string.gsub(text, '4', 'غ´') end
	if string.match(text, '5') then text = string.gsub(text, '5', 'غµ') end 
	if string.match(text, '6') then text = string.gsub(text, '6', 'غ¶') end
	if string.match(text, '7') then text = string.gsub(text, '7', 'غ·') end
	if string.match(text, '8') then text = string.gsub(text, '8', 'غ¸') end
	if string.match(text, '9') then text = string.gsub(text, '9', 'غ¹') end
	return text
end

return {
  patterns = {"^[/!][Pp]raytime (.*)$","^[/!](praytime)$"}, 
  run = run 
}

end
