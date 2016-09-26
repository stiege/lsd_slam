cmake_minimum_required(VERSION 2.8.7)
project(lsd_slam_core)
include(ExternalProject)

set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/lib)
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

find_package(OpenCV REQUIRED)
find_package(Boost COMPONENTS thread filesystem system REQUIRED)
find_package(Eigen3 REQUIRED)
#find_package(Pangolin 0.1 REQUIRED)
find_package(SuiteParse REQUIRED) # Apparently needed by g2o

# FabMap
# uncomment this part to enable fabmap
#add_subdirectory(${PROJECT_SOURCE_DIR}/thirdparty/openFabMap)
#include_directories(${PROJECT_SOURCE_DIR}/thirdparty/openFabMap/include)
#add_definitions("-DHAVE_FABMAP")
#set(FABMAP_LIB openFABMAP )

# SSE flags
add_definitions("-DENABLE_SSE")

# Also add some useful compiler flag
set(CMAKE_CXX_FLAGS
   "${CMAKE_CXX_FLAGS} -msse4.1 -msse3 -msse2 -msse -march=native -O3 -std=c++0x -pthread"
) 

#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g") 
##==== Option to build local copy of G2O ============================
option( BUILD_LOCAL_G2O "Build a local copy of G2O" ON )
if( BUILD_LOCAL_G2O )
  set( G2O_USE_OPENMP ${USE_OPENMP} )
  list( APPEND EXTERNAL_PROJECTS G2O )

  include( ${PROJECT_SOURCE_DIR}/cmake/BuildG2O.cmake )
elseif()
  find_package(G2O REQUIRED)

  # These are the G2O libraries I use
  set( G2O_LIBRARIES
      ${G2O_CORE_LIBRARY}
      ${G2O_STUFF_LIBRARY}
      ${G2O_SOLVER_CSPARSE_EXTENSION}
      ${G2O_SOLVER_CSPARSE}
      ${G2O_TYPES_SBA}
      ${G2O_TYPES_SIM3} )
endif()

# To include/link G2O you need to be able to find the Suitesparse libs
find_package(SuiteParse REQUIRED)
list( APPEND G2O_LIBRARIES
  ${CSPARSE_LIBRARY} )
list( APPEND G2O_INCLUDE_DIR
  ${CSPARSE_INCLUDE_DIR}
  ${CHOLMOD_INCLUDE_DIR} )


##====  Option to build local copy of Pangolin ======================
option( BUILD_LOCAL_PANGOLIN "Build a local copy of Pangolin" ON )
if( BUILD_LOCAL_PANGOLIN )
  list( APPEND EXTERNAL_PROJECTS Pangolin )
  include( ${PROJECT_SOURCE_DIR}/cmake/BuildPangolin.cmake )
elseif()
  find_package(Pangolin 0.1 REQUIRED)
endif()

# Set source files
set(lsd_SOURCE_FILES
  ${PROJECT_SOURCE_DIR}/DataStructures/Frame.cpp
  ${PROJECT_SOURCE_DIR}/DataStructures/FramePoseStruct.cpp
  ${PROJECT_SOURCE_DIR}/DataStructures/FrameMemory.cpp
  ${PROJECT_SOURCE_DIR}/SlamSystem.cpp
  ${PROJECT_SOURCE_DIR}/GUI.cpp
  ${PROJECT_SOURCE_DIR}/LiveSLAMWrapper.cpp
  ${PROJECT_SOURCE_DIR}/DepthEstimation/DepthMap.cpp
  ${PROJECT_SOURCE_DIR}/DepthEstimation/DepthMapPixelHypothesis.cpp
  ${PROJECT_SOURCE_DIR}/util/globalFuncs.cpp
  ${PROJECT_SOURCE_DIR}/util/SophusUtil.cpp
  ${PROJECT_SOURCE_DIR}/util/settings.cpp
  ${PROJECT_SOURCE_DIR}/util/Undistorter.cpp
  ${PROJECT_SOURCE_DIR}/util/RawLogReader.cpp
  ${PROJECT_SOURCE_DIR}/Tracking/Sim3Tracker.cpp
  ${PROJECT_SOURCE_DIR}/Tracking/Relocalizer.cpp
  ${PROJECT_SOURCE_DIR}/Tracking/SE3Tracker.cpp
  ${PROJECT_SOURCE_DIR}/Tracking/least_squares.cpp
  ${PROJECT_SOURCE_DIR}/Tracking/TrackingReference.cpp
  ${PROJECT_SOURCE_DIR}/IOWrapper/Timestamp.cpp
  ${PROJECT_SOURCE_DIR}/GlobalMapping/FabMap.cpp
  ${PROJECT_SOURCE_DIR}/GlobalMapping/KeyFrameGraph.cpp
  ${PROJECT_SOURCE_DIR}/GlobalMapping/g2oTypeSim3Sophus.cpp
  ${PROJECT_SOURCE_DIR}/GlobalMapping/TrackableKeyFrameSearch.cpp
)
set(SOURCE_FILES
  ${lsd_SOURCE_FILES}
  ${PROJECT_SOURCE_DIR}/IOWrapper/OpenCV/ImageDisplay_OpenCV.cpp
  ${PROJECT_SOURCE_DIR}/IOWrapper/Pangolin/PangolinOutput3DWrapper.cpp
)

include_directories(
  ${EIGEN3_INCLUDE_DIR}
  ${PROJECT_SOURCE_DIR}
  ${OpenCV_INCLUDE_DIRS}
  ${Boost_INCLUDE_DIR}
  ${Pangolin_INCLUDE_DIRS}
  ${G2O_INCLUDE_DIR}
  ${PROJECT_SOURCE_DIR}/thirdparty/Sophus
  ${CSPARSE_INCLUDE_DIR} #Has been set by SuiteParse
  ${CHOLMOD_INCLUDE_DIR} #Has been set by SuiteParse
)

# build shared library.
add_library(lsdslam SHARED ${SOURCE_FILES})
target_link_libraries(lsdslam ${FABMAP_LIB} ${Boost_LIBRARIES} ${OpenCV_LIBS} ${G2O_LIBRARIES} ${Pangolin_LIBRARIES})

# build image node
add_executable(LSD LSD.cpp)
target_link_libraries(LSD lsdslam)

## Build a local copy of gtest (as per the GTest FAQ)
include(${CMAKE_SOURCE_DIR}/cmake/BuildGTestLibraries.cmake )
#add_subdirectory( test/unit/logger )
#add_subdirectory( test/unit/lsd_core )
# /TEST

include(${CMAKE_SOURCE_DIR}/DataStructures/DataStructures.cmake)
add_custom_target( deps DEPENDS ${EXTERNAL_PROJECTS} )
