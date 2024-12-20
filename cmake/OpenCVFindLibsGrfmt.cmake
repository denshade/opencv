# ----------------------------------------------------------------------------
#  Detect 3rd-party image IO libraries
# ----------------------------------------------------------------------------

# --- zlib (required) ---
if(WITH_ZLIB_NG)
  ocv_clear_vars(ZLIB_LIBRARY ZLIB_LIBRARIES ZLIB_INCLUDE_DIR)
  set(ZLIB_LIBRARY zlib CACHE INTERNAL "")
  add_subdirectory("${OpenCV_SOURCE_DIR}/3rdparty/zlib-ng")
  set(ZLIB_INCLUDE_DIR "${${ZLIB_LIBRARY}_BINARY_DIR}" CACHE INTERNAL "")
  set(ZLIB_INCLUDE_DIRS ${ZLIB_INCLUDE_DIR})
  set(ZLIB_LIBRARIES ${ZLIB_LIBRARY})

  ocv_parse_header_version(ZLIB "${${ZLIB_LIBRARY}_SOURCE_DIR}/zlib.h.in" ZLIB_VERSION)
  ocv_parse_header_version(ZLIBNG "${${ZLIB_LIBRARY}_SOURCE_DIR}/zlib.h.in" ZLIBNG_VERSION)

  set(HAVE_ZLIB_NG YES)
else()
  if(BUILD_ZLIB)
    ocv_clear_vars(ZLIB_FOUND)
  else()
    ocv_clear_internal_cache_vars(ZLIB_LIBRARY ZLIB_INCLUDE_DIR)
  if(ANDROID)
    set(_zlib_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES})
    set(CMAKE_FIND_LIBRARY_SUFFIXES .so)
  endif()
  if(QNX)
    set(ZLIB_FOUND TRUE)
    set(ZLIB_LIBRARY z)
    set(ZLIB_LIBRARIES z)
  else()
    find_package(ZLIB "${MIN_VER_ZLIB}")
  endif()
  if(ANDROID)
    set(CMAKE_FIND_LIBRARY_SUFFIXES ${_zlib_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES})
    unset(_zlib_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES)
  endif()
  if(ZLIB_FOUND AND ANDROID)
    if(ZLIB_LIBRARY MATCHES "/usr/lib.*/libz.so$")
      set(ZLIB_LIBRARY z)
      set(ZLIB_LIBRARIES z)
      set(ZLIB_LIBRARY_RELEASE z)
    endif()
  endif()
  endif()

  if(NOT ZLIB_FOUND)
    ocv_clear_vars(ZLIB_LIBRARY ZLIB_LIBRARIES ZLIB_INCLUDE_DIR)

    set(ZLIB_LIBRARY zlib CACHE INTERNAL "")
    add_subdirectory("${OpenCV_SOURCE_DIR}/3rdparty/zlib")
    set(ZLIB_INCLUDE_DIR "${${ZLIB_LIBRARY}_SOURCE_DIR}" "${${ZLIB_LIBRARY}_BINARY_DIR}" CACHE INTERNAL "")
    set(ZLIB_INCLUDE_DIRS ${ZLIB_INCLUDE_DIR})
    set(ZLIB_LIBRARIES ${ZLIB_LIBRARY})

    ocv_parse_header_version(ZLIB "${${ZLIB_LIBRARY}_SOURCE_DIR}/zlib.h" ZLIB_VERSION)
  endif()
endif()

# --- libavif (optional) ---

if(WITH_AVIF)
  ocv_clear_internal_cache_vars(AVIF_LIBRARY AVIF_INCLUDE_DIR)
  include(cmake/OpenCVFindAVIF.cmake)
  if(AVIF_FOUND)
    set(HAVE_AVIF 1)
  endif()
endif()

