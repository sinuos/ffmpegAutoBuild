--[[
描述:		ffmpeg config.h解析模块
作者:		weiny zhou
创建日期:	2012-04-28
修改日期:	2012-04-28
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--

function config_paser_to_table(szConfig)
	local tblConfig={};
	local file=io.input(szConfig);
	for line in file:lines() do
		local tmp,value=config_parser_line(line);
		if(tmp~=nil) then
			tblConfig[tmp]=value;
		end
	end
	file:close();
	return tblConfig;
end

function config_parser_line(szLine)
	local nPos=string.find(szLine,"#define");
	if nPos~=1 then
		print("str=",szLine,"can't find");
		return nil;	
	end
	local line=string.sub(szLine,nPos+string.len("#define"));
	line=trim(line);
	nPos=string.find(line," ");
	if(nPos==nil) then
		return 	line,nil;
	end
	local name=string.sub(line,1,nPos);
	local value=trim(string.sub(line,nPos));
	if string.sub(value,1,1) ~="\"" then
		value=tonumber(value);
	end
	
	return name,value;
end
--config_paser_to_table("E:\\weinydesign\\media\\AutoBuild\\ffmpeg\\config.h");