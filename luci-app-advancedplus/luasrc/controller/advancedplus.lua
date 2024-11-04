local NIXIO_FS = require("nixio.fs")
local LUCI_HTTP = require("luci.http")
local LUCI_SYS = require("luci.sys")
local LUCI_UCI = require("luci.model.uci").cursor()

local ap = "advancedplus"

module("luci.controller.advancedplus", package.seeall)

function index()
	if not NIXIO_FS.access("/etc/config/advancedplus") then return end

	local page
	page = entry({"admin", "system", "advancedplus"}, alias("admin", "system", "advancedplus", "advancededit"), _("Advanced Plus"), 61)
	page.dependent = true
	page.acl_depends = { "luci-app-advancedplus" }
	entry({"admin", "system", "advancedplus", "advancededit"}, cbi("advancedplus/advancededit"), _("Advanced Edit"), 10).leaf = true
	entry({"admin", "system", "advancedplus", "advancedset"}, cbi("advancedplus/advancedset"), _("Advanced Setting"), 20).leaf = true
	if NIXIO_FS.access('/www/luci-static/kucat/css/style.css') then
		entry({"admin", "system", "advancedplus", "config-kucat"}, cbi("advancedplus/config-kucat"), "KuCat".._("Theme Config"), 40).leaf = true
	end
	if NIXIO_FS.access('/www/luci-static/argon/css/cascade.css') then
		entry({"admin", "system", "advancedplus", "config-argon"}, form("advancedplus/config-argon"), "Argon".._("Theme Config"), 50).leaf = true
	end
	entry({"admin", "system", "advancedplus", "upload-login"}, form("advancedplus/upload-login"), _("Login Background Upload"), 70).leaf = true
	entry({"admin", "system", "advancedplus", "upload-desktop"}, form("advancedplus/upload-desktop"), _("Desktop Background Upload"), 80).leaf = true
	entry({"admin", "system", "advancedplus", "advancedrun"}, call("advanced_run"))
	entry({"admin", "system", "advancedplus", "check"}, call("act_check"))
end

function act_check()
	LUCI_HTTP.prepare_content("text/plain; charset=utf-8")
	local f = io.open("/tmp/advancedplus.log", "r+")
	local fdp = NIXIO_FS.readfile("/tmp/advancedpos") or 0
	f:seek("set", fdp)
	local a = f:read(2048000) or ""
	fdp = f:seek()
	NIXIO_FS.writefile("/tmp/advancedpos", tostring(fdp))
	f:close()
	LUCI_HTTP.write(a)
end

function advanced_run()
	local selectipk = LUCI_HTTP.formvalue('select_ipk')
	LUCI_SYS.exec("echo 'start' > /tmp/advancedplus.log && echo 'start' > /tmp/advancedpos")
	LUCI_UCI:set(ap, 'advancedplus', 'select_ipk', selectipk)
	LUCI_UCI:commit(ap)
	NIXIO_FS.writefile("/tmp/advancedpos", "0")
	LUCI_HTTP.prepare_content("application/json")
	LUCI_HTTP.write('')
	LUCI_SYS.exec(string.format("bash /usr/bin/advancedplusipk "..selectipk.." > /tmp/advancedplus.log 2>&1 &" ))
end
