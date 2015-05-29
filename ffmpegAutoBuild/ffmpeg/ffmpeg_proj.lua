--[[
描述:		ffmpeg 生成工程模块
作者:		weiny zhou
创建日期:	2012-04-29
修改日期:	2012-04-29
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--

dofile(szffmpegPath.."/project/ffmpeg_proj_vc"..luaExt);
dofile(szffmpegPath.."/project/ffmpeg_proj_android"..luaExt);
dofile(szffmpegPath.."/project/ffmpeg_proj_ios"..luaExt);
dofile(szffmpegPath.."/project/ffmpeg_proj_makefile"..luaExt);

--[[
函数:create_ffmpeg_project
功能:创建 工程文件
参数:
返回:
]]--
function create_ffmpeg_project(szFilePath,projName,tblfile,proType,includes,useClang)
	local szFileName=szFilePath;
	if proType==project_type.vc then--生成windows工程
		szFileName=szFileName..".vcproj";
		return create_ffmpeg_vc_project(szFileName,projName,tblfile,includes,useClang);
	elseif proType==project_type.android then--生成android工程
		szFileName=szFileName..".mk";
		return create_ffmpeg_android_project(szFileName,projName,tblfile,includes);
	elseif proType==project_type.ios then--生成ios工程
		szFileName=szFileName..".sh";
		return create_ffmpeg_ios_project(szFileName,projName,tblfile,includes);
	elseif proType==project_type.makefile then--生成makefile工程
		szFileName=szFileName..".sh";
		return create_ffmpeg_makefile_project(szFileName,projName,tblfile,includes);
	end
end

