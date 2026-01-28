# Agent Conventions

This repo is a local fork of PCSX2. Notes below capture the working Windows build + runtime steps used here.

## Build prerequisites (Windows)
- Visual Studio 2022 Build Tools (MSVC) + Windows SDK 10.0.26100.0 or newer.
- CMake (installed to `C:\Program Files\CMake\bin`).
- vcpkg at `C:\vcpkg` (this is the path used by the working build).

## vcpkg dependencies (x64-windows)
Install these before configuring:
- `libpng zlib libjpeg-turbo zstd lz4 libwebp sdl3 freetype plutovg plutosvg[freetype] shaderc`
- `qtbase[widgets,gui,network,concurrent,opengl] qttools[linguist] kddockwidgets[qtwidgets]`
- `vulkan-loader directx-dxc`

Commands used:
```powershell
# vcpkg bootstrap
C:\vcpkg\bootstrap-vcpkg.bat

# core deps
C:\vcpkg\vcpkg.exe install libpng zlib libjpeg-turbo zstd lz4 libwebp sdl3 freetype plutovg plutosvg[freetype] shaderc --triplet x64-windows --x-buildtrees-root "C:\vcpkg_buildtrees"

# Qt + KDDockWidgets
C:\vcpkg\vcpkg.exe install qtbase[widgets,gui,network,concurrent,opengl] qttools[linguist] kddockwidgets[qtwidgets] --triplet x64-windows --x-buildtrees-root "C:\vcpkg_buildtrees"

# Vulkan loader + DXC (dxcompiler/dxil)
C:\vcpkg\vcpkg.exe install vulkan-loader directx-dxc --triplet x64-windows --x-buildtrees-root "C:\vcpkg_buildtrees"
```

## Configure + build
```powershell
# configure
"C:\Program Files\CMake\bin\cmake.exe" -S . -B build-vcpkg -G "Visual Studio 17 2022" -A x64 -DCMAKE_TOOLCHAIN_FILE="C:\vcpkg\scripts\buildsystems\vcpkg.cmake"

# build
"C:\Program Files\CMake\bin\cmake.exe" --build build-vcpkg --config Release
```

## Post-build runtime fixes
The Qt runtime plugins must be deployed and a few DLLs copied so the app can initialize graphics.

```powershell
# Deploy Qt plugins into the Release folder
C:\vcpkg\installed\x64-windows\tools\qt6\bin\windeployqt.exe "C:\Users\Jason Cormier\AI Projects\New folder\build-vcpkg\pcsx2-qt\Release\pcsx2-qt.exe"

# Vulkan loader + DXC DLLs into the same folder
Copy-Item -Force "C:\vcpkg\installed\x64-windows\bin\vulkan-1.dll" "C:\Users\Jason Cormier\AI Projects\New folder\build-vcpkg\pcsx2-qt\Release"
Copy-Item -Force "C:\vcpkg\installed\x64-windows\bin\dxcompiler.dll" "C:\Users\Jason Cormier\AI Projects\New folder\build-vcpkg\pcsx2-qt\Release"
Copy-Item -Force "C:\vcpkg\installed\x64-windows\bin\dxil.dll" "C:\Users\Jason Cormier\AI Projects\New folder\build-vcpkg\pcsx2-qt\Release"
```

## Built-in game patches (patches.zip)
PCSX2 looks for `resources\patches.zip`. We generate it from the official patches repo and copy it to both the user config folder and the build output.

```powershell
# Clone patches repo
git clone https://github.com/PCSX2/pcsx2_patches.git "C:\Users\Jason Cormier\AI Projects\pcsx2_patches"

# Build patches.zip
Compress-Archive -Path "C:\Users\Jason Cormier\AI Projects\pcsx2_patches\patches\*" -DestinationPath "C:\Users\Jason Cormier\AI Projects\pcsx2_patches\patches.zip" -Force

# Copy patches.zip to user resources and build output
Copy-Item -Force "C:\Users\Jason Cormier\AI Projects\pcsx2_patches\patches.zip" "C:\Users\Jason Cormier\Documents\PCSX2\resources\patches.zip"
Copy-Item -Force "C:\Users\Jason Cormier\AI Projects\pcsx2_patches\patches.zip" "C:\Users\Jason Cormier\AI Projects\New folder\build-vcpkg\pcsx2-qt\Release\resources\patches.zip"
```

## Run
```powershell
C:\Users\Jason Cormier\AI Projects\New folder\build-vcpkg\pcsx2-qt\Release\pcsx2-qt.exe
```

## Local modifications in this fork
- Vulkan shaderc is linked statically (for vcpkg builds) via:
  - `pcsx2/CMakeLists.txt` adds `SHADERC_LIBRARIES` and defines `PCSX2_SHADERC_STATIC`.
  - `pcsx2/GS/Renderers/Vulkan/VKShaderCache.cpp` uses static shaderc when `PCSX2_SHADERC_STATIC` is defined.

If you update or rebase, re-verify those files and re-run the post-build runtime steps.
