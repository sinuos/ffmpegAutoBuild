--[[
描述:		ffmpeg 生成VC工程模块
作者:		weiny zhou
创建日期:	2012-07-05
修改日期:	2012-07-05
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--

function create_ffmpeg_vc_project(szFileName,projName,tblfile,includes,useClang)
	local vcProjinc;
	for index,value in pairs(includes) do
		if vcProjinc==nil then
			vcProjinc=value;
		else		
			vcProjinc=vcProjinc..";"..value
		end
	end
	GUIDIndex=1001
	local szGUID="93995380-89BD-4b04-88EB-625FBE52";--93995380-89BD-4b04-88EB-625FBE52EBFB
	local szHead,szEnd=vc_create_2008_vcproj(szFileName,projName,vcProjinc,";inline=__inline","");
	local filetext="\n";
	for index,value in pairs(tblfile) do
		if value~=nil then
			local text="<Filter Name=\""..index.."\" Filter=\"\" "
			.."UniqueIdentifier=\"{"..szGUID..tostring(GUIDIndex) .."}\" >\n";
			for fileindex,filevalue in pairs(value) do
				text=text..create_ffmpeg_vc_add_file(filevalue,includes,useClang).."\n";
			end
			text=text.."</Filter>\n";
			filetext=filetext..text;	
		end
	end
	filetext=szHead..filetext..szEnd;
	GUIDIndex=GUIDIndex+1;--GUIDIndex递增
	local file=io.open(szFileName,"w");
	file:write(filetext);
	file:close();
	return ;
end
function create_ffmpeg_vc_add_file(filename,includes,useClang)
	local szExt=getFileExt(filename);
	local adddepen=""--Assembly $(InputPath)";
	--local outputs="$(IntDir)/$(InputName).obj";
	local yasmincludes="";
	for index,value in pairs(includes) do
		yasmincludes=yasmincludes.." -I"..value.." ";
	end
	--使用Clang编译
	if szExt=="c" and (useClang)then
		return "<File RelativePath=\""..filename.."\"\n>\n"
		.."<FileConfiguration Name=\"Debug|Win32\"> <Tool Name=\"VCCustomBuildTool\" "
		.."Description=\""..gcc.print.."\"\n"
		.."CommandLine=\""..gcc.build.debug.buildHead..yasmincludes..gcc.build.debug.buildFoot.."\"\nAdditionalDependencies=\""..adddepen.."\" \n"
		.."Outputs=\""..gcc.target.."\"/>\n</FileConfiguration>\n"
		.."<FileConfiguration Name=\"Release|Win32\"> <Tool Name=\"VCCustomBuildTool\" "
		.."Description=\""..gcc.print.."\"\n"
		.."CommandLine=\""..gcc.build.release.buildHead..yasmincludes..gcc.build.release.buildFoot.."\"\nAdditionalDependencies=\""..adddepen.."\" \n"
		.."Outputs=\""..gcc.target.."\"/>\n</FileConfiguration>\n"
		.."</File>";
	elseif szExt=="c" or szExt=="h" then
		return "<File RelativePath=\""..filename.."\"\n>\n</File>\n";
	elseif szExt=="asm" then
		return "<File RelativePath=\""..filename.."\"\n>\n"
		.."<FileConfiguration Name=\"Debug|Win32\"> <Tool Name=\"VCCustomBuildTool\" "
		.."Description=\""..yasm.print.."\"\n"
		.."CommandLine=\""..yasm.build.debug.buildHead..yasmincludes..yasm.build.debug.buildFoot.."\"\nAdditionalDependencies=\""..adddepen.."\" \n"
		.."Outputs=\""..yasm.target.."\"/>\n</FileConfiguration>\n"
		.."<FileConfiguration Name=\"Release|Win32\"> <Tool Name=\"VCCustomBuildTool\" "
		.."Description=\""..yasm.print.."\"\n"
		.."CommandLine=\""..yasm.build.release.buildHead..yasmincludes..yasm.build.release.buildFoot.."\"\nAdditionalDependencies=\""..adddepen.."\" \n"
		.."Outputs=\""..yasm.target.."\"/>\n</FileConfiguration>\n"
		.."</File>";
	elseif szExt=="S" then
		return "<File RelativePath=\""..filename.."\"\n>\n"
		.."<FileConfiguration Name=\"Debug|Win32\"> <Tool Name=\"VCCustomBuildTool\" "
		.."Description=\""..yasm.print.."\"\n"
		.."CommandLine=\""..yasm.build.debug.buildHead..yasmincludes..yasm.build.debug.buildFoot.."\"\nAdditionalDependencies=\""..adddepen.."\" \n"
		.."Outputs=\""..yasm.target.."\"/>\n"
		.."<FileConfiguration Name=\"Release|Win32\"> <Tool Name=\"VCCustomBuildTool\" "
		.."Description=\""..yasm.print.."\"\n"
		.."CommandLine=\""..yasm.build.release.buildHead..yasmincludes..yasm.build.release.buildFoot.."\"\nAdditionalDependencies=\""..adddepen.."\" \n"
		.."Outputs=\""..yasm.target.."\"/>\n"
		.."</File>";
	end
	return "";
end