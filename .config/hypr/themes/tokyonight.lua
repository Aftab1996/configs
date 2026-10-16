hl.exec_cmd("awww img /home/tipu/Pictures/wallpaper/tokyonight/tron_original.png --transition-type random")
hl.exec_cmd("awww-deamon &")
hl.exec_cmd("pkill -x waybar")
hl.exec_cmd("kitten theme Tokyo Night")
hl.exec_cmd("bash -c 'pkill -x qs; sleep 0.3; qs -p ~/.config/quickshell/tokyonight.qml &'")
hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 7,

		border_size = 1,
		col = {
			active_border = "#f7768e",
			inactive_border = "#a9b1d6",
		},
		resize_on_border = true,
		allow_tearing = false,
		layout = "dwindle",
	},
	animations = {
		enabled = true,
	},

	decoration = {
		rounding = 5,
		rounding_power = 4,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
	},
})
