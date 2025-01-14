import argparse
import shutil
import subprocess
import platform
import os
from pathlib import Path
import c_parser

def check_cmake_installed() -> None:
    """Checks if CMake is installed on the system."""
    try:
        subprocess.run(["cmake", "--version"],
                       check=True, stdout=subprocess.PIPE,
                       stderr=subprocess.PIPE)
    except subprocess.CalledProcessError as e:
        raise EnvironmentError("CMake is not installed or not found in the system path:", {e})

def compile_using_cmake(cmake_file: Path,
                        flags="-DCMAKE_INSTALL_PREFIX=build/bin") -> Path:
    """
    Compiles a C project using CMake and generates a shared library.

    :param cmake_file: Path to the CMakeLists.txt file.
    :param install_dir: Optional directory to install the binaries. Default is 'build/bin'.
    """
    # Check if CMake is installed
    check_cmake_installed()

    # Get the absolute path to the directory where the CMakeLists.txt is located
    cmake_dir = Path(cmake_file).parent

    # Create the build directory if it doesn't exist
    build_dir = cmake_dir / "build"

    # Build the CMake command to configure and build
    cmd_configure = ["cmake", "-S", str(cmake_dir), "-B", str(build_dir), flags]

    # Run CMake configuration
    print("Configuring the project with CMake...")
    subprocess.run(cmd_configure, check=True)

   # Determine the build system (make or ninja) and build the project
    print("Building the project with CMake...")
    system = platform.system().lower()
    if system in ["linux", "darwin"]:  # On Linux/macOS, we'll use make
        cmd_build = ["cmake", "--build", str(build_dir)]
    else:  # On other systems, use the default build system
        cmd_build = ["cmake", "--build", str(build_dir)]
    subprocess.run(cmd_build, check=True)

    # After successful build, determine the correct output file path based on the platform
    if system == "linux":
        output_file = str(build_dir / "pmrender.so")  # Linux: .so files
    elif system == "darwin":  # macOS
        output_file = str(build_dir / "pmrender.dylib")  # macOS: .dylib files
    elif system == "windows":
        output_file = str(build_dir / "pmrender.dll")  # Windows: .dll files
    else:
        raise NotImplementedError(f"Platform not supported: {system}")
    return Path(output_file)

def copy_shared_object(shared_object: Path,
                       sharer_lib_out_dir: Path) -> Path:
    """
    Copies the shared object to the specified output directory.

    :param shared_object: Path to the shared object file to be copied.
    :param sharer_lib_out_dir: The directory where the shared object will be copied to.
    """

    # Ensure the directory path exists (create it if it doesn't exist)
    os.makedirs(sharer_lib_out_dir, exist_ok=True)

    # Define the destination path (in this case, the same name, but with a specific extension)
    destination_path = os.path.join(sharer_lib_out_dir, shared_object.name)

    # Copy the file
    shutil.copy(shared_object, destination_path)

    print(f"Shared object copied to: {destination_path}")

    return Path(destination_path)

def main() -> None:

    cdir = os.getcwd()
    WORKSPACE = Path(cdir)

    # Configurar o parser de argumentos
    argparser = argparse.ArgumentParser(description="Crossplatform Native Library Compiler.")
    argparser.add_argument('platform',
                            choices=['macos', 'android', 'windows', 'linux', 'ios', 'web',
                                        'macos-release', 'android-release', 'windows-release',
                                        'linux-release', 'ios-release', 'web-release'],
                            help="Platform to build native shared library.")

    # Analisar os argumentos
    args = argparser.parse_args()
    sharer_lib_out_dir = Path('none')
    if args.platform == "windows":
        print("Compiling for Windows...")
        sharer_lib_out_dir = WORKSPACE / "src" / "app" / "puremark" / "lib" / \
        "autogen" / "native_libraries" / "windows"

    elif args.platform == "macos":
        print("Compiling for macOS...")
        sharer_lib_out_dir = WORKSPACE / "src" / "app" / "puremark" / "lib" / \
        "autogen" / "native_libraries" / "macos"

    elif args.platform == "linux":
        print("Compiling for Linux...")
        sharer_lib_out_dir = WORKSPACE / "src" / "app" / "puremark" / "lib" / \
        "autogen" / "native_libraries" / "linux"

    elif args.platform == "android":
        print("Compiling for Android...")

    elif args.platform == "ios":
        print("Compiling for iOS...")
        raise NotImplementedError("iOS platform not supported yet.")

    elif args.platform == "web":
        print("Compiling for Web...")
        raise NotImplementedError("Web platform not supported yet.")

    elif args.platform == "windows-release":
        print("Compiling for Windows Release...")
        sharer_lib_out_dir = WORKSPACE / "src" / "app" / "puremark" / \
        "build" "windows" / "Runner" / "Release"

    elif args.platform == "macos-release":
        print("Compiling for macOS Release...")
        sharer_lib_out_dir = WORKSPACE / "src" / "app" / "puremark" / \
        "build" / "macos" / "Build" / "Products" / "Release"

    elif args.platform == "linux-release":
        print("Compiling for Linux Release...")
        sharer_lib_out_dir = WORKSPACE / "src" / "app" / "puremark" / \
        "build" / "linux" / "x64" / "release" / "bundle"

    elif args.platform == "android-release":
        print("Compiling for Android Release...")

    elif args.platform == "ios-release":
        print("Compiling for iOS Release...")
        raise NotImplementedError("iOS platform not supported yet.")

    elif args.platform == "web-release":
        print("Compiling for Web Release...")
        raise NotImplementedError("Web platform not supported yet.")

    else:
        raise NotImplementedError(f"Platform not supported: {args.platform}")


    # Criando os caminhos de forma segura
    cmake_file = WORKSPACE / "src" / "pmrender" / "CMakeLists.txt"
    bindings_out_dir = WORKSPACE / "src" / "app" / "puremark" / \
    "lib" / "autogen" / "bindings"

    # Compilar a biblioteca compartilhada
    try:
        if sharer_lib_out_dir == Path("none"):
            raise FileNotFoundError("Output shared library directory not specified.")

        shared_object = compile_using_cmake(cmake_file)
        print(f"Build completed successfully. Shared library is located at:\n"
              f"{shared_object}")

        shared_object_new = copy_shared_object(shared_object, sharer_lib_out_dir)
        print(f"Shared library copied to:\n {shared_object_new}")
        # Gerar os bindings Dart
        c_file = Path(cmake_file).parent / "src" / "bindings.h"
        print(f"Generating Dart bindings for:\n {c_file}")
        dart_file = c_parser.generate_dart_bindings(c_file,
                                                    bindings_out_dir,
                                                    sharer_lib_out_dir)

        print(f"Bindings generated successfully. Dart file is located at:\n"
              f"{dart_file}")

    except FileNotFoundError as e:
        print(f"Erro: {e}")

if __name__ == "__main__":
    main()
