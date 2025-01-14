cmake_minimum_required(VERSION 3.10)

# Nome do seu projeto
project(pmrender)

# Garantir que o compilador Clang 19.0+ seja usado
find_program(CLANG_EXECUTABLE clang REQUIRED)  # Encontrar clang para C
find_program(CLANGXX_EXECUTABLE clang++ REQUIRED)  # Encontrar clang++ para C++

# Verificar a versão do Clang
execute_process(COMMAND ${CLANG_EXECUTABLE} --version OUTPUT_VARIABLE CLANG_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
string(REGEX MATCH "([0-9]+)\\.([0-9]+)" CLANG_MAJOR_MINOR_VERSION ${CLANG_VERSION})

# Garantir que a versão do Clang seja 19.0 ou superior
if(NOT CLANG_MAJOR_MINOR_VERSION VERSION_GREATER "19.0")
    message(FATAL_ERROR "Required Clang 19.0 or greater. Found: ${CLANG_VERSION}")
endif()

# Definir explicitamente os compiladores para C e C++
set(CMAKE_C_COMPILER ${CLANG_EXECUTABLE})
set(CMAKE_CXX_COMPILER ${CLANGXX_EXECUTABLE})

# Garantir que o código seja compilado com C17
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)  # Impede o uso de extensões de compilador não padrão

# ------------------ Begin of cmark-gfm build ------------------

# Paths for cmark-gfm repo
set(REPO_URL "https://github.com/github/cmark-gfm.git")
set(REPO_DIR "${PROJECT_SOURCE_DIR}/lib/cmark-gfm")
set(BUILD_DIR "${REPO_DIR}/build")

# Check if git is available
message(STATUS "Checking if git is available...")
execute_process(
    COMMAND git --version
    RESULT_VARIABLE git_check_result
    OUTPUT_VARIABLE git_check_output
    ERROR_VARIABLE git_check_error_output
)

if(NOT git_check_result EQUAL 0)
    message(FATAL_ERROR "Git not found. Please install Git and try again.")
else()
    message(STATUS "Git found: ${git_check_output}")
endif()

# Check if the repository already exists
if(EXISTS ${REPO_DIR})
    message(STATUS "Repository already exists in: ${REPO_DIR}.")
    
    if(OVERRIDE_REPO)
        message(WARNING "Overwriting repository...")
        # Remove existing repository
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E remove_directory ${REPO_DIR}
            RESULT_VARIABLE remove_result
            ERROR_VARIABLE remove_error_output
        )
        if(NOT remove_result EQUAL 0)
            message(FATAL_ERROR "Error deleting repository: ${remove_error_output}")
        endif()
        message(STATUS "Repository deleted. Now cloning...")

        # Cloning repo
        message(STATUS "Cloning repo: ${REPO_URL} into ${REPO_DIR}...")
        execute_process(
            COMMAND git clone ${REPO_URL} ${REPO_DIR}
            RESULT_VARIABLE result
            OUTPUT_VARIABLE output
            ERROR_VARIABLE error_output
        )
        if(NOT result EQUAL 0)
            message(FATAL_ERROR "Error cloning md4ast: ${error_output}")
        else()
            message(STATUS "Repository cloned successfully.\n")
        endif()
    else()
        message(WARNING "To override the existing repository, set the flag: -DOVERRIDE_REPO=ON")
        message(STATUS "Skipping...\n")
    endif()
else()
    # Cloning repo
    message(STATUS "Cloning repo: ${REPO_URL} into ${REPO_DIR}...")
    execute_process(
        COMMAND git clone ${REPO_URL} ${REPO_DIR}
        RESULT_VARIABLE result
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error_output
    )
    if(NOT result EQUAL 0)
        message(FATAL_ERROR "Error cloning md4ast: ${error_output}")
    else()
        message(STATUS "Repository cloned successfully.\n")
    endif()
endif()

# Overwrite repository if OFF by default
set(OVERRIDE_REPO OFF CACHE BOOL "Override existing repository" FORCE)

# Creating build directory
message(STATUS "Creating build directory: ${BUILD_DIR}...")
file(MAKE_DIRECTORY ${BUILD_DIR})

