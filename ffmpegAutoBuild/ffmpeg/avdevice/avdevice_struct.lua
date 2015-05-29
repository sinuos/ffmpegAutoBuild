--[[
描述:		lua avdevice struct处理模块
作者:		weiny zhou
创建日期:	2012-05-02
修改日期:	2012-05-02
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--

--[[
函数:avdevice_struct_avdevice_get_table
功能:返回所有需要解析结构体列表
参数:
返回:table
]]--
function avdevice_struct_avdevice_get_table()
	local tbl={
	{name="AVClass",file="../libavutil/log.h"},
	{name="AVOutputFormat",file="../libavformat/avformat.h"},
	{name="AVInputFormat",file="../libavformat/avformat.h"}
	};
	return tbl;
end
--[[
函数:avdevice_struct_avdevice_default
功能:读取结构体定义信息
参数:
返回:table
]]--
function avdevice_struct_avdevice_default(szFileName,szStruct)
	local szStructText=ffmpeg_get_struct(szFileName,szStruct);
	if szStructText==nil then
		print("file=",szFileName,",can't not find typedef struct"..szStruct);
		return ;
	end
	szStructText=ffmpeg_remove_c_struct_text_comment(szStructText);
	--print(szStructText);
	local avdevicetbl=ffmpeg_c_struct_to_lua_table(szStructText);
	print("dispose "..szStruct.." end.");
	return avdevice_struct_avdevice_set_default(avdevicetbl,szStruct);
end
--[[
函数:avdevice_struct_avdevice_set_default
功能:对avdevice结构体table付初值
参数:
返回:table
]]--
function avdevice_struct_avdevice_set_default(avdevicetbl,szStruct)
	if szStruct=="AVInputFormat" or szStruct=="AVOutputFormat" then
		for index,value in ipairs(avdevicetbl) do
			if value.name=="audio_codec" or value.name=="video_codec" or value.name=="subtitle_codec" then
				avdevicetbl[index].default="CODEC_ID_NONE";
			end
		end
	end;
	print("set "..szStruct.." default value end.");
	return avdevicetbl;
end
--[[
函数:avdevice_struct_avdevice_Repalce
功能:替换该文件中avdevice变量
参数:
返回:
]]--
function avdevice_struct_avdevice_Repalce(szFileName,avdevicetbl,szStruct)
	return ffmpeg_struct_var_Repalce(szFileName,avdevicetbl,szStruct);
end

