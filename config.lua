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