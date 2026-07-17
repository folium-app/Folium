//
//  CytrusSettings.swift
//  Folium
//
//  Created by Jarrod Norwell on 10/6/2026.
//

import Foundation
import SettingsKit

enum CytrusSettingsItems : String, CaseIterable {
    // Core (General)
    case cpuJIT = "cytrus.cpuJIT"
    case cpuClockPercentage = "cytrus.cpuClockPercentage"
    case new3DS = "cytrus.new3DS"
    case lleApplets = "cytrus.lleApplets"
    case deterministicAsyncOperations = "cytrus.deterministicAsyncOperations"
    case requiredOnlineLLEModules = "cytrus.requiredOnlineLLEModules"
    
    // Debugging (General)
    case logLevel = "cytrus.logLevel"
    
    // Graphics (3D)
    case stereoscopic3D = "cytrus.stereoscopic3D"
    case `3DFactor` = "cytrus.3DFactor"
    case swapEyes3D = "cytrus.swapEyes3D"
    
    // Graphics (General)
    case spirvOptimizer = "cytrus.spirvOptimizer"
    case asyncPresentation = "cytrus.asyncPresentation"
    case vsync = "cytrus.vsync"
    case textureFilter = "cytrus.textureFilter"
    case textureSampling = "cytrus.textureSampling"
    
    // Graphics (Resolution)
    case upscaleFactor = "cytrus.upscaleFactor"
    
    // Graphics (Shaders)
    case spirvShaderGen = "cytrus.spirvShaderGen"
    case asyncShaderCompilation = "cytrus.asyncShaderCompilation"
    case hardwareShaders = "cytrus.hardwareShaders"
    case diskShaderCache = "cytrus.diskShaderCache"
    case shaderAccurateMultiplication = "cytrus.shaderAccurateMultiplication"
    case shaderJIT = "cytrus.shaderJIT"
    
    // Sound (General)
    case soundEmulation = "cytrus.soundEmulation"
    case soundStretching = "cytrus.soundStretching"
    case realtimeSound = "cytrus.realtimeSound"
    case volume = "cytrus.volume"
    case soundOutput = "cytrus.soundOutput"
    case soundInput = "cytrus.soundInput"
    
    // System (General)
    case clockType = "cytrus.clockType"
    case stepsPerHour = "cytrus.stepsPerHour"
    
    // System (Region)
    case systemRegion = "cytrus.systemRegion"
    case regionFreePatch = "cytrus.regionFreePatch"
    
    var title: String {
        switch self {
        case .cpuJIT:
            "CPU JIT"
        case .cpuClockPercentage:
            "CPU Clock Percentage"
        case .new3DS:
            "New 3DS"
        case .lleApplets:
            "LLE Applets"
        case .deterministicAsyncOperations:
            "Deterministic Async Operations"
        case .requiredOnlineLLEModules:
            "Required Online LLE Modules"
            
        case .logLevel:
            "Log Level"
            
        case .stereoscopic3D:
            "Stereoscopic 3D"
        case .`3DFactor`:
            "3D Factor"
        case .swapEyes3D:
            "Swap Eyes"
            
        case .spirvOptimizer:
            "SPIRV Optimizer"
        case .asyncPresentation:
            "Async Presentation"
        case .vsync:
            "Vertical Sync"
        case .textureFilter:
            "Texture Filter"
        case .textureSampling:
            "Texture Sampling"
            
        case .upscaleFactor:
            "Upscale Factor"
            
        case .spirvShaderGen:
            "SPIRV Shader Generation"
        case .asyncShaderCompilation:
            "Async Shader Compilation"
        case .hardwareShaders:
            "Hardware Shaders"
        case .diskShaderCache:
            "Disk Shader Cache"
        case .shaderAccurateMultiplication:
            "Accurate Multiplication"
        case .shaderJIT:
            "Shader JIT"
            
        case .soundEmulation:
            "Sound Emulation"
        case .soundStretching:
            "Sound Stretching"
        case .realtimeSound:
            "Realtime Sound"
        case .volume:
            "Volume"
        case .soundOutput:
            "Sound Output"
        case .soundInput:
            "Sound Input"
            
        case .clockType:
            "Clock Type"
        case .stepsPerHour:
            "Steps Per Hour"
            
        case .systemRegion:
            "System Region"
        case .regionFreePatch:
            "Region Free Patch"
        }
    }
    
