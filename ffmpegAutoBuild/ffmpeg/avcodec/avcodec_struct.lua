--[[
描述:		lua avcodec struct处理模块
作者:		weiny zhou
创建日期:	2012-05-01
修改日期:	2012-05-08
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--
--[[
修改:
	添加avcodec_struct_array_avcodec_get_table函数
]]--

--[[
函数:avcodec_struct_avcodec_get_table
功能:返回所有需要解析结构体列表
参数:
返回:table
]]--
function avcodec_struct_avcodec_get_table()
	local tbl={
	{name="AVCodec",file="avcodec.h"},
	{name="AVClass",file="../libavutil/log.h"},
	{name="AVCodecParser",file="avcodec.h"},
	{name="AVBitStreamFilter",file="avcodec.h"},
	{name="DVprofile",file="dvdata.h"},
	{name="AVOption",file="../libavutil/opt.h",func=avoption_dispose}
	};
	return tbl;
end
function avcodec_struct_array_avcodec_get_table()
	local tbl={
		{name="DVprofile",file="dvdata.h",tar="dvdata.c"},
		{name="SiprModeParam",file="sipr.c",tar="sipr.c"}
	};
	return tbl;
end
--[[
函数:avcodec_struct_avcodec_default
功能:读取结构体定义信息
参数:
返回:table
]]--
function avcodec_struct_avcodec_default(szFileName,szStruct)
	
	local szStructText=ffmpeg_get_struct(szFileName,szStruct);
	if szStructText==nil then
		print("file=",szFileName,",can't not find typedef struct"..szStruct);
		return ;
	end
	szStructText=ffmpeg_remove_c_struct_text_comment(szStructText);
	szStructText=ffmpeg_remove_null_line(szStructText);
	--print(szStructText);
	local avcodectbl=ffmpeg_c_struct_to_lua_table(szStructText);
	print("dispose "..szStruct.." end.");
	return avcodec_struct_avcodec_set_default(avcodectbl,szStruct);
end
--[[
函数:avcodec_struct_avcodec_set_default
功能:对avcodec结构体table付初值
参数:
返回:table
]]--
function avcodec_struct_avcodec_set_default(avcodectbl,szStruct)
	if szStruct=="AVCodec" then
		for index,value in ipairs(avcodectbl) do
			if value.name=="type" then
				--value.default=
				avcodectbl[index].default="AVMEDIA_TYPE_UNKNOWN";
			elseif value.name=="id" then
				avcodectbl[index].default="CODEC_ID_NONE";
			end
		end
	end;
	print("set "..szStruct.." default value end.");
	return avcodectbl;
end
--[[
函数:avcodec_struct_avcodec_Repalce
功能:替换该文件中avcodec变量
参数:
返回:
]]--
function avcodec_struct_avcodec_Repalce(szFileName,avcodectbl,szStruct)
	return ffmpeg_struct_var_Repalce(szFileName,avcodectbl,szStruct);
end
