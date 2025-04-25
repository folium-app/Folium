//
//  CytrusRoomDetailsController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 23/4/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Cytrus
import Foundation
import UIKit

class RoomMember : AnyHashableSendable, @unchecked Sendable {
    let avatarURL, gameName, macAddress, nickname, username: String
    let gameID: UInt64
    
    init(_ cytrusRoomMember: CytrusNetworkMember) {
        self.avatarURL = cytrusRoomMember.avatarURL
        self.gameName = cytrusRoomMember.gameName
        self.macAddress = cytrusRoomMember.macAddress
        self.nickname = cytrusRoomMember.nickname
        self.username = cytrusRoomMember.username
        self.gameID = cytrusRoomMember.gameID
    }
}

class ImageStringItem : AnyHashableSendable, @unchecked Sendable {
    var image: UIImage? = nil
    let text: String
    
    init(image: UIImage? = nil, text: String) {
        self.image = image
        self.text = text
    }
}

class StringItem : AnyHashableSendable, @unchecked Sendable {
    let text: String
    var shouldBeBold: Bool = true
    
    init(text: String, shouldBeBold: Bool = true) {
        self.text = text
        self.shouldBeBold = shouldBeBold
    }
}

class BlurredCellWithImageAndText : BlurredCollectionViewCell {
    var textLabel: UILabel? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        layer.cornerCurve = .continuous
        layer.cornerRadius = (.smallCornerRadius + 8) - 10
        
        textLabel = .init()
        guard let textLabel else { return }
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize)
        textLabel.numberOfLines = 5
        textLabel.textAlignment = .left
        addSubview(textLabel)
        
        textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func imageStringItem(_ imageStringItem: ImageStringItem) {
        guard let textLabel/*, let imageView*/ else { return }
        // imageView.image = imageStringItem.image?
        //     .applyingSymbolConfiguration(.init(hierarchicalColor: .tintColor))
        textLabel.text = imageStringItem.text
    }
    
    func roomMember(_ roomMember: RoomMember) {
        guard let textLabel else { return }
        textLabel.text = if roomMember.nickname.isEmpty {
            roomMember.username
        } else {
            roomMember.nickname
        }
    }
    
    func stringItem(_ stringItem : StringItem) {
        guard let textLabel else { return }
        let font: UIFont = UIFont.preferredFont(forTextStyle: .headline)
        textLabel.font = if stringItem.shouldBeBold {
            .boldSystemFont(ofSize: font.pointSize)
        } else {
            .systemFont(ofSize: font.pointSize, weight: .regular)
        }
        textLabel.text = stringItem.text
    }
}

/*
 @property (nonatomic, strong) NSString *details, *id, *ip, *name, *owner, *preferredGame, *verifyUID;
 @property (nonatomic) uint16_t port;
 @property (nonatomic) uint32_t maxPlayers, netVersion, numberPlayers;
 @property (nonatomic) uint64_t preferredGameID;
 @property (nonatomic) BOOL hasPassword;
 
 members
 */

enum HeaderFooter : String, CaseIterable {
    case location = "Location"
    case details = "Details"
    case id = "ID"
    case ip = "IP Address"
    case name = "Name"
    case owner = "Owner"
    case preferredGame = "Preferred Game"
    case verifyUID = "UID"
    case port = "Port"
    case maxPlayers = "Max Players"
    case netVersion = "Network Version"
    case numberPlayers = "Number Of Players"
    case preferredGameID = "Preferred Game ID"
    case hasPassword = "Password Locked"
    case members = "Members"
    
    var header: String {
        rawValue
    }
}

struct IPData : Codable, Hashable {
    let status: String
    let country: String
    let countryCode: String
    let region: String
    let regionName: String
    let city: String
    let zip: String
    let lat: Double
    let lon: Double
    let timezone: String
    let isp: String
    let org: String
    let asInfo: String
    let query: String

    enum CodingKeys: String, CodingKey {
        case status
        case country
        case countryCode
        case region
        case regionName
        case city
        case zip
        case lat
        case lon
        case timezone
        case isp
        case org
        case asInfo = "as"
        case query
    }
}

class CytrusRoomDetailsController : UICollectionViewController {
    var room: CytrusNetworkRoom
    
    var dataSource: UICollectionViewDiffableDataSource<HeaderFooter, AnyHashableSendable>? = nil
    var snapshot: NSDiffableDataSourceSnapshot<HeaderFooter, AnyHashableSendable>? = nil
    
