//
//  CytrusSettings.swift
//  Folium
//
//  Created by Jarrod Norwell on 10/6/2026.
//

import Cytrus
import Foundation
import SettingsKit

enum CytrusSettingsItems : String, CaseIterable {
    // Core (General)
    case asyncFilesystemOperations = "cytrus.asyncFilesystemOperations"
    case asyncPresentation = "cytrus.asyncPresentation"
    case asyncShaderCompilation = "cytrus.asyncShaderCompilation"
    case cpuClockPercent = "cytrus.cpuClockPercent"
    case cpuJIT = "cytrus.cpuJIT"
    case deterministicAsyncOperations = "cytrus.deterministicAsyncOperations"
    case fastInterpreter = "cytrus.fastInterpreter"
    case new3DSMode = "cytrus.new3DSMode"
    case requiredOnlineLLEModules = "cytrus.requiredOnlineLLEModules"

    // Debugging (General)
    case logFilter = "cytrus.logFilter"

    // Graphics (General)
    case graphicsAPI = "cytrus.graphicsAPI"
    case hardwareShader = "cytrus.hardwareShader"
    case integerScaling = "cytrus.integerScaling"
    case rightEyeRender = "cytrus.rightEyeRender"
    case skipDuplicateFrames = "cytrus.skipDuplicateFrames"
    case vsync = "cytrus.vsync"

    // Graphics (Resolution)
    case resolutionScaleFactor = "cytrus.resolutionScaleFactor"

    // Graphics (Shaders)
    case shaderJIT = "cytrus.shaderJIT"
    case shadersAccurateMultiply = "cytrus.shadersAccurateMultiply"
    case spirvOptimizer = "cytrus.spirvOptimizer"
    case spirvShaderGeneration = "cytrus.spirvShaderGeneration"

    // Graphics (Timing & Simulation)
    // case delayGameRenderThreadMicroseconds = "cytrus.delayGameRenderThreadMicroseconds"
    case simulate3DSGPUTimings = "cytrus.simulate3DSGPUTimings"

    // Graphics (Texture)
    case textureFilter = "cytrus.textureFilter"
    case textureSampling = "cytrus.textureSampling"

    // Sound (General)
    case audioEmulationMode = "cytrus.audioEmulationMode"
    case audioStretching = "cytrus.audioStretching"
    case inputType = "cytrus.inputType"
    case outputType = "cytrus.outputType"
    case realtimeAudio = "cytrus.realtimeAudio"
    case simulateHeadphonesPluggedIn = "cytrus.simulateHeadphonesPluggedIn"

    // System (Region)
    case regionFreePatch = "cytrus.regionFreePatch"
    case regionValue = "cytrus.regionValue"

    // System (General)
    case stepsPerHour = "cytrus.stepsPerHour"

    // Web/API
    case webAPIURL = "cytrus.webAPIURL"
    
    var title: String {
        switch self {
        // Core (General)
        case .asyncFilesystemOperations:
            "Async Filesystem Operations"
        case .asyncPresentation:
            "Async Presentation"
        case .asyncShaderCompilation:
            "Async Shader Compilation"
        case .cpuClockPercent:
            "CPU Clock Percent"
        case .cpuJIT:
            "CPU JIT"
        case .deterministicAsyncOperations:
            "Deterministic Async Ops"
        case .fastInterpreter:
            "Fast Interpreter"
        case .new3DSMode:
            "New 3DS Mode"
        case .requiredOnlineLLEModules:
            "Required Online LLE Modules"

        // Debugging (General)
        case .logFilter:
            "Log Filter"

        // Graphics (General)
        case .graphicsAPI:
            "Graphics API"
        case .hardwareShader:
            "Hardware Shader"
        case .integerScaling:
            "Integer Scaling"
        case .rightEyeRender:
            "Right Eye Render"
        case .skipDuplicateFrames:
            "Skip Duplicate Frames"
        case .vsync:
            "Vertical Sync"

        // Graphics (Resolution)
        case .resolutionScaleFactor:
            "Resolution Scale"

        // Graphics (Shaders)
        case .shaderJIT:
            "Shader JIT"
        case .shadersAccurateMultiply:
            "Accurate Multiplication"
        case .spirvOptimizer:
            "SPIR-V Optimizer"
        case .spirvShaderGeneration:
            "SPIR-V Shader Generation"

        // Graphics (Timing & Simulation)
        // case .delayGameRenderThreadMicroseconds:
        //     "Render Thread Delay (µs)"
        case .simulate3DSGPUTimings:
            "Simulate 3DS GPU Timings"

        // Graphics (Texture)
        case .textureFilter:
            "Texture Filter"
        case .textureSampling:
            "Texture Sampling"

        // Sound (General)
        case .audioEmulationMode:
            "Audio Emulation Mode"
        case .audioStretching:
            "Audio Stretching"
        case .realtimeAudio:
            "Realtime Audio"
        case .inputType:
            "Input Type"
        case .outputType:
            "Output Type"
        case .simulateHeadphonesPluggedIn:
            "Simulate Headphones Plugged In"

        // System (Region)
        case .regionFreePatch:
            "Region Free Patch"
        case .regionValue:
            "Region Value"

        // System (General)
        case .stepsPerHour:
            "Steps Per Hour"

        // Web/API
        case .webAPIURL:
            "Web API URL"
        }
    }
    
