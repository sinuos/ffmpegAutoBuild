--[[
描述:		ffmpeg amr数组模块
作者:		weiny zhou
创建日期:	2012-05-07
修改日期:	2012-05-07
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--

--[[
函数:amr_array_not_const_value
功能:将amrwbdata.h,amrnbdata.h静态数组转换
参数:
返回:string,string
]]--
function amr_array_not_const_value(szName,szArray)
	local szOutText="";
	local szNewArray=szArray;
	local flag=",";
	local flaglen=string.len(flag);
	local nBegin,nEnd;
	local nIndex=0;
	nBegin=string.find(szNewArray,"{");
	nEnd=string.find(szNewArray,flag,nBegin);
	while nEnd~=nil do
		local tmp=string.sub(szNewArray,nBegin,nEnd-1);
		if string.find(tmp,"%(") then
			if not string.find(tmp,"%)") then
				local nTmpPos;
				nTmpPos,nEnd=string.find(szNewArray,"%b()%s-"..flag,nBegin);
				tmp=string.sub(szNewArray,nBegin,nEnd-1);
			end
			szNewArray=string.sub(szNewArray,1,nBegin).." 0"
			..string.sub(szNewArray,nEnd);
			nBegin=nBegin+3+flaglen;
			szOutText=szOutText..szName.."["..
			tostring(nIndex).."] = "..tmp..";\n";
		else
			nBegin=nEnd+flaglen;
		end
		nEnd=string.find(szNewArray,flag,nBegin);
		nIndex=nIndex+1;
	end
	return szOutText,szNewArray;
end

function amr_array_not_const_value_file_dispose(szFileName,szCallFunc)
	local file=io.open(szFileName,"r");
	if file==nil then
		print("open file error,file=",szFileName);return;
	end
	local szText=file:read("*a");
	file:close();
	file=nil;
	local flag="static%s+const%s+[%w_]+%s+[%w_]+%s-%[%s-%]%s-=%s-%b{}%s-;";
	local nBegin,nEnd=string.find(szText,flag);
	local nModifyCount=0;
	local newtbl={};
	local nLastPos=nil;
	while nEnd~=nil do
		local tmp=string.sub(szText,nBegin,nEnd);
		local name=arm_array_get_value_name(tmp);
		local szOutText,szNewArray=amr_array_not_const_value(name,tmp);
		if string.len(szOutText)>10 then
			szOutText="static inline void "..name.."_init(){/*wz lua script build func*/\n"..
			szOutText.."\n}";
			table.insert(newtbl,name.."_init");
		end
		tmp=szNewArray.."\n"..szOutText.."\n";
		szText=string.sub(szText,1,nBegin-1)..tmp..string.sub(szText,nEnd+1);
		nEnd=nBegin+string.len(tmp);
		nLastPos=nEnd;
		nBegin,nEnd=string.find(szText,flag,nEnd);
		nModifyCount=nModifyCount+1;
	end
	if nModifyCount==0 then
		return -1;
	end
	if nLastPos~=nil then
		local tmp="\n void "..szCallFunc.."(){\nconst function_val func[]={";
		for index,value in ipairs(newtbl) do 
			tmp=tmp..value..",";
		end
		tmp=tmp.."};int i;\nfor(i=0;i<sizeof(func)/sizeof(*func);++i) func[i]();\n}";
		szText=string.sub(szText,1,nLastPos)..tmp..string.sub(szText,nLastPos);
	end
	file=io.open(szFileName,"w");
	file:write(szText);
	file:close();
	return 0;
end

function arm_array_get_value_name(szArray)
	local name= string.sub(szArray,string.find(szArray,"[%w_]+%s-%[%]%s-="));
	local nFlagPos=string.find(name,"%[");
	name=string.sub(name,1,nFlagPos-1);
	return trim(name);
end