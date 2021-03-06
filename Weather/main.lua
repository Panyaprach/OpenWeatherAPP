--Declare variable section
local json = require("json")
local widget = require("widget")
local cx, cy, sunriseTime, sunsetTime
local name, temp, main, desc, icon
local resp, imgIcon, place, bat, bat, btn, swicthBtn
local background, date, currentTime
local tab , l_temp, h_temp, hum, pressu
local lang = {"th","en"} , id

--this function decode response from callTranslator()
local function getResponse( event )
	if not event.isError then
		resp = json.decode(event.response)
		name.text = resp["text"][1]
		main.text = resp["text"][2]
		desc.text = resp["text"][3]
		if lang[id] == "en" then
			swicthBtn:setLabel( "Thai" )
			btn:setLabel( "Check" )
			hum.text = string.gsub( hum.text, "ความชื้น", "Humidity" )
			pressu.text = string.gsub( pressu.text, "ความดัน", "Pressure" )
		elseif lang[id] == "th" then
			swicthBtn:setLabel( "อังกฤษ" )
			btn:setLabel( "ตรวจสอบ" )
			hum.text = string.gsub( hum.text, "Humidity", "ความชื้น" )
			pressu.text = string.gsub( pressu.text, "Pressure", "ความดัน" )
		end
	end
end
--this function call yandex api to translate language
local function callTranslator()
		local apikey = "trnsl.1.1.20170329T185317Z.24f358f17feb356b.5bb984fb80e9f299d24c4b36fa3fdc35cbe9d4d2"
		network.request(
		"https://translate.yandex.net/api/v1.5/tr.json/translate?key="..apikey.."&text="
		..name.text.."&text="..main.text.."&text="..desc.text.."&lang="..lang[id],
		"GET",
		getResponse
		)
end
--this function change app language between thai and english
local function swicthLang( event )
	if event.phase == "ended" then
			id = (id % 2) + 1
			callTranslator()
	end
end
--this function get current time
local function auTo_Time( )
	currentTime.text = os.date("%H:%M")
end

--this function decode response form loadWeather()
local function networkResponse( event )
	if not event.isError then
		resp = json.decode(event.response)
		if resp["cod"] == 200 then
			name.text = resp["name"]
			temp.text = resp["main"]["temp"].."°C"
			main.text = resp["weather"][1]["main"]
			desc.text = resp["weather"][1]["description"]
			l_temp.text = "L : "..resp["main"]["temp_min"].." °C"
			h_temp.text = "H : "..resp["main"]["temp_max"].." °C"
			icon = resp["weather"][1]["icon"]
			hum.text = "Humidity : "..resp["main"]["humidity"]
			pressu.text = "Pressure : "..resp["main"]["pressure"]
			local pos_x = 0
			if icon == "01n" or icon == "01d" then
				pos_x = 15
			end
			if imgIcon then
				imgIcon:removeSelf()
				imgIcon = nil
			end
			imgIcon = display.newImage("icon/"..icon..".png", cx - pos_x, cy - 95)
			imgIcon.xScale = 1.3
			imgIcon.yScale = 1.3
			callTranslator()
		elseif resp["cod"] == 404 then
			--don't do anything
		end
	end
end

--this function call openweathermap api
local function loadWeather()
	local LoadQ = place.text
	if LoadQ == "" then
		LoadQ = "London"
	end
	network.request(
	"http://api.openweathermap.org/data/2.5/weather?q="..LoadQ.."&appid=ce7e84f7f44f4182839513d2fb4fa9f7&units=metric",
	"GET",
	networkResponse
	)
end

--this function checking event form "check" button [btn variable]
local function nameListener( event )
	if event.phase == "ended" then
		loadWeather()
	end
end

--main
display.setDefault("background",0,0,0)
id = 2
cx = display.contentCenterX
cy = display.contentCenterY
background = display.newImage("icon/1bg.jpg", cx, cy)
background.alpha = 0.8
tab = display.newRect(cx,-30,display.contentWidth,30)
tab:setFillColor(0,0,0,.75)
display.newText("10%", cx+65 , -30, "Kristen ITC", 15)
bat = display.newImage("icon/bate.png",cx+100, -30)
bat.xScale = 0.9
bat.yScale = 0.9
sig = display.newImage("icon/Signal.png",cx+35, -32)
sig.xScale = 0.75
sig.yScale = 0.75
currentTime = display.newText(""..os.date("%H:%M"),cx+138, -30,"Kristen ITC",15)
name = display.newText("Place",cx, 50, "Kristen ITC",29)
name:setFillColor(255/255,220/255,91/255)
temp = display.newText("Temp",cx - 80, cy + 110, "Kristen ITC",30)
main = display.newText("Main",cx, cy + 20, "Kristen ITC",30)
desc = display.newText("Desc",cx, 300, "Kristen ITC",18)
l_temp = display.newText("L : ",cx - 80,cy + 140, "Kristen ITC", 15)
h_temp = display.newText("H : ",cx - 80,cy + 160, "Kristen ITC", 15)
hum = display.newText("Humidity : ",cx + 80,cy + 150, "Kristen ITC", 15)
pressu = display.newText("Pressure : ",cx + 80,cy + 120, "Kristen ITC", 15)
place = native.newTextField( cx - 50, cy+220, 150, 50 )
place.align = "center"
place.font = native.newFont( "Kristen ITC", 15 )
place:resizeHeightToFitFont()
btn = widget.newButton({
	x = cx+100,y = cy+220,
	width = 70 , height = 30,
	shape = "roundedRect",
	fillColor = {default={0,0,0,0.4},over={0,0,0,0.7}},
	strokeColor = { default={1,1,1}, over={0,0,0,0.5} },
    strokeWidth = 2, cornerRadius = 10,
	label = "Check" , font =  "Kristen ITC", fontSize = 15,
	labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
	onEvent = nameListener
})
swicthBtn = widget.newButton({
	x = cx + 115,y = 15,
	width = 70 , height = 30,
	shape = "roundedRect",
	fillColor = {default={0,0,0,0.4},over={0,0,0,0.7}},
	strokeColor = { default={1,1,1}, over={0,0,0,0.5} },
    strokeWidth = 2, cornerRadius = 10,
	label = "Thai" , font =  "Kristen ITC", fontSize = 15,
	labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
	onEvent = swicthLang
})
timer.performWithDelay(100, auTo_Time, 0)
loadWeather()
