cmake_minimum_required(VERSION 3.10)

set(PROJECT_NAME "rust_builder")
project(${PROJECT_NAME} LANGUAGES CXX)

include("../cargokit/cmake/cargokit.cmake")
apply_cargokit(${PROJECT_NAME} ../../rust elcaju_core "")

set(rust_builder_bundled_libraries
  "${${PROJECT_NAME}_cargokit_lib}"
  PARENT_SCOPE
)
