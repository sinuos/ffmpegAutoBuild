--[[
描述:		main 主执行模块
作者:		weiny zhou
创建日期:	2012-04-30
修改日期:	2012-04-30
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--
PROJECT_TYPE=3;--项目类型

curPath="E:/WeinyDesign/WeinyCore/ffmpegAutoBuild/";
luaExt=".lua";
local ffmpegProjPath="C:/Users/Weiny/Desktop/ffmpeg/";
local unixDir="&quot;$(WZLINUX_INC)&quot;";
VCIncDir="&quot;$(VCInstallDir)include&quot;";

CLANG_RESOURCE_DIRS="D:/llvm/build/bin/MinSizeRel/../lib/clang/3.1";
CLANG_CACHE_PATH="C:\\Users\\Weiny\\AppData\\Local\\Temp\\clang-module-cache"

IS_INSERT_INCLUDE=false;--是否插入include config.h
IS_INSERT_DEFINE=false;--是否插入宏定义

dofile(curPath.."parser"..luaExt);
--[[
函数:run_vc
功能:生成VC编译工程
参数:
返回:
]]--
function run_vc(isConvC99,useClang)
	run_ffmpeg(project_type.vc,ffmpegProjPath,isConvC99,useClang);
print("\n\n\n\n**************************华丽的分割线******************");
print("*                                                         *");
print("*                     生成VC工程项目成功                  *")
print("*                                                         *");
print("*                                                         *");
print("***********************************************************");
end

--[[
函数:run_android
功能:生成android编译工程
参数:
返回:
]]--
function run_android()
	run_ffmpeg(project_type.android,ffmpegProjPath);
	print("\n\n\n\n**************************华丽的分割线******************");
	print("*                                                         *");
	print("*                     生成android工程项目成功             *")
	print("*                                                         *");
	print("*                                                         *");
	print("***********************************************************");
end
function run()
	if (PROJECT_TYPE==1) then
		run_vc(true,false);
	elseif (PROJECT_TYPE==2) then
		run_vc(false,true);
	elseif (PROJECT_TYPE==3) then
		run_android();
	end;
	
end
function run_ffmpeg(protype,szPath,isConvC99,useClang)
	--avcodec_parser_allfile(szPath,includes,protype);
	--avdevice_parser_allfile(szPath,includes,protype);
	local includes={"./","../","../"};
	local ffmpegtbl={
	{name="libavcodec",func=avcodec_parser_allfile},
	{name="libavdevice",func=avdevice_parser_allfile},
	{name="libavfilter",func=avfilter_parser_allfile},
	{name="libavformat",func=avformat_parser_allfile},
	{name="libavresample",func=avresample_parser_allfile},
	{name="libavutil",func=avutil_parser_allfile},
	{name="libpostproc",func=postproc_parser_allfile},
	{name="libswresample",func=swresample_parser_allfile},
	{name="libswscale",func=swscale_parser_allfile}
	};
	local isToc89=false;
	if protype==project_type.vc then
		if(isConvC99==nil or isConvC99==true) then
			isToc89=true;
		end;
		table.insert(includes,unixDir);
		table.insert(includes,"&quot;$(SolutionDir)../..&quot;");
		table.insert(includes,"&quot;$(WSYSEX_INC)/zlib&quot;");
		table.insert(includes,VCIncDir);
	elseif protype==project_type.android then
		table.insert(includes,"$(JNI_H_INCLUDE)");
		table.insert(includes,"$(CUR_PATH)");
		table.insert(includes,"$(LOCAL_PATH)");
	end
	for index,value in pairs(ffmpegtbl) do
		print("begin dispose",value.name)
		value.func(szPath..value.name.."/",includes,protype,isToc89,useClang);
		print("end dispose",value.name)
	end
	run_successed();
	
end
function run_successed()
	print("\n\n*********************************");
	print("*\t恭喜转换结束\t*");
	print("*\t尽情享受ffmpeg工具转VC带来的喜悦感吧.\t*");
	print("\n\n*********************************");
end

run();

--[[
local szFilePath="F:/ffmpeg-0.8.11/libavcodec/"


if false then
local tbl=avcodec_struct_avcodec_default(szFilePath.."avcodec.h","AVCodec");
avcodec_struct_avcodec_Repalce(szFilePath.."pngenc.c",tbl,"AVCodec");
else
local tbl=avcodec_struct_avcodec_default(szFilePath.."ass_split.c","ASSSection");
ffmpeg_struct_array_var_Repalce(szFilePath.."ass_split.c",tbl,"ASSSection");
end
]]--