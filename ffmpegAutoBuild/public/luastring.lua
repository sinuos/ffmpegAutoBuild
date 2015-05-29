--[[
描述:		lua string　字符串处理 相关lua文件
作者:		weiny zhou
创建日期:	2012-02-28
修改日期:	2012-02-28
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--

--[[
函数:lua_string_split
功能:字符串分割
]]--
function lua_string_split(str, split_char)
    local sub_str_tab = {};
    while (true) do
        local pos = string.find(str, split_char);
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str;
            break;
        end
        local sub_str = string.sub(str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        str = string.sub(str, pos + 1, #str);
    end

    return sub_str_tab;
end

function trim (s) 
return (string.gsub(s, "^%s*(.-)%s*$", "%1"));
end
--[[
function trim__(s)
  return s:match "^%s*(.-)%s*$"
end
function trim(s)
  return s:match"^%s*(.*)":match"(.-)%s*$"
end
]]--

function strhextoint(szHex)
	return tonumber(szHex,16);
end
function strtoint(str)
	if string.len(str)>2 then
		local tmp=string.sub(str,1,2);
		tmp=string.lower(tmp);
		if tmp=="0x" then
			return strhextoint(string.sub(str,3));
		end
	end
	return tonumber(str);
end
--[[
函数:mathstroperation
功能:数学运算计算表达式,并返回结果
参数:
返回:string
]]--
function mathstroperation(szExpre)
	function hexstrtointstr(s)
		return tostring(strtoint(s));
	end
	szExpre=string.lower(szExpre);
	if string.find(szExpre,"[^%(%)%+%-%*/%xx%s]+") then
		return ;
	end
	szExpre=string.gsub(szExpre,"0x[%x]+",hexstrtointstr);
	szExpre="return "..szExpre;
	return loadstring(szExpre)();
end

--ansi数学运算
function charMathOperation(str)
	function chartoint(chstr)
		chstr=string.sub(chstr,2,2);
		return tostring(string.byte(chstr));
	end
	str=string.gsub(str,"%b''",chartoint);
	str="return "..str;
	return loadstring(str)();
end
