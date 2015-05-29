--[[
描述:		ffmpeg common 解析模块
作者:		weiny zhou
创建日期:	2012-04-29
修改日期:	2012-07-05
版权:		版权所有，未经授权不得擅自拷贝复制或传播本代码的部分或全部.违者必究!
]]--
szffmpegPath=curPath.."/ffmpeg/";
dofile(szffmpegPath.."/config"..luaExt);
dofile(szffmpegPath.."/makefile"..luaExt);
dofile(szffmpegPath.."/ffmpeg"..luaExt);
dofile(szffmpegPath.."/ffmpeg_proj"..luaExt);
dofile(szffmpegPath.."/func_type"..luaExt);
dofile(szffmpegPath.."/ffmpeg_amr"..luaExt);
dofile(szffmpegPath.."/ffmpeg_array"..luaExt);
dofile(szffmpegPath.."/ffmpeg_option"..luaExt);
dofile(szffmpegPath.."/ffmpeg_struct_def"..luaExt);
dofile(szffmpegPath.."/ffmpeg_struct"..luaExt);
dofile(szffmpegPath.."/ffmpeg_struct_array"..luaExt);
dofile(szffmpegPath.."/ffmpeg_const_struct"..luaExt);
dofile(szffmpegPath.."/ffmpeg_enum"..luaExt);
dofile(szffmpegPath.."/ffmpeg_struct_array_ex"..luaExt);
dofile(szffmpegPath.."/avcodec/avcodec_struct"..luaExt);
dofile(szffmpegPath.."/avcodec/avcodec"..luaExt);
dofile(szffmpegPath.."/avdevice/avdevice_struct"..luaExt);
dofile(szffmpegPath.."/avdevice/avdevice"..luaExt);
dofile(szffmpegPath.."/avfilter/avfilter_struct"..luaExt);
dofile(szffmpegPath.."/avfilter/avfilter"..luaExt);
dofile(szffmpegPath.."/avformat/avformat_struct"..luaExt);
dofile(szffmpegPath.."/avformat/avformat"..luaExt);
dofile(szffmpegPath.."/avresample/avresample_struct"..luaExt);
dofile(szffmpegPath.."/avresample/avresample"..luaExt);
dofile(szffmpegPath.."/avutil/avutil_struct"..luaExt);
dofile(szffmpegPath.."/avutil/avutil"..luaExt);
dofile(szffmpegPath.."/postproc/postproc_struct"..luaExt);
dofile(szffmpegPath.."/postproc/postproc"..luaExt);
dofile(szffmpegPath.."/swresample/swresample_struct"..luaExt);
dofile(szffmpegPath.."/swresample/swresample"..luaExt);
dofile(szffmpegPath.."/swscale/swscale_struct"..luaExt);
dofile(szffmpegPath.."/swscale/swscale"..luaExt);
print("******************************************************");
print("*                                                    *");
print("*名称:ffmpeg 转VC工具  V1.1.3                        *");
print("*作者:Weiny Zhou                                     *");
print("*创建日期:2012-04-30                                 *");
print("*修改日期:2012-07-05                                 *");
print("*联系方式:weinyzhou86@gmail.com                                 *");
print("*版权:版权归Weiny Zhou所有，未经允许不得擅自拷贝复制 *");
print("*程序的部分或全部.违者必究.                          *");
print("*                                                    *");
print("******************************************************");