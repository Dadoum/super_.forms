cmake_minimum_required(VERSION 3.20)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/cmake-d/cmake-d)
project(super_forms D)

set(win32_default OFF)
set(cocoa_default OFF)
set(wayland_default OFF)
set(x11_default OFF)

if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|AMD64|X86_64|amd64")
    set(arch_id x64)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "x86$|X86$")
    set(arch_id x32)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64")
    set(arch_id arm64)
endif()

if(WIN32 OR MSVC OR MSYS OR MINGW)
    set(win32_default ON)
elseif(APPLE)
    set(cocoa_default ON)
elseif(UNIX AND NOT APPLE)
    set(wayland_default ON)
    set(x11_default ON)
else()
    message(WARNING "Unsupported OS; no backend is enabled by default. ")
endif()

option(has_win32    "Win32 support"      ${win32_default})
option(has_cocoa    "Cocoa/STeP support" ${cocoa_default})
option(has_wayland  "Wayland support"    ${wayland_default})
option(has_x11      "X11 support"        ${x11_default})

  ############################################
 ############### Dependencies ###############
############################################

#### DUB DEPENDENCIES ####
include(UseDub)
DubProject_Add(ddbus ~3.0.0-beta.2)
DubProject_Add(erupted ~2.1.45+v1.2.195)
DubProject_Add(eventsystem ~2.0.0)

########## SKIA ##########
if (SHARED_SKIA)
    set(SKIA_TMP_PATH ${CMAKE_BINARY_DIR}/SkiaSharp/ CACHE PATH "Skia path")
    file(MAKE_DIRECTORY ${SKIA_TMP_PATH})

    if(WIN32 OR MSVC OR MSYS OR MINGW)
        set(skia_identifier Win32)
    elseif(APPLE)
        set(skia_identifier macOS)
    elseif(UNIX AND NOT APPLE)
        set(skia_identifier Linux)
    else()
        message(FATAL "Unsupported OS; Build SkiaSharp and place it yourself. ")
    endif()

    string(TOLOWER ${skia_identifier} skia_url_identifier)
    file(DOWNLOAD "https://globalcdn.nuget.org/packages/skiasharp.nativeassets.${skia_url_identifier}.2.88.0-preview.179.nupkg"
            "${SKIA_TMP_PATH}/skia.zip")

    file(MAKE_DIRECTORY ${SKIA_TMP_PATH}/source/)

    file(ARCHIVE_EXTRACT
            INPUT ${SKIA_TMP_PATH}/skia.zip
            DESTINATION ${SKIA_TMP_PATH}/
    )

    add_library(skia SHARED IMPORTED GLOBAL)

    if(WIN32 OR MSVC OR MSYS OR MINGW)
        set_property(TARGET skia PROPERTY IMPORTED_LOCATION ${SKIA_TMP_PATH}/runtimes/win-${arch_id}/native/libSkiaSharp.dll)
    elseif(APPLE)
        set_property(TARGET skia PROPERTY IMPORTED_LOCATION ${SKIA_TMP_PATH}/runtimes/osx/native/libSkiaSharp.dylib)
    elseif(UNIX AND NOT APPLE)
        set_property(TARGET skia PROPERTY IMPORTED_LOCATION ${SKIA_TMP_PATH}/runtimes/linux-${arch_id}/native/libSkiaSharp.so)
    endif()
else()
    add_library(skia STATIC IMPORTED GLOBAL)
    target_link_directories(skia INTERFACE skia/)
    target_link_libraries(skia INTERFACE fontconfig freetype2 jpeg particles pathkit png skottie skparagraph skresources sksg skshaper stdc++ webp webpmux webpdemux)
    set_property(TARGET skia PROPERTY IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/skia/libskia.a)
endif()

  #############################################
 ################ super.forms ################
#############################################
set(SUPER_FORMS_SOURCE_DIR "lib/")
file(GLOB_RECURSE SUPER_FORMS_SOURCES "${SUPER_FORMS_SOURCE_DIR}*.d")

add_library(super_forms ${SUPER_FORMS_SOURCES})

if (has_win32)
    target_compile_versions(super_forms PRIVATE Windows32)
endif()
if (has_cocoa)
    target_compile_versions(super_forms PRIVATE Cocoa)
endif()
if (has_wayland)
    target_compile_versions(super_forms PRIVATE Wayland)
endif()
if (has_x11)
    DubProject_Add(xcb-d ~2.1.1+1.11.1)
    target_compile_versions(super_forms PRIVATE X11)
    target_link_libraries(super_forms PRIVATE xcb-d)
endif()

target_include_directories(super_forms PUBLIC "${SUPER_FORMS_SOURCE_DIR}")
target_link_libraries(super_forms PUBLIC ddbus erupted eventsystem skia)

  #############################################
 ########### super.forms - example ###########
#############################################
set(SUPER_FORMS_EXAMPLE_SOURCE_DIR "example/")
file(GLOB_RECURSE SUPER_FORMS_EXAMPLE_SOURCES "${SUPER_FORMS_EXAMPLE_SOURCE_DIR}*.d")

add_executable(super_forms_example ${SUPER_FORMS_EXAMPLE_SOURCES})
target_include_directories(super_forms_example PUBLIC "${SUPER_FORMS_EXAMPLE_SOURCE_DIR}")
target_link_libraries(super_forms_example super_forms)
