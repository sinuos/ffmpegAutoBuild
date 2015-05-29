--[[
描述:		文件处理模块
作者:		weiny zhou
创建日期:	2012-04-29
修改日期:	2012-04-29
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--

function getFileExt(szFileName)
	return szFileName:match(".+%.(%w+)$");
end

function getFileRemoveExt(szFileName)
	local idx = szFileName:match(".+()%.%w+$");
	if(idx) then
		return szFileName:sub(1, idx-1);
	else
		return szFileName;
	end
end
function getFileShortName(szFileName)
	local filename=getFileName(szFileName);
	local ext=getFileExt(filename);
	return string.sub(filename,1,string.len(filename)-string.len(ext)-1);
end
function getFileName(szFileName)
	return string.match(szFileName,".+/([^/]*%.%w+)$");
	--return string.match(filename, ".+\\([^\\]*%.%w+)$");
end
function getFilePath(szFileName)
	return string.match(szFileName, "(.+)/[^/]*%.%w+$");-- *nix system
	--return string.match(filename, “(.+)\\[^\\]*%.%w+$”) — windows
end
function isExist(szFileName)
	local file=io.open(szFileName,"rb");
	if file==nil then
		return false;	
	end
	io.close(file);
	return true;
end