    var details: String? {
        switch self {
        // Core (General)
        case .asyncFilesystemOperations:
            "Performs file I/O on background threads to reduce stutter"
        case .asyncPresentation:
            "Presents frames on a separate thread for smoother rendering"
        case .asyncShaderCompilation:
            "Compiles shaders in parallel to minimize hitching"
        case .cpuClockPercent:
            "Adjusts emulated CPU speed as a percentage of normal"
        case .cpuJIT:
            "Uses just-in-time compilation for higher CPU performance"
        case .deterministicAsyncOperations:
            "Forces deterministic timing for debugging; may reduce performance"
        case .fastInterpreter:
            "Uses a faster, less accurate CPU interpreter"
        case .new3DSMode:
            "Emulates New 3DS hardware instead of Old 3DS"
        case .requiredOnlineLLEModules:
            "Loads extra LLE modules needed for online features"

        // Debugging (General)
        case .logFilter:
            "Filters log output to reduce noise"

        // Graphics (General)
        case .graphicsAPI:
            "Selects the underlying graphics API used by the renderer"
        case .hardwareShader:
            "Runs 3DS shaders on the GPU instead of software"
        case .integerScaling:
            "Scales output by whole-number factors to avoid blur"
        case .rightEyeRender:
            "Controls rendering for the right eye in 3D modes"
        case .skipDuplicateFrames:
            "Skips repeated frames to improve perceived smoothness"
        case .vsync:
            "Syncs rendering to display refresh to reduce tearing"

        // Graphics (Resolution)
        case .resolutionScaleFactor:
            "Upscales internal resolution for sharper visuals"

        // Graphics (Shaders)
        case .shaderJIT:
            "JIT-compiles shaders to improve performance"
        case .shadersAccurateMultiply:
            "Uses precise multiplication for better accuracy; slower"
        case .spirvOptimizer:
            "Optimizes SPIR-V shaders to reduce stutter; may affect speed"
        case .spirvShaderGeneration:
            "Generates shaders as SPIR-V instead of GLSL"

        // Graphics (Timing & Simulation)
        // case .delayGameRenderThreadMicroseconds:
        //     "Adds a microsecond delay to the game render thread"
        case .simulate3DSGPUTimings:
            "Simulates original GPU timing for improved accuracy"

        // Graphics (Texture)
        case .textureFilter:
            "Selects the texture filtering algorithm"
        case .textureSampling:
            "Overrides the sampling filter used by games"

        // Sound (General)
        case .audioEmulationMode:
            "Chooses HLE or LLE audio emulation mode"
        case .audioStretching:
            "Stretches audio to mask frame drops"
        case .inputType:
            "Chooses the backend for audio input"
        case .outputType:
            "Chooses the backend for audio output"
        case .realtimeAudio:
            "Keeps audio playback in real time despite slowdowns"
        case .simulateHeadphonesPluggedIn:
            "Reports headphones as connected to the system"

        // System (Region)
        case .regionFreePatch:
            "Shows all system apps regardless of region"
        case .regionValue:
            "Sets the system region used by the emulator"

        // System (General)
        case .stepsPerHour:
            "Sets pedometer steps reported per hour"

        // Web/API
        case .webAPIURL:
            "Configures the Web API endpoint for services"
        }
    }
    