# --- libjpeg (optional) ---
if(WITH_JPEG)
  if(BUILD_JPEG)
    ocv_clear_vars(JPEG_FOUND)
  else()
    ocv_clear_internal_cache_vars(JPEG_LIBRARY JPEG_INCLUDE_DIR)
    if(QNX)
      set(JPEG_LIBRARY jpeg)
      set(JPEG_LIBRARIES jpeg)
      set(JPEG_FOUND TRUE)
    else()
      include(FindJPEG)
    endif()
  endif()

  if(NOT JPEG_FOUND)
    ocv_clear_vars(JPEG_LIBRARY JPEG_INCLUDE_DIR)

    if(NOT BUILD_JPEG_TURBO_DISABLE)
      set(JPEG_LIBRARY libjpeg-turbo CACHE INTERNAL "")
      set(JPEG_LIBRARIES ${JPEG_LIBRARY})
      add_subdirectory("${OpenCV_SOURCE_DIR}/3rdparty/libjpeg-turbo")
      set(JPEG_INCLUDE_DIR "${${JPEG_LIBRARY}_SOURCE_DIR}/src" CACHE INTERNAL "")
    else()
      set(JPEG_LIBRARY libjpeg CACHE INTERNAL "")
      set(JPEG_LIBRARIES ${JPEG_LIBRARY})
      add_subdirectory("${OpenCV_SOURCE_DIR}/3rdparty/libjpeg")
      set(JPEG_INCLUDE_DIR "${${JPEG_LIBRARY}_SOURCE_DIR}" CACHE INTERNAL "")
    endif()
    set(JPEG_INCLUDE_DIRS "${JPEG_INCLUDE_DIR}")
  endif()

  macro(ocv_detect_jpeg_version header_file)
    if(NOT DEFINED JPEG_LIB_VERSION AND EXISTS "${header_file}")
      ocv_parse_header("${header_file}" JPEG_VERSION_LINES JPEG_LIB_VERSION)
    endif()
  endmacro()
  ocv_detect_jpeg_version("${JPEG_INCLUDE_DIR}/jpeglib.h")
  if(DEFINED CMAKE_CXX_LIBRARY_ARCHITECTURE)
    ocv_detect_jpeg_version("${JPEG_INCLUDE_DIR}/${CMAKE_CXX_LIBRARY_ARCHITECTURE}/jconfig.h")
  endif()
  # no needed for strict platform check here, both files 64/32 should contain the same version
  ocv_detect_jpeg_version("${JPEG_INCLUDE_DIR}/jconfig-64.h")
  ocv_detect_jpeg_version("${JPEG_INCLUDE_DIR}/jconfig-32.h")
  ocv_detect_jpeg_version("${JPEG_INCLUDE_DIR}/jconfig.h")
  ocv_detect_jpeg_version("${${JPEG_LIBRARY}_BINARY_DIR}/jconfig.h")
  if(NOT DEFINED JPEG_LIB_VERSION)
    set(JPEG_LIB_VERSION "unknown")
  endif()
  set(HAVE_JPEG YES)
endif()

# --- libtiff (optional, should be searched after zlib and libjpeg) ---
if(WITH_TIFF)
  if(BUILD_TIFF)
    ocv_clear_vars(TIFF_FOUND)
  else()
    ocv_clear_internal_cache_vars(TIFF_LIBRARY TIFF_INCLUDE_DIR)
    if(QNX)
      set(TIFF_LIBRARY tiff)
      set(TIFF_LIBRARIES tiff)
      set(TIFF_FOUND TRUE)
    else()
      include(FindTIFF)
    endif()
    if(TIFF_FOUND)
      ocv_parse_header("${TIFF_INCLUDE_DIR}/tiff.h" TIFF_VERSION_LINES TIFF_VERSION_CLASSIC TIFF_VERSION_BIG TIFF_VERSION TIFF_BIGTIFF_VERSION)
    endif()
  endif()

  if(NOT TIFF_FOUND)
    ocv_clear_vars(TIFF_LIBRARY TIFF_LIBRARIES TIFF_INCLUDE_DIR)

    set(TIFF_LIBRARY libtiff CACHE INTERNAL "")
    set(TIFF_LIBRARIES ${TIFF_LIBRARY})
    add_subdirectory("${OpenCV_SOURCE_DIR}/3rdparty/libtiff")
    set(TIFF_INCLUDE_DIR "${${TIFF_LIBRARY}_SOURCE_DIR}" "${${TIFF_LIBRARY}_BINARY_DIR}" CACHE INTERNAL "")
    ocv_parse_header("${${TIFF_LIBRARY}_SOURCE_DIR}/tiff.h" TIFF_VERSION_LINES TIFF_VERSION_CLASSIC TIFF_VERSION_BIG TIFF_VERSION TIFF_BIGTIFF_VERSION)
  endif()

  if(TIFF_VERSION_CLASSIC AND NOT TIFF_VERSION)
    set(TIFF_VERSION ${TIFF_VERSION_CLASSIC})
  endif()

  if(TIFF_BIGTIFF_VERSION AND NOT TIFF_VERSION_BIG)
    set(TIFF_VERSION_BIG ${TIFF_BIGTIFF_VERSION})
  endif()

  if(NOT TIFF_VERSION_STRING AND TIFF_INCLUDE_DIR)
    foreach(_TIFF_INCLUDE_DIR IN LISTS TIFF_INCLUDE_DIR)
      if(EXISTS "${_TIFF_INCLUDE_DIR}/tiffvers.h")
        file(STRINGS "${_TIFF_INCLUDE_DIR}/tiffvers.h" tiff_version_str REGEX "^#define[\t ]+TIFFLIB_VERSION_STR[\t ]+\"LIBTIFF, Version .*")
        string(REGEX REPLACE "^#define[\t ]+TIFFLIB_VERSION_STR[\t ]+\"LIBTIFF, Version +([^ \\n]*).*" "\\1" TIFF_VERSION_STRING "${tiff_version_str}")
        unset(tiff_version_str)
      endif()
    endforeach()
  endif()

  set(HAVE_TIFF YES)
