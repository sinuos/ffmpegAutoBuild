--[[
描述:		lua ffmpeg AVOption struct处理模块
作者:		weiny zhou
创建日期:	2012-05-07
修改日期:	2012-05-07
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--

function avoption_dispose(szFileName)
	local file=io.open(szFileName,"r");
	local szText=file:read("*a");
	file:close();
	file=nil;
	local varName="AVOption";
	local flag="%s+"..varName.."%s+[%w_]+%s-=%s-%b{}%s-;";
	local nBegin,nEnd=string.find(szText,flag);
	while nEnd~=nil do
		local replacetbl={"%.dbl =","%.str =","%.i64 ="};
		local tmp=string.sub(szText,nBegin,nEnd);
		for index,value in ipairs(replacetbl) do
			szText=string.gsub(tmp,value,"");
		end
		szText=string.sub(szText,1,nBegin-1)
		..tmp.. string.sub(szText,nEnd+1);
		nEnd=string.len(tmp)+nBegin;
		nBegin,nEnd=string.find(szText,flag,nEnd);
	end
	file=io.open(szFileName,"w");
	file:write(szText);
	file:close();
	return 0;
end