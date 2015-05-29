--[[
描述:		ffmpeg avcodec 解析模块
作者:		weiny zhou
创建日期:	2012-04-28
修改日期:	2012-04-29
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--



--[[
函数:avcodec_parser_allfile
功能:avcodec 处理函数
参数:
返回:
]]--
function avcodec_parser_allfile(szPath,includes,proType,isToc89,useClang)
	local filename="Makefile";
	local projName="libavcodec";
	local childincludes=includes;
	table.insert(childincludes,"../../")
	local makefiletabl={
		{name="",path="",file=filename,tbl=nil},
		{name="_x86",path="x86/",file=filename,tbl=nil},
		{name="_sparc",path="sparc/",file=filename,tbl=nil},
		{name="_sh4",path="sh4/",file=filename,tbl=nil},
		{name="_ppc",path="ppc/",file=filename,tbl=nil},
		{name="_mips",path="mips/",file=filename,tbl=nil},
		{name="_bfin",path="bfin/",file=filename,tbl=nil},
		{name="_avr32",path="avr32/",file=filename,tbl=nil},
		{name="_arm",path="arm/",file=filename,tbl=nil},
		{name="_alpha",path="alpha/",file=filename,tbl=nil}
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
			local tmpincludes=childincludes;
			if string.len(value.name)<2 then
				tmpincludes=includes;
			end
			create_ffmpeg_project(szProjPath,projName..value.name,avcodectbl,proType,tmpincludes,useClang);
			if isToc99 then
				avcodec_file_Replace_c99_to_c98(szPath..value.path,avcodectbl);
			end
		end;
	end
	if isToc99 then
		avcodec_file_array_Replace_c99_to_c98(szPath);
		avcodec_other_replace_c99_to_c89(szPath);
	end;
	return ;
end

function avcodec_file_Replace_c99_to_c98(szFilePath,avcodectbl)
	local avcodec_list_tbl=avcodec_struct_avcodec_get_table();
	--创建table表
	for index,value in pairs(avcodec_list_tbl) do
		if not value.func then
			avcodec_list_tbl[index].tbl=avcodec_struct_avcodec_default(szFilePath..value.file,value.name);
		else
			avcodec_list_tbl[index].func=value.func;
		end;
	end
	for index,value in pairs(avcodectbl) do
		if value~=nil then
			for fileindex,filename in pairs(value) do
				for list_index,list_value in pairs(avcodec_list_tbl) do
					print("dispose file=",filename,"struct=",list_value.name);
					if not list_value.func then
						avcodec_struct_avcodec_Repalce(filename,list_value.tbl,list_value.name);
					else
						list_value.func(filename);--指定处理函数
					end
					avoption_dispose(filename);--处理avoption
					print("dispose file=",filename,"struct=",list_value.name,"end");			
				end
			end
		end
	end
end
--[[
函数:avcodec_file_array_Replace_c99_to_c98
功能:替换数组
参数:
返回:
]]--
function avcodec_file_array_Replace_c99_to_c98(szFilePath)
	local avcodec_list_tbl=avcodec_struct_array_avcodec_get_table();
	--创建table表
	for index,value in pairs(avcodec_list_tbl) do
		avcodec_list_tbl[index].tbl=avcodec_struct_avcodec_default(szFilePath..value.file,value.name);
		ffmpeg_struct_array_var_Repalce(szFilePath..value.tar,avcodec_list_tbl[index].tbl,value.name);
	end
end
function avcodec_other_replace_c99_to_c89(szFilePath)
	amr_array_not_const_value_file_dispose(szFilePath.."amrwbdata.h","amrwbdatafunc");
	amr_array_not_const_value_file_dispose(szFilePath.."amrnbdata.h","amrnbdatafunc");
	local replacetbl={
	{src="ass_split.h",tar="srtenc.c",struct="ASSCodesCallbacks"},
	{src="g729dec.c",tar="g729dec.c",struct="G729FormatDescription"}
	}
	for index,value in ipairs(replacetbl) do
		local avcodectbl=avcodec_struct_avcodec_default(szFilePath..value.src,value.struct);
		avcodec_struct_avcodec_Repalce(szFilePath..value.tar,avcodectbl,value.struct);--个别类型特殊处理
	end;
	ffmpeg_const_struct_dispose_and_replace(szFilePath.."twinvq_data.h");--处理常量结构体
	
	local enumtbl=ffmpeg_enum_dispose(szFilePath.."sipr.h","SiprMode");
	local typedef=avutil_struct_avutil_default(szFilePath.."sipr.c","SiprModeParam");
	if enumtbl and typedef then
		ffmpeg_struct_array_ex_enum_dispose(szFilePath.."sipr.c","SiprModeParam",typedef,enumtbl);
	end
	local tbl=avcodec_struct_avcodec_default(szFilePath.."ass_split.c","ASSSection");
	ffmpeg_struct_array_var_Repalce(szFilePath.."ass_split.c",tbl,"ASSSection");
end