    var details: String? {
        switch self {
        case .cpuJIT:
            "Enable CPU JIT significantly improving emulation performance"
        case .cpuClockPercentage:
            "Sets the clock frequency of the emulated 3DS CPU\n\nUnderclock: Increased FPS, Potential Freezing\n\nOverclock: Fixes Lag, Potential Freezing"
        case .new3DS:
            "Sets whether Azahar will emulate the Old 3DS or New 3DS"
        case .lleApplets:
            "Sets whether to use the LLE system applets, if installed"
        case .deterministicAsyncOperations:
            "Force enable deterministic async operations\n\nOnly for debugging, Slows Performance"
        case .requiredOnlineLLEModules:
            "Enable required online LLE modules for online support"
            
        case .logLevel:
            "Sets a log level filter removing unwanted data from the log"
            
        case .stereoscopic3D:
            "Enable stereoscopic 3D and set how it should be rendered"
        case .`3DFactor`:
            "Set the intensity of the stereoscopic 3D rendering"
        case .swapEyes3D:
            "Sets whether the stereoscopic 3D should swap eyes"
            
        case .spirvOptimizer:
            "Enable the SPIRV optimizer\n\nDisabled: Reduces Stutter, Slows Performance"
        case .asyncPresentation:
            "Enable presentation on separate threads improving emulation performance"
        case .vsync:
            "Enable vertical sync so the renderer runs at the displays refresh rate"
        case .textureFilter:
            "Sets which texture filter should be used for the renderer"
        case .textureSampling:
            "Override the sampling filter used by games benefiting certain games when upscaling"
            
        case .upscaleFactor:
            nil
            
        case .spirvShaderGen:
            "Sets whether to emit PICA fragment shader using SPIRV or GLSL"
        case .asyncShaderCompilation:
            "Sets whether to compile shaders on multiple worker threads"
        case .hardwareShaders:
            "Sets whether to use hardware shaders to emulate the 3DS shaders"
        case .diskShaderCache:
            "Enable shader caching to reduce stuttering by loading shaders from and saving shaders to disk"
        case .shaderAccurateMultiplication:
            "Sets whether to use accurate multiplication in hardware shaders\n\nDisabled: Faster, Less Compatibility\n\nEnabled: Slower, Accurate"
        case .shaderJIT:
            "Enable shader JIT significantly improving shader emulation performance"
            
        case .soundEmulation,
                .soundStretching:
            nil
        case .realtimeSound:
            "Scales sound playback speed to account for drops in emulation framerate"
        case .volume:
            nil
        case .soundOutput:
            "Sets which sound output type to use for audio emulation"
        case .soundInput:
            "Sets which sound input type to use for audio emulation"
            
        case .clockType:
            "Sets the clock to use when Azahar starts"
        case .stepsPerHour:
            "Sets the number of steps per hour reported by the pedometer"
            
        case .systemRegion:
            "Sets the system region Azahar will use during emulation"
        case .regionFreePatch:
            "Enable system apps to appear on the home menu regardless of the system region"
        }
    }
    
