--[[
描述:		ffmpeg avformat 解析模块
作者:		weiny zhou
创建日期:	2012-04-30
修改日期:	2012-04-30
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--


--[[
函数:avformat_parser_allfile
功能:avformat 处理函数
参数:
返回:
]]--
function avformat_parser_allfile(szPath,includes,proType,isToc89,useClang)
	local filename="Makefile";
	local projName="libavformat";
	local makefiletabl={
		{name="",path="",file=filename,tbl=nil}
	};
	--生成table
	for index,value in ipairs(makefiletabl) do
		local szFileName=szPath..value.path..value.file;
		value.tbl=makefile_parser_to_table(szFileName);
		if(value.tbl~=nil) then
			local avcodectbl,filedefine=ffmpeg_insert_include(szPath,value.tbl);--在所有文件插入config.h包含头
			--插入define
			ffmpeg_insert_define(filedefine);
			--创建编译工程文件
			local szProjPath=szPath..value.path..projName..value.name;
			create_ffmpeg_project(szProjPath,projName,avcodectbl,proType,includes,useClang);
			if isToc89 then
				avformat_file_Replace_c99_to_c98(szPath..value.path,avcodectbl);
			end;
		end
	end
	if isToc89 then
		avformat_other_replace_c99_to_c89(szPath);
	end;
	return ;
end
function avformat_file_Replace_c99_to_c98(szFilePath,avcodectbl)
	local avcodec_list_tbl=avformat_struct_avformat_get_table();
	--创建table表
	for index,value in pairs(avcodec_list_tbl) do
		avcodec_list_tbl[index].tbl=avformat_struct_avformat_default(szFilePath..value.file,value.name);
	end
	for index,value in pairs(avcodectbl) do
		if value~=nil then
			for fileindex,filename in pairs(value) do
				for list_index,list_value in pairs(avcodec_list_tbl) do
					print("dispose file=",filename,"struct=",list_value.name);
					avformat_struct_avformat_Repalce(filename,list_value.tbl,list_value.name);
					avoption_dispose(filename);--处理avoption
					print("dispose file=",filename,"struct=",list_value.name,"end");			
				end
			end
		end
	end
end

function avformat_other_replace_c99_to_c89(szFilePath)
	local szFileName=szFilePath.."rawdec.h";
	local AVClasstbl=avformat_struct_avformat_default(szFilePath.."../libavutil/log.h","AVClass");
	local AVInputFormattbl=avformat_struct_avformat_default(szFilePath.."avformat.h","AVInputFormat");
	if AVClasstbl then
		avformat_struct_avformat_Repalce(szFileName,AVClasstbl,"AVClass");
	end;
	if AVInputFormattbl then
		avformat_struct_avformat_Repalce(szFileName,AVInputFormattbl,"AVInputFormat");
	end;
	local filelist={"rtpdec.c","rtpdec_amr.c","rtpdec_asf.c","rtpdec_g726.c","rtpdec_h263.c","rtpdec_h264.c",
	"rtpdec_latm.c","rtpdec_mpeg4.c","rtpdec_qcelp.c","rtpdec_qdm2.c","rtpdec_qt.c","rtpdec_svq3.c",
	"rtpdec_vp8.c","rtpdec_xiph.c","rdt.c"};
	local tbl=avformat_struct_avformat_default(szFilePath.."rtpdec.h","RTPDynamicProtocolHandler_s");
	if tbl then
		for index,value in pairs(filelist) do
			avformat_struct_avformat_Repalce(szFilePath..value,tbl,"RTPDynamicProtocolHandler");
		end
	end
end