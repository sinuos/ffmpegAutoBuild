--[[
描述:		lua avformat struct处理模块
作者:		weiny zhou
创建日期:	2012-05-02
修改日期:	2012-05-02
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--

--[[
函数:avformat_struct_avformat_get_table
功能:返回所有需要解析结构体列表
参数:
返回:table
]]--
function avformat_struct_avformat_get_table()
	local tbl={
	{name="URLProtocol",file="avio.h"},
	{name="AVClass",file="../libavutil/log.h"},
	{name="AVOutputFormat",file="avformat.h"},
	{name="AVInputFormat",file="avformat.h"},
	{name="RTPDynamicProtocolHandler_s",file="rtpdec.h"},
	{name="ogg_codec",file="oggdec.h"}
	};
	return tbl;
end
--[[
函数:avformat_struct_avformat_default
功能:读取结构体定义信息
参数:
返回:table
]]--
function avformat_struct_avformat_default(szFileName,szStruct)
	local szStructText=ffmpeg_get_struct(szFileName,szStruct);
	if szStructText==nil then
		print("file=",szFileName,",can't not find typedef struct"..szStruct);
		return ;
	end
	szStructText=ffmpeg_remove_c_struct_text_comment(szStructText);
	--print(szStructText);
	local avformattbl=ffmpeg_c_struct_to_lua_table(szStructText);
	print("dispose "..szStruct.." end.");
	return avformat_struct_avformat_set_default(avformattbl,szStruct);
end
--[[
函数:avformat_struct_avformat_set_default
功能:对avformat结构体table付初值
参数:
返回:table
]]--
function avformat_struct_avformat_set_default(avformattbl,szStruct)
	if szStruct=="AVInputFormat" or szStruct=="AVOutputFormat"then
		for index,value in ipairs(avformattbl) do
			if value.name=="audio_codec" or value.name=="video_codec" or value.name=="subtitle_codec" then
				avformattbl[index].default="CODEC_ID_NONE";
			end
		end
	end;
	print("set "..szStruct.." default value end.");
	return avformattbl;
end
--[[
函数:avformat_struct_avformat_Repalce
功能:替换该文件中avformat变量
参数:
返回:
]]--
function avformat_struct_avformat_Repalce(szFileName,avcodectbl,szStruct)
	print("avformat_struct_avformat_Repalce file=",szFileName,"struct=",szStruct);
	return ffmpeg_struct_var_Repalce(szFileName,avcodectbl,szStruct);
end

