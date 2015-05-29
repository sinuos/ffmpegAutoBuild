--[[
描述:		ffmpeg struct处理模块
作者:		weiny zhou
创建日期:	2012-05-01
修改日期:	2012-05-07
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--
--[[
修改: 
	2012-05-07.修改因为创建数组，导致名字冲突错误
]]--
--[[
函数:ffmpeg_get_struct
功能:获取结构体
参数:
返回:string
]]--

function ffmpeg_get_struct(szFileName,structName)
	function ffmpeg_get_struct_not_struct_name_header2(szText)
		local nBegin,nEnd=string.find(szText,"%s+struct%s+"..structName.."%s-%b{}%s-"..";");
		if nBegin==nil then
			print("struct typedef not find,",structName);
			return nil;
		end;
		return string.sub(szText,nBegin,nEnd);
	end
	function ffmpeg_get_struct_not_struct_name_header(szText)
		local nBegin,nEnd=string.find(szText,"typedef%s+struct%s+%b{}%s-"..structName..";");
		if nBegin==nil then
			return ffmpeg_get_struct_not_struct_name_header2(szText);
		end;
		return string.sub(szText,nBegin,nEnd);
	end
	local file=io.open(szFileName,"r");
	if(file==nil) then
		print("ffmpeg_get_struct open file error,",szFileName);return;	
	end
	local szText=file:read("*a");
	file:close();
	file=nil;
	local szStruct=nil;
	print("begin dispose ",structName);
	local nBegin,nEnd=string.find(szText,"typedef%s+struct%s+"..structName.."%s-%b{}%s-"..structName..";");
	if nBegin~=nil then
		szStruct=string.sub(szText,nBegin,nEnd);
		return szStruct;
	end;
	return ffmpeg_get_struct_not_struct_name_header(szText);
end

--[[
函数:ffmpeg_remove_c_struct_text_comment
功能:删除C语言结构体中的注释
参数:
返回:string
]]--
function ffmpeg_remove_c_struct_text_comment(szStructText)
	local nBeginPos;--=string.find(szStructText,"/$*");
	local nEndPos=nil;
	--删除所有/*的多行注释
	szStructText=string.gsub(szStructText, "/%*.-%*/", "");
	--nBeginPos=string.find(szStructText,"//");
	local lineflag="\r\n";
	if string.find(szStructText,"\r\n")==nil then
		lineflag="\n";
	end
	szStructText=string.gsub(szStructText, "//.-"..lineflag, lineflag);
	
	return szStructText;
end
--[[
函数:ffmpeg_remove_null_line
功能:删除C语言结构体中的多余空行,请勿用于结构体变量
参数:
返回:string
]]--
function ffmpeg_remove_null_line(szStructText)
	szStructText=string.gsub(szStructText,"(,\n%s+)","");
	szStructText=string.gsub(szStructText,"\n%s-\n","");--删除空行
	return szStructText;
end
function ffmpeg_struct_define_dispose_ex(szStruct)
	local nBegin,nEnd;
	local nFlag="%b##";
	nBegin,nEnd=string.find(szStruct,nFlag);
	local definetbl={};
	while nBegin~=nil and nEnd~=nil do
		nEnd=nEnd-1;
		local tmp=string.sub(szStruct,nBegin,nEnd);
		local nlen;
		if string.sub(tmp,1,3)=="#if" then
			nLen=string.len("#if")+1;
		elseif string.sub(tmp,1,5)=="#elif" then
			nLen=string.len("#elif")+1;
		else
			nLen=string.len("#else")+1;
		end
		local name=ffmpeg_struct_get_define_info(tmp,nLen);--获取宏定义
		if name==nil then
			name="";
		end
		--删除所有空行和宏定义
		tmp=trim(string.sub(tmp,nLen+string.len(name)));
		local tbl=ffmpeg_c_struct_to_lua_table(tmp);--子项列表
		local inserttbl={};
		
		if GetTableCount(tbl)>0 then
			
			inserttbl[name]=tbl;
			table.insert(definetbl,inserttbl);
		end;
		nBegin,nEnd=string.find(szStruct,nFlag,nEnd);
	end
	return definetbl;
end
function ffmpeg_struct_define_dispose(linetext)
	return ffmpeg_struct_define_dispose_ex(linetext);
end
--[[
函数:ffmpeg_c_struct_to_lua_table
功能:将C结构体转换lua table
参数:
返回:table
]]--
function ffmpeg_c_struct_to_lua_table(szStructText)
	szStructText=trim(szStructText);
	local nBeginPos,nEndPos=string.find(szStructText,"%b{}");
	if nBeginPos~=nil then
		szStructText=string.sub(szStructText,nBeginPos+1,nEndPos-1);
	end
	nBeginPos=1;
	local structtbl={};
	local lineflag=";";
	
	while(nBeginPos~=nil)do
		nEndPos=string.find(szStructText,lineflag,nBeginPos);
		if nEndPos==nil then
			break;		
		end
		local tbl={};
		local linetext=trim(string.sub(szStructText,nBeginPos,nEndPos-1));
		if line_is_have_struct(linetext) then
			print("this line is a struct ,but not support.",linetext); 
		elseif line_is_have_define(linetext) then
			if string.sub(linetext,1,3)=="#if" then
				local nTmpPos;
				local enddeflen=string.len("#endif");
				nTmpPos,nEndPos=string.find(szStructText,"#if.-#endif",nBeginPos);
				linetext=string.sub(szStructText,nTmpPos,nEndPos+enddeflen);
				tbl.list=ffmpeg_struct_define_dispose(linetext);
				if tbl.list~=nil then
					tbl.t="define";
					table.insert(structtbl,	tbl);
				end;
			end
		else
			
			tbl.name,tbl.typedef,tbl.default,tbl.t=dispose_line_get_info(linetext);
			if tbl.name~=nil then
				table.insert(structtbl,	tbl);	
			end
		end;
		nBeginPos=nEndPos+string.len(lineflag);
	end
	return structtbl;
end

--[[
函数:line_is_have_struct
功能:判断行是否含有结构体
参数:linetext=string
返回:boolean
]]--
function line_is_have_struct(linetext)
	if string.find(linetext,"{") then
		return true;
	end
	return false;
end
--[[
函数:line_is_have_define
功能:判断行是否含有宏定义
参数:linetext=string
返回:boolean
]]--
function line_is_have_define(linetext)
	if string.find(linetext,"#if") then
		return true;
	end
	return false;
end

--[[
函数:ffmpeg_struct_get_var_text
功能:获取结构体变量
参数:szFileName=string
返回:string,int,int
]]--
function ffmpeg_struct_get_var_text(szText,varName,nPos)
	function ffmpeg_struct_get_var_text2(szText,varName,nPos)
		local nBegin,nEnd=string.find(szText,"%s-"..varName.."%s+[%w_ #]+%s-=%s-%b{}",nPos);
		if nil~=nBegin then
			return string.sub(szText,nBegin,nEnd),nBegin,nEnd;
		end;
		return nil;
	end
	local nBegin,nEnd=string.find(szText,"%s-"..varName.."%s+[%w_]+%s-=%s-%b{}",nPos);
	if nil~=nBegin then
		return string.sub(szText,nBegin,nEnd),nBegin,nEnd;
	end;
	
	return ffmpeg_struct_get_var_text2(szText,varName,nPos);
end
--[[
函数:ffmpeg_struct_get_var_name
功能:获取结构体变量名
参数:szvar=string
返回:string
]]--
function ffmpeg_struct_get_var_name(szvar)
	szvar=trim(szvar);
	local nBegin,nEnd=string.find(szvar,"%s+[%w_# ]+%s-=");
	if not nBegin then
		print("get var name error,",szvar);return ;
	end
	local szName=string.sub(szvar,nBegin,nEnd);
	
	return trim(string.sub(szName,1,string.len(szName)-1));
end
--[[
函数:ffmpeg_struct_get_var_to_table
功能:结构体变量转table
参数:szvar=string
返回:table
]]--
function ffmpeg_struct_get_var_to_table(szvar)
	function ffmpeg_struct_get_var_to_table_line(tmp,vartbl)
		if string.sub(tmp,string.len(tmp))=="," then--如果最后一个字符是,就删除
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
	local nBegin,nEnd=string.find(szvar,"%b{}");
	local szStructText;
	if nBegin~=nil then
	 szStructText=trim(string.sub(szvar,nBegin+1,nEnd-1));--去掉括号
	else
		szStructText=szvar;
	end
	local lineflag=",";
	local lineflaglen=string.len(lineflag);
	nBegin=1;--[[string.find(szStructText,lineflag);
	if nBegin==nil then
		return ;	
	end]]--
	nEnd=string.find(szStructText,lineflag,nBegin);
	local vartbl={};
	local tmp;
	while(nEnd~=nil) do
		tmp=string.sub(szStructText,nBegin,nEnd-1);
		tmp=trim(tmp);
		if string.find(tmp,"{")~=nil then
			if string.find(tmp,"}")==nil then
				
				local nTmpPos;
				nTmpPos,nEnd=string.find(szStructText,"%b{}",nBegin);
				--nEnd=string.find(szStructText,lineflag,nTmpPos);
				if nEnd==nil then
					break;				
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
					break;				
				end
				tmp=string.sub(szStructText,nBegin,nEnd);
				tmp=trim(tmp);		
			end
		elseif string.find(tmp,"\"")~=nil then
			local nTmpPos=string.find(tmp,"\"");--第一个位置
			if string.find(tmp,"\"",nTmpPos+1)==nil then
				nTmpPos,nEnd=string.find(szStructText,"%b\"\"",nBegin);
				if nEnd==nil then
					break;				
				end
				tmp=string.sub(szStructText,nBegin,nEnd);
				tmp=trim(tmp);		
			end
		end
		ffmpeg_struct_get_var_to_table_line(tmp,vartbl);
		nBegin=nEnd+lineflaglen;
		nEnd=string.find(szStructText,lineflag,nBegin);
	end
	tmp=string.sub(szStructText,nBegin);
	tmp=trim(tmp);
	if string.len(tmp)>0 then
		ffmpeg_struct_get_var_to_table_line(tmp,vartbl);
	end
	return vartbl;
end
--[[
函数:ffmpeg_struct_var_is_has_define
功能:判断结构体变量转是否含有宏定义
参数:szvar=string
返回:boolean
]]--
function ffmpeg_struct_var_is_has_define(szvar)
	return line_is_have_define(szvar);
end

function ffmpeg_struct_var_in_define(szvar)
	if string.find(szvar,"##")~=nil then
		return true;	
	end
	return false;
end
function ffmpeg_struct_line_var_dispose(line)
	--line=trim(line);
	local name,value;
	local nBegin,nEnd;
	nBegin=string.find(line,"%.");
	nEnd=string.find(line,"=");
	if nEnd==nil then
		value=trim(line);
		if(string.len(value))<1 then
			print("this line is null,",line);return ;
		end
		return name,value;
	end
	if nBegin==nil then
		nBegin=1;	
	end
	name=string.sub(line,nBegin+1,nEnd-1);
	--name=trim(name);
	value=string.sub(line,nEnd+1);
	return trim(name),trim(value);
end

--[[
函数:ffmpeg_struct_table_is_item_is_array
功能:判断是否是数组
参数:
返回:boolean
]]--
function ffmpeg_struct_table_is_item_is_array(line)
	line=trim(line);
	local nPos=string.find(line,"{");
	if nPos~=nil and nPos~=1 then
		return true;	
	end
	return false;
end
local ffmpeg_var_index=1;
function ffmpeg_struct_create_var_name(itemName,fileName)
	ffmpeg_var_index=ffmpeg_var_index+1;
	return fileName.."_"..itemName.."_"..tostring(ffmpeg_var_index);
end
--[[
函数:ffmpeg_struct_table_array_add_value
功能:创建数组变量
参数:
返回:string,string
]]--
function ffmpeg_struct_table_array_add_value(szText,itemName,fileName,isdef,szVarStructName)
	local szArray;
	local szName;
	local szVarName;
	local nBegin=string.find(szText,"{");
	szArray=" = "..string.sub(szText,nBegin);
	szName=string.sub(szText,1,nBegin-1);
	szName="static "..string.gsub(szName,"[%(%)]","");--删除括号
	--加上变量名
	nBegin=string.find(szName,"%[");
	szVarName=ffmpeg_struct_create_var_name(itemName,fileName);--生成变量名
	--if isdef then
		szVarName=szVarName..szVarStructName;
	--end
	if nBegin==nil then
		szName=szName.." "..szVarName;
	else
		szName=string.sub(szName,1,nBegin-1).." "..szVarName.." "..string.sub(szName,nBegin);
	end
	szArray=szName..szArray..";";
	return szArray,szVarName;
end
function GetTableCount(tbl)
		local nCount=0;
		for index,value in pairs(tbl) do
			nCount=nCount+1;
		end
		return nCount;
end
function ffmpeg_struct_table_create_default_val(typedeftbl,vartbl,isdef,szName,szShortFile)
	
	function ffmpeg_struct_table_create_default_val_tostring(vartable,nIndex,valuetbl,szShortFile,nTblCount,isdef,szName)
		local sztmp;
		local szarray;
		if vartable[nIndex]~=nil then--按照顺序取
			if type(vartable[nIndex])=="table" then
				szarray,sztmp=ffmpeg_struct_def_create_default_val(vartable[nIndex],valuetbl.name,szShortFile,isdef,szName);
			elseif not (ffmpeg_struct_table_is_item_is_array(vartable[nIndex])) then
					sztmp=vartable[nIndex];
					if isdef and sztmp~=nil then
						sztmp=sztmp..",";
					end;
			else
					szarray,sztmp=ffmpeg_struct_table_array_add_value(vartable[nIndex],valuetbl.name,szShortFile,isdef,szName);
					if isdef and sztmp~=nil then
						sztmp=sztmp..",";
					end;
			end
				nTblCount=nTblCount-1;
		elseif 	vartable[valuetbl.name] ~=nil then--按照名称取
			if type(vartable[valuetbl.name])=="table" then
				szarray,sztmp=ffmpeg_struct_def_create_default_val(vartable[valuetbl.name],valuetbl.name,szShortFile,isdef,szName);
			elseif not (ffmpeg_struct_table_is_item_is_array(vartable[valuetbl.name])) then
					sztmp=vartable[valuetbl.name];
					if isdef and sztmp~=nil then
						sztmp=sztmp..",";
					end;
			else
					szarray,sztmp=ffmpeg_struct_table_array_add_value(vartable[valuetbl.name],valuetbl.name,szShortFile,isdef,szName);
					if isdef and sztmp~=nil then
						sztmp=sztmp..",";
					end;
			end
			nTblCount=nTblCount-1;
		else--按照名称到定义表取默认值
			print("valuetbl.default=",valuetbl.default);
			sztmp=valuetbl.default;
			if isdef and sztmp~=nil then
				sztmp=sztmp..",";
			end;
		end
		
		return sztmp,szarray,nTblCount;
	end
	local szText="";
	local nIndex=1;--vartbl索引值
	local szArray="";
	local nVarTblCount=GetTableCount(vartbl);
	local flag1;
	for index,value in pairs(typedeftbl) do
		local tmp;
		local array;
		if nVarTblCount==0 then
			print("vartbl count is zero.",szShortFile);
			break;		
		end
		if value.t=="define" then--含有宏定义
			
			for index2,value2 in pairs(value.list) do
				--print("index=",index2,"value=",value2);
				
				for itemIndex,itemValue in pairs(value2) do 
					--print("index=",itemIndex,"value=",itemValue);
					szText=szText.."#if "..itemIndex.."\n"
					for itemIndextbl,itemValuetbl in pairs(itemValue) do
						tmp,array,nVarTblCount=ffmpeg_struct_table_create_default_val_tostring(vartbl,nIndex,itemValuetbl,szShortFile,nVarTblCount,isdef,szName);
						if isdef then
							flag1="";
						else
							flag1=","
						end
						szText=szText..tmp..flag1.."/*"..itemValuetbl.name.."*/\n";					
					end
					szText=szText.."#endif\n";
				end		
				
			end
		else
			--print("dispose name=",value.name);
			if isdef then
				flag1="";
			else
				flag1=","
			end
			tmp,array,nVarTblCount=ffmpeg_struct_table_create_default_val_tostring(vartbl,nIndex,value,szShortFile,nVarTblCount,isdef,szName);
			szText=szText..tmp..flag1.."/*"..value.name.."*/\n";
		end
		if array~=nil then
			szArray=szArray..array.."/*"..value.name.."*/\n";
		end;
		nIndex=nIndex+1;
	end
	return szText,szArray;
end

--[[
函数:ffmpeg_struct_var_Repalce
功能:替换该文件中struct变量
参数:
返回:
]]--
function ffmpeg_struct_var_Repalce(szFileName,avcodectbl,structName)
	local file=io.open(szFileName,"r");
	if(file==nil) then
		print("open file error",szFileName);
		return ;	
	end
	print("dispose struct",structName);
	local szText=file:read("*a");
	file:close();
	file=nil;
	local nBegin,nEnd;
	local szAvcodecVar;
	local szShortFile=getFileShortName(szFileName);
	local nModifyCount=0;--查找需修改个数
	nEnd=1;
	
	szAvcodecVar,nBegin,nEnd=ffmpeg_struct_get_var_text(szText,structName,nEnd);
	while szAvcodecVar~=nil do
		local szRepalce,szAddArray;
		local newText;
		szAvcodecVar=ffmpeg_remove_c_struct_text_comment(szAvcodecVar);--删除所有注释
		if (not ffmpeg_struct_var_is_has_define(szAvcodecVar))and
		(not ffmpeg_struct_var_in_define(szAvcodecVar)) then--处理不含有宏定义的文件
			local tbl=ffmpeg_struct_get_var_to_table(szAvcodecVar);
			if tbl~=nil then
				local name=ffmpeg_struct_get_var_name(szAvcodecVar);
				szRepalce,szAddArray=ffmpeg_struct_table_create_default_val(avcodectbl,tbl,false,name,szShortFile);--创建默认值
				szRepalce=structName.." "..name.." = {\n"..szRepalce.."\n}";
				newText="\n"..szAddArray.."\n"..szRepalce;
			else
				break;
			end
		elseif (not ffmpeg_struct_var_in_define(szAvcodecVar)) then--内含有宏定义
			print("this file has define.",szFileName);
			local tbl=ffmpeg_struct_var_define_to_table(szAvcodecVar);
			if tbl~=nil then
				local name=ffmpeg_struct_get_var_name(szAvcodecVar);
				szRepalce,szAddArray=ffmpeg_struct_table_create_default_val(avcodectbl,tbl,true,name,szShortFile);--创建默认值
				szRepalce=structName.." "..name.." = {\n"..szRepalce.."\n}";
				newText="\n"..szAddArray.."\n"..szRepalce;
			else
				break;
			end
		else--包含在宏定义中
			print("this file in define.",szFileName);
			szAvcodecVar=ffmpeg_struct_def_remove_lineflag(szAvcodecVar);
			local tbl=ffmpeg_struct_get_var_to_table(szAvcodecVar);
			if tbl~=nil then
				local name=ffmpeg_struct_get_var_name(szAvcodecVar);
				szRepalce,szAddArray=ffmpeg_struct_table_create_default_val(avcodectbl,tbl,false,name,szShortFile);--创建默认值
				szRepalce=ffmpeg_struct_def_add_lineflag(szRepalce);--添加\
				szRepalce=structName.." "..name.." = {\\\n"..szRepalce.."\\\n}";
				szAddArray=ffmpeg_struct_def_remove_mulite_line(szAddArray);--删除换行
				newText="\n"..szAddArray.."\\\n"..szRepalce;
			else
				break;
			end
		end;
		if newText~=nil then
			szText=string.sub(szText,1,nBegin-1)..newText..string.sub(szText,nEnd+1);--替换其中内容
		end
		szAvcodecVar,nBegin,nEnd=ffmpeg_struct_get_var_text(szText,structName,nBegin+string.len(newText));
		nModifyCount=nModifyCount+1;
	end
	if nModifyCount==0 then
		print("file=",szFileName,"not var modify=",structName);
		return -1;
	end
	file=io.open(szFileName,"w");
	if (file==nil) then
		print("open file error,can't not write.",szFileName);
		return ;
	end
	file:write(szText);
	file:close();
	print("dispose end struct",structName);
	return 0;
end