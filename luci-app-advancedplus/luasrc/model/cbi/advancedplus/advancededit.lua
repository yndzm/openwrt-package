local NIXIO_FS = require("nixio.fs")
local LUCI_SYS = require("luci.sys")

local m, s

m = Map("advancedplus")
m.title = translate("Advanced Edit")
m.description = translate("<font color=\"Red\"><strong>Configuration documents are directly edited unless you know what you are doing, please do not easily modify these configuration documents. Incorrect configuration may result in errors such as inability to power on!</strong></font><br/>")
m.apply_on_parse = true

s = m:section(TypedSection, "basic")
s.anonymous = true

local function CreateTab(s, fileName, filePath)
	if NIXIO_FS.access(filePath) then
		local fileCFG = fileName.."conf"
		s:tab(fileCFG, fileName, translate("This page is about configuration")..filePath..translate("Document content, Automatic restart takes effect after saving the application."))
		local conf = s:taboption(fileCFG, Value, fileCFG, nil, translate("The starting number symbol (#) or each line of the semicolon (;) is considered a comment, Remove (;) and enable the specified option."))
		conf.template = "cbi/tvalue"
		conf.rows = 20
		conf.wrap = "off"
		conf.cfgvalue = function()
			return NIXIO_FS.readfile(filePath) or ""
		end
		conf.write = function(_, _, uci)
			if uci then
				local fileTMP = "/tmp/"..fileName..".tmp"
				uci = uci:gsub("\r\n?", "\n")
				NIXIO_FS.writefile(fileTMP, uci)
				if (LUCI_SYS.call("cmp -s "..fileTMP.." "..filePath) == 1) then
					NIXIO_FS.writefile(filePath, uci)
					LUCI_SYS.call("/etc/init.d/"..fileName.." restart >/dev/null")
				end
				NIXIO_FS.remove(fileTMP)
			end
		end
	end
end

CreateTab(s, "dnsmasq", "/etc/dnsmasq.conf")
CreateTab(s, "hosts", "/etc/hosts")
CreateTab(s, "dhcp", "/etc/config/dhcp")
CreateTab(s, "firewall", "/etc/config/firewall")
CreateTab(s, "network", "/etc/config/network")
CreateTab(s, "wireless", "/etc/config/wireless")

CreateTab(s, "arpbind", "/etc/config/arpbind")
CreateTab(s, "autotimeset", "/etc/config/autotimeset")
CreateTab(s, "bypass", "/etc/config/bypass")
CreateTab(s, "ddns", "/etc/config/ddns")
CreateTab(s, "homeproxy", "/etc/config/homeproxy")
CreateTab(s, "mwan3", "/etc/config/mwan3")
CreateTab(s, "nginx", "/etc/config/nginx")
CreateTab(s, "openclash", "/etc/config/openclash")
CreateTab(s, "parentcontrol", "/etc/config/parentcontrol")
CreateTab(s, "smartdns", "/etc/config/smartdns")
CreateTab(s, "socat", "/etc/config/socat")
CreateTab(s, "upnpd", "/etc/config/upnpd")
CreateTab(s, "wolplus", "/etc/config/wolplus")

CreateTab(s, "ddns-go", "/etc/ddns-go/ddns-go-config.yaml")

return m
