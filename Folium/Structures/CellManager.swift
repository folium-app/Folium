//
//  CellManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 7/6/2026.
//

import FontKit
import SettingsKit
import UIKit

struct CellManager {
    struct Library {
        static func grapeCell(viewController: GamesController) -> UICollectionView.CellRegistration<GrapeCell, GrapeGame> {
            UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
                cell.configureCell(with: itemIdentifier, controller: viewController)
            }
        }
        static func mandarineCell(viewController: GamesController) -> UICollectionView.CellRegistration<MandarineCell, MandarineGame> {
            UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
                cell.configureCell(with: itemIdentifier, controller: viewController)
            }
        }
        
        static func tomatoCell(viewController: GamesController) -> UICollectionView.CellRegistration<TomatoCell, TomatoGame> {
            UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
                cell.configureCell(with: itemIdentifier, controller: viewController)
            }
        }
    }
    
    struct Settings {
        static var boolCell: UICollectionView.CellRegistration<UICollectionViewListCell, BoolSetting> {
            UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
                var contentConfiguration = UIListContentConfiguration.cell()
                contentConfiguration.text = itemIdentifier.title
                contentConfiguration.secondaryText = itemIdentifier.secondaryTitle
                cell.contentConfiguration = contentConfiguration
                
                let toggle = UISwitch(frame: .zero, primaryAction: UIAction { action in
                    guard let toggle: UISwitch = action.sender as? UISwitch else {
                        return
                    }
                    
                    UserDefaults.standard.set(toggle.isOn, forKey: itemIdentifier.key)
                    
                    guard let delegate: SettingDelegate = itemIdentifier.delegate else {
                        return
                    }
                    
                    delegate.didChangeSetting(at: indexPath)
                })
                toggle.isEnabled = itemIdentifier.isEnabled
                toggle.isOn = itemIdentifier.value
                
                cell.accessories = [
                    UICellAccessory.customView(configuration: UICellAccessory.CustomViewConfiguration(customView: toggle,
                                                                                                      placement: .trailing()))
                ]
            }
        }
        
        static var inputNumberCell: UICollectionView.CellRegistration<UICollectionViewListCell, InputNumberSetting> {
            UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
                var contentConfiguration = UIListContentConfiguration.subtitleCell()
                contentConfiguration.text = itemIdentifier.title
                contentConfiguration.secondaryText = itemIdentifier.secondaryTitle
                contentConfiguration.secondaryTextProperties.color = .secondaryLabel
                cell.contentConfiguration = contentConfiguration
                
                cell.accessories = [
                    UICellAccessory.label(text: "\(Int(itemIdentifier.value))"),
                    UICellAccessory.disclosureIndicator()
                ]
            }
        }
        
        static var inputStringCell: UICollectionView.CellRegistration<UICollectionViewListCell, InputStringSetting> {
            UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
                var contentConfiguration = UIListContentConfiguration.valueCell()
                contentConfiguration.text = itemIdentifier.title
                contentConfiguration.secondaryText = itemIdentifier.value
                contentConfiguration.secondaryTextProperties.color = .secondaryLabel
                cell.contentConfiguration = contentConfiguration
                
                cell.accessories = [
                    .disclosureIndicator()
                ]
            }
        }
        
        static var selectionCell: UICollectionView.CellRegistration<UICollectionViewListCell, SelectionSetting> {
            UICollectionView.CellRegistration<UICollectionViewListCell, SelectionSetting> { cell, indexPath, itemIdentifier in
                var contentConfiguration = UIListContentConfiguration.cell()
                contentConfiguration.text = itemIdentifier.title
                cell.contentConfiguration = contentConfiguration
                
                let children: [UIMenuElement] = switch itemIdentifier.values {
                case let stringInt as [String : Int]:
                    stringInt.reduce(into: [UIAction](), { partialResult, element in
                        var state: UIMenuElement.State = .off
                        if let selectedValue = itemIdentifier.selectedValue as? Int {
                            state = element.value == selectedValue ? .on : .off
                        }
                        
                        partialResult.append(.init(title: element.key, state: state, handler: { _ in
                            UserDefaults.standard.set(element.value, forKey: itemIdentifier.key)
                            if let delegate = itemIdentifier.delegate {
                                delegate.didChangeSetting(at: indexPath)
                            }
                        }))
                    })
                case let stringString as [String : String]:
                    stringString.reduce(into: [UIAction](), { partialResult, element in
                        var state: UIMenuElement.State = .off
                        if let selectedValue = itemIdentifier.selectedValue as? String {
                            state = element.value == selectedValue ? .on : .off
                        }
                        
                        partialResult.append(.init(title: element.key, state: state, handler: { _ in
                            UserDefaults.standard.set(element.value, forKey: itemIdentifier.key)
                            if let delegate = itemIdentifier.delegate {
                                delegate.didChangeSetting(at: indexPath)
                            }
                        }))
                    })
                default:
                    []
                }
                
                var title = "Automatic"
                if let selectedValue = itemIdentifier.selectedValue {
                    switch selectedValue {
                    case let intValue as Int:
                        if let values = itemIdentifier.values as? [String : Int] {
                            title = values.first(where: { $0.value == intValue })?.key ?? title
                        }
                    case let stringValue as String:
                        if let values = itemIdentifier.values as? [String : String] {
                            title = values.first(where: { $0.value == stringValue })?.key ?? title
                        }
                    default:
                        break
                    }
                }
                
                cell.accessories = [
                    UICellAccessory.label(text: title),
                    UICellAccessory.popUpMenu(UIMenu(children: children.sorted(by: { lhs, rhs in
                        lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
                    })))
                ]
            }
        }
        
        static func segmentedCell(_ controller: UIViewController) -> UICollectionView.CellRegistration<UICollectionViewListCell, SegmentedSetting> {
            UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
                var contentConfiguration = UIListContentConfiguration.valueCell()
                contentConfiguration.text = itemIdentifier.title
                cell.contentConfiguration = contentConfiguration
                
                let segmentedControl: UISegmentedControl = UISegmentedControl(frame: .zero, primaryAction: UIAction { action in
                    guard let segmentedControl: UISegmentedControl = action.sender as? UISegmentedControl else {
                        return
                    }
                    
                    UserDefaults.standard.set(segmentedControl.selectedSegmentIndex, forKey: itemIdentifier.key)
                    
                    guard let delegate: SettingDelegate = itemIdentifier.delegate else {
                        return
                    }
                    
                    delegate.didChangeSetting(at: indexPath)
                    itemIdentifier.action(controller)
                })
                
                if let items = itemIdentifier.values as? [String : Int] {
                    for item in items {
                        segmentedControl.insertSegment(withTitle: item.key, at: item.value, animated: true)
                    }
                }
                
                segmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: itemIdentifier.key)
                
                cell.accessories = [
                    UICellAccessory.customView(configuration: UICellAccessory.CustomViewConfiguration(customView: segmentedControl,
                                                                                                      placement: .trailing(),
                                                                                                      reservedLayoutWidth: .actual))
                ]
            }
        }
        
        static var stepperCell: UICollectionView.CellRegistration<UICollectionViewListCell, StepperSetting> {
            UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
                var contentConfiguration = UIListContentConfiguration.subtitleCell()
                contentConfiguration.text = itemIdentifier.title
                if itemIdentifier.max > 1 {
                    contentConfiguration.secondaryText = "\(Int(itemIdentifier.value)) out of \(Int(itemIdentifier.max))"
                } else {
                    if itemIdentifier.value < 0.1 {
                        contentConfiguration.secondaryText = "0 out of \(Int(itemIdentifier.max))"
                    } else if itemIdentifier.value > 0.9 {
                        contentConfiguration.secondaryText = "1 out of \(Int(itemIdentifier.max))"
                    } else {
                        contentConfiguration.secondaryText = "\(String(format: "%.1f", itemIdentifier.value)) out of \(Int(itemIdentifier.max))"
                    }
                }
                contentConfiguration.secondaryTextProperties.color = .secondaryLabel
                cell.contentConfiguration = contentConfiguration
                
                let stepper = UIStepper(frame: .zero, primaryAction: UIAction { action in
                    guard let stepper: UIStepper = action.sender as? UIStepper else {
                        return
                    }
                    
                    UserDefaults.standard.set(stepper.value, forKey: itemIdentifier.key)
                    
                    guard let delegate: SettingDelegate = itemIdentifier.delegate else {
                        return
                    }
                    
                    delegate.didChangeSetting(at: indexPath)
                })
                stepper.minimumValue = itemIdentifier.min
                stepper.maximumValue = itemIdentifier.max
                stepper.stepValue = itemIdentifier.max > 1 ? 1 : 0.1
                stepper.value = itemIdentifier.value
                
                cell.accessories = [
                    UICellAccessory.customView(configuration: UICellAccessory.CustomViewConfiguration(customView: stepper,
                                                                                                      placement: .trailing(),
                                                                                                      reservedLayoutWidth: .actual))
                ]
            }
        }
        
        static var tapCell: UICollectionView.CellRegistration<UICollectionViewListCell, TapSetting> {
            UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
                var contentConfiguration = UIListContentConfiguration.cell()
                contentConfiguration.text = itemIdentifier.title
                contentConfiguration.textProperties.alignment = .center
                contentConfiguration.textProperties.color = itemIdentifier.color
                contentConfiguration.textProperties.font = UIFont.bold(from: .body)
                cell.contentConfiguration = contentConfiguration
            }
        }
    }
}
