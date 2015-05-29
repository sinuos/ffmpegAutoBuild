--[[
描述:		ffmpeg makefile解析模块
作者:		weiny zhou
创建日期:	2012-04-28
修改日期:	2012-04-28
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--

function makefile_parser_to_table(szMakefile)
	local tblMakefile={};
	local file=io.open(szMakefile,"r");
	if(file==nil) then
		return ;	
	end
	local name,value;
	local flag=false;
	for line in file:lines() do--读取行数据
		if(not flag) then--判断是否上一行有\
			name,value,flag=makefile_parser_line(line);--
		else
			if makefile_error_line(line) then
				value,flag=makefile_paser_next_line(line,nextflag);
			else
				print("line is nil or error.");
				name=nil;
				flag=false;
			end
		end
		if name~=nil and value~=nil then
			local tmp={};
			if type(value)~="table" then
				table.insert(tmp,value);
				value=tmp;
			end
			for index,tblvalue in ipairs(value) do
				if tblMakefile[name]==nil then
					tblMakefile[name]={};				
				end
				table.insert(tblMakefile[name],tblvalue);
			end	
		end
	end
	io.close(file);
	return tblMakefile;
end
function makefile_error_line(szLine)
	szLine=trim(szLine);
	if(string.len(szLine)<1) then
		return false;	
	end
	local frist=string.sub(szLine,1,1);
	if frist=="#" or frist=="$" then
		return false;
	end
	frist=string.sub(szLine,1,5);
	if frist==nil or frist=="else" or frist=="ifdef" or ifdef=="endif" then
		return false;	
	end
	if string.find(szLine,":=")~=nil then
		return false	
	end
	return true;
end
--[[
函数:makefile_parser_line
功能:解析=号符
参数:
返回:
]]--
function makefile_parser_line(szLine)
	szLine=trim(szLine);
	if not makefile_error_line(szLine) then 
		print("error parser,",szLine);
		return ;	
	end
	local nPos=string.find(szLine,"+=");
	if(nPos~=nil) then		
		return makefile_paser_line1(szLine,nPos,2);
	end
	nPos=string.find(szLine,"=");
	if (nPos~=nil) then
		return makefile_paser_line1(szLine,nPos,1);
	end
	return ;
end

--[[
函数:makefile_paser_line1
功能:解析=号符
参数:
返回:
]]--
function makefile_paser_line1(szLine,nPos,nCount)
	local name,value;
	local lastflag;
	name=string.sub(szLine,1,nPos);
	name=trim(name);
	value=string.sub(szLine,nPos+nCount);--截取.o列表
	value,lastflag=makefile_paser_next_line(value);
	return name,value,lastflag;
end


--[[
函数:makefile_paser_next_line
功能:解析\下一行
参数:
返回:
]]--

function makefile_paser_next_line(szLine,nextflag)
	local value=trim(szLine);
	local nPos;--=string.find(value," ");
	local tmp=string.sub(value,string.len(value)-1);
	local lastflag;
	if trim(tmp)=="\\" then--是否有下一行
		lastflag=true;
	else
		lastflag=false;
	end
	if lastflag then
		value=string.sub(value,1,string.len(value)-1);--删除下一行标识
	end
	value=trim(value);
	nPos=string.find(value," ");
	
	if(nPos==nil) and ((not lastflag)or nextflag~=nil or value~=nil) then
		return value,lastflag;
	elseif nPos==nil then
		print("error",value);
		return ;
	end
	tmp=value;--含有多个参数
	value={};
	table.insert(value,trim(string.sub(tmp,1,nPos)));--截取第一个参数
	tmp=trim(string.sub(tmp,nPos+1));-- 截取保留剩余的
	nPos=string.find(tmp," ");
	while (nPos~=nil) do
		table.insert(value,trim(string.sub(tmp,1,nPos)));
		tmp=trim(string.sub(tmp,nPos+1));
		nPos=string.find(tmp," ");
	end
	if string.len(tmp)>3 then		
		table.insert(value,tmp);--最后一个项
	end
	return value,lastflag;
end