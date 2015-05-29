--[[
描述:		函数类型模块
作者:		weiny zhou
创建日期:	2012-05-01
修改日期:	2012-05-07
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--

--[[
bug 
	2012-05-07.修改因为数组，导致截取名称错误
]]--
--[[
函数:remove_name_flag
功能:移除name 中干扰标识
参数:
返回:
]]--
function remove_name_flag(szName)
	if string.sub(szName,1,1)=="(" then
		szName=string.sub(szName,2);
	end
	if string.sub(szName,string.len(szName))==")" then
		szName=string.sub(szName,1,string.len(szName)-1);
	end
	if string.sub(szName,1,1)=="*" then
		szName=string.sub(szName,2);
	end
	return szName;
end
function dispose_line_get_info(linetext)
	local line=trim(linetext);
	local isConst=false;
	local linetype=nil;
	local func_type={
	{def="NULL",t="array",func=dispose_functype_array,f="%["},
	--[[funcptr=]]{def="NULL",t="funcptr",func=dispose_functype_funcptr,f="%("},
	--[[str=]]{def="NULL",t="string",func=dispose_functype_string,f="char *"},
	--[[ptr=]]{def="NULL",t="ptr",func=dispose_functype_string,f="*"},
	--[[enum=]]{def=nil,t="enum",func=dispose_functype_int,f="enum"},
	--[[struct=]]{def=nil,t="struct",func=nil,f="struct"},
	--[[float=]]{def="0.0",t="float",func=dispose_functype_int,f="float"},
	--[[int=]]{def="0",t="int",func=dispose_functype_int,f="int"}	
	};
	if string.find(linetext,"typedef")~=nil then
		print("this line is typedef",linetext);
		return;	
	end
	local name,funcdef;
	for index,value in ipairs(func_type) do
		if string.find(line,value.f)~=nil then
			name,funcdef=value.func(line);
			name=remove_name_flag(name);
			return name,funcdef,value.def,value.t;
		end	
	end
	name,funcdef=func_type[7].func(line);
	name=remove_name_flag(name);
	return name,funcdef,func_type[7].def,func_type[7].t;
end

function dispose_functype_funcptr(linetext)
	local name=nil;
	local nBegin=string.find(linetext,"%(%*");
	local nEnd=string.find(linetext,"%)");
	name=string.sub(linetext,nBegin+2,nEnd-1);
	local funcdef=string.sub(linetext,1,nBegin)..string.sub(linetext,nEnd);
	return trim(name),trim(funcdef);
end

function dispose_functype_templet(linetext,flags,flagslen)
	local name=nil;
	local funcdef=nil;
	local nBegin=string.find(linetext,flags);
	local nEnd=nBegin;
	while(nEnd~=nil) do
		local nTmp=string.find(linetext,flags,nEnd+flagslen);
		if nTmp==nil then
			break;		
		end
		nEnd=nTmp;
	end
	name=string.sub(linetext,nEnd+flagslen);
	funcdef=string.sub(linetext,1,nEnd);
	return trim(name),trim(funcdef);
end

function dispose_functype_int(linetext)
	return dispose_functype_templet(linetext," ",1);
end
function dispose_functype_string(linetext)
	return dispose_functype_templet(linetext,"*",1);
end
function dispose_functype_array(linetext)
	local name=nil;
	local funcdef=nil;
	linetext=trim(string.gsub(linetext,"%b[]",""));--删除数据中[]
	return dispose_functype_int(linetext);
end
