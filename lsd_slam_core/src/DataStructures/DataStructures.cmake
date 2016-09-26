
MESSAGE("INC: ${GTEST_INCLUDE_DIRS}")
include_directories(${GTEST_INCLUDE_DIRS})

add_executable(basic_test ${CMAKE_CURRENT_LIST_DIR}/FrameUnitTests.cpp)

target_link_libraries(basic_test ${GTEST_BOTH_LIBRARIES})
