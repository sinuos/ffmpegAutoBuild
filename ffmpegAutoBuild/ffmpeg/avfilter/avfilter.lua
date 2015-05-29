--[[
描述:		ffmpeg avfilter 解析模块
作者:		weiny zhou
创建日期:	2012-04-30
修改日期:	2012-04-30
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--


--[[
函数:avfilter_parser_allfile
功能:avfilter 处理函数
参数:
返回:
]]--
function avfilter_parser_allfile(szPath,includes,proType,isToc89,useClang)
	local filename="Makefile";
	local projName="libavfilter";
	local makefiletabl={
		{name="",path="",file=filename,tbl=nil},
		{name="_x86",path="x86/",file=filename,tbl=nil}
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
				avfilter_file_Replace_c99_to_c98(szPath..value.path,avcodectbl);
			end;
		end
	end
	return ;
end

function avfilter_file_Replace_c99_to_c98(szFilePath,avcodectbl)
	local avcodec_list_tbl=avfilter_struct_avfilter_get_table();
	--创建table表
	for index,value in pairs(avcodec_list_tbl) do
		if not value.func then
			avcodec_list_tbl[index].tbl=avfilter_struct_avfilter_default(szFilePath..value.file,value.name);
		else
			avcodec_list_tbl[index].tbl=avfilter_struct_avfilter_default(szFilePath..value.file,value.name);
			avcodec_list_tbl[index].func=value.func;
		end;
	end
	for index,value in pairs(avcodectbl) do
		if value~=nil then
			for fileindex,filename in pairs(value) do
				for list_index,list_value in pairs(avcodec_list_tbl) do
					print("dispose file=",filename,"struct=",list_value.name);
					if not list_value.func then
						avfilter_struct_avfilter_Repalce(filename,list_value.tbl,list_value.name);
					else
						list_value.func(filename,list_value.tbl,list_value.name);--指定处理函数
					end	
					print("dispose file=",filename,"struct=",list_value.name,"end");			
				end
			end
		end
	end
end