local normalW, normalH = 640, 960

if not display then return end -- This is needed for dekstop app

-- This calculation extends the standard letterbox scaling
-- Using this point x = 0, y = 0 is always in the top left corner of the screen on all devices
-- And x = display.contentWidth, y = display.contentHeight is always in the bottom right corner
local w, h = display.pixelWidth, display.pixelHeight
local scale = math.max(normalW / w, normalH / h)
w, h = w * scale, h * scale


application =
{
   content =
   {
		fps = 60,
      width = 800,
      height = 1200,
      scale = "letterbox",
      xAlign = "center",
      yAlign = "center",
		
		imageSuffix =
		{
			--[""] = 1.000,	--iPhone4 / iPod4 / iPhone5	| 640(deviceWidth)/800 = 0.800
									--iPad1/iPad2						| 1024(deviceHeight)/1200 = 0.853
									--Samsung S3						| 720(deviceWidth)/800 = 0.900
									--K.FireHD / Nexus7(1)			| 800(deviceWidth)/800 = 1.000
									--iPhone6?							| 828(deviceWidth)/800 = 1.035

			["@2x"] = 1.250	--Samsung S4/S5					| 1080(deviceWidth)/800 = 1.350
									--K.FireHD-9" / Nexus7(2)		| 1200(deviceWidth)/800 = 1.500
									--iPad3/iPad4/iPad-Air			| 2048(deviceHeight)/1200 = 1.707
									--Nexus10							| 1600(deviceWidth)/800 = 2.000
		}
   }
}