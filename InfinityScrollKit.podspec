Pod::Spec.new do |spec|

# ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
spec.name         = "InfinityScrollKit"
spec.version      = "1.0.5"
spec.summary      = "A SwiftUI library that provides infinite scrolling functionality for lists."
spec.description  = <<-DESC
    InfinityScrollKit is a lightweight and easy-to-use SwiftUI library designed for implementing infinite scroll views. It supports various platforms, including iOS, tvOS, macOS, macCatalyst, watchOS, and visionOS. Whether you're dealing with paginated APIs or dynamic content loading, this library simplifies the process of building endless scrolling lists in SwiftUI.
DESC

spec.homepage     = "https://github.com/PierreJanineh-com/InfinityScrollKit.git"
spec.license      = { :type => "MIT", :file => "LICENSE" }
spec.author       = { "Pierre Janineh" => "infinityscrollkit@pierrejanineh.com" }
spec.source       = { :git => "https://github.com/PierreJanineh-com/InfinityScrollKit.git", :tag => "#{spec.version}" }

# ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
spec.swift_versions = ["5.10", "6.0"]
spec.platform     = :ios, "14.0"
spec.ios.deployment_target = "14.0"
spec.tvos.deployment_target = "14.0"
spec.macos.deployment_target = "14.0"
spec.watchos.deployment_target = "7.0"
# spec.visionos.deployment_target = "1.0"

# ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
spec.source_files  = "Sources/InfinityScrollKit/**/*.{swift}"
spec.exclude_files = "Tests"

end
