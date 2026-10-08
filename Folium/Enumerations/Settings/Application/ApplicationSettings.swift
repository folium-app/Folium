//
//  ApplicationSettingsItems.swift
//  Folium
//
//  Created by Jarrod Norwell on 7/6/2026.
//

import ColourKit
import ExtensionsKit
import FontKit
import Foundation
import OnboardingKit
import SettingsKit
import StoreKit
import UIKit

struct Purchase {
    enum PurchaseError: Error {
        case failed
        case refunded
    }
    
    static func purchase(productID: String) async throws -> Transaction {
        let products = try await Product.products(for: [productID])
        
        guard let product = products.first else {
            throw PurchaseError.failed
        }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                // A revoked transaction should not grant access.
                guard transaction.revocationDate == nil else {
                    await transaction.finish()
                    throw PurchaseError.refunded
                }
                
                await transaction.finish()
                return transaction
                
            case .unverified:
                throw PurchaseError.failed
            }
            
        case .userCancelled:
            throw CancellationError()
            
        case .pending:
            // The purchase hasn't completed yet.
            throw PurchaseError.failed
            
        @unknown default:
            throw PurchaseError.failed
        }
    }
}

enum ApplicationSettingsItems : String, CaseIterable {
    // Purchase
    case purchase = "folium.purchase"
    case restorePurchase = "folium.restorePurchase"
    
    // General
    case autoResumeOnForeground = "folium.autoResumeOnForeground"
    
    // Library (General)
    case defaultSystemForLibrary = "folium.defaultSystemForLibrary"
    
    var title: String {
        switch self {
        case .purchase:
            UserDefaults.standard.bool(forKey: "extraFeaturesPurchased") ? "Purchased" : "Purchase"
        case .restorePurchase:
            "Restore Purchase"
        case .autoResumeOnForeground:
            "Auto Resume Emulation"
        case .defaultSystemForLibrary:
            "Default System"
        }
    }
    
    var details: String? {
        switch self {
        case .purchase:
            "Access peer to peer functionality for several systems allowing direct device-to-device multiplayer keeping things safe and smooth"
        case .restorePurchase:
            nil
        case .autoResumeOnForeground:
            "Automatically resumes emulation when the application enters the foreground"
        case .defaultSystemForLibrary:
            "Sets the system the library will open to upon application launch"
        }
    }
    
