Pod::Spec.new do |s|
  s.name             = 'elcaju_core'
  s.version          = '0.1.0'
  s.summary          = 'Rust core for El Caju Cashu wallet.'
  s.description      = 'Flutter bridge to elcaju_core Rust crate via flutter_rust_bridge.'
  s.homepage         = 'https://github.com/AlejandroCastillejo/elcaju'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Javier Forte' => 'forte11cuba@gmail.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'
  s.swift_version = '5.0'

  s.script_phase = {
    :name => 'Build Rust library',
    :script => 'sh "$PODS_TARGET_SRCROOT/../cargokit/build_pod.sh" ../../rust elcaju_core',
    :execution_position => :before_compile,
    :input_files => ['${BUILT_PRODUCTS_DIR}/cargokit_phony'],
    :output_files => ["${BUILT_PRODUCTS_DIR}/libelcaju_core.a"],
  }
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'OTHER_LDFLAGS' => '-force_load ${BUILT_PRODUCTS_DIR}/libelcaju_core.a',
  }
end
