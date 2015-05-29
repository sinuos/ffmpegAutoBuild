--[[
描述:		ffmpeg struct array处理模块
作者:		weiny zhou
创建日期:	2012-05-08
修改日期:	2012-05-08
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--


--[[
函数:ffmpeg_struct_array_get_var_text
功能:获取结构体变量
参数:szFileName=string
返回:string,int,int
]]--
function ffmpeg_struct_array_get_var_text(szText,varName,nPos)
	function ffmpeg_struct_get_var_text2(szText,varName,nPos)
		local nBegin,nEnd=string.find(szText,"%s-"..varName.."%s+[%w_ #]+%s-%[%s-[%d]-%]%s-=%s-%b{}",nPos);
		if nil~=nBegin then
			return string.sub(szText,nBegin+1,nEnd-1),nBegin,nEnd;--去掉后面的括号
		end;
		return nil;
	end
	local nBegin,nEnd=string.find(szText,"%s-"..varName.."%s+[%w_]+%s-%[%s-[%d]-%]%s-=%s-%b{}",nPos);
	if nil~=nBegin then
		return string.sub(szText,nBegin+1,nEnd-1),nBegin,nEnd;--去掉后面的括号
	end;
	
	return ffmpeg_struct_get_var_text2(szText,varName,nPos);
end
function ffmpeg_struct_array_var_Replace_Ex(szAvcodecVar,avcodectbl,szShortFile)
	local szFlags="%b{}";
	local nBegin,nEnd=string.find(szAvcodecVar,szFlags);
	local szRepalce,szAddArray;
	local nCount=0;
	while(nEnd~=nil) do
		local tmp=string.sub(szAvcodecVar,nBegin,nEnd);
		
		local tbl=ffmpeg_struct_get_var_to_table(tmp);--转换成表
		for index,value in pairs(tbl) do
			print("index=",index,"value=",value);
		end
		local newText;
		if tbl~=nil then
			local name=ffmpeg_struct_get_var_name(tmp);
			szRepalce,szAddArray=ffmpeg_struct_table_create_default_val(avcodectbl,tbl,false,name,szShortFile);--创建默认值
			szRepalce=" {\n"..szRepalce.."\n}";
			newText="\n"..szRepalce;
			nCount=nCount+1;
		end
		if newText~=nil then
			szAvcodecVar=string.sub(szAvcodecVar,1,nBegin-1)..newText..string.sub(szAvcodecVar,nEnd+1);--替换其中内容
		end
		nBegin,nEnd=string.find(szAvcodecVar,szFlags,nBegin+string.len(newText));
	end;
	if nCount==0 then
		return ;
	end;
	szAvcodecVar=" "..szAvcodecVar.."}";
	return szAvcodecVar;
end
--[[
函数:ffmpeg_struct_array_var_Repalce
功能:替换该文件中struct array变量
参数:
返回:
]]--
function ffmpeg_struct_array_var_Repalce(szFileName,avcodectbl,structName)
	local file=io.open(szFileName,"r");
	if(file==nil) then
		print("open file error",szFileName);
		return ;	
	end
	local szText=file:read("*a");
	file:close();
	file=nil;
	local nBegin,nEnd;
	local szAvcodecVar;
	local szShortFile=getFileShortName(szFileName);
	local nModifyCount=0;--查找需修改个数
	nEnd=1;
	
	szAvcodecVar,nBegin,nEnd=ffmpeg_struct_array_get_var_text(szText,structName,nEnd);
	--截取数据块
	while szAvcodecVar~=nil do
		local szRepalce,szAddArray;
		local newText=nil;
		szAvcodecVar=ffmpeg_remove_c_struct_text_comment(szAvcodecVar);--删除所有注释
		if (not ffmpeg_struct_var_is_has_define(szAvcodecVar))and
		(not ffmpeg_struct_var_in_define(szAvcodecVar)) then--处理不含有宏定义的文件
			newText=ffmpeg_struct_array_var_Replace_Ex(szAvcodecVar,avcodectbl,szShortFile);
		else
			print("this file in define.",szFileName);
		end;
		if newText~=nil then
			szText=string.sub(szText,1,nBegin-1)..newText..string.sub(szText,nEnd+1);--替换其中内容
		end
		if newText==nil then
			print("change var error,",szAvcodecVar);
			return ;
		end
		szAvcodecVar,nBegin,nEnd=ffmpeg_struct_array_get_var_text(szText,structName,nBegin+string.len(newText));
		nModifyCount=nModifyCount+1;
	end
	if nModifyCount==0 then
		print("file=",szFileName,"not var modify=",structName);
		return -1;
	end
	file=io.open(szFileName,"w");
	if (file==nil) then
		print("open file error,can't not write.",szFileName);
		return ;
	end
	file:write(szText);
	file:close();
	return 0;
end