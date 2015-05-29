--[[
描述:		paser 解析模块
作者:		weiny zhou
创建日期:	2012-04-29
修改日期:	2012-04-29
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--
--LOG
--[[
--datetime
	1.修改编译选项，添加宏定义
	2.添加android生成项.
]]--
gcc={
	build={
		debug={
			buildHead="gcc -c  -O0 -D_WIN32 -DHAVE_CONFIG_H=1 -DUNICODE -D_UNICODE -DWIN32 -D_DEBUG -D_MT -D_DLL -I&quot;$(WSYSEX_INC)/zlib&quot; ",
			buildFoot="$(InputPath) -o $(IntDir)/$(InputName).obj",
			},
		release={
				buildHead="gcc -c -O2 -D_WIN32 -DHAVE_CONFIG_H=1  -DUNICODE -D_UNICODE -DWIN32 -D_WIN32 -DNDEBUG -D_MT -D_DLL -I&quot;$(WSYSEX_INC)/zlib&quot; ",
				buildFoot="$(InputPath) -o $(IntDir)/$(InputName).obj",
			}
	},
	
	print="Assembly $(InputPath)",
	target="$(IntDir)/$(InputName).obj"
	};--gcc编译器路径
yasm={
	build={
		debug={
			buildHead="yasm -f win32 -O0 -D_WIN32 -DHAVE_CONFIG_H=1 -DPREFIX  ",
			buildFoot="-o &quot;$(IntDir)/$(InputName)&quot;.obj &quot;$(InputPath)&quot;",
			},
		release={
			buildHead="yasm -f win32 -O2 -D_WIN32 -DHAVE_CONFIG_H=1 -DPREFIX  ",
			buildFoot="-o &quot;$(IntDir)/$(InputName)&quot;.obj &quot;$(InputPath)&quot;",
		}
	},
	print="Assembly $(InputPath)",
	target="$(IntDir)/$(InputName).obj"
	};--yasm汇编编译器路径
nasm={
	build={
		debug={
			buildHead="nasm -f win32 -O0 -DWINDOWS -D_WIN32 -DHAVE_CONFIG_H=1  ",
			buildFoot="-o $(IntDir)/$(InputName).obj $(InputPath)",
			},
		release={
			buildHead="nasm -f win32 -O2 -DWINDOWS -D_WIN32 -DHAVE_CONFIG_H=1  ",
			buildFoot="-o $(IntDir)/$(InputName).obj $(InputPath)",
			}
		},
	print="Assembly $(InputPath)",
	target="$(IntDir)/$(InputName).obj"
	};--nasm汇编编译器路径
clang={build={
	debug={
		buildHead="clang -cc1 -triple i686-pc-win32 -emit-llvm-bc -disable-free -disable-llvm-verifier -main-file-name &quot;$(InputFileName)&quot; "
		.."  -mrelocation-model static -mdisable-fp-elim -masm-verbose -mconstructor-aliases -target-cpu pentium4 -momit-leaf-frame-pointer -coverage-file  &quot;$(IntDir)/$(InputName).obj&quot;"
		.." -nostdsysteminc -nobuiltininc -resource-dir &quot;"..CLANG_RESOURCE_DIRS.."&quot; ",
		buildFoot=" -DUNICODE -D_UNICODE -DWIN32 -D_WIN32 -D_DEBUG -D_MT -D_DLL -DHAVE_CONFIG_H=1 -DWINDOWS "
		.." -fmodule-cache-path &quot;".."$(TEMP)/clang-module-cache".."&quot;  -O0 -ferror-limit 19 -fmessage-length 0 -mstackrealign -fms-extensions -fms-compatibility"
		.." -fmsc-version=1500 -fdelayed-template-parsing -fno-inline -fgnu-runtime -fobjc-runtime-has-arc -fobjc-runtime-has-weak -fobjc-fragile-abi -fdiagnostics-show-option -fdiagnostics-format msvc -o "
		.." &quot;$(IntDir)/$(InputName).obj&quot;  -x c &quot;$(InputPath)&quot; "
		},
	release={
		buildHead="clang  -cc1 -triple i686-pc-win32 -emit-llvm-bc -disable-free -disable-llvm-verifier -main-file-name &quot;$(InputFileName)&quot;"
		.." -mrelocation-model static -mdisable-fp-elim -masm-verbose -mconstructor-aliases -target-cpu pentium4 -momit-leaf-frame-pointer -coverage-file &quot;$(IntDir)/$(InputName).obj&quot;"
		.."  -nostdsysteminc -nobuiltininc -resource-dir &quot;"..CLANG_RESOURCE_DIRS.."&quot; ",
		buildFoot=" -DUNICODE -D_UNICODE -DWIN32 -D_WIN32 -DNDEBUG -D_MT -D_DLL -DHAVE_CONFIG_H=1 -DWINDOWS -fmodule-cache-path &quot;".."$(TEMP)/clang-module-cache".."&quot; "
		.." -O2 -ferror-limit 19 -fmessage-length 0 -mstackrealign -fms-extensions -fms-compatibility -fmsc-version=1500 -fdelayed-template-parsing -fgnu-runtime -fobjc-runtime-has-arc -fobjc-runtime-has-weak -fobjc-fragile-abi -fdiagnostics-show-option -fdiagnostics-format msvc -o "
		.." &quot;$(IntDir)/$(InputName).obj&quot; -x c &quot;$(InputPath)&quot; "
		}
	},
	print="Assembly $(InputPath)",
	target="$(IntDir)/$(InputName).obj"
	};--clang 编译器路径
	--SHORTFILENAME这些必须替换
--项目生成类型
project_type={
	makefile=0,
	vc=1,
	android=2,
	ios=3
};
dofile(curPath.."/project/vc/build_vc"..luaExt);
dofile(curPath.."/project/android/build_android"..luaExt);
dofile(curPath.."/public/luastring"..luaExt);
dofile(curPath.."/public/luafile"..luaExt);
dofile(curPath.."/ffmpeg/common"..luaExt);