endif()

# --- libwebp (optional) ---

if(WITH_WEBP)
  if(BUILD_WEBP)
    ocv_clear_vars(WEBP_FOUND WEBP_LIBRARY WEBP_LIBRARIES WEBP_INCLUDE_DIR)
  else()
    ocv_clear_internal_cache_vars(WEBP_LIBRARY WEBP_INCLUDE_DIR)
    include(cmake/OpenCVFindWebP.cmake)
    if(WEBP_FOUND)
      set(HAVE_WEBP 1)
    endif()
  endif()
endif()

# --- Add libwebp to 3rdparty/libwebp and compile it if not available ---
if(WITH_WEBP AND NOT WEBP_FOUND
    AND (NOT ANDROID OR HAVE_CPUFEATURES)
)
  ocv_clear_vars(WEBP_LIBRARY WEBP_INCLUDE_DIR)
  set(WEBP_LIBRARY libwebp CACHE INTERNAL "")
  set(WEBP_LIBRARIES ${WEBP_LIBRARY})

  add_subdirectory("${OpenCV_SOURCE_DIR}/3rdparty/libwebp")
  set(WEBP_INCLUDE_DIR "${${WEBP_LIBRARY}_SOURCE_DIR}/src" CACHE INTERNAL "")
  set(HAVE_WEBP 1)
endif()

if(NOT WEBP_VERSION AND WEBP_INCLUDE_DIR)
  if(EXISTS "${WEBP_INCLUDE_DIR}/webp/encode.h")
    file(STRINGS "${WEBP_INCLUDE_DIR}/webp/encode.h" WEBP_ENCODER_ABI_VERSION REGEX "#define[ \t]+WEBP_ENCODER_ABI_VERSION[ \t]+([x0-9a-f]+)" )
    if(WEBP_ENCODER_ABI_VERSION MATCHES "#define[ \t]+WEBP_ENCODER_ABI_VERSION[ \t]+([x0-9a-f]+)")
        set(WEBP_ENCODER_ABI_VERSION "${CMAKE_MATCH_1}")
    else()
      unset(WEBP_ENCODER_ABI_VERSION)
    endif()
  endif()

  if(EXISTS "${WEBP_INCLUDE_DIR}/webp/decode.h")
    file(STRINGS "${WEBP_INCLUDE_DIR}/webp/decode.h" WEBP_DECODER_ABI_VERSION REGEX "#define[ \t]+WEBP_DECODER_ABI_VERSION[ \t]+([x0-9a-f]+)" )
    if(WEBP_DECODER_ABI_VERSION MATCHES "#define[ \t]+WEBP_DECODER_ABI_VERSION[ \t]+([x0-9a-f]+)")
        set(WEBP_DECODER_ABI_VERSION "${CMAKE_MATCH_1}")
    else()
      unset(WEBP_DECODER_ABI_VERSION)
    endif()
  endif()

  if(EXISTS "${WEBP_INCLUDE_DIR}/webp/demux.h")
    file(STRINGS "${WEBP_INCLUDE_DIR}/webp/demux.h" WEBP_DEMUX_ABI_VERSION REGEX "#define[ \t]+WEBP_DEMUX_ABI_VERSION[ \t]+([x0-9a-f]+)" )
    if(WEBP_DEMUX_ABI_VERSION MATCHES "#define[ \t]+WEBP_DEMUX_ABI_VERSION[ \t]+([x0-9a-f]+)")
        set(WEBP_DEMUX_ABI_VERSION "${CMAKE_MATCH_1}")
    else()
      unset(WEBP_DEMUX_ABI_VERSION)
    endif()
  endif()

set(WEBP_VERSION "decoder: ${WEBP_DECODER_ABI_VERSION}, encoder: ${WEBP_ENCODER_ABI_VERSION}, demux: ${WEBP_DEMUX_ABI_VERSION}")
endif()

