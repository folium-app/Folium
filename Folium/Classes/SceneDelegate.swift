//
//  SceneDelegate.swift
//  Folium
//
//  Created by Jarrod Norwell on 3/6/2026.
//

import AVFoundation
import ColourKit
import ExtensionsKit
import FontKit
import OnboardingKit
import StoreKit
import SwiftUI
import UIKit

import Cherry
import Cytrus
import Durian
import Grape
import Kiwi
import Lychee
import Mandarine
import Mango
import Plum
import Tomato

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let userDefaults = UserDefaults.standard
    
    var window: UIWindow? = nil
    
    private var authorizationActors = AuthorizationActors()
    private var directoryManager = DirectoryManager()
    
    private let cherrySystem = CherrySystem()
    private let cytrusSystem = CytrusSystem()
    private let durianSystem = DurianSystem()
    private let grapeSystem = GrapeSystem()
    private let kiwiSystem = KiwiSystem()
    private let lycheeSystem = LycheeSystem()
    private let mandarineSystem = MandarineSystem()
    private let mangoSystem = MangoSystem()
    private let plumSystem = PlumSystem()
    private let tomatoSystem = TomatoSystem()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Task.detached(priority: .background) {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else {
                    continue
                }
                
                var inDate: Bool = false
                if let expirationDate = transaction.expirationDate {
                    inDate = expirationDate > Date()
                }
                
                UserDefaults.standard.set(transaction.revocationDate.isNil && inDate, forKey: "extraFeaturesPurchased")
                NotificationCenter.default.post(name: NSNotification.Name("extraFeaturesStatusDidChange"), object: true)
                
                await transaction.finish()
            }
        }
        
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        
        let gamePopulationManager = GamePopulationManager(cherrySystem, cytrusSystem, durianSystem, grapeSystem,
                                                          kiwiSystem, lycheeSystem, mandarineSystem, mangoSystem,
                                                          plumSystem, tomatoSystem)
        let onboardingFlow = OnboardingFlow(authorizationActors, directoryManager, gamePopulationManager)
        
        window = UIWindow(windowScene: windowScene)
        guard let window else {
            return
        }
        
        let onboardingComplete: Bool = UserDefaults.standard.bool(forKey: "folium.onboardingComplete")
        
        window.rootViewController = if onboardingComplete {
            TabController(directoryManager: directoryManager, gamePopulationManager: gamePopulationManager)
        } else {
            FoliumOnboardingController(window.rootViewController ?? UIViewController(), { controller in
                await onboardingFlow.cameraAuthorization(controller)
            })
        }
        
        window.tintColor = .systemIndigo
        window.makeKeyAndVisible()
        
        _ = Task {
            try await directoryManager.initializeSystemDirectoriesForInitialLaunch()
            
            await cherrySystem.initializePaths()
            await cherrySystem.initializeSystem()
            
            await cytrusSystem.initializeLogging()
            
            await durianSystem.initializePaths()
            await durianSystem.initializeSystem()
            await setSettingsForDurian()
            
            await grapeSystem.initializePaths()
            await grapeSystem.initializeSystem()
            await setSettingsForGrape()
            
            await kiwiSystem.initializePaths()
            await kiwiSystem.initializeSystem()
            await setSettingsForKiwi()
            
            await lycheeSystem.initializePaths()
            await lycheeSystem.initializeSystem()
            
            await mandarineSystem.initializePaths()
            await mandarineSystem.initializeMemoryCards()
            await mandarineSystem.initializeSystem()
            
            await mangoSystem.initializePaths()
            await mangoSystem.initializeSystem()
            
            await plumSystem.initializePaths()
            await plumSystem.initializeSystem()
            
            await tomatoSystem.initializePaths()
            await tomatoSystem.initializeSystem()
            await setSettingsForTomato()
            
            let session: AVAudioSession = AVAudioSession.sharedInstance()
            DispatchQueue.global(qos: .background).async {
                do {
                    try session.setCategory(.playback, options: [.mixWithOthers])
                    try session.setActive(true)
                } catch {
                    print(error, error.localizedDescription)
                }
            }
        }
        
        initializeUserDefaultsWithDefaultValues()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        NotificationCenter.default.post(name: .applicationStateDidChange, object: ApplicationState.disconnected)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {
        NotificationCenter.default.post(name: .applicationStateDidChange, object: ApplicationState.foregrounded)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        NotificationCenter.default.post(name: .applicationStateDidChange, object: ApplicationState.backgrounded)
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
            .durian : [
                "consoleModel" : 0,
                "adjustColours" : false,
                "blendFrames" : false,
                "showIcons" : false
            ],
            .grape : [
                "skipBootScreen" : true,
                "consoleModel" : 0
            ],
            .kiwi : [
                "adjustColours" : true,
                "blendFrames" : true
            ],
            .mandarine : [
                "logBios" : false,
                "logCdrom" : false,
                "logController" : false,
                "logDma" : false,
                "logGpu" : false,
                "logGte" : false,
                "logMdec" : false,
                "logMemoryCard" : false,
                "logMemoryControl" : false,
                "logSpu" : false,
                "logSystem" : true,
                
                "forceNTSC" : false,
                "forceWidescreen" : false,
                "nativeTextureFormat" : true,
                "vsync" : false,
                "widescreen" : false,
                
                "height" : 480,
                "width" : 640,
                
                "soundEnabled" : true,
                
                "extendedMemory" : false,
                "preserveState" : true,
                "timeTravel" : false
            ],
            .tomato : [
                "skipBootScreen" : false,
                
                "adjustColours" : true,
                "blendFrames" : true,
                "frameSkipping" : false
            ]
        ]
        
        let applicationDefaultValues : [String : Any] = [
            "autoResumeOnForeground" : false,
            "defaultSystemForLibrary" : "Cherry"
        ]
        
        for (system, defaultValues) in systemsWithDefaultValues {
            for (key, value) in defaultValues {
                if userDefaults.value(forKey: "\(system.string.localizedLowercase).\(key)") == nil {
                    userDefaults.set(value, forKey: "\(system.string.localizedLowercase).\(key)")
                }
            }
        }
        
        for (key, value) in applicationDefaultValues {
            if userDefaults.value(forKey: "folium.\(key)") == nil {
                userDefaults.set(value, forKey: "folium.\(key)")
            }
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
    
    func setSettingsForDurian() async {
        let settingsForDurian: [DurianSettingsItems : (setting: durian.SETTING, type: Any.Type)] = [
            .consoleModel : (durian.SETTING.CONSOLE_MODEL, Int.self)
        ]
        
        await SettingsHeaders.grapeHeaders.asyncForEach { header in
            await DurianSettingsItems.settings(header).asyncForEach { item in
                guard let settingForDurian: (setting: durian.SETTING, type: Any.Type) = settingsForDurian[item] else {
                    return
                }
                
                switch settingForDurian.type {
                case is Int.Type:
                    _ = await durianSystem.setSetting(setting: settingForDurian.setting, value: UserDefaults.standard.integer(forKey: item.rawValue))
                default:
                    break
                }
            }
        }
    }
    
    func setSettingsForGrape() async {
        let settingsForGrape: [GrapeSettingsItems : (setting: grape.SETTING, type: Any.Type)] = [
            .skipBootScreen : (grape.SETTING.SKIP_BOOT_SCREEN, Bool.self),
            .consoleModel : (grape.SETTING.CONSOLE_MODEL, Int.self)
        ]
        
        await SettingsHeaders.grapeHeaders.asyncForEach { header in
            await GrapeSettingsItems.settings(header).asyncForEach { item in
                guard let settingForGrape: (setting: grape.SETTING, type: Any.Type) = settingsForGrape[item] else {
                    return
                }
                
                switch settingForGrape.type {
                case is Bool.Type:
                    _ = await grapeSystem.setSetting(setting: settingForGrape.setting, value: UserDefaults.standard.bool(forKey: item.rawValue))
                case is Int.Type:
                    _ = await grapeSystem.setSetting(setting: settingForGrape.setting, value: UserDefaults.standard.integer(forKey: item.rawValue))
                default:
                    break
                }
            }
        }
    }
    
    func setSettingsForKiwi() async {
        let settingsForKiwi: [KiwiSettingsItems : kiwi.SETTING] = [
            .adjustColours : kiwi.SETTING.ADJUST_COLOURS,
            .blendFrames : kiwi.SETTING.BLEND_FRAMES
        ]
        
        await SettingsHeaders.kiwiHeaders.asyncForEach { header in
            await KiwiSettingsItems.settings(header).asyncForEach { item in
                guard let settingForKiwi: kiwi.SETTING = settingsForKiwi[item] else {
                    return
                }
                
                _ = await kiwiSystem.setSetting(setting: settingForKiwi, value: UserDefaults.standard.value(forKey: item.rawValue))
            }
        }
    }
    
    func setSettingsForMandarine() {
        let settingsForMandarine: [MandarineSettingsItems : mandarine.SETTING] = [
            .extendedMemory : mandarine.SETTING.EXTENDED_MEMORY,
            .forceNTSC : mandarine.SETTING.FORCE_NTSC,
            .forceWidescreen : mandarine.SETTING.FORCE_WIDESCREEN,
            .logBios : mandarine.SETTING.LOG_BIOS,
            .logCdrom : mandarine.SETTING.LOG_CDROM,
            .logController : mandarine.SETTING.LOG_CONTROLLER,
            .logDma : mandarine.SETTING.LOG_DMA,
            .logGpu : mandarine.SETTING.LOG_GPU,
            .logGte : mandarine.SETTING.LOG_GTE,
            .logMdec : mandarine.SETTING.LOG_MDEC,
            .logMemoryCard : mandarine.SETTING.LOG_MEMORY_CARD,
            .logMemoryControl : mandarine.SETTING.LOG_MEMORY_CONTROL,
            .logSpu : mandarine.SETTING.LOG_SPU,
            .logSystem : mandarine.SETTING.LOG_SYSTEM,
            .nativeTextureFormat : mandarine.SETTING.NATIVE_TEXTURE_FORMAT,
            .preserveState : mandarine.SETTING.PRESERVE_STATE,
            .soundEnabled : mandarine.SETTING.SOUND_ENABLED,
            .timeTravel : mandarine.SETTING.TIME_TRAVEL,
            .vsync : mandarine.SETTING.VSYNC,
            .widescreen : mandarine.SETTING.WIDESCREEN
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
    
    func setSettingsForTomato() async {
        let settingsForTomato: [TomatoSettingsItems : tomato.SETTING] = [
            .skipBootScreen : tomato.SETTING.SKIP_BOOT_SCREEN,
            
            .adjustColours : tomato.SETTING.ADJUST_COLOURS,
            .blendFrames : tomato.SETTING.BLEND_FRAMES,
            .frameSkipping : tomato.SETTING.FRAME_SKIPPING
        ]
        
        await SettingsHeaders.tomatoHeaders.asyncForEach { header in
            await TomatoSettingsItems.settings(header).asyncForEach { item in
                guard let settingForTomato: tomato.SETTING = settingsForTomato[item] else {
                    return
                }
                
                _ = await tomatoSystem.setSetting(setting: settingForTomato, value: UserDefaults.standard.value(forKey: item.rawValue))
            }
        }
    }
}
