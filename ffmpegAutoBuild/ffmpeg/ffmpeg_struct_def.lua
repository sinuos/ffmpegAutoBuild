--[[
描述:		ffmpeg struct处理模块
作者:		weiny zhou
创建日期:	2012-05-03
修改日期:	2012-05-04
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--

--[[
函数:ffmpeg_struct_var_define_to_table
功能:解析含有宏定义的结构体变量并转换为table
参数:
返回:table
]]--
function ffmpeg_struct_var_define_to_table(szvar)
	function ffmpeg_struct_get_var_define_to_table_line(tmp,vartbl)
		if string.sub(tmp,string.len(tmp))=="," then
			tmp=string.sub(tmp,1,string.len(tmp)-1);
		end
		local name,value=ffmpeg_struct_line_var_dispose(tmp);
		if value~=nil then
			if name==nil then
				table.insert(vartbl,value);
			else
				vartbl[name]=value;
			end
		end
	end
	function ffmpeg_struct_var_define_to_table2(szStructText,tmp,nBegin,nEnd,lineflaglen,vartbl)
		if string.find(tmp,"{")~=nil then
			if string.find(tmp,"}")==nil then	
				local nTmpPos;
				nTmpPos,nEnd=string.find(szStructText,"%b{}",nBegin);
				--nEnd=string.find(szStructText,lineflag,nTmpPos);
				if nEnd==nil then
					return;			
				end
				tmp=string.sub(szStructText,nBegin,nEnd);
				tmp=trim(tmp);
			end 
		elseif	string.find(tmp,"%(")~=nil then
			if string.find(tmp,"%)")==nil then
				local nTmpPos;
				nTmpPos,nEnd=string.find(szStructText,"%b()",nBegin);
				--nEnd=string.find(szStructText,lineflag,nTmpPos);
				if nEnd==nil then
					return ;				
				end
				tmp=string.sub(szStructText,nBegin,nEnd);
				tmp=trim(tmp);		
			end
		elseif string.find(tmp,"\"")~=nil then
			local nTmpPos=string.find(tmp,"\"");--第一个位置
			if string.find(tmp,"\"",nTmpPos+1)==nil then
				nTmpPos,nEnd=string.find(szStructText,"%b\"\"",nBegin);
				if nEnd==nil then
					return ;			
				end
				tmp=string.sub(szStructText,nBegin,nEnd);
				tmp=trim(tmp);		
			end
		end
		ffmpeg_struct_get_var_define_to_table_line(tmp,vartbl);
		nBegin=nEnd+lineflaglen;
		return nBegin;
	end
	function ffmpeg_struct_var_define_to_table3(szStructText,tmp,nBegin,nEnd,lineflaglen,vartbl)
		local nTmpPos;
		if string.find(tmp,"{")~=nil then
			if string.find(tmp,"}")==nil then
				nTmpPos,nEnd=string.find(szStructText,"%b{}",nBegin);
			end
		elseif	string.find(tmp,"%(")~=nil then
			if string.find(tmp,"%)")==nil then
				nTmpPos,nEnd=string.find(szStructText,"%b()",nBegin);
			end
		else
			tmp=ffmpeg_struct_def_block_dispose(tmp,vartbl);
			if tmp==nil then
				return ;
			end
			return nEnd;
		end
		if nEnd==nil then
			return ;			
		end
		tmp=string.sub(szStructText,nBegin,nEnd);
		ffmpeg_struct_get_var_define_to_table_line(tmp,vartbl);
		return nEnd+1;
	end
	local nBegin,nEnd=string.find(szvar,"%b{}");
	local szStructText=trim(string.sub(szvar,nBegin+1,nEnd-1));--去掉括号
	local lineflag=",";
	local lineflaglen=string.len(lineflag);
	nBegin=1;
	print("szStructText=",szStructText);
	nEnd=string.find(szStructText,lineflag,nBegin);
	local vartbl={};
	local tmp;
	while(nEnd~=nil) do
		tmp=string.sub(szStructText,nBegin,nEnd-1);
		tmp=trim(tmp);
		if line_is_have_define(tmp) then
			local nTmpPos;
			nTmpPos,nEnd=string.find(szStructText,"#if.-#endif",nBegin);
			tmp=string.sub(szStructText,nBegin,nEnd);
			nBegin=ffmpeg_struct_var_define_to_table3(szStructText,tmp,nBegin,nEnd,lineflaglen,vartbl);
			if nBegin==nil then
				return;
			end
		else
			nBegin=ffmpeg_struct_var_define_to_table2(szStructText,tmp,nBegin,nEnd,lineflaglen,vartbl);			
			if nBegin==nil then
				break;
			end
		end;
		nEnd=string.find(szStructText,lineflag,nBegin);
	end
	tmp=string.sub(szStructText,nBegin);
	tmp=trim(tmp);
	if string.len(tmp)>0 then
		ffmpeg_struct_get_var_define_to_table_line(tmp,vartbl);
	end
	print("dispose end.",szvar);
	return vartbl;
end
--[[
函数:ffmpeg_struct_get_define_info
功能:获取宏定义信息
参数:
返回:string
]]--
function ffmpeg_struct_get_define_info(szBlock,deflen)
	local lineflag="\r\n";
	if string.find(szBlock,lineflag)==nil then
		lineflag="\n";
	end
	local defEnd=1;
	local tmpPos=string.find(szBlock,lineflag);
	local definfo;
	while(tmpPos~=nil) do
		if string.sub(szBlock,tmpPos-1,tmpPos-1)=="\\" then
			defEnd=tmpPos-1;
			tmpPos=string.find(szBlock,lineflag,tmpPos+1);
		else
			defEnd=tmpPos-1;
			definfo=string.sub(szBlock,deflen,defEnd);
			break;
		end
	end
	return definfo;
end
--[[
函数:ffmpeg_struct_def_block_dispose
功能:宏定义块处理
参数:
返回:int
]]--
function ffmpeg_struct_def_block_dispose(szDefine,vartbl)
	
	function ffmpeg_struct_def_dispose_ex_line(szBlock)
		local szdef="";
		local nLen;
		local tbl;
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
		szBlock=trim(string.sub(szBlock,nLen+string.len(szdef)));
		tbl=ffmpeg_struct_get_var_to_table(szBlock);--解析所有的子项
		return tbl,szdef;
	end
	function ffmpeg_struct_def_blocktab_to_var_table(vartbl,tbl,nIndex,szDef)
		local lclIndex=nIndex;
		print("tbl count=",GetTableCount(tbl));
		for index,value in pairs(tbl) do
			--print("index=",index,"value=",value);
			local inserttbl={}
			if type(index)=="string" then
				
				if (vartbl[index]==nil) or (type(vartbl[index])=="table") then
					if vartbl[index]==nil then
						vartbl[index]={};
					end
					inserttbl.def=szDef;
					if string.len(szDef)<1 then
						inserttbl.def=nil;
					end
					inserttbl.val=value;
					table.insert(vartbl[index],inserttbl);
				else
					print(index," this type error.");
					string.sub(index,nil,nil);
				end
			else
				if (vartbl[lclIndex]==nil) or (type(vartbl[lclIndex])=="table") then
					if vartbl[lclIndex]==nil then
						vartbl[lclIndex]={};
					end
					inserttbl.def=szDef;
					if string.len(szDef)<1 then
						inserttbl.def=nil;
					end
					inserttbl.val=value;
					table.insert(vartbl[lclIndex],inserttbl);
					lclIndex=lclIndex+1;
				else
					print(index," this type error.");
					--string.sub(index,nil,nil);
					return ;
				end
			end
		end
		return 0;
	end
	local nFlag="%b##"; 
	local nBegin,nEnd=string.find(szDefine,nFlag);
	local nTabCount=GetTableCount(vartbl);
	while nBegin~=nil and nEnd~=nil do
		nEnd=nEnd-1;
		
		local tmp=string.sub(szDefine,nBegin,nEnd);--截取块
		local tbl;
		tmp=trim(tmp);
		print("tmp",tmp);
		if string.len(tmp)<2 then
			break;		
		end
		tbl,tmp=ffmpeg_struct_def_dispose_ex_line(tmp);--子项列表
		tmp=ffmpeg_struct_def_blocktab_to_var_table(vartbl,tbl,nTabCount,tmp);
		if tmp==nil then
			return ;
		end
		nBegin=nEnd;
		nBegin,nEnd=string.find(szDefine,nFlag,nBegin);
		--print("find end=",nEnd,"begin=",nBegin,string.sub(szDefine,nBegin,nBegin));
	end
	return 0;
end


function ffmpeg_struct_def_create_default_val(tbl,szName,szShortFile,isdef,szVarStructName)
	local szArray;
	local szText;
	for index,value in pairs(tbl) do
		local tmp,tmpArray;
		if szText==nil then
			szText="\n#if"..value.def.."\n";
		elseif value.def~=nil then
			szText=szText.."\n#elif "..value.def.."\n";
		else
			szText=szText.."\n#else\n";
		end
		if ffmpeg_struct_table_is_item_is_array(value.val) then
			tmpArray,tmp=ffmpeg_struct_table_array_add_value(value.val,szName,szShortFile,isdef,szVarStructName);
			if tmpArray~=nil then
				szArray=szArray.."\n"..tmpArray;
			end
			szText=szText..tmp..",";
		else
			szText=szText..value.val..",";
		end
	end
	if szText~=nil then
		szText=szText.."\n#endif\n"	
	end
	return szArray,szText;
end


function ffmpeg_struct_def_remove_lineflag(szStructVar)
	local lineflag="\r\n";
	if string.find(szStructVar,lineflag)==nil then
		lineflag="\n";
	end
	return string.gsub(szStructVar,"\\"..lineflag,lineflag);
end
function ffmpeg_struct_def_remove_mulite_line(szVar)
	local lineflag="\r\n";
	if string.find(szVar,lineflag)==nil then
		lineflag="\n";
	end
	return string.gsub(szVar,lineflag,"");
end
function ffmpeg_struct_def_add_lineflag(szStructVar)
	local lineflag="\r\n";
	if string.find(szStructVar,lineflag)==nil then
		lineflag="\n";
	end
	return string.gsub(szStructVar,lineflag,"\\"..lineflag);
end