    func setting(_ delegate: SettingDelegate? = nil) -> BaseSetting {
        switch self {
        case .cpuJIT,
                .shaderJIT:
            SegmentedSetting(key: rawValue,
                             title: title,
                             details: details,
                             values: [
                                "JIT-less" : 0,
                                "JIT" : 1
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: { viewController in },
                             delegate: delegate)
        case .lleApplets,
                .deterministicAsyncOperations,
                .requiredOnlineLLEModules,
                .regionFreePatch,
                .swapEyes3D,
                .spirvShaderGen,
                .spirvOptimizer,
                .asyncShaderCompilation,
                .asyncPresentation,
                .diskShaderCache,
                .vsync,
                .shaderAccurateMultiplication,
                .soundStretching,
                .realtimeSound:
            BoolSetting(key: rawValue,
                        title: title,
                        details: details,
                        secondaryTitle: nil,
                        isEnabled: true,
                        value: UserDefaults.standard.bool(forKey: rawValue),
                        delegate: delegate)
        case .cpuClockPercentage:
            InputNumberSetting(key: rawValue,
                               title: title,
                               details: details,
                               secondaryTitle: nil,
                               isEnabled: true,
                               min: 25,
                               max: 400,
                               value: UserDefaults.standard.double(forKey: rawValue),
                               delegate: delegate)
            
        case .logLevel:
            SelectionSetting(key: rawValue,
                             title: title,
                             details: details,
                             values: [
                                "Trace" : "Trace",
                                "Debug" : "Debug",
                                "Info" : "Info",
                                "Warning" : "Warning",
                                "Error" : "Error",
                                "Critical" : "Critical"
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
            
        case .`3DFactor`:
            InputNumberSetting(key: rawValue,
                               title: title,
                               details: details,
                               secondaryTitle: nil,
                               isEnabled: true,
                               min: Double(UInt8.min),
                               max: Double(UInt8.max),
                               value: UserDefaults.standard.double(forKey: rawValue),
                               delegate: delegate)
            
        case .new3DS:
            SegmentedSetting(key: rawValue,
                             title: title,
                             details: details,
                             values: [
                                "Old" : 0,
                                "New" : 1
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: { viewController in },
                             delegate: delegate)
            
        case .stereoscopic3D:
            SelectionSetting(key: rawValue,
                             title: title,
                             details: details,
                             values: [
                                "Off" : 0,
                                "SideBySide" : 1,
                                "SideBySideFull" : 2,
                                "Anaglyph" : 3,
                                "Interlaced" : 4,
                                "ReverseInterlaced" : 5,
                                "CardboardVR" : 6
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
            
        case .textureFilter:
            SelectionSetting(key: rawValue,
                             title: title,
                             details: details,
                             values: [
                                "Automatic" : 0,
                                "Anime4K" : 1,
                                "Bicubic" : 2,
                                "ScaleForce" : 3,
                                "xBRZ" : 4,
                                "MMPX" : 5
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
            
        case .textureSampling:
            SelectionSetting(key: rawValue,
                             title: title,
                             details: details,
                             values: [
                                "GameControlled" : 0,
                                "NearestNeighbor" : 1,
                                "Linear" : 2
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
            
        case .upscaleFactor:
            SelectionSetting(key: rawValue,
                             title: title,
                             details: details,
                             values: [
                                "Automatic" : 0,
                                "Native" : 1,
                                "2x" : 2,
                                "3x" : 3,
                                "4x" : 4
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
            
        case .hardwareShaders:
            SegmentedSetting(key: rawValue,
                             title: title,
                             details: details,
                             values: [
                                "SW" : 0,
                                "HW" : 1
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: { viewController in },
                             delegate: delegate)
            
        case .volume:
            InputNumberSetting(key: rawValue,
                               title: title,
                               details: details,
                               secondaryTitle: nil,
                               isEnabled: true,
                               min: 0.0,
                               max: 100.0,
                               value: UserDefaults.standard.double(forKey: rawValue),
                               delegate: delegate)
            
        case .soundEmulation:
            SelectionSetting(key: rawValue,
                             title: title,
                             details: details,
                             values: [
                                "HLE" : 0,
                                "LLE" : 1,
                                "LLE Multithreaded" : 2
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
        case .soundOutput:
            SelectionSetting(key: rawValue,
                             title: title,
                             details: details,
                             values: [
                                "CoreAudio" : 6
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
        case .soundInput:
            SelectionSetting(key: rawValue,
                             title: title,
                             details: details,
                             values: [
                                "CoreAudio" : 6
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
            
        case .clockType:
            SegmentedSetting(key: rawValue,
                             title: title,
                             details: details,
                             values: [
                                "System" : 0,
                                "Fixed" : 1
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: { viewController in },
                             delegate: delegate)
            
        case .stepsPerHour:
            InputNumberSetting(key: rawValue,
                               title: title,
                               details: details,
                               secondaryTitle: nil,
                               isEnabled: true,
                               min: Double(UInt16.min),
                               max: Double(UInt16.max),
                               value: UserDefaults.standard.double(forKey: rawValue),
                               delegate: delegate)
            
        case .systemRegion:
            SelectionSetting(key: rawValue,
                             title: title,
                             details: details,
                             values: [
                                "Detect" : -1,
                                "Japan" : 0,
                                "United States of America" : 1,
                                "Europe" : 2,
                                "Australia" : 3,
                                "China" : 4,
                                "Korea" : 5,
                                "Taiwan" : 6
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
        }
    }
    
    static func settings(_ header: SettingsHeaders) -> [CytrusSettingsItems] {
        switch header {
        case .coreGeneral:
            [
                .cpuJIT,
                .cpuClockPercentage,
                .new3DS,
                .lleApplets,
                .deterministicAsyncOperations
            ]
        case .debuggingGeneral:
            [
                .logLevel
            ]
        case .graphics3D:
            [
                .stereoscopic3D,
                .`3DFactor`,
                .swapEyes3D
            ]
        case .graphicsGeneral:
            [
                .spirvOptimizer,
                .asyncPresentation,
                .vsync,
                .textureFilter,
                .textureSampling
            ]
        case .graphicsResolution:
            [
                .upscaleFactor
            ]
        case .graphicsShader:
            [
                .spirvShaderGen,
                .asyncShaderCompilation,
                .hardwareShaders,
                .diskShaderCache,
                .shaderAccurateMultiplication,
                .shaderJIT
            ]
        case .soundGeneral:
            [
                .soundEmulation,
                .soundStretching,
                .realtimeSound,
                .volume,
                .soundOutput,
                .soundInput
            ]
        case .systemGeneral:
            [
                .clockType,
                .stepsPerHour
            ]
        case .systemRegion:
            [
                .systemRegion,
                .regionFreePatch
            ]
        default:
            []
        }
    }
}
