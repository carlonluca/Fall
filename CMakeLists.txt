#
# GPLv3 license
#
# Copyright (c) 2021 Luca Carlon
#
# This file is part of Fall
#
# Fall is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Fall is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Fall.  If not, see <http://www.gnu.org/licenses/>.
#

cmake_minimum_required(VERSION 3.14)

project(Fall VERSION 0.1 LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(BUILD_PIAV "Build PiAV support" OFF)

# QtCreator supports the following variables for Android, which are identical to qmake Android variables.
# Check https://doc.qt.io/qt/deployment-android.html for more information.
# They need to be set before the find_package(...) calls below.

#if(ANDROID)
#    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
#    if (ANDROID_ABI STREQUAL "armeabi-v7a")
#        set(ANDROID_EXTRA_LIBS
#            ${CMAKE_CURRENT_SOURCE_DIR}/path/to/libcrypto.so
#            ${CMAKE_CURRENT_SOURCE_DIR}/path/to/libssl.so)
#    endif()
#endif()

find_package(QT NAMES Qt6 Qt5 COMPONENTS Core Quick Multimedia REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS Core Quick DBus Multimedia REQUIRED)

if(BUILD_PIAV)
    find_library(AVDEVICE_LIBRARY REQUIRED NAMES avdevice)
    find_library(AVCODEC_LIBRARY REQUIRED NAMES avcodec)
    find_library(AVFILTER_LIBRARY REQUIRED NAMES avfilter)
    find_library(AVFORMAT_LIBRARY REQUIRED NAMES avformat)
    find_library(AVUTIL_LIBRARY REQUIRED NAMES avutil)
    find_library(SWRESAMPLE_LIBRARY REQUIRED NAMES swresample)
    find_library(SWSCALE_LIBRARY REQUIRED NAMES swscale)

    set(LINK_LIBAV ${AVDEVICE_LIBRARY} ${AVFILTER_LIBRARY} ${AVCODEC_LIBRARY} ${AVFORMAT_LIBRARY} ${AVUTIL_LIBRARY} ${SWRESAMPLE_LIBRARY} ${SWSCALE_LIBRARY})
    set(LINK_PULSE -L${CMAKE_SYSROOT}/usr/lib/arm-linux-gnueabihf/pulseaudio -lpulsecommon-14.2)
    set(LINK_BLAS  -L${CMAKE_SYSROOT}/usr/lib/arm-linux-gnueabihf/blas -lblas)
    set(LINK_LAPACK  -L${CMAKE_SYSROOT}/usr/lib/arm-linux-gnueabihf/lapack -llapack)
endif()

include(${CMAKE_CURRENT_SOURCE_DIR}/lqtutils/CMakeLists.txt)
set(PROJECT_SOURCES
    ${lqtutils_src}
    main.cpp
    kmslayer.h kmslayer.cpp
    qml.qrc
)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(Fall
        MANUAL_FINALIZATION
        ${PROJECT_SOURCES}
    )
else()
    if(ANDROID)
        add_library(Fall SHARED
            ${PROJECT_SOURCES}
        )
    else()
        add_executable(Fall
          ${PROJECT_SOURCES}
        )
    endif()
endif()

if(BUILD_PIAV)
    add_definitions(-DBUILD_PIAV)
endif()

target_compile_definitions(Fall
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(Fall
  PRIVATE Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Quick Qt${QT_VERSION_MAJOR}::DBus Qt${QT_VERSION_MAJOR}::Multimedia
  )
if(BUILD_PIAV)
    target_link_libraries(Fall PRIVATE -L${CMAKE_SYSROOT}/usr/local/Qt-rasp3-6.3.0/lib -lQtAVPlayer ${LINK_LIBAV} ${LINK_PULSE} ${LINK_BLAS} ${LINK_LAPACK})
endif()

include_directories(AFTER /usr/include/libdrm/)

set_target_properties(Fall PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
)

if(QT_VERSION_MAJOR EQUAL 6)
    qt_import_qml_plugins(Fall)
    qt_finalize_executable(Fall)
endif()
