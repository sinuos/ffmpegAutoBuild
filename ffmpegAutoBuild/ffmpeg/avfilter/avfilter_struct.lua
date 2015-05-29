--[[
描述:		lua avfilter struct处理模块
作者:		weiny zhou
创建日期:	2012-05-02
修改日期:	2012-05-02
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--

--[[
函数:avfilter_struct_avfilter_get_table
功能:返回所有需要解析结构体列表
参数:
返回:table
]]--
function avfilter_struct_avfilter_get_table()
	local tbl={
	{name="AVFilter",file="avfilter.h"},
	{name="AVFilterPad",file="avfilter.h",func=ffmpeg_struct_array_var_Repalce}
	};
	return tbl;
end
--[[
函数:avfilter_struct_avfilter_default
功能:读取结构体定义信息
参数:
返回:table
]]--
function avfilter_struct_avfilter_default(szFileName,szStruct)
	local szStructText=ffmpeg_get_struct(szFileName,szStruct);
	if szStructText==nil then
		print("file=",szFileName,",can't not find typedef struct"..szStruct);
		return ;
	end
	szStructText=ffmpeg_remove_c_struct_text_comment(szStructText);
	print(szStructText);
	local avfiltertbl=ffmpeg_c_struct_to_lua_table(szStructText);
	print("dispose "..szStruct.." end.");
	return avfilter_struct_avfilter_set_default(avfiltertbl,szStruct);
end
--[[
函数:avfilter_struct_avfilter_set_default
功能:对avfilter结构体table付初值
参数:
返回:table
]]--
function avfilter_struct_avfilter_set_default(avfiltertbl,szStruct)
	
	print("set "..szStruct.." default value end.");
	return avfiltertbl;
end
--[[
函数:avfilter_struct_avfilter_Repalce
功能:替换该文件中avfilter变量
参数:
返回:
]]--
function avfilter_struct_avfilter_Repalce(szFileName,avfiltertbl,szStruct)
	return ffmpeg_struct_var_Repalce(szFileName,avfiltertbl,szStruct);
end

