cmake_minimum_required(VERSION 3.5)
project(ament_boost)

find_package(ament_cmake REQUIRED)

find_package(Subversion REQUIRED)

add_custom_target(svn_boost ALL
    "${Subversion_SVN_EXECUTABLE}" 
    checkout http://svn.boost.org/svn/boost/trunk/ 
    "${CMAKE_BINARY_DIR}/src/boost")

add_custom_target(bootstrap_boost ALL
    DEPENDS "${CMAKE_BINARY_DIR}/src/boost/b2${CMAKE_EXECUTABLE_SUFFIX}")
add_dependencies(bootstrap_boost svn_boost)
if (WIN32)
  set(SHELL_SUFFIX ".bat")
else ()
  set(SHELL_SUFFIX ".sh")
endif ()
add_custom_command(
    OUTPUT "${CMAKE_BINARY_DIR}/src/boost/b2${CMAKE_EXECUTABLE_SUFFIX}"
    COMMAND "${CMAKE_BINARY_DIR}/src/boost/bootstrap${SHELL_SUFFIX}"
    COMMENT "boost bootstrap"
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/src/boost")

add_custom_target(build_boost ALL
    "${CMAKE_BINARY_DIR}/src/boost/b2${CMAKE_EXECUTABLE_SUFFIX}"
      address-model=64 headers
    DEPENDS bootstrap_boost
    COMMENT "building boost"
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/src/boost")
add_custom_target(copy_boost_includes ALL
    "${CMAKE_COMMAND}" -E copy_directory "${CMAKE_BINARY_DIR}/src/boost/boost"
        "${CMAKE_BINARY_DIR}/b2/include/boost"
    DEPENDS build_boost
    COMMENT "copy boost includes")

install(
    DIRECTORY "${CMAKE_BINARY_DIR}/b2/include/"
    DESTINATION include
    MESSAGE_NEVER)

ament_package()