# --- libopenjp2 (optional, check before libjasper) ---
if(WITH_OPENJPEG)
  if(BUILD_OPENJPEG)
    ocv_clear_vars(OpenJPEG_FOUND)
  else()
    find_package(OpenJPEG QUIET)
  endif()

  if(NOT OpenJPEG_FOUND OR OPENJPEG_MAJOR_VERSION LESS 2)
    ocv_clear_vars(OPENJPEG_MAJOR_VERSION OPENJPEG_MINOR_VERSION OPENJPEG_BUILD_VERSION OPENJPEG_LIBRARIES OPENJPEG_INCLUDE_DIRS)
    message(STATUS "Could NOT find OpenJPEG (minimal suitable version: 2.0, "
            "recommended version >= 2.3.1). OpenJPEG will be built from sources")
    add_subdirectory("${OpenCV_SOURCE_DIR}/3rdparty/openjpeg")
    if(OCV_CAN_BUILD_OPENJPEG)
      set(HAVE_OPENJPEG YES)
      message(STATUS "OpenJPEG libraries will be built from sources: ${OPENJPEG_LIBRARIES} "
              "(version \"${OPENJPEG_VERSION}\")")
    else()
      set(HAVE_OPENJPEG NO)
      message(STATUS "OpenJPEG libraries can't be built from sources. System requirements are not fulfilled.")
    endif()
  else()
    set(HAVE_OPENJPEG YES)
    set(OPENJPEG_VERSION "${OPENJPEG_MAJOR_VERSION}.${OPENJPEG_MINOR_VERSION}.${OPENJPEG_BUILD_VERSION}")
    message(STATUS "Found system OpenJPEG: ${OPENJPEG_LIBRARIES} "
            "(found version \"${OPENJPEG_VERSION}\")")
  endif()
endif()

# --- libjasper (optional, should be searched after libjpeg) ---
if(WITH_JASPER AND NOT HAVE_OPENJPEG)
  if(BUILD_JASPER)
    ocv_clear_vars(JASPER_FOUND)
  else()
    include(FindJasper)
  endif()

  if(NOT JASPER_FOUND)
    ocv_clear_vars(JASPER_LIBRARY JASPER_LIBRARIES JASPER_INCLUDE_DIR)

    set(JASPER_LIBRARY libjasper CACHE INTERNAL "")
    set(JASPER_LIBRARIES ${JASPER_LIBRARY})
    add_subdirectory("${OpenCV_SOURCE_DIR}/3rdparty/libjasper")
    set(JASPER_INCLUDE_DIR "${${JASPER_LIBRARY}_SOURCE_DIR}" CACHE INTERNAL "")
  endif()

  set(HAVE_JASPER YES)

  if(NOT JASPER_VERSION_STRING)
    ocv_parse_header2(JASPER "${JASPER_INCLUDE_DIR}/jasper/jas_config.h" JAS_VERSION "")
  endif()
endif()

if(WITH_SPNG)
  if(BUILD_SPNG)
    ocv_clear_vars(PNG_FOUND)
  else()
    # CMakeConfig bug in SPNG, include is missing there in version 0.7.4 and older
    # See https://github.com/randy408/libspng/pull/264
    include(CMakeFindDependencyMacro)
    find_package(SPNG QUIET)
    if(SPNG_FOUND)
      set(SPNG_LIBRARY "spng::spng" CACHE INTERNAL "")
      set(SPNG_LIBRARIES ${SPNG_LIBRARY})
    else()
      if(PkgConfig_FOUND)
        pkg_check_modules(SPNG QUIET spng)
      endif()
    endif()
    if(SPNG_FOUND)
      set(HAVE_SPNG YES)
      message(STATUS "imgcodecs: PNG codec will use SPNG, version: ${SPNG_VERSION}")
    endif()
  endif()
  if(NOT SPNG_FOUND)
    set(SPNG_LIBRARY libspng CACHE INTERNAL "")
    set(SPNG_LIBRARIES ${SPNG_LIBRARY})
    add_subdirectory("${OpenCV_SOURCE_DIR}/3rdparty/libspng")
    set(SPNG_INCLUDE_DIR "${${SPNG_LIBRARY}_SOURCE_DIR}" CACHE INTERNAL "")
    set(SPNG_DEFINITIONS "")
    ocv_parse_header("${SPNG_INCLUDE_DIR}/spng.h" SPNG_VERSION_LINES SPNG_VERSION_MAJOR SPNG_VERSION_MINOR SPNG_VERSION_PATCH)

    set(HAVE_SPNG YES)
    set(SPNG_VERSION "${SPNG_VERSION_MAJOR}.${SPNG_VERSION_MINOR}.${SPNG_VERSION_PATCH}")
    message(STATUS "imgcodecs: PNG codec will use SPNG, version: ${SPNG_VERSION} ")
  endif()
