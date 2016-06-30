require 'luabind'
require 'filesystem'

local function dir_scan(dir, callback)
	for full_path in dir:list_directory() do
		if fs.is_directory(full_path) then
			-- 递归处理
			dir_scan(full_path, callback)
		else
			callback(full_path)
		end
	end
end

local function main()
	--添加require搜寻路径
	package.path = package.path .. ';' .. arg[1] .. 'src\\?.lua'
	package.cpath = package.cpath .. ';' .. arg[1] .. 'build\\?.dll'
	require 'utility'
	require 'localization'

	if not arg[2] then
		print('请将地图拖动到make.bat中!')
		return
	end
	
	-- 保存路径
	local root_dir   = fs.path(ansi_to_utf8(arg[1]))
	local input_path  = fs.path(ansi_to_utf8(arg[2]))
	local output_dir = root_dir / 'output'
	
	fs.set_current_path(root_dir)

	-- 创建一个临时目录
	if fs.exists(output_dir) then
		fs.rename(output_dir, root_dir / 'del')
		fs.remove_all(root_dir / 'del')
	end
	fs.create_directories(output_dir)

	-- 解压地图
	local map = mpq_open(input_path)
	if not map then
		print('地图打开失败')
		return
	end

	local success, failed = 0, 0
	for name in pairs(map) do
		local path = output_dir / name
		local dir = path:parent_path()
		fs.create_directories(dir)
		if map:extract(name, path) then
			success = success + 1
		else
			failed = failed + 1
			print('文件导出失败', name)
		end
	end

	print('成功:', success, '失败:', failed, '用时:', os.clock())
end

main()