    func setting(_ delegate: SettingDelegate? = nil) -> BaseSetting {
        switch self {
        case .asyncFilesystemOperations:
            BoolSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                        isEnabled: true, value: UserDefaults.standard.bool(forKey: rawValue), delegate: delegate)
        case .asyncPresentation:
            BoolSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                        isEnabled: true, value: UserDefaults.standard.bool(forKey: rawValue), delegate: delegate)
        case .asyncShaderCompilation:
            BoolSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                        isEnabled: true, value: UserDefaults.standard.bool(forKey: rawValue), delegate: delegate)
        case .cpuClockPercent:
            SelectionSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                             values: [
                                "50%" : 50,
                                "75%" : 75,
                                "90%" : 90,
                                "Default" : 100,
                                "110%" : 110
                             ], selectedValue: UserDefaults.standard.value(forKey: rawValue), action: {}, delegate: delegate)
        case .cpuJIT:
            BoolSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                        isEnabled: true, value: UserDefaults.standard.bool(forKey: rawValue), delegate: delegate)
        case .deterministicAsyncOperations:
            BoolSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                        isEnabled: true, value: UserDefaults.standard.bool(forKey: rawValue), delegate: delegate)
        case .fastInterpreter:
            BoolSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                        isEnabled: true, value: UserDefaults.standard.bool(forKey: rawValue), delegate: delegate)
        case .new3DSMode:
            SegmentedSetting(key: rawValue, title: title, details: details,
                             values: [
                                "Old" : 0,
                                "New" : 1
                             ], selectedValue: UserDefaults.standard.value(forKey: rawValue), action: { _ in }, delegate: delegate)
        case .requiredOnlineLLEModules:
            BoolSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                        isEnabled: true, value: UserDefaults.standard.bool(forKey: rawValue), delegate: delegate)
        case .logFilter:
            SelectionSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                             values: [
                                "Trace" : "*:Trace",
                                "Debug" : "*:Debug",
                                "Info" : "*:Info",
                                "Warning" : "*:Warning",
                                "Error" : "*:Error",
                                "Critical" : "*:Critical"
                             ], selectedValue: UserDefaults.standard.string(forKey: rawValue), action: {}, delegate: delegate)
        case .graphicsAPI:
            SelectionSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                             values: [
                                "Vulkan" : 2
                             ], selectedValue: UserDefaults.standard.value(forKey: rawValue), action: {}, delegate: delegate)
        case .hardwareShader:
            BoolSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                        isEnabled: true, value: UserDefaults.standard.bool(forKey: rawValue), delegate: delegate)
        case .integerScaling:
            BoolSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                        isEnabled: true, value: UserDefaults.standard.bool(forKey: rawValue), delegate: delegate)
        case .rightEyeRender:
            BoolSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                        isEnabled: true, value: UserDefaults.standard.bool(forKey: rawValue), delegate: delegate)
        case .skipDuplicateFrames:
            BoolSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                        isEnabled: true, value: UserDefaults.standard.bool(forKey: rawValue), delegate: delegate)
        case .vsync:
            BoolSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                        isEnabled: true, value: UserDefaults.standard.bool(forKey: rawValue), delegate: delegate)
        case .resolutionScaleFactor:
            SelectionSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                             values: [
                                "Automatic" : 0,
                                "Native" : 1,
                                "2x" : 2,
                                "3x" : 3,
                                "4x" : 4
                             ], selectedValue: UserDefaults.standard.value(forKey: rawValue), action: {}, delegate: delegate)
        case .shaderJIT:
            BoolSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                        isEnabled: true, value: UserDefaults.standard.bool(forKey: rawValue), delegate: delegate)
        case .shadersAccurateMultiply:
            BoolSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                        isEnabled: true, value: UserDefaults.standard.bool(forKey: rawValue), delegate: delegate)
        case .spirvOptimizer:
            BoolSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                        isEnabled: true, value: UserDefaults.standard.bool(forKey: rawValue), delegate: delegate)
        case .spirvShaderGeneration:
            BoolSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                        isEnabled: true, value: UserDefaults.standard.bool(forKey: rawValue), delegate: delegate)
        case .simulate3DSGPUTimings:
            BoolSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                        isEnabled: true, value: UserDefaults.standard.bool(forKey: rawValue), delegate: delegate)
        case .textureFilter:
            SelectionSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                             values: [
                                "Automatic" : 0,
                                "Anime4K" : 1,
                                "Bicubic" : 2,
                                "ScaleForce" : 3,
                                "xBRZ" : 4,
                                "MMPX" : 5
                             ], selectedValue: UserDefaults.standard.value(forKey: rawValue), action: {}, delegate: delegate)
        case .textureSampling:
            SelectionSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                             values: [
                                "GameControlled" : 0,
                                "NearestNeighbor" : 1,
                                "Linear" : 2
                             ], selectedValue: UserDefaults.standard.value(forKey: rawValue), action: {}, delegate: delegate)
        case .audioEmulationMode:
            SelectionSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                             values: [
                                "HLE" : 0,
                                "LLE" : 1,
                                "LLE Multithreaded" : 2
                             ], selectedValue: UserDefaults.standard.value(forKey: rawValue), action: {}, delegate: delegate)
        case .audioStretching:
            BoolSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                        isEnabled: true, value: UserDefaults.standard.bool(forKey: rawValue), delegate: delegate)
        case .inputType:
            SelectionSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                             values: [
                                "CoreAudio" : 6
                             ], selectedValue: UserDefaults.standard.value(forKey: rawValue), action: {}, delegate: delegate)
        case .outputType:
            SelectionSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                             values: [
                                "CoreAudio" : 7
                             ], selectedValue: UserDefaults.standard.value(forKey: rawValue), action: {}, delegate: delegate)
        case .realtimeAudio:
            BoolSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                        isEnabled: true, value: UserDefaults.standard.bool(forKey: rawValue), delegate: delegate)
        case .simulateHeadphonesPluggedIn:
            BoolSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                        isEnabled: true, value: UserDefaults.standard.bool(forKey: rawValue), delegate: delegate)
        case .regionFreePatch:
            BoolSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                        isEnabled: true, value: UserDefaults.standard.bool(forKey: rawValue), delegate: delegate)
        case .regionValue:
            SelectionSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                             values: [
                                "Detect" : -1,
                                "JPN" : 0,
                                "USA" : 1,
                                "EUR" : 2,
                                "AUS" : 3,
                                "CHN" : 4,
                                "KOR" : 5,
                                "TWN" : 6
                             ], selectedValue: nil, action: {}, delegate: delegate)
        case .stepsPerHour:
            InputNumberSetting(key: rawValue, title: title, details: details, secondaryTitle: nil,
                               isEnabled: true, min: 0, max: 999, value: UserDefaults.standard.double(forKey: rawValue), delegate: delegate)
        case .webAPIURL:
            InputStringSetting(key: rawValue, title: title, details: details, placeholder: "http(s)://domain:port",
                               value: UserDefaults.standard.string(forKey: rawValue), action: {}, delegate: delegate)
        }
    }
    

    static func settings(_ header: SettingsHeaders) -> [CytrusSettingsItems] {
        switch header {
        case .coreGeneral:
            [
                .cpuJIT,
                .cpuClockPercent,
                .new3DSMode,
                .requiredOnlineLLEModules,
                .deterministicAsyncOperations,
                .fastInterpreter,
                .asyncFilesystemOperations
            ]
        case .debuggingGeneral:
            [
                .logFilter
            ]
        case .graphics3D:
            [
                .rightEyeRender
            ]
        case .graphicsGeneral:
            [
                .graphicsAPI,
                .hardwareShader,
                .asyncPresentation,
                .integerScaling,
                .skipDuplicateFrames,
                .vsync
            ]
        case .graphicsResolution:
            [
                .resolutionScaleFactor
            ]
        case .graphicsShader:
            [
                .spirvShaderGeneration,
                .asyncShaderCompilation,
                .shaderJIT,
                .shadersAccurateMultiply,
                .spirvOptimizer
            ]
        case .graphicsTimingSimulation:
            [
                .simulate3DSGPUTimings
            ]
        case .graphicsTexture:
            [
                .textureFilter,
                .textureSampling
            ]
        case .soundGeneral:
            [
                .audioEmulationMode,
                .audioStretching,
                .realtimeAudio,
                .outputType,
                .inputType,
                .simulateHeadphonesPluggedIn
            ]
        case .systemGeneral:
            [
                .stepsPerHour
            ]
        case .systemRegion:
            [
                .regionValue,
                .regionFreePatch
            ]
        case .webAPI:
            [
                .webAPIURL
            ]
        default:
            []
        }
    }
    
    static var settings: [CytrusSettingsItems : (setting: cytrus.SETTING, type: Any.Type)] = [
        .asyncFilesystemOperations : (cytrus.SETTING.ASYNC_FILESYSTEM_OPERATIONS, Bool.self),
        .asyncPresentation : (cytrus.SETTING.ASYNC_PRESENTATION, Bool.self),
        .asyncShaderCompilation : (cytrus.SETTING.ASYNC_SHADER_COMPILATION, Bool.self),
        .cpuClockPercent : (cytrus.SETTING.CPU_CLOCK_PERCENT, Int.self),
        .cpuJIT : (cytrus.SETTING.CPU_JIT, Bool.self),
        .deterministicAsyncOperations : (cytrus.SETTING.DETERMINISTIC_ASYNC_OPERATIONS, Bool.self),
        .fastInterpreter : (cytrus.SETTING.FAST_INTERPRETER, Bool.self),
        .new3DSMode : (cytrus.SETTING.NEW_3DS_MODE, Int.self),
        .requiredOnlineLLEModules : (cytrus.SETTING.REQUIRED_ONLINE_LLE_MODULES, Bool.self),
        
        .logFilter : (cytrus.SETTING.LOG_FILTER, String.self),
        
        .graphicsAPI : (cytrus.SETTING.GRAPHICS_API, Int.self),
        .hardwareShader : (cytrus.SETTING.HARDWARE_SHADER, Bool.self),
        .integerScaling : (cytrus.SETTING.INTEGER_SCALING, Bool.self),
        .rightEyeRender : (cytrus.SETTING.RIGHT_EYE_RENDER, Bool.self),
        .skipDuplicateFrames : (cytrus.SETTING.SKIP_DUPLICATE_FRAMES, Bool.self),
        .vsync : (cytrus.SETTING.VSYNC, Bool.self),
        
        .resolutionScaleFactor : (cytrus.SETTING.RESOLUTION_SCALE_FACTOR, Int.self),
        
        .shaderJIT : (cytrus.SETTING.SHADER_JIT, Bool.self),
        .shadersAccurateMultiply : (cytrus.SETTING.SHADERS_ACCURATE_MULTIPLY, Bool.self),
        .spirvOptimizer : (cytrus.SETTING.SPIRV_OPTIMIZER, Bool.self),
        .spirvShaderGeneration : (cytrus.SETTING.SPIRV_SHADER_GENERATION, Bool.self),
        
        .simulate3DSGPUTimings : (cytrus.SETTING.SIMULATE_3DS_GPU_TIMINGS, Bool.self),
        
        .textureFilter : (cytrus.SETTING.TEXTURE_FILTER, Int.self),
        .textureSampling : (cytrus.SETTING.TEXTURE_SAMPLING, Int.self),
        
        .audioEmulationMode : (cytrus.SETTING.AUDIO_EMULATION_MODE, Int.self),
        .audioStretching : (cytrus.SETTING.AUDIO_STRETCHING, Bool.self),
        .inputType : (cytrus.SETTING.INPUT_TYPE, Int.self),
        .outputType : (cytrus.SETTING.OUTPUT_TYPE, Int.self),
        .realtimeAudio : (cytrus.SETTING.REALTIME_AUDIO, Bool.self),
        .simulateHeadphonesPluggedIn : (cytrus.SETTING.SIMULATE_HEADPHONES_PLUGGED_IN, Bool.self),
        
        .regionFreePatch : (cytrus.SETTING.REGION_FREE_PATCH, Bool.self),
        .regionValue : (cytrus.SETTING.REGION_VALUE, Int.self),
        
        .stepsPerHour : (cytrus.SETTING.STEPS_PER_HOUR, Int.self),
        
        .webAPIURL : (cytrus.SETTING.WEB_API_URL, String.self)
    ]
}
