cmake_minimum_required(VERSION 3.20)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/cmake-d/cmake-d)
project(super_forms D)

set(win32_default OFF)
set(cocoa_default OFF)
set(wayland_default OFF)
set(x11_default OFF)

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
option(has_cocoa    "Cocoa/STEP support" ${cocoa_default})
option(has_wayland  "Wayland support"    ${wayland_default})
option(has_x11      "X11 support"        ${x11_default})

option(has_vulkan_render    "Vulkan renderer support"   ON)
option(has_opengl_render    "OpenGL renderer support"   ON)
option(has_software_render  "Software renderer support" ON)

  ############################################
 ############### super_.forms ###############
############################################

set(SUPER_FORMS_SOURCE_DIR "lib/")
file(GLOB_RECURSE SUPER_FORMS_SOURCES "${SUPER_FORMS_SOURCE_DIR}*.d")

add_library(super_forms ${SUPER_FORMS_SOURCES})
target_include_directories(super_forms PUBLIC "${SUPER_FORMS_SOURCE_DIR}")

if (has_win32)
    target_compile_versions(super_forms PRIVATE User32)
endif()
if (has_cocoa)
    target_compile_versions(super_forms PRIVATE Cocoa)
endif()
if (has_wayland)
    target_compile_versions(super_forms PRIVATE Wayland)
endif()
if (has_x11)
    target_compile_versions(super_forms PRIVATE X11)
endif()

if (has_vulkan_render)
    target_compile_versions(super_forms PRIVATE VulkanRender)
endif()
if (has_opengl_render)
    target_compile_versions(super_forms PRIVATE OpenGLRender)
endif()
if (has_software_render)
    target_compile_versions(super_forms PRIVATE SoftwareRender)
endif()

   # ###########################################
  # ############## Dependencies ###############
 # ###########################################

include(FetchContent)
include(UseDub)

DubProject_Add(ddbus ~3.0.0-beta.2)
DubProject_Add(erupted ~2.1.45+v1.2.195)
DubProject_Add(eventsystem ~2.0.0)

target_link_libraries(super_forms PUBLIC ddbus erupted eventsystem)

if (has_win32)

endif()
if (has_cocoa)

endif()
if (has_wayland)

endif()
if (has_x11)
    DubProject_Add(xcb-d ~2.1.1+1.11.1)
    target_link_libraries(super_forms PRIVATE xcb-d)
endif()

if (has_vulkan_render)
    FetchContent_Declare(
            vkvg
            GIT_REPOSITORY https://github.com/jpbruyere/vkvg.git
            GIT_TAG v0.2.1
    )
    FetchContent_MakeAvailable(vkvg)
    target_link_libraries(super_forms PUBLIC vkvg_static stdc++)
endif()

if (has_software_render)

endif()

  ############################################
 ########## super_.forms - example ##########
############################################
set(SUPER_FORMS_EXAMPLE_SOURCE_DIR "example/")
file(GLOB_RECURSE SUPER_FORMS_EXAMPLE_SOURCES "${SUPER_FORMS_EXAMPLE_SOURCE_DIR}*.d")

add_executable(super_forms_example ${SUPER_FORMS_EXAMPLE_SOURCES})
target_include_directories(super_forms_example PUBLIC "${SUPER_FORMS_EXAMPLE_SOURCE_DIR}")
target_link_libraries(super_forms_example super_forms)
