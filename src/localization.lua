require "i18n"

local cm = i18n.conv_method((2 << 16) | string.byte("?", 1))

function utf8_to_ansi(str)
	return i18n.utf8_to_ansi(str, cm)
end

function ansi_to_utf8(str)
	return i18n.ansi_to_utf8(str, cm)
end

local real_print = print

function print(...)
	local args = {...}
	for i = 1, #args do
		args[i] = utf8_to_ansi(tostring(args[i]))
	end
	return real_print(table.unpack(args))
end
