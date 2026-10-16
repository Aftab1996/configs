-- Kill Quickshell
hl.exec_cmd("awww img /home/tipu/Pictures/wallpaper/everforestlight.png --transition-type random")
hl.exec_cmd("awww-deamon &")
hl.exec_cmd(
	"waybar -c /home/tipu/.config/waybar/themes/everforest/config.jsonc -s ~/.config/waybar/themes/everforest/style.css && pkill -x waybar && pkill -x qs"
)
hl.exec_cmd("bash -c 'sleep 0.5'")
hl.exec_cmd("kitten themes Everforest Dark Soft")
hl.config({
	general = {
		gaps_in = 3,
		gaps_out = 10,
		border_size = 2,
		col = {
			active_border = "#A7C080",
			inactive_border = "#DBBC7F",
		},
		resize_on_border = true,
		allow_tearing = false,
		layout = "dwindle",
	},
	decoration = {
		rounding = 10,
		rounding_power = 2,
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

hl.bind("SUPER + D", hl.dsp.exec_cmd("rofi -show drun -config /home/tipu/.config/rofi/themes/everforestlight.rasi"))
