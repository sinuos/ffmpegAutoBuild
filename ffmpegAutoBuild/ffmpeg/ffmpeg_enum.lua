--[[
描述:		ffmpeg enum 解析模块
作者:		weiny zhou
创建日期:	2012-05-09
修改日期:	2012-05-10
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--
--测试文件:pixfmt.h 枚举类型PixelFormat
--[[
函数:ffmpeg_enum_dispose
功能:ffmpeg enum 解析
参数:szFileName=string
返回:table
]]--
function ffmpeg_enum_dispose(szFileName,szEnum)
	local file=io.open(szFileName,"r");
	if not file then
		print("open file error,file=",szFileName);
		return ;
	end
	local szText=file:read("*a");
	file:close();
	file=nil;
	
	local szEnumBlock=ffmpeg_enum_get_def_text(szText,szEnum);
	
	return ffmpeg_enum_dispose_block(szEnumBlock);
end

--[[
函数:ffmpeg_enum_get_def_text
功能:ffmpeg 获取 enum
参数:szText=string,szEnum=string
返回:string
]]--
function ffmpeg_enum_get_def_text(szText,szEnum)
	function ffmpeg_enum_get_def_text2(szText,szEnum)
		local flag="enum%s-%b{}%s-"..szEnum.."%s-;";
		local nBegin,nEnd=string.find(szText,flag);
		if not nBegin  then
			print("can'r not find enum,",szEnum);
			return ;
		end
		local szEnumBlock=string.sub(szText,nBegin,nEnd);
		return szEnumBlock;
	end
	local flag="enum%s+"..szEnum.."%s-%b{}";
	local nBegin,nEnd=string.find(szText,flag);
	if not nBegin  then
		print("can'r not find enum,",szEnum);
		return ffmpeg_enum_get_def_text2(szText,szEnum);
	end
	local szEnumBlock=string.sub(szText,nBegin,nEnd);
	return szEnumBlock;
end

--[[
函数:ffmpeg_enum_dispose_block
功能:ffmpeg enum 数据块解析
参数:
返回:
]]--
function ffmpeg_enum_dispose_block(szBlock)
	--删除大括号
	local nBegin,nEnd=string.find(szBlock,"%b{}");
	if nBegin then
		szBlock=string.sub(szBlock,nBegin+1,nEnd-1);
	end;
	--删除所有的注释
	szBlock=ffmpeg_remove_c_struct_text_comment(szBlock);
	local tbl={
		itbl={},--整数索引
		sztbl={}
		};
	ffmpeg_enum_dispose_block2(szBlock,tbl,-1);
	return tbl;
end
function ffmpeg_enum_dispose_block2(szBlock,tbl,nLastIndex,szDef)
	local nIndex=nLastIndex;
	local flag=","
	local szLine;
	local szValue;
	local nBegin,nEnd;
	nBegin=1;
	nEnd=string.find(szBlock,flag);
	while nEnd~=nil do
		szLine=trim(string.sub(szBlock,nBegin,nEnd-1));--去掉逗号
		if string.find(szLine,"#") then
			nBegin,nEnd=string.find(szBlock,"#if.-#endif",nBegin);
			if nEnd==nil then
				return nIndex;
			end
			szLine=string.sub(szBlock,nBegin,nEnd);--截取宏定义块
			nIndex=ffmpeg_enum_dispose_define_block(szLine,nIndex,tbl);
		else
			local inserttbl={};
			local szInserttbl={};
			szValue,nIndex=ffmpeg_enum_dispose_line(szLine,nIndex);
			inserttbl.val=szValue;
			
			if szDef then
				szInserttbl.def=szDef;
				inserttbl.def=szDef;
			end;
			szInserttbl.val=nIndex;
			tbl.sztbl[szValue]=szInserttbl;
			table.insert(tbl.itbl,nIndex+1,inserttbl);
		end
		nBegin=nEnd+1;
		nEnd=string.find(szBlock,flag,nBegin);
	end
	szLine=trim(string.sub(szBlock,nBegin));
	if string.len(szLine)>3 then
		if string.find(szLine,"#") then
			nBegin,nEnd=string.find(szLine,"#if.-#endif");
			if  nEnd then
				szLine=string.sub(szLine,nBegin,nEnd);--截取宏定义块
				nIndex=ffmpeg_enum_dispose_define_block(szLine,nIndex,tbl);
			end
			
		else
			local inserttbl={};
			local szInserttbl={};
			szValue,nIndex=ffmpeg_enum_dispose_line(szLine,nIndex);
			inserttbl.val=szValue;
			
			if szDef then
				szInserttbl.def=szDef;
				inserttbl.def=szDef;
			end;
			szInserttbl.val=nIndex;
			tbl.sztbl[szValue]=szInserttbl;
			table.insert(tbl.itbl,nIndex+1,inserttbl);
		end
	end
	return nIndex;--返回最后的index
end
--[[
函数:ffmpeg_enum_dispose_line
功能:解析单行
参数:
返回:string,int
]]--
function ffmpeg_enum_dispose_line(szLine,nLastIndex)
	local nIndex=nLastIndex;--当前索引
	local szValue,szTmp;
	local nPos=string.find(szLine,"=");
	if nPos then
		szTmp=string.sub(szLine,nPos+1);
		nIndex=tonumber(mathstroperation(szTmp));--计算值
		szValue=string.sub(szLine,1,nPos-1);
	else
		szValue=szLine;
		nIndex=nIndex+1;
	end
	return trim(szValue),nIndex;
end

--[[
函数:ffmpeg_enum_dispose_define_block
功能:解析宏定义块
参数:
返回:int
]]--
function ffmpeg_enum_dispose_define_block(szBlock,nLastIndex,tbl)
	local nBegin,nEnd;
	local szflag="%b##";
	local nIndex=nLastIndex;
	nBegin,nEnd=string.find(szBlock,szflag);
	while nEnd~=nil do
		local tmp=string.sub(szBlock,nBegin,nEnd);
		local nLen;
		local szdef;
		if string.sub(szBlock,1,3)=="#if" then
			nLen=string.len("#if")+1;
			szdef=ffmpeg_struct_get_define_info(szBlock,nLen);
		elseif string.sub(szBlock,1,5)=="#elif" then
			nLen=string.len("#elif")+1;
			szdef=ffmpeg_struct_get_define_info(szBlock,nLen);
		else
			nLen=string.len("#else")+1;
		end
		--删除宏所有空行
		tmp=trim(string.sub(tmp,nLen+string.len(szdef)));
		nIndex=ffmpeg_enum_dispose_block2(tmp,tbl,nIndex,szdef);
		nBegin,nEnd=string.find(szBlock,szflag,nEnd+1);
	end
	return nIndex;
end