    func setting(_ delegate: SettingDelegate? = nil) -> BaseSetting {
        switch self {
        case .purchase:
            if UserDefaults.standard.bool(forKey: "extraFeaturesPurchased") {
                TapSetting(key: rawValue,
                           title: title,
                           details: details,
                           color: .systemGreen,
                           handler: { controller in },
                           delegate: delegate)
            } else {
                TapSetting(key: rawValue,
                           title: title,
                           details: details,
                           color: .tintColor,
                           handler: { controller in
                    func purchase(_ completionHandler: @escaping () -> Void) async {
                        do {
                            _ = try await Purchase.purchase(productID: "00000003")
                            UserDefaults.standard.set(true, forKey: "extraFeaturesPurchased")
                            NotificationCenter.default.post(name: NSNotification.Name("extraFeaturesStatusDidChange"), object: true)
                        } catch {
                            UserDefaults.standard.set(false, forKey: "extraFeaturesPurchased")
                            NotificationCenter.default.post(name: NSNotification.Name("extraFeaturesStatusDidChange"), object: false)
                        }
                        completionHandler()
                    }
                    
                    var viewController: OBControllerWithList {
                        let image: UIImage? = UIImage(systemName: "plus")
                        
                        let labelConfiguration: LabelConfiguration = LabelConfiguration(alignment: .left,
                                                                                        color: .label,
                                                                                        font: UIFont.bold(from: .compatibleExtraLargeTitle),
                                                                                        text: "Extra Features")
                        
                        let secondaryLabelConfiguration: LabelConfiguration = LabelConfiguration(alignment: .left,
                                                                                                 color: .secondaryLabel,
                                                                                                 font: UIFont.regular(from: .body),
                                                                                                 text: "Access extra features not integral to the functionality of the app or emulation with more to be added")
                        
                        let buttons: [(UIButton.Configuration, @MainActor (UIViewController) async -> Void)] = [
                            (UIButton.Configuration.configuration(.large, .capsule, nil, "Cancel"), { controller in
                                onMainThread {
                                    controller.dismiss(animated: true)
                                }
                            }),
                            (UIButton.Configuration.configuration(.large, .capsule, nil, "Purchase",
                                                                  .large, .tintColor, inverseColor: true), { controller in
                                                                      _ = Task {
                                                                          await purchase {
                                                                              onMainThread {
                                                                                  controller.dismiss(animated: true)
                                                                              }
                                                                          }
                                                                      }
                            })
                        ]
                        
                        let cells: [String : [CellConfiguration]] = [
                            /*
                            "Emulation Enhancements" : [
                                CellConfiguration(image: UIImage(systemName: "square.stack.3d.forward.dottedline"),
                                                  labels: (
                                                    LabelConfiguration(alignment: .left,
                                                                       color: .label,
                                                                       font: UIFont.regular(from: .headline),
                                                                       text: "Fast Forward"),
                                                    LabelConfiguration(alignment: .left,
                                                                       color: .secondaryLabel,
                                                                       font: UIFont.regular(from: .subheadline),
                                                                       text: "Tap and hold the new fast forward button to speed up emulation in some systems")
                                                  )),
                                CellConfiguration(image: UIImage(systemName: "arrow.down.document"),
                                                  labels: (
                                                    LabelConfiguration(alignment: .left,
                                                                       color: .label,
                                                                       font: UIFont.regular(from: .headline),
                                                                       text: "Unlimited Saves"),
                                                    LabelConfiguration(alignment: .left,
                                                                       color: .secondaryLabel,
                                                                       font: UIFont.regular(from: .subheadline),
                                                                       text: "Provides more than the available 3 saves, allowing for finer save control")
                                                  ))
                            ],*/
                            "Peer To Peer" : [
                                CellConfiguration(image: UIImage(systemName: "house"),
                                                  labels: (
                                                    LabelConfiguration(alignment: .left,
                                                                       color: .label,
                                                                       font: UIFont.regular(from: .headline),
                                                                       text: "Local"),
                                                    nil,
                                                    LabelConfiguration(alignment: .left,
                                                                       color: .secondaryLabel,
                                                                       font: UIFont.regular(from: .subheadline),
                                                                       text: "Keep everything safe and secure with direct device-to-device transfers over the local area network")
                                                  )),
                                CellConfiguration(image: UIImage(systemName: "gauge.with.dots.needle.100percent"),
                                                  labels: (
                                                    LabelConfiguration(alignment: .left,
                                                                       color: .label,
                                                                       font: UIFont.regular(from: .headline),
                                                                       text: "Performant"),
                                                    nil,
                                                    LabelConfiguration(alignment: .left,
                                                                       color: .secondaryLabel,
                                                                       font: UIFont.regular(from: .subheadline),
                                                                       text: "Lag will never be an issue with the app only sending button input and image data between devices")
                                                  ))
                            ]/*,
                            "Visual Enhancements" : [
                                CellConfiguration(image: UIImage(systemName: "square.resize.up"),
                                                  labels: (
                                                    LabelConfiguration(alignment: .left,
                                                                       color: .label,
                                                                       font: UIFont.regular(from: .headline),
                                                                       text: "Upscaling"),
                                                    LabelConfiguration(alignment: .left,
                                                                       color: .secondaryLabel,
                                                                       font: UIFont.regular(from: .subheadline),
                                                                       text: "Choose from up to 23 upscaling options in some systems with a minimum of 4 in others")
                                                  ))
                            ]*/
                        ]
                        
                        let configuration: OBControllerWithListConfiguration  = OBControllerWithListConfiguration(image: image,
                                                                                                                  textConfiguration: labelConfiguration,
                                                                                                                  secondaryConfiguration: secondaryLabelConfiguration,
                                                                                                                  tertiaryConfiguration: nil,
                                                                                                                  buttons: buttons,
                                                                                                                  cells: cells)
                        
                        let viewController: OBControllerWithList = OBControllerWithList(configuration: configuration)
                        viewController.modalPresentationStyle = .overFullScreen
                        return viewController
                    }
                    
                    controller.present(viewController, animated: true)
                }, delegate: delegate)
            }
        case .restorePurchase:
            TapSetting(key: rawValue,
                       title: title,
                       details: details,
                       color: .systemGreen,
                       useColor: false,
                       handler: { controller in
                _ = Task {
                    var result: Bool = false
                    
                    try await AppStore.sync()
                    for await entitlement in Transaction.currentEntitlements {
                        guard case .verified(let transaction) = entitlement else {
                            continue
                        }
                        
                        result = transaction.revocationDate.isNil
                        UserDefaults.standard.set(result, forKey: "extraFeaturesPurchased")
                        NotificationCenter.default.post(name: NSNotification.Name("extraFeaturesStatusDidChange"), object: result)
                        
                        await transaction.finish()
                    }
                    
                    var title: String = "Success"
                    var message: String = "Extra Features have successfully been restored"
                    
                    switch result {
                    case false:
                        title = "Failure"
                        message = "Extra Features have not been restored"
                    case true:
                        break
                    }
                    
                    let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                    controller.present(alertController, animated: true)
                }
            },
                       delegate: delegate)
        case .autoResumeOnForeground:
            BoolSetting(key: rawValue,
                        title: title,
                        details: details,
                        secondaryTitle: nil,
                        isEnabled: true,
                        value: UserDefaults.standard.bool(forKey: rawValue),
                        delegate: delegate)
            
        case .defaultSystemForLibrary:
            SelectionSetting(key: rawValue,
                             title: title,
                             details: details,
                             values: Dictionary(uniqueKeysWithValues: System.allCases.map { system in (system.consoleShort, system.string) }),
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
        }
    }
    
    static func settings(_ header: SettingsHeaders) -> [ApplicationSettingsItems] {
        switch header {
        case .premiumExtraFeatures:
            [
                .purchase,
                .restorePurchase
            ]
        case .general:
            [
                .autoResumeOnForeground
            ]
        case .libraryGeneral:
            [
                .defaultSystemForLibrary
            ]
        default:
            []
        }
    }
}
