--[[
描述:		ffmpeg 解析模块
作者:		weiny zhou
创建日期:	2012-04-30
修改日期:	2012-04-30
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--

--[[
函数:ffmpeg_insert_include
功能:ffmpeg 添加include
参数:
返回:
]]--
function ffmpeg_insert_include(szFilePath,tblFilelist)
	local avcodectbl={};
	local filedefine={};
	for index,value in pairs(tblFilelist) do
		local name,define=dispose_name_define(index);
		--print("define=",define,"index=",index);
		if(type(value)=="table") then
			for itemIndex,itemValue in pairs(value) do
				local szFilename=szFilePath..itemValue;
				
				szFilename=ffmpeg_insert_include_dispose(szFilename);
				if szFilename~=nil and define==nil then
					define=1;
				end
				if szFilename~=nil and define~=nil then
					if filedefine[szFilename]==nil then
						if avcodectbl.name==nil then
							avcodectbl.name={};					
						end
						table.insert(avcodectbl.name,szFilename);
					end
					if filedefine[szFilename]==nil then
						filedefine[szFilename]={};				
					end
					table.insert(filedefine[szFilename],define);
				else
					print("ffmpeg_insert_include table filename is nil",szFilename,define);
				end
			end
		elseif value==nil then
			print("ffmpeg_insert_include index=",index," is nil");
		else
			local szFilename=szFilePath..value;
			szFilename=ffmpeg_insert_include_dispose(szFilename);
			if szFilename~=nil and define~=nil then
				if filedefine[szFilename]==nil then
					if avcodectbl.name==nil then
							avcodectbl.name={};					
					end
					table.insert(avcodectbl.name,szFilename);
				end
				if filedefine[szFilename]==nil then
						filedefine[szFilename]={};				
				end
				table.insert(filedefine[szFilename],define);
			end
		end
	end
	return avcodectbl,filedefine;
end
function dispose_name_define(indexName)
	indexName=trim(indexName);
	local nPos=string.find(indexName,"%-%$%(");
	if nPos==nil then
		return 	indexName;
	end
	local name=string.sub(indexName,1,nPos-1);
	local define=string.sub(indexName,nPos+string.len("-$("),string.len(indexName)-1);
	nPos=string.find(define,"%)");
	if nPos~=nil then
		define=string.sub(define,1,nPos-1);
	end
	return name,define;
end
--[[
函数:ffmpeg_insert_include_dispose
功能:ffmpeg 添加include处理函数
参数:
返回:
]]--
function ffmpeg_insert_include_dispose(szFilename)
	if string.sub(szFilename,1,1)=="$" then
		print("this input is not a filename",szFilename);
		return ;
	end
	if not (IS_INSERT_INCLUDE) then
		print("IS_INSERT_INCLUDE=false");
	end;
	local ext=getFileExt(szFilename);
	if ext==nil then
		print("ffmpeg_insert_include_dispose ext is nil,",szFilename);
		return ;
	elseif ext=="h" then
		print("ffmpeg_insert_include_dispose ext is header file,",szFilename);
		return ;
	end
	local szTmp=getFileRemoveExt(szFilename);
	local szCFile=szTmp..".c";
	local szSFile=szTmp..".S";
	local szAsmFile=szTmp..".asm";
	if isExist(szCFile) then
		if  (IS_INSERT_INCLUDE) then
			ffmpeg_insert_include_c_dispose(szCFile);
		end;
		return szCFile;
	elseif isExist(szSFile) then
		if  (IS_INSERT_INCLUDE) then
			ffmpeg_insert_include_S_dispose(szSFile);
		end;
		return szSFile;
	elseif isExist(szAsmFile) then
		if  (IS_INSERT_INCLUDE) then
			ffmpeg_insert_include_asm_dispose(szAsmFile);
		end;
		return szAsmFile;
	end
	print("ffmpeg_insert_include_dispose any file is not exist,",szFilename);
	return ;
end
--[[
函数:ffmpeg_insert_include_c_dispose
功能:ffmpeg c添加include处理函数
参数:
返回:
]]--
function ffmpeg_insert_include_c_dispose(szFileName)
	--print("dispose file=",szFileName);
	local file=io.open(szFileName,"r");
	if file==nil then
		print("ffmpeg_insert_include_c_dispose open file error.",szFileName);	
		return;
	end
	local szFileText=file:read("*a");
	file:close();file=nil;
	local nBegin=0;
	local nEnd=0;
	if string.sub(szFileText,1,2)=="/*" then
		nBegin=0;
		nEnd=string.find(szFileText,"*/");
		if nEnd~=nil then
			nEnd=nEnd+string.len("*/")+1;		
		end
	end
	local szWriteText=nil;
	local defConfig="#ifdef HAVE_CONFIG_H";
	local inserttext=defConfig.."\n".."#include \"config.h\"".."\n".."#endif\n";
	
	if  nEnd==nil or nBegin==nil then
		
		if string.find(szFileText,defConfig)==nil then--判断是否写入过
			szWriteText=inserttext..szFileText;
		else
			--print("this file old time write.",szFileName);
			return 0;
		end
	else
		if string.find(szFileText,defConfig)==nil then--判断是否写入过
			szWriteText=string.sub(szFileText,1,nEnd-1)..inserttext..string.sub(szFileText,nEnd);
		else
			--print("this file old time write.",szFileName);
			return 0;
		end
	end
	file=io.open(szFileName,"w");
	if (file==nil) then
		print("ffmpeg_insert_include_c_dispose write file error.",szFileName);
		return ;
	end
	file:write(szWriteText);
	file:close();
	print("dispose successed file=",szFileName);
	return 0;
		
end
function ffmpeg_insert_include_asm_dispose(szFileName)
	--print("dispose file=",szFileName);
	local file=io.open(szFileName,"r");
	if file==nil then
		print("ffmpeg_insert_include_c_dispose open file error.",szFileName);	
		return;
	end
	local szFileText="";
	local nextLine="";
	for line in file:lines() do
		if string.sub(line,1,1)~=";" then
			nextLine=line.."\n";
			break;
		end
		szFileText=szFileText..line.."\n";
	end
	local lastText=file:read("*a");--余下所有内容
	file:close();file=nil;
	local nBegin=0;
	local nEnd=0;
	
	local szWriteText=nil;
	local defConfig="%ifdef HAVE_CONFIG_H";
	local inserttext=defConfig.."\n".."%include \"config.asm\"".."\n".."%endif\n";
	--local findtext="%%ifdef HAVE_CONFIG_H".."\n".."%%include \"config.asm\"".."\n".."%%endif\n";
	
	if string.find(lastText,"%"..defConfig)==nil then
			szWriteText=szFileText.."\n"..inserttext..nextLine..lastText;
	else
			--print("this file old time write.",szFileName);
			return 0;
	end
	
	file=io.open(szFileName,"w");
	if (file==nil) then
		print("ffmpeg_insert_include_c_dispose write file error.",szFileName);
		return ;
	end
	file:write(szWriteText);
	file:close();
	print("dispose successed file=",szFileName);
	return 0;
end
function ffmpeg_insert_include_S_dispose(szFileName)
	return ffmpeg_insert_include_c_dispose(szFileName);
end
--[[
函数:ffmpeg_insert_define
功能:插入宏定义
参数:
返回:
]]--
function ffmpeg_insert_define(deftbl)
	if not (IS_INSERT_DEFINE) then
		print("IS_INSERT_DEFINE=false");
		return ;
	end;

	for index,value in pairs(deftbl) do
		local ext=getFileExt(index);
		if ext=="c" then
			ffmpeg_insert_c_define(index,value);
		elseif ext=="asm" then
			ffmpeg_insert_asm_define(index,value);
		elseif ext=="S" then		
			ffmpeg_insert_S_define(index,value);
		else
			print("avcodec_insert_define file is error",index);
		end
	end
	
end
function ffmpeg_insert_c_define(szFileName,deflist)
	local flagtext="#ifdef HAVE_CONFIG_H".."\n".."#include \"config%.h\"".."\n".."#endif\n";
	local modifyFlag="\n#endif\n/* this file weiny zhou lua script build*/";
	local file=io.open(szFileName,"r");
	local szFileText=file:read("*a");
	file:close();
	--判断是否已修改
	
	if  string.sub(szFileText,string.len(szFileText)-string.len(modifyFlag)+1)==modifyFlag then
		print("ffmpeg_insert_c_define this file old time write.",szFileName);return;
	end
	local nPos=string.find(szFileText,flagtext);
	if nPos==nil then
		print("file is error",szFileName);return;
	end
	nPos=nPos+string.len(flagtext)-1;--减掉转义字符
	local definetext=nil;
	for index,value in pairs(deflist) do
		if definetext==nil then
			definetext="#if "..trim(value);
		else
			definetext=definetext.."||\\\n"..value;
		end
	end
	if definetext==nil then
		--print("defiletext is nil,this file not add.",szFileName);
		return ;
	end
	local szWriteText=string.sub(szFileText,1,nPos-1).."\n"..definetext.."\n"..string.sub(szFileText,nPos)..modifyFlag;
	file=io.open(szFileName,"w");
	if (file==nil) then
		print("ffmpeg_insert_include_c_dispose write file error.",szFileName);
		return ;
	end
	file:write(szWriteText);
	file:close();
end

function ffmpeg_insert_asm_define(szFileName,deflist)
	local flagtext="%%ifdef HAVE_CONFIG_H".."\n".."%%include \"config%.asm\"".."\n".."%%endif\n";
	local modifyFlag="\n%endif\n;/* this file weiny zhou lua script build*/";
	local file=io.open(szFileName,"r");
	local szFileText=file:read("*a");
	file:close();
	--判断是否已修改
	if string.sub(szFileText,string.len(szFileText)-string.len(modifyFlag)+1) ==modifyFlag then
		print("ffmpeg_insert_c_define this file old time write.",szFileName);return;
	end
	local nPos=string.find(szFileText,flagtext);
	if nPos==nil then
		print("file is error",szFileName);return;
	end
	nPos=nPos+string.len(flagtext)-4;--减掉转义字符
	local definetext=nil;
	for index,value in pairs(deflist) do
		if definetext==nil then
			definetext="%ifdef "..value;
		else
			definetext=definetext.."||\\\n"..value;
		end
	end
	if definetext==nil then
		--print("defiletext is nil,this file not add.",szFileName);
		return ;
	end
	local szWriteText=string.sub(szFileText,1,nPos-1)..definetext.."\n"..string.sub(szFileText,nPos)..modifyFlag;
	file=io.open(szFileName,"w");
	if (file==nil) then
		print("ffmpeg_insert_include_c_dispose write file error.",szFileName);
		return ;
	end
	file:write(szWriteText);
	file:close();
end
function ffmpeg_insert_S_define(szFileName,deflist)
	return ffmpeg_insert_c_define(szFileName,deflist);
end