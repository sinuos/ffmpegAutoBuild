--[[
描述:		vc 项目生成模块
作者:		weiny zhou
创建日期:	2012-07-05
修改日期:	2012-07-05
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--



function android_create_mk(szFileName,szProject,szInclude,szDefine,szLibs)
	local szBegin="LOCAL_PATH := $(call my-dir)/../\n\n"..
			"include $(CLEAR_VARS)\n\n"..
			"LOCAL_MODULE := "..szProject.."\n\n"..
			"include $(LOCAL_PATH)/config.mak\n\n"..
			"LOCAL_CFLAGS := -ffast-math -O3 -DHAVE_AV_CONFIG_H -DNDEBUG=1 -DW_NOT_PRINTF=1 -D__GNU__ "..szDefine.." -DPRO_TAG=\"\\\""..szProject.."\\\"\"".."\n\n"..
			""
	local szEnd="LOCAL_ARM_MODE := arm\n\n"..
			"include $(BUILD_STATIC_LIBRARY)";
	return szBegin,szEnd;
end