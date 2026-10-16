-- Kill Quickshell
hl.exec_cmd("awww img /home/tipu/Pictures/wallpaper/jupiter.png --transition-type random")
hl.exec_cmd("awww-deamon &")
hl.exec_cmd("pkill qs")
hl.exec_cmd("bash -c 'sleep 0.3; qs -n -d -p /home/tipu/.config/hypr/themes/studybar.qml&'")
hl.exec_cmd("kitten theme Catppuccin-Frappe ")
hl.exec_cmd("qs -p /home/tipu/.config/quickshell/noti.qml")

hl.config({
	general = {
		gaps_in = 0,
		gaps_out = 0,
		border_size = 2,
		col = {
			active_border = "#838ba7",
			inactive_border = "#303446",
		},
		resize_on_border = true,
		allow_tearing = false,
		layout = "dwindle",
	},
	animations = {
		enabled = false,
	},

	decoration = {
		rounding = 0,
		rounding_power = 4,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		shadow = {
			enabled = false,
		},
		blur = {
			enabled = false,
		},
	},
})
hl.bind("SUPER + D", hl.dsp.exec_cmd("rofi -show drun"))
