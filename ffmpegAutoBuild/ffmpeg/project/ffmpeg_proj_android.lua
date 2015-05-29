--[[
描述:		ffmpeg 生成android工程模块
作者:		weiny zhou
创建日期:	2012-07-05
修改日期:	2012-07-05
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--

function create_ffmpeg_android_project(szFileName,projName,tblfile,includes)
	local vcProjinc="LOCAL_C_INCLUDES += \\\n";
	for index,value in pairs(includes) do
		vcProjinc=vcProjinc..value.." \\\n";
	end
	
	local szHead,szEnd=android_create_mk(szFileName,projName,vcProjinc,"-DHAVE_CONFIG_H=1 -DANDROID=1 -D__LINUX__=1","");
	local filetext="\nLOCAL_SRC_FILES := \\\n";
	for index,value in pairs(tblfile) do
		if value~=nil then
			local text="";
			for fileindex,filevalue in pairs(value) do
				text=text..create_ffmpeg_android_add_file(filevalue,includes);
			end
			filetext=filetext..text;	
		end
	end
	filetext=szHead.."\n"..filetext.."\n"..vcProjinc.."\n"..szEnd;
	local file=io.open(szFileName,"w");
	file:write(filetext);
	file:close();
	return ;
end

function create_ffmpeg_android_add_file(filename,includes)
	local szExt=getFileExt(filename);
	
	if szExt=="h" then--如果是头文件则忽略
		return "";
	end
	if szExt=="c" or szExt=="asm" or szExt=="S" then
		return " "..filename.." \\\n";
	end;
	return "";
end