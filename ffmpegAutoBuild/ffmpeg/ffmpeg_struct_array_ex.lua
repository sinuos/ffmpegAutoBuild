--[[
描述:		ffmpeg struct array 扩展模块
作者:		weiny zhou
创建日期:	2012-05-09
修改日期:	2012-05-09
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--

--针对文件pixdesc.c,结构体 AVPixFmtDescriptor


function ffmpeg_struct_array_ex_enum_dispose(szFileName,szStruct,deftbl,indexTbl)
	local file=io.open(szFileName,"r");
	local szText=file:read("*a");
	file:close();
	local szBlock,nBegin,nEnd=ffmpeg_struct_array_ex_get_text(szText,szStruct,1);
	local nModifyCount=0;
	local szShortFile=getFileShortName(szFileName);
	while(nEnd) do
		if not string.find(szBlock,"#if") then
			local tmp=ffmpeg_struct_array_ex_dispose_block(szBlock,deftbl,szShortFile,indexTbl);
			szText=string.sub(szText,1,nBegin)..tmp..string.sub(szText,nEnd);
			nEnd=nBegin+string.len(tmp);
			nModifyCount=nModifyCount+1;
		else
			print("this block have defined");
		end
		szBlock,nBegin,nEnd=ffmpeg_struct_array_ex_get_text(szText,szStruct,nEnd+1);
	end
	if nModifyCount==0 then
		print("modify count is 0");
		return ;
	end
	file=io.open(szFileName,"w");
	file:write(szText);
	file:close();
	
	return 0;
end

function ffmpeg_struct_array_ex_get_text(szText,szStruct,nPos)
	local flag="%s+"..szStruct.."%s+[%w_]+%s-%[[%w_]-%]%s-=%s-%b{}";
	local nBegin,nEnd=string.find(szText,flag,nPos);
	if not nBegin then
		print("find struct is error",szStruct);
		return ;
	end
	nBegin=string.find(szText,"{",nBegin);
	local szStructText=string.sub(szText,nBegin,nEnd);
	return szStructText,nBegin,nEnd;
end

function ffmpeg_struct_array_ex_dispose_block(szBlock,deftbl,szShortFile,indexEnumTbl)
	function ffmpeg_struct_array_ex_get_index(tbl,szIndex)
		print("szIndex",szIndex);
		if tbl.sztbl[szIndex].val then
			return tbl.sztbl[szIndex].val;
		end
		print("index is error,can't found index=",szIndex);
		string.sub(nil,0,0);
	end
	--删除括号
	szBlock=string.sub(szBlock,2,string.len(szBlock)-1);
	local nMaxIndex=0;--记录索引最大值
	local tbl={};
	local szBlockItem,nBegin,nEnd=ffmpeg_struct_array_ex_dispose_item(szBlock,1);
	while nEnd~=nil do
		local szIndex,szValue=ffmpeg_struct_array_ex_dispose_item_dispose(szBlockItem);
		local nIndex=tonumber(szIndex)
		local inserttbl={};
		if not nIndex then
			if not indexEnumTbl then
				print("array index is not number,input indextbl is nil");
				return ;
			end
			nIndex=ffmpeg_struct_array_ex_get_index(indexEnumTbl,szIndex);
			inserttbl.def=indexEnumTbl.sztbl[szIndex].def;
		elseif indexEnumTbl then
			inserttbl.def=indexEnumTbl.itbl[nIndex+1].def;
		end
		if nMaxIndex<nIndex then
			nMaxIndex=nIndex;
		end
		--解析内容
		local itemtbl=ffmpeg_struct_get_var_to_table(szValue);
		--生成新的内容信息
		local szRepalce,szAddArray=ffmpeg_struct_table_create_default_val(deftbl,itemtbl,false,"array_ex",szShortFile);
		if string.len(szAddArray)>10 then
			print("this item have array");
			string.sub(nil,0,0);
		end
		szRepalce="{\n"..szRepalce.."\n}";
		
		inserttbl.val=szRepalce;
		
		table.insert(tbl,nIndex+1,inserttbl);
		szBlockItem,nBegin,nEnd=ffmpeg_struct_array_ex_dispose_item(szBlock,nEnd);
	end
	return ffmpeg_struct_array_ex_table_create_text(tbl,nMaxIndex);
end

function ffmpeg_struct_array_ex_dispose_item(szBlock,nPos)
	local flag="%b[]%s-=%s-%b{}";
	local nBegin,nEnd=string.find(szBlock,flag,nPos);
	if not nBegin then
		print("find block item is error");
		return ;
	end
	local szItem=string.sub(szBlock,nBegin,nEnd);
	return szItem,nBegin,nEnd;
end

function ffmpeg_struct_array_ex_dispose_item_dispose(szItem)
	local nBegin,nEnd=string.find(szItem,"%b[]");
	local szIndex=string.sub(szItem,nBegin+1,nEnd-1);
	return trim(szIndex),string.sub(szItem,string.find(szItem,"%b{}"));
end

function ffmpeg_struct_array_ex_table_create_text(arraytbl,nMax)
	local i=0;
	local szStructText="";
	while i<=nMax do
		if arraytbl[i+1]==nil then
			szStructText=szStructText.."{0},/*"..tostring(i).."*/\n";
		else
			if arraytbl[i+1].def then
				szStructText=szStructText.."#if"..arraytbl[i+1].def.."\n"..arraytbl[i+1].val..",/*"..tostring(i).."*/\n#endif\n";
			else
				szStructText=szStructText..arraytbl[i+1].val..",/*"..tostring(i).."*/\n";
			end
		end
		i=i+1;
		print("index=",i);
	end
	return szStructText;
end