//
//  AuthenticationController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 2/7/2024.
//

import AuthenticationServices
import Firebase
import FirebaseAuth
import Foundation
import LayoutManager
import UIKit

extension AuthDataResult : @unchecked Sendable {}

class AuthenticationController : UIViewController {
    fileprivate var currentNonce: String? = nil
    
    fileprivate var bottomContainerView: UIVisualEffectView? = nil, topContainerView: UIView? = nil
    fileprivate var textLabel: UILabel? = nil, secondaryTextLabel: UILabel? = nil
    fileprivate var signInWithAppleAccountButton: UIButton? = nil, skipAppleAccountButton: UIButton? = nil
    
    fileprivate var collectionView: UICollectionView? = nil
    fileprivate var dataSource: UICollectionViewDiffableDataSource<String, String>? = nil
    fileprivate var snapshot: NSDiffableDataSourceSnapshot<String, String>? = nil
    
    var darkAppleIDHeightConstraint: NSLayoutConstraint? = nil, lightAppleIDHeightConstraint: NSLayoutConstraint? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        beginAddingSubviews()
        
        if #available(iOS 17, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], action: #selector(traitCollectionDidChange(with:traitCollection:)))
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #unavailable(iOS 17) {
            guard let signInWithAppleAccountButton else {
                return
            }
            
            signInWithAppleAccountButton.setNeedsUpdateConfiguration()
        }
    }
}

// MARK: Delegates
extension AuthenticationController : ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let window = view.window {
            return window
        } else {
            print("\(#function): failed")
            return .init() // MARK: this should not be called
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
        let identityToken = credential.identityToken, let identityTokenString: String = .init(data: identityToken, encoding: .utf8) else {
            return
        }
        
        let appleCredential = OAuthProvider.appleCredential(withIDToken: identityTokenString, rawNonce: currentNonce, fullName: credential.fullName)
        
        let task = Task { try await Auth.auth().signIn(with: appleCredential) }
        Task {
            switch await task.result {
            case .failure(let error):
                print("\(#function): failed: \(error.localizedDescription)")
                
                present(alert(title: "Error", message: error.localizedDescription, preferredStyle: .alert, actions: [
                    .init(title: "Close", style: .cancel)
                ]), animated: true)
            case .success(_):
                print("\(#function): success")
                
                let libraryController = UINavigationController(rootViewController: LibraryController(collectionViewLayout: LayoutManager.shared.library))
                libraryController.modalPresentationStyle = .fullScreen
                self.present(libraryController, animated: true)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        print("\(#function): failed: \(error.localizedDescription)")
        
        present(alert(title: "Error", message: error.localizedDescription, preferredStyle: .alert, actions: [
            .init(title: "Close", style: .cancel)
        ]), animated: true)
    }
}

extension AuthenticationController : UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        toggleProgressiveVisualEffectView((scrollView.contentOffset.y + view.safeAreaInsets.top) > 20)
    }
}

// MARK: Functions
extension AuthenticationController {
    @objc fileprivate func beginAuthenticationFlow() {
        let nonce: String = .nonce()
        currentNonce = nonce
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]
        request.nonce = .sha256(from: nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    @objc fileprivate func traitCollectionDidChange(with traitEnvironment: UITraitEnvironment, traitCollection: UITraitCollection) {
        guard let signInWithAppleAccountButton else {
            return
        }
        
        signInWithAppleAccountButton.setNeedsUpdateConfiguration()
    }
}

// MARK: Subviews
extension AuthenticationController {
    fileprivate func beginAddingSubviews() {
        bottomContainerView = .init(effect: UIBlurEffect(style: .systemThickMaterial))
        guard let bottomContainerView else {
            return
        }
        
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.isUserInteractionEnabled = true
        view.addSubview(bottomContainerView)
        
        bottomContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        topContainerView = .init()
        guard let topContainerView else {
            return
        }
        
        topContainerView.translatesAutoresizingMaskIntoConstraints = false
        topContainerView.backgroundColor = .secondarySystemBackground
        view.insertSubview(topContainerView, belowSubview: bottomContainerView)
        
        topContainerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        topContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        var skipSignInWithAppleAccountConfiguration = UIButton.Configuration.plain()
        skipSignInWithAppleAccountConfiguration.attributedTitle = .init("Skip", attributes: .init([
            .font : UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize),
            .foregroundColor : UIColor.label
        ]))
        skipSignInWithAppleAccountConfiguration.buttonSize = .medium
        
        skipAppleAccountButton = .init(configuration: skipSignInWithAppleAccountConfiguration, primaryAction: .init(handler: { _ in
            UserDefaults.standard.set(true, forKey: "userSkippedAuthentication")
            
            let libraryController = UINavigationController(rootViewController: LibraryController(collectionViewLayout: LayoutManager.shared.library))
            libraryController.modalPresentationStyle = .fullScreen
            self.present(libraryController, animated: true)
        }))
        guard let skipAppleAccountButton else {
            return
        }
        
        skipAppleAccountButton.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.contentView.addSubview(skipAppleAccountButton)
        