    init(_ room: CytrusNetworkRoom, _ collectionViewLayout: UICollectionViewLayout) {
        self.room = room
        super.init(collectionViewLayout: collectionViewLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController {
            navigationController.navigationBar.prefersLargeTitles = true
        }
        title = room.name
        view.backgroundColor = nil
        
        let style: UIBlurEffect.Style = if let `private` = UIBlurEffect.Style(rawValue: 1100) {
            `private`
        } else {
            .systemMaterial
        }
        
        let visualEffectView: UIVisualEffectView = .init(effect: UIBlurEffect(style: style))
        collectionView.backgroundColor = nil
        collectionView.backgroundView = visualEffectView
        
        let locationCellRegistration: UICollectionView.CellRegistration<LargeMapCell, MultiplayerLocation> = .init {
            $0.set($2, #selector(self.connectToRoom), self)
        }
        
        let roomMemberCellRegistration: UICollectionView.CellRegistration<BlurredCellWithImageAndText, RoomMember> = .init {
            $0.roomMember($2)
        }
        
        let stringItemCellRegistration: UICollectionView.CellRegistration<BlurredCellWithImageAndText, StringItem> = .init {
            $0.stringItem($2)
        }
        
        let imageStringItemCellRegistration: UICollectionView.CellRegistration<BlurredCellWithImageAndText, ImageStringItem> = .init {
            $0.imageStringItem($2)
        }
        
        let headerCellRegistration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell> = .init(elementKind: UICollectionView.elementKindSectionHeader) {
            var contentConfiguration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            if let dataSource = self.dataSource, let section = dataSource.sectionIdentifier(for: $2.section) {
                contentConfiguration.text = section.header
            }
            $0.contentConfiguration = contentConfiguration
            
            $0.accessories = if let dataSource = self.dataSource,
                                let section = dataSource.sectionIdentifier(for: $2.section),
                                section == .members, self.room.members.count > 1 {
                [
                    .label(text: "Swipe for more"),
                    .outlineDisclosure()
                ]
            } else {
                []
            }
        }
        
        dataSource = .init(collectionView: collectionView) {
            switch $2 {
            case let multiplayerLocation as MultiplayerLocation:
                $0.dequeueConfiguredReusableCell(using: locationCellRegistration, for: $1, item: multiplayerLocation)
            case let imageStringItem as ImageStringItem:
                $0.dequeueConfiguredReusableCell(using: imageStringItemCellRegistration, for: $1, item: imageStringItem)
            case let roomMember as RoomMember:
                $0.dequeueConfiguredReusableCell(using: roomMemberCellRegistration, for: $1, item: roomMember)
            case let stringItem as StringItem:
                $0.dequeueConfiguredReusableCell(using: stringItemCellRegistration, for: $1, item: stringItem)
            default: nil
            }
        }
        guard let dataSource else { return }
        dataSource.supplementaryViewProvider = {
            switch $1 {
            case UICollectionView.elementKindSectionHeader:
                $0.dequeueConfiguredReusableSupplementary(using: headerCellRegistration, for: $2)
            default: nil
            }
        }
        
        snapshot = .init()
        guard var snapshot else { return }
        snapshot.appendSections(HeaderFooter.allCases)
        
        snapshot.appendItems([
            StringItem(text: room.details.isEmpty ? "Unavailable" : room.details, shouldBeBold: false)
        ], toSection: .details)
        snapshot.appendItems([
            StringItem(text: room.id.isEmpty ? "Unavailable" : room.id)
        ], toSection: .id)
        snapshot.appendItems([
            StringItem(text: room.ip)
        ], toSection: .ip)
        snapshot.appendItems([
            StringItem(text: room.name)
        ], toSection: .name)
        snapshot.appendItems([
            StringItem(text: room.owner.isEmpty ? "Unavailable" : room.owner)
        ], toSection: .owner)
        snapshot.appendItems([
            StringItem(text: room.preferredGame)
        ], toSection: .preferredGame)
        snapshot.appendItems([
            StringItem(text: room.verifyUID)
        ], toSection: .verifyUID)
        snapshot.appendItems([
            StringItem(text: "\(room.port)")
        ], toSection: .port)
        snapshot.appendItems([
            StringItem(text: "\(room.maxPlayers)")
        ], toSection: .maxPlayers)
        snapshot.appendItems([
            StringItem(text: "\(room.netVersion)")
        ], toSection: .netVersion)
        snapshot.appendItems([
            StringItem(text: "\(room.numberPlayers)")
        ], toSection: .numberPlayers)
        snapshot.appendItems([
            StringItem(text: "\(room.preferredGameID)")
        ], toSection: .preferredGameID)
        snapshot.appendItems([
            StringItem(text: room.hasPassword ? "Locked" : "Unlocked")
        ], toSection: .hasPassword)
        snapshot.appendItems(room.members.map { RoomMember($0) }, toSection: .members)
        
        Task {
            if !room.ip.isEmpty, let url = URL(string: "http://ip-api.com/json/\(room.ip)") {
                let (data, _) = try await URLSession.shared.data(from: url)
                let result = try JSONDecoder().decode(IPData.self, from: data)
                
                snapshot.appendItems([
                    MultiplayerLocation(state: room.state, latitude: result.lat, longitude: result.lon)
                ], toSection: .location)
            }
            
            await dataSource.apply(snapshot)
        }
        
        /*Cytrus.shared.multiplayer.stateChangedHandler { state in
            let str = switch state {
            case .uninitialized: "Uninitialized"
            case .idle: "Idle"
            case .joining: "Joining"
            case .joined: "Joined"
            case .moderator: "Moderator"
            @unknown default:
                fatalError()
            }
            
            print(str)
        }*/
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }
}

extension CytrusRoomDetailsController {
    @objc func connectToRoom() {
        guard let dataSource,
              let item = dataSource.snapshot().itemIdentifiers(inSection: .location).first as? MultiplayerLocation else { return }
        
        
        let alertController: UIAlertController = .init(title: "Connect", message: "Connect to \(room.name)?", preferredStyle: .alert)
        alertController.addTextField { $0.placeholder = "Username" }
        if room.hasPassword {
            alertController.addTextField { $0.placeholder = "Password" }
        }
        
        alertController.addAction(.init(title: "Cancel", style: .cancel))
        alertController.addAction(.init(title: "Connect", style: .default, handler: { action in
            guard let textFields = alertController.textFields, let textField = textFields.first else { return }
            guard let text = textField.text, !text.isEmpty else { return }
            
            var password: String? = nil
            if self.room.hasPassword, let textField = textFields.last {
                password = textField.text
            }
            
            Cytrus.shared.multiplayer.connect(to: self.room, with: text, and: password) { error in
                print("error", error.rawValue)
            } state: { state in
                item.state = state
                
                var snapshot = dataSource.snapshot()
                snapshot.reloadItems([item])
                Task { await dataSource.apply(snapshot, animatingDifferences: false) }
            }
        }))
        present(alertController, animated: true)
    }
}