endif()

# --- libpng (optional, should be searched after zlib) ---
if(NOT HAVE_SPNG AND WITH_PNG)
  if(BUILD_PNG)
    ocv_clear_vars(PNG_FOUND)
  else()
    ocv_clear_internal_cache_vars(PNG_LIBRARY PNG_INCLUDE_DIR)
    find_package(PNG QUIET)
  endif()

  if(NOT PNG_FOUND)
    ocv_clear_vars(PNG_LIBRARY PNG_LIBRARIES PNG_INCLUDE_DIR PNG_DEFINITIONS)

    set(PNG_LIBRARY libpng CACHE INTERNAL "")
    set(PNG_LIBRARIES ${PNG_LIBRARY})
    add_subdirectory("${OpenCV_SOURCE_DIR}/3rdparty/libpng")
    set(PNG_INCLUDE_DIR "${${PNG_LIBRARY}_SOURCE_DIR}" CACHE INTERNAL "")
    set(PNG_DEFINITIONS "")
    ocv_parse_header_version(PNG "${PNG_INCLUDE_DIR}/png.h" PNG_LIBPNG_VER_STRING)
  endif()

  set(HAVE_PNG YES)
endif()


# --- OpenEXR (optional) ---
if(WITH_OPENEXR)
  ocv_clear_vars(HAVE_OPENEXR)
  if(NOT BUILD_OPENEXR)
    ocv_clear_internal_cache_vars(OPENEXR_INCLUDE_PATHS OPENEXR_LIBRARIES OPENEXR_ILMIMF_LIBRARY OPENEXR_VERSION)
    include("${OpenCV_SOURCE_DIR}/cmake/OpenCVFindOpenEXR.cmake")
  endif()

  if(OPENEXR_FOUND)
    set(HAVE_OPENEXR YES)
  else()
    ocv_clear_vars(OPENEXR_INCLUDE_PATHS OPENEXR_LIBRARIES OPENEXR_ILMIMF_LIBRARY OPENEXR_VERSION)

    set(OPENEXR_LIBRARIES IlmImf)
    add_subdirectory("${OpenCV_SOURCE_DIR}/3rdparty/openexr")
    if(OPENEXR_VERSION)  # check via TARGET doesn't work
      set(BUILD_OPENEXR ON)
      set(HAVE_OPENEXR YES)
      set(BUILD_OPENEXR ON)
    endif()
  endif()
endif()

# --- GDAL (optional) ---
if(WITH_GDAL)
    find_package(GDAL QUIET)

    if(NOT GDAL_FOUND)
        set(HAVE_GDAL NO)
        ocv_clear_vars(GDAL_VERSION GDAL_LIBRARIES)
    else()
        set(HAVE_GDAL YES)
        ocv_include_directories(${GDAL_INCLUDE_DIR})
    endif()
endif()

if(WITH_GDCM)
  find_package(GDCM QUIET)
  if(NOT GDCM_FOUND)
    set(HAVE_GDCM NO)
    ocv_clear_vars(GDCM_VERSION GDCM_LIBRARIES)
  else()
    set(HAVE_GDCM YES)
    # include(${GDCM_USE_FILE})
    set(GDCM_LIBRARIES gdcmMSFF) # GDCM does not set this variable for some reason
  endif()
endif()

if(WITH_IMGCODEC_GIF)
  set(HAVE_IMGCODEC_GIF ON)
elseif(DEFINED WITH_IMGCODEC_GIF)
  set(HAVE_IMGCODEC_GIF OFF)
endif()
if(WITH_IMGCODEC_HDR)
  set(HAVE_IMGCODEC_HDR ON)
elseif(DEFINED WITH_IMGCODEC_HDR)
  set(HAVE_IMGCODEC_HDR OFF)
endif()
if(WITH_IMGCODEC_SUNRASTER)
  set(HAVE_IMGCODEC_SUNRASTER ON)
elseif(DEFINED WITH_IMGCODEC_SUNRASTER)
  set(HAVE_IMGCODEC_SUNRASTER OFF)
endif()
if(WITH_IMGCODEC_PXM)
  set(HAVE_IMGCODEC_PXM ON)
elseif(DEFINED WITH_IMGCODEC_PXM)
  set(HAVE_IMGCODEC_PXM OFF)
endif()
if(WITH_IMGCODEC_PFM)
  set(HAVE_IMGCODEC_PFM ON)
elseif(DEFINED WITH_IMGCODEC_PFM)
  set(HAVE_IMGCODEC_PFM OFF)
endif()
