cmake_minimum_required(VERSION 3.5)
project(ament_boost)

find_package(ament_cmake REQUIRED)

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/git_submodule_update_no_ignore_error.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/git_submodule_update_no_ignore_error.cmake
  COPYONLY
)

add_custom_target(git_boost_subsubmodule_dl ALL
    ${CMAKE_COMMAND} -P
    "${CMAKE_CURRENT_BINARY_DIR}/git_submodule_update_no_ignore_error.cmake")
add_custom_target(git_boost_checkout ALL
    git submodule foreach --recursive git checkout
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
add_dependencies(git_boost_checkout git_boost_subsubmodule_dl)

add_custom_target(bootstrap_boost ALL
    DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/src/boost/b2${CMAKE_EXECUTABLE_SUFFIX}")
add_dependencies(bootstrap_boost git_boost_checkout)
if (WIN32)
  set(SHELL_SUFFIX ".bat")
else ()
  set(SHELL_SUFFIX ".sh")
endif ()
add_custom_command(
    OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/src/boost/b2${CMAKE_EXECUTABLE_SUFFIX}"
    COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/src/boost/bootstrap${SHELL_SUFFIX}"
    COMMENT "boost bootstrap"
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/src/boost")

add_custom_target(build_boost ALL
    "${CMAKE_CURRENT_SOURCE_DIR}/src/boost/b2${CMAKE_EXECUTABLE_SUFFIX}"
      address-model=64 headers
    DEPENDS bootstrap_boost
    COMMENT "building boost"
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/src/boost")
add_custom_target(copy_boost_includes ALL
    "${CMAKE_COMMAND}" -E copy_directory "${CMAKE_SOURCE_DIR}/src/boost/boost"
        "${CMAKE_BINARY_DIR}/b2/include/boost"
    DEPENDS build_boost
    COMMENT "copy boost includes")

install(
    DIRECTORY "${CMAKE_BINARY_DIR}/b2/include/"
    DESTINATION include
    MESSAGE_NEVER)

ament_package()
