--[[
描述:		ffmpeg array处理模块
作者:		weiny zhou
创建日期:	2012-05-11
修改日期:	2012-05-11
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--

--声明 针对处理eval.c si_prefixes

function ffmpeg_array_replace_text(szFileName,szArray)
	local file=io.open(szFileName,"r");
	if not file then
		print("open file error,",szFileName); return;
	end
	local szText=file:read("*a");
	file:close();
	local szArrayText,nBegin,nEnd=ffmpeg_array_get_text(szText,szArray);
	if not nEnd then
		return;
	end
	print("szArrayText=",szArrayText);
	local szArrayText=ffmpeg_array_dispose_text(szArrayText);
	if not szArrayText then
		return ;
	end
	szText=string.sub(szText,1,nBegin)..szArrayText..string.sub(szText,nEnd);
	file=io.open(szFileName,"w");
	file:write(szText);
	file:close();
	return 0;
end
--[[
函数:ffmpeg_array_get_text
功能:获取数据内容
参数:
返回:
]]--
function ffmpeg_array_get_text(szText,szArray)
	local flag="%s+"..szArray.."%s-%b[]%s-=%s-%b{}";
	local nBegin,nEnd=string.find(szText,flag);
	if not nEnd then
		print("find array error,",szArray);return;
	end
	nBegin,nEnd=string.find(szText,"%b{}",nBegin);
	local szArrayText=string.sub(szText,nBegin,nEnd);
	return szArrayText,nBegin,nEnd;
end

function ffmpeg_array_dispose_text(szArrayText)
	szArrayText=string.sub(szArrayText,2,string.len(szArrayText)-1);
	local nBegin=1;
	local flag=","
	local nEnd=string.find(szArrayText,flag);
	local tmp;
	local tbl={};
	while nEnd do
		tmp=string.sub(szArrayText,nBegin,nEnd-1);
		tmp=trim(tmp);
		local nIndex,szValue=ffmpeg_array_parser_line(tmp);
		nBegin=nEnd+1;
		table.insert(tbl,nIndex+1,szValue);
		nEnd=string.find(szArrayText,flag,nBegin);
	end
	tmp=string.sub(szArrayText,nBegin);
	tmp=trim(tmp);
	if string.len(tmp)>3 then
		local nIndex,szValue=ffmpeg_array_parser_line(tmp);
		table.insert(tbl,nIndex+1,szValue);
	end
	--转换成文本
	return ffmpeg_array_table_to_text(tbl);
end

--[[
函数:ffmpeg_array_parser_line
功能:解析行
参数:
返回:
]]--
function ffmpeg_array_parser_line(szLine)
	
	local nBegin,nEnd=string.find(szLine,"%b[]");
	local nIndex=tonumber(charMathOperation(string.sub(szLine,nBegin+1,nEnd-1)));
	local nBegin=string.find(szLine,"=");
	local szVale=string.sub(szLine,nBegin+1);
	return nIndex,szVale;
end


function ffmpeg_array_table_to_text(arraytbl)
	function getTableMax(tbl)
		local nMax=0;
		for index,value in pairs(tbl) do
			if nMax<index then
				nMax=index;
			end
		end
		return nMax;
	end
	local szReplace="";
	local nMaxIndex=getTableMax(arraytbl);
	for i=0,nMaxIndex-1 do
		if arraytbl[i+1] then
			szReplace=szReplace..arraytbl[i+1]..",/*".."*/\n";
		else
			szReplace=szReplace.."0,\n";
		end
	end
	return szReplace;
end