        skipAppleAccountButton.leadingAnchor.constraint(equalTo: bottomContainerView.contentView.leadingAnchor, constant: 20).isActive = true
        skipAppleAccountButton.bottomAnchor.constraint(equalTo: bottomContainerView.contentView.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        skipAppleAccountButton.trailingAnchor.constraint(equalTo: bottomContainerView.contentView.trailingAnchor, constant: -20).isActive = true
        
        var signInWithAppleAccountConfiguration = UIButton.Configuration.filled()
        signInWithAppleAccountConfiguration.attributedTitle = .init("Continue with Apple", attributes: .init([
            .font : UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        ]))
        signInWithAppleAccountConfiguration.buttonSize = .large
        signInWithAppleAccountConfiguration.cornerStyle = .large
        signInWithAppleAccountConfiguration.baseBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
        signInWithAppleAccountConfiguration.baseForegroundColor = traitCollection.userInterfaceStyle == .dark ? .black : .white
        
        signInWithAppleAccountButton = .init(configuration: signInWithAppleAccountConfiguration, primaryAction: .init(handler: { _ in
            self.beginAuthenticationFlow()
        }))
        guard let signInWithAppleAccountButton else {
            return
        }
        signInWithAppleAccountButton.translatesAutoresizingMaskIntoConstraints = false
        signInWithAppleAccountButton.configurationUpdateHandler = {
            guard var configuration = $0.configuration else {
                return
            }
            
            configuration.baseBackgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .white : .black
            configuration.baseForegroundColor = self.traitCollection.userInterfaceStyle == .dark ? .black : .white
            
            $0.configuration = configuration
        }
        bottomContainerView.contentView.addSubview(signInWithAppleAccountButton)
        
        signInWithAppleAccountButton.leadingAnchor.constraint(equalTo: bottomContainerView.contentView.leadingAnchor, constant: 20).isActive = true
        signInWithAppleAccountButton.bottomAnchor.constraint(equalTo: skipAppleAccountButton.topAnchor, constant: -20).isActive = true
        signInWithAppleAccountButton.trailingAnchor.constraint(equalTo: bottomContainerView.contentView.trailingAnchor, constant: -20).isActive = true
        
        secondaryTextLabel = .init()
        guard let secondaryTextLabel else {
            return
        }
        
        secondaryTextLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryTextLabel.attributedText = .init(string: "Beautifully designed, high performing multi-system emulation in the palm of your hands", attributes: [
            .font : UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor : UIColor.secondaryLabel
        ])
        secondaryTextLabel.numberOfLines = 3
        secondaryTextLabel.textAlignment = .center
        bottomContainerView.contentView.addSubview(secondaryTextLabel)
        
        secondaryTextLabel.leadingAnchor.constraint(equalTo: bottomContainerView.contentView.leadingAnchor, constant: 20).isActive = true
        secondaryTextLabel.bottomAnchor.constraint(equalTo: signInWithAppleAccountButton.topAnchor, constant: -20).isActive = true
        secondaryTextLabel.trailingAnchor.constraint(equalTo: bottomContainerView.contentView.trailingAnchor, constant: -20).isActive = true
        
        textLabel = .init()
        guard let textLabel else {
            return
        }
        
        let fontStyle: UIFont.TextStyle = if #available(iOS 17, *) { .extraLargeTitle } else { .largeTitle }
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.attributedText = .init(string: "Folium", attributes: [
            .font : UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: fontStyle).pointSize),
            .foregroundColor : UIColor.label
        ])
        textLabel.textAlignment = .center
        bottomContainerView.contentView.addSubview(textLabel)
        
        textLabel.topAnchor.constraint(equalTo: bottomContainerView.contentView.topAnchor, constant: 20).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: bottomContainerView.contentView.leadingAnchor, constant: 20).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: secondaryTextLabel.topAnchor, constant: -8).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: bottomContainerView.contentView.trailingAnchor, constant: -20).isActive = true
        
        let collectionViewLayout = UICollectionViewCompositionalLayout { _, _ in
            let count = UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2
            let ratio: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? (1 / 4) : (1 / 2)
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(ratio), heightDimension: .fractionalWidth(ratio))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300))
            let group: NSCollectionLayoutGroup = if #available(iOS 16, *) {
                .horizontal(layoutSize: groupSize, repeatingSubitem: item, count: count)
            } else {
                .horizontal(layoutSize: groupSize, subitem: item, count: count)
            }
            group.interItemSpacing = .fixed(10)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
            section.interGroupSpacing = 10
            return section
        }
        
        collectionView = .init(frame: .zero, collectionViewLayout: collectionViewLayout)
        guard let collectionView else {
            return
        }
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = topContainerView.backgroundColor
        collectionView.delegate = self
        topContainerView.addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: topContainerView.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor).isActive = true
        
        let cellRegistration = UICollectionView.CellRegistration<DefaultCell, String> {
            $0.set(text: $2)
        }
        
        dataSource = .init(collectionView: collectionView) {
            $0.dequeueConfiguredReusableCell(using: cellRegistration, for: $1, item: $2)
        }
        
        snapshot = .init()
        guard let dataSource, var snapshot else {
            return
        }
        
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var strings: [String] = []
        (0...100).forEach { _ in
            strings.append(String(characters.shuffled().prefix((4...9).randomElement() ?? 4)))
        }
        
        snapshot.appendSections(["Section 0"])
        snapshot.appendItems(strings, toSection: "Section 0")
        Task {
            await dataSource.apply(snapshot)
        }
    }
}
