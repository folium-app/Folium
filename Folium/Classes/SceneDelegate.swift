//
//  SceneDelegate.swift
//  Folium
//
//  Created by Jarrod Norwell on 3/6/2026.
//

import ColourKit
import ExtensionsKit
import FontKit
import OnboardingKit
import SwiftUI
import UIKit

import Cytrus
import Grape
import Kiwi
import Mandarine
import Tomato

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let userDefaults: UserDefaults = .standard
    
    var window: UIWindow? = nil
    
    private var directoryManager: DirectoryManager = DirectoryManager()
    
    private let cytrusSystem: CytrusSystem = CytrusSystem()
    private let grapeSystem: GrapeSystem = GrapeSystem()
    private let kiwiSystem: KiwiSystem = KiwiSystem()
    private let mandarineSystem: MandarineSystem = MandarineSystem()
    private let tomatoSystem: TomatoSystem = TomatoSystem()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        
        let gamesManager: GamesManager = GamesManager(cytrusSystem: cytrusSystem,
                                                      grapeSystem: grapeSystem,
                                                      kiwiSystem: kiwiSystem,
                                                      mandarineSystem: mandarineSystem,
                                                      tomatoSystem: tomatoSystem)
        let onboardingModel: OnboardingModel = OnboardingModel(gamesManager: gamesManager)
        
        window = UIWindow(windowScene: windowScene)
        guard let window else {
            return
        }
        
        let onboardingComplete: Bool = UserDefaults.standard.bool(forKey: "folium.onboardingComplete")
        
        var onboardingController: OBController {
            let textConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                           color: .label,
                                                                           font: .regular(from: .extraLargeTitle),
                                                                           text: "Folium")
            
            let secondaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                    color: .secondaryLabel,
                                                                                    font: .regular(from: .body),
                                                                                    text: "Generations of gaming in the palm of your hands")
            
            let tertiaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                   color: .tertiaryLabel,
                                                                                   font: .regular(from: .callout),
                                                                                   text: "Developed by Jarrod Norwell\nLicensed under GPLv3")
            
            let buttons: [(UIButton.Configuration, @MainActor (UIViewController) async -> Void)] = [
                (UIButton.Configuration.configuration(.large, .capsule, nil, "Continue"), { controller in
                    await onboardingModel.camera(controller: controller)
                })
            ]
            
            let configuration: OBControllerConfiguration = OBControllerConfiguration(image: UIImage(systemName: "leaf.fill"),
                                                                                     textConfiguration: textConfiguration,
                                                                                     secondaryConfiguration: secondaryTextConfiguration,
                                                                                     tertiaryConfiguration: tertiaryTextConfiguration,
                                                                                     buttons: buttons,
                                                                                     colors: [
                                                                                        Colour(red: 0.90, green: 0.90, blue: 1.00),
                                                                                        Colour(red: 0.80, green: 0.80, blue: 1.00),
                                                                                        Colour(red: 0.70, green: 0.70, blue: 1.00),
                                                                                        Colour(red: 0.55, green: 0.55, blue: 0.95),
                                                                                        Colour(red: 0.45, green: 0.45, blue: 0.90),
                                                                                        Colour(red: 0.35, green: 0.35, blue: 0.84), // iOS systemIndigo
                                                                                        Colour(red: 0.30, green: 0.30, blue: 0.72),
                                                                                        Colour(red: 0.25, green: 0.25, blue: 0.60),
                                                                                        Colour(red: 0.20, green: 0.20, blue: 0.48)
                                                                                     ])
            
            return OBController(configuration: configuration)
        }
        
        window.rootViewController = if onboardingComplete {
            TabController(gamesManager: gamesManager)
        } else {
            onboardingController
        }
        
        window.tintColor = .systemIndigo
        window.makeKeyAndVisible()
        
        let task: Task = Task {
            try await directoryManager.initializeSystemDirectoriesForInitialLaunch()
            
            try moveMandarineShaderFilesIfNeeded()
        }
        
        Task {
            switch await task.result {
            case .success(_):
                await cytrusSystem.initializeLogging()
                
                await grapeSystem.initializePaths()
                await grapeSystem.initializeSystem()
                
                await kiwiSystem.initializePaths()
                await kiwiSystem.initializeSystem()
                
                await mandarineSystem.initializePaths()
                await mandarineSystem.initializeMemoryCards()
                await mandarineSystem.initializeSystem()
                
                await tomatoSystem.initializeSystem()
                await tomatoSystem.initializePaths()
            case .failure(let failure):
                print(failure, failure.localizedDescription)
            }
        }
        
        initializeUserDefaultsWithDefaultValues()
        setSettingsForCytrus()
        setSettingsForMandarine()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {
        // pause
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // resume, if enabled
    }
    
    private func initializeUserDefaultsWithDefaultValues() {
        let systemsWithDefaultValues: [System : [String : Any]] = [
            .cytrus : [
                "cpuJIT" : 0,
                "cpuClockPercentage" : 100,
                "new3DS" : 1,
                "lleApplets" : true,
                "deterministicAsyncOperations" : false,
                "requiredOnlineLLEModules" : false,
                
                "logLevel" : "Info",
                
                "stereoscopic3D" : 0,
                "`3DFactor" : 0,
                "swapEyes3D" : false,
                
                "spirvOptimizer" : true,
                "asyncPresentation" : true,
                "vsync" : false,
                "textureFilter" : 0,
                "textureSampling" : 0,
                
                "upscaleFactor" : 0,
                
                "spirvShaderGen" : true,
                "asyncShaderCompilation" : false,
                "hardwareShaders" : 1,
                "diskShaderCache" : true,
                "shaderAccurateMultiplication" : true,
                "shaderJIT" : false,
                
                "soundEmulation" : 0,
                "soundStretching" : true,
                "realtimeSound" : false,
                "volume" : 100,
                "soundOutput" : 6,
                "soundInput" : 6,
                
                "clockType" : 0,
                "stepsPerHour" : Double(UInt16.max),
                
                "systemRegion" : -1,
                "regionFreePatch" : true
            ],
            .mandarine : [
                "widescreen" : false,
                "forceWidescreen" : false,
                "vsync" : false,
                "forceNTSC" : false,
                "height" : 480,
                "width" : 640,
                "soundEnabled" : true,
                "extendedMemory" : false
            ],
            .tomato : [
                "backupType" : 0,
                "forceRTC" : 0,
                "forceSolarSensor" : 0,
                "solarSensorLevel" : 100,
                "skipBIOS" : 0,
                "colourCorrection" : 0,
                "filter" : 0,
                "lcdGhosting" : 0,
                "interpolation" : 1,
                "volume" : 100
            ]
        ]
        
        for (system, defaultValues) in systemsWithDefaultValues {
            for (key, value) in defaultValues {
                if userDefaults.value(forKey: "\(system.string.localizedLowercase).\(key)") == nil {
                    userDefaults.set(value, forKey: "\(system.string.localizedLowercase).\(key)")
                }
            }
        }
    }
    
    func moveMandarineShaderFilesIfNeeded() throws {
        guard let documentDirectoryURL: URL = .documentDirectoryURL else {
            return
        }
        
        print(documentDirectoryURL.path)
        
        let shadersDirectoryURL: URL = documentDirectoryURL.appending(component: "Mandarine")
            .appending(component: "shaders")
        
        let shaderFileNames: [String] = [
            "blit",
            "copy",
            "render"
        ]
        
        for shaderFileName in shaderFileNames {
            let to: URL = shadersDirectoryURL.appending(component: shaderFileName.appending(".shader"))
            guard let from: URL = Bundle.main.url(forResource: shaderFileName, withExtension: "shader", subdirectory: "shaders/mandarine"),
                  !FileManager.default.fileExists(atPath: to.path) else {
                return
            }
            
            try FileManager.default.copyItem(at: from, to: to)
        }
    }
    
    func setSettingsForCytrus() {
        let settings: [CytrusSettingsItems : cytrus.SETTING] = [
            .lleApplets : cytrus.SETTING.LLE_APPLETS,
            .deterministicAsyncOperations : cytrus.SETTING.DETERMINISTIC_ASYNC_OPERATIONS,
            .requiredOnlineLLEModules : cytrus.SETTING.REQUIRED_ONLINE_LLE_MODULES,
            .regionFreePatch : cytrus.SETTING.REGION_PREF_PATCH,
            .swapEyes3D : cytrus.SETTING.SWAP_EYES_3D,
            .spirvShaderGen : cytrus.SETTING.SPIRV_SHADER_GEN,
            .spirvOptimizer : cytrus.SETTING.SPIRV_OPTIMIZER,
            .asyncShaderCompilation : cytrus.SETTING.ASYNC_SHADER_COMPILATION,
            .asyncPresentation : cytrus.SETTING.ASYNC_PRESENTATION,
            .diskShaderCache : cytrus.SETTING.DISK_SHADER_CACHE,
            .vsync : cytrus.SETTING.VSYNC,
            .shaderAccurateMultiplication : cytrus.SETTING.SHADER_ACCURATE_MULTIPLICATION,
            .soundStretching : cytrus.SETTING.SOUND_STRETCHING,
            .realtimeSound : cytrus.SETTING.REALTIME_SOUND
        ]
        
        SettingsHeaders.cytrusHeaders.forEach { header in
            CytrusSettingsItems.settings(header).forEach { item in
                guard let setting: cytrus.SETTING = settings[item] else {
                    return
                }
                
                Task {
                    await cytrusSystem.setSetting(setting: setting, value: UserDefaults.standard.value(forKey: item.rawValue))
                }
            }
        }
    }
    
    func setSettingsForMandarine() {
        let settingsForMandarine: [MandarineSettingsItems : mandarine.SETTING] = [
            .extendedMemory : mandarine.SETTING.EXTENDED_MEMORY,
            .soundEnabled : mandarine.SETTING.SOUND_ENABLED
        ]
        
        SettingsHeaders.mandarineHeaders.forEach { header in
            MandarineSettingsItems.settings(header).forEach { item in
                guard let settingForMandarine: mandarine.SETTING = settingsForMandarine[item] else {
                    return
                }
                
                Task {
                    await mandarineSystem.setSetting(setting: settingForMandarine, value: UserDefaults.standard.value(forKey: item.rawValue))
                }
            }
        }
    }
}
