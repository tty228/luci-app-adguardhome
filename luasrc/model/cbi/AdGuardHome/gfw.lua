local nt = require "luci.sys".net
local fs=require"nixio.fs"
luci.sys.call("/usr/share/AdGuardHome/blacklist_full_wget get_blacklist")
local uci = require"luci.model.uci".cursor()
local gfwfile = uci:get("AdGuardHome", "AdGuardHome", "gfw_path") or "/usr/share/AdGuardHome/blacklist_full"

m=Map("AdGuardHome")

s = m:section(TypedSection, "AdGuardHome", "")
s.anonymous = true
s.addremove = false

a=s:option(Flag,"gfw_shunt_enable",translate("Enable"))
a.rmempty = true
a.description = translate("Use GFW list shunting to prevent DNS pollution")

--a=s:option(Value,"gfw_path",translate('gfwlist File path'))
--a.default = "/usr/share/AdGuardHome/blacklist_full"
--a:depends("gfw_shunt_enable","1")

a = s:option(Value, "gfwlist_url", translate("GFW domains(gfwlist) Update URL"))
a:value("https://raw.githubusercontent.com/hezhijie0327/GFWList2AGH/main/gfwlist2domain/blacklist_full.txt", translate("hezhijie0327/blacklist_full.txt"))
a:value("https://raw.githubusercontent.com/hezhijie0327/GFWList2AGH/main/gfwlist2domain/blacklist_lite.txt", translate("hezhijie0327/blacklist_lite.txt"))
a:depends("gfw_shunt_enable","1")

a=s:option(Value,"chinadns",translate('chinadns'))
a.default = "127.0.0.1"
a:depends("gfw_shunt_enable","1")

a=s:option(Value,"gfwdns",translate('gfwdns'))
a.default = "127.0.0.1:5335"
a:depends("gfw_shunt_enable","1")

a = s:option(TextValue, "downloadlinks", translate("Additional proxy list"))
a.description = translate("Default synchronization ShadowSocksR Plus+ & passwall proxy list")
a.optional = false
a.rows = 15
a.wrap = "soft"
a.cfgvalue = function(self, section)
    return fs.readfile("/usr/share/AdGuardHome/proxy_host")
end
a.write = function(self, section, value)
    fs.writefile("/usr/share/AdGuardHome/proxy_host", value:gsub("\r\n", "\n"))
end
a:depends("gfw_shunt_enable","1")

--a=s:option(Flag,"auto_updategfwlist_enable",translate("auto update gfwlist"))
--a.rmempty = true
--a:depends("gfw_shunt_enable","1")

--a=s:option(ListValue,"updategfwlist_time",translate("time"))
--a.rmempty = true
--for t=0,23 do
--a:value(t,translate("Every day "..t.." o'clock"))
--end	
--a.default=8	
--a.datatype=uinteger
--a:depends("auto_updategfwlist_enable","1")


a = s:option(Button, "restart", translate("Update"))
a.inputtitle = translate("Update core version")
a.template = "AdGuardHome/AdGuardHome_check_gfw"
local gfw_count = luci.sys.exec("cat " .. gfwfile .. " |wc -l")
a.description = translate("当前规则数目 " .. gfw_count .. "<br><br><br>懒得做计划任务了<br>每天零点更新<br>0 0 * * * /usr/share/AdGuardHome/blacklist_full_wget download &>/dev/null 2>&1<br>每隔 7 天零点更新<br>0 0 */7 * * /usr/share/AdGuardHome/blacklist_full_wget download &>/dev/null 2>&1")


return m
