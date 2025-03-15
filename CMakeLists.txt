cmake_minimum_required(VERSION 3.16)

project(RequestAndResponseTest VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)


# WEB ENGINE STUFF
# if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
#     find_package(Qt6 REQUIRED COMPONENTS Quick WebEngineQuick WebViewQuick)
# else() # if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
#     find_package(Qt6 REQUIRED COMPONENTS Quick WebViewQuick)
# endif()

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appRequestAndResponseTest
    main.cpp
)

qt_add_qml_module(appRequestAndResponseTest
    URI RequestAndResponseTest
    VERSION 1.0
    QML_FILES
        Main.qml
        SOURCES cpp/Backend.h cpp/Backend.cpp
        QML_FILES
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appRequestAndResponseTest PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appRequestAndResponseTest
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# WEB ENGINE STUFF
# if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
#     target_link_libraries(appRequestAndResponseTest
#         PRIVATE Qt6::Quick Qt6::WebEngineQuick Qt6::WebViewQuick
#     )
# else() # if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
#     target_link_libraries(appRequestAndResponseTest
#         PRIVATE Qt6::Quick Qt6::WebViewQuick
#     )
# endif()

target_link_libraries(appRequestAndResponseTest
    PRIVATE Qt6::Quick
)


include(GNUInstallDirs)
install(TARGETS appRequestAndResponseTest
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
