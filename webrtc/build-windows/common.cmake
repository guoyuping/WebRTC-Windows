#=======================
#  WebRTC common settings
#=======================

# cmake ��֧�� architecture��û��Ԥ����ı���
# ������ֹ�ָ����
set (target_arch "x64")

set (build_with_libjingle 0)
set (webrtc_root "")
set (webrtc_vp8_dir "")

# Adds video support to dependencies shared by voice and video engine.
# This should normally be enabled; the intended use is to disable only
# when building voice engine exclusively.
set (enable_video 1)
    # Selects fixed-point code where possible.
set (prefer_fixed_point  0)

# Enable data logging. Produces text files with data logged within engines
# which can be easily parsed for offline processing.
set (enable_data_logging 0)

# Enables the use of protocol buffers for debug recordings.
set (enable_protobuf  1)

# Disable these to not build components which can be externally provided.
set (build_libjpeg  1)
set (build_libyuv 1)
set (build_libvpx  1)
set (libyuv_dir "../..//third_party/libyuv")

if (${enable_video})
	add_definitions(-DWEBRTC_MODULE_UTILITY_VIDEO)
endif()

if (MSVC)
	add_definitions(-DWEBRTC_WIN)
	# TODO(andrew): enable all warnings when possible.
	# TODO(phoglund): get rid of 4373 supression when
	# http://code.google.com/p/webrtc/issues/detail?id=261 is solved.
	set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} /wd4373  /wd4389")
	set(CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO} /wd4373  /wd4389")
elseif (UNIX)
	add_definitions(-DWEBRTC_LINUX)
endif()








###################################################
#  list functions from  curl/CMake/Utilities.cmake
###################################################


# File containing various utilities

# Converts a CMake list to a string containing elements separated by spaces
function(TO_LIST_SPACES _LIST_NAME OUTPUT_VAR)
  set(NEW_LIST_SPACE)
  foreach(ITEM ${${_LIST_NAME}})
    set(NEW_LIST_SPACE "${NEW_LIST_SPACE} ${ITEM}")
  endforeach()
  string(STRIP ${NEW_LIST_SPACE} NEW_LIST_SPACE)
  set(${OUTPUT_VAR} "${NEW_LIST_SPACE}" PARENT_SCOPE)
endfunction()

# Appends a lis of item to a string which is a space-separated list, if they don't already exist.
function(LIST_SPACES_APPEND_ONCE LIST_NAME)
  string(REPLACE " " ";" _LIST ${${LIST_NAME}})
  list(APPEND _LIST ${ARGN})
  list(REMOVE_DUPLICATES _LIST)
  to_list_spaces(_LIST NEW_LIST_SPACE)
  set(${LIST_NAME} "${NEW_LIST_SPACE}" PARENT_SCOPE)
endfunction()

# Convinience function that does the same as LIST(FIND ...) but with a TRUE/FALSE return value.
# Ex: IN_STR_LIST(MY_LIST "Searched item" WAS_FOUND)
function(IN_STR_LIST LIST_NAME ITEM_SEARCHED RETVAL)
  list(FIND ${LIST_NAME} ${ITEM_SEARCHED} FIND_POS)
  if(${FIND_POS} EQUAL -1)
    set(${RETVAL} FALSE PARENT_SCOPE)
  else()
    set(${RETVAL} TRUE PARENT_SCOPE)
  endif()
endfunction()




################################################
# functions to extract platform specific source 
################################################

function (extract_windows_source source_list out_arg)
	set (new_source_list)
	foreach (source_name ${${source_list}})
		if (NOT source_name MATCHES "(_mac\\.h$|_mac\\.cc$|_posix\\.cc$|_posix\\.h$)")
			#message(STATUS "source_name =${source_name}")
			list(APPEND new_source_list ${source_name})
		endif()
	endforeach()
	set(${out_arg} ${new_source_list} PARENT_SCOPE)
endfunction()

function (extract_linux_source source_list out_arg)
	set (new_source_list)
	foreach (source_name ${${source_list}})
		if (NOT source_name MATCHES "_win\\.h$|_win\\.cc$|_mac\\.cc$|_mac\\.h$")
			list(APPEND new_source_list ${source_name})
		endif()
	endforeach()
	set(${out_arg} ${new_source_list} PARENT_SCOPE)
endfunction()

function (extract_platform_specific_source source_list)
	if (MSVC)
		extract_windows_source(${source_list} new_source_list)
	elseif(UNIX)
		extract_linux_source(${source_list} new_source_list)
	endif()
	set(${source_list} ${new_source_list} PARENT_SCOPE)
endfunction()