# Setup CMake
message(STATUS "Configuring cmark-gfm build with Clang...")
execute_process(
    COMMAND ${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMARK_STATIC=OFF -DCMARK_SHARED=ON
            -S ${REPO_DIR} -B ${BUILD_DIR}
    RESULT_VARIABLE result
    OUTPUT_VARIABLE output
    ERROR_VARIABLE error_output
)
if(NOT result EQUAL 0)
    message(FATAL_ERROR "Error configuring md4ast build with cmake clang: ${error_output}")
else()
    message(STATUS "CMake configuration completed. CMakeFiles created in ${BUILD_DIR}.\n")
endif()

# Build invocation
message(STATUS "Building cmark-gfm in ${BUILD_DIR}...")
if(WIN32)
    # No Windows, usamos cmake --build
    message(STATUS "Windows detected, building md4ast with cmake --build ${BUILD_DIR} ...")
    execute_process(
        COMMAND ${CMAKE_COMMAND} --build ${BUILD_DIR} --config Release
        RESULT_VARIABLE result
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error_output
    )
elseif(UNIX)
    # No Linux (ou Unix), usamos make
    message(STATUS "Unix detected, building md4ast with make -C ${BUILD_DIR} ...")
    execute_process(
        COMMAND make -C ${BUILD_DIR}
        RESULT_VARIABLE result
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error_output
    )
else()
    message(FATAL_ERROR "Unsupported platform for building: ${CMAKE_SYSTEM_NAME}")
endif()
if(NOT result EQUAL 0)
    message(FATAL_ERROR "Error compiling cmark-gfm: ${error_output}")
else()
    message(STATUS "Build successful, shared libs are on dir: ${BUILD_DIR}/src")
endif()

file(COPY ${BUILD_DIR}/src/cmark-gfm_export.h DESTINATION ${REPO_DIR}/src)
file(COPY ${BUILD_DIR}//src/cmark-gfm_version.h DESTINATION ${REPO_DIR}/src)
file(COPY ${BUILD_DIR}//src/config.h DESTINATION ${REPO_DIR}/src)

# ------------------ End of cmark-gfm build ------------------

# Set up where to find your project’s header and source files
message(STATUS "Setting up pmrender dynamic library...")
message(STATUS "Including *.h from ${REPO_DIR}/src...")
message(STATUS "Including *.h from ${PROJECT_SOURCE_DIR}/src...")
include_directories(${REPO_DIR}/src)
include_directories(${PROJECT_SOURCE_DIR}/src)

# Add the compilation for your project (shared library)
message(STATUS "Including *.c from: ${PROJECT_SOURCE_DIR}/src")
message(STATUS "Including md4c.c from: ${BUILD_DIR}/src\n")
file(GLOB SOURCES ${PROJECT_SOURCE_DIR}/src/*.c)
add_library(cmark-gfm STATIC ${REPO_DIR}/src/cmark.c)

# Add the shared library (pmrender.dll) linked with the static md4ast library
message(STATUS "Linking md4c static library with pmrender dynamic library...")
add_library(pmrender SHARED ${SOURCES})

# Set output directory for libraries and executables
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})  # Libraries will be placed here
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})  # Executables will be placed here

# Link libraries
# Adapt for different platforms (Windows and Linux)
if(WIN32)
    target_link_libraries(pmrender PRIVATE ${REPO_DIR}/build/src/cmark-gfm.lib)
elseif(UNIX)
    set(CMARK_LIBRARIES ${REPO_DIR}/build/src/libcmark-gfm.so)  # Linux: dynamic library
    target_link_libraries(pmrender PRIVATE ${CMARK_LIBRARIES})
endif()

# Ensure md4ast is built before pmrender
add_dependencies(pmrender cmark-gfm)
message(STATUS "Setting pmrender dynamic library install into ${CMAKE_BINARY_DIR}/bin...")

# Inform the build directory
message(STATUS "Configuration complete. In the build directory, run:\n\tOn Windows: cmake --build .\n\tOn Unix: make\n")
