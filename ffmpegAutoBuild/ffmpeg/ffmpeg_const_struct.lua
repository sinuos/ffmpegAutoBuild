--[[
描述:		ffmpeg const struct 处理模块
作者:		weiny zhou
创建日期:	2012-05-08
修改日期:	2012-05-08
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
声明:		此模块主要针对twinvq_data.h中的static const struct{}=name={};此格式的变量定义
]]--

--[[
函数:ffmpeg_const_struct_dispose_and_replace
功能:解析此格式static const struct{}=name={}内容，并且完成替换
参数:
返回:
]]--
function ffmpeg_const_struct_dispose_and_replace(szFileName)
	local file=io.open(szFileName,"r");
	if not file then
		print("open file error,file=",szFileName);
		return ;
	end
	local szText=file:read("*a");
	file:close();
	file=nil;
	local nBegin,nEnd;
	local szStructVar;
	local nModifyCount=0;
	local szShortFile=getFileShortName(szFileName);
	szStructVar,nBegin,nEnd=ffmpeg_const_struct_get_var_text(szText,1);
	while szStructVar~=nil do
		print("szStructVar=",szStructVar);
		local tmp=ffmpeg_const_struct_dispose_and_replaceEx(szStructVar,szShortFile);
		
		if tmp~=nil then
			szText=string.sub(szText,1,nBegin-1)..tmp..string.sub(szText,nEnd+1);
			nModifyCount=nModifyCount+1;
		end
		szStructVar,nBegin,nEnd=ffmpeg_const_struct_get_var_text(szText,nBegin+string.len(tmp));
	end
	if nModifyCount==0 then
		print("ffmpeg_const_struct_dispose_and_replace,this file not modify",szFileName);
		return ;
	end
	file=io.open(szFileName,"w");
	file:write(szText);
	file:close();
	return 0;
end
function ffmpeg_const_struct_get_struct_def(szStructVar)
	local nBegin,nEnd=string.find(szStructVar,"%b{}");
	local szTypedef=string.sub(szStructVar,nBegin,nEnd);
	
	nBegin,nEnd=string.find(szStructVar,"%s-[%w_]+%s-",nEnd);
	local name=string.sub(szStructVar,nBegin,nEnd);
	name=trim(name);
	
	local szVar=string.sub(szStructVar,string.find(szStructVar,"%b{}",nEnd));
	return szTypedef,name,szVar;
end
function ffmpeg_const_struct_dispose_and_replaceEx(szStructVar,szShortFile)
	local szTypedef,name,szVar=ffmpeg_const_struct_get_struct_def(szStructVar);
	
	local deftbl=ffmpeg_c_struct_to_lua_table(szTypedef);--转换为定义表
	local tbl=ffmpeg_struct_get_var_to_table(szVar);--转换成表
	local structName=name.."_"..szShortFile;
	
	
	szTypedef="typedef struct "..structName.." "..szTypedef.." "..structName..";\n";--类型定义
	local szRepalce,szAddArray=ffmpeg_struct_table_create_default_val(deftbl,tbl,false,name,szShortFile);--创建默认值
	--szRepalce=structName.." "..name.." = {\n"..szRepalce.."\n}";
	--newText="\n"..szAddArray.."\n"..szRepalce;
	return szTypedef.."\nstatic const "..structName.." "..name.."={\n"..szRepalce.."\n}";
end
--[[
函数:ffmpeg_struct_array_get_var_text
功能:获取结构体变量
参数:szFileName=string
返回:string,int,int
]]--
function ffmpeg_const_struct_get_var_text(szText,nPos)
	local szFlag="static%s+const%s+struct%s-%b{}%s-[%w_]+%s=%s-%b{}";
	local nBegin,nEnd=string.find(szText,szFlag,nPos);
	if nil~=nBegin then
		return string.sub(szText,nBegin,nEnd),nBegin,nEnd;
	end;
	return;
end