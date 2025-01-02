//
//  PlayTimeWidget.swift
//  PlayTimeWidget
//
//  Created by Jarrod Norwell on 14/11/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import WidgetKit
import SwiftUI

struct User : Codable {
    struct Game : Codable {
        let console: String
        let icon: Data?
        let sha256: String
        var lastPlayed: TimeInterval = 0, playTime: TimeInterval = 0
    }
    
    var games: [Game]
    let name: String
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        var data: Data? = nil
        if let image = UIImage(named: "Icon_Dark") {
            data = image.pngData()
        }
        
        return SimpleEntry(isPlaceHolder: true, game: .init(console: "", icon: data, sha256: "", lastPlayed: Date.now.timeIntervalSince1970,
                                playTime: Date.now.timeIntervalSince1970), date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        var data: Data? = nil
        if let image = UIImage(named: "Icon_Dark") {
            data = image.pngData()
        }
        
        return SimpleEntry(isPlaceHolder: true, game: .init(console: "", icon: data, sha256: "", lastPlayed: Date.now.timeIntervalSince1970,
                                playTime: Date.now.timeIntervalSince1970), date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        if let userDefaults = UserDefaults(suiteName: "group.com.antique.Folium"), let data = userDefaults.data(forKey: "user") {
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                user.games.forEach { game in
                    entries.append(.init(console: game.console, game: game, date: Date.now, configuration: configuration))
                }
            } catch {
                print(error.localizedDescription)
            }
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    var console: String = ""
    var isPlaceHolder: Bool = false
    let game: User.Game
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct PlayTimeWidgetEntryView : View {
    var entry: Provider.Entry
    
    func timeFromTimeInterval() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full
        return formatter.string(from: entry.game.playTime) ?? ""
    }
    
    var image: UIImage {
        return if let data = entry.game.icon {
            if entry.isPlaceHolder {
                .init(data: data) ?? .init()
            } else {
                switch entry.console {
                case "Grape", "Mango", "Lychee":
                    .init(data: data) ?? .init()
                default:
                    data.decodeRGB565(width: 48, height: 48) ?? .init()
                }
            }
        } else {
            .init()
        }
    }

    var body: some View {
        if let userDefaults = UserDefaults(suiteName: "group.com.antique.Folium"), userDefaults.bool(forKey: "additionalFeaturesAreAllowed") {
            VStack(alignment: .leading) {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 64, height: 64)
                    .clipShape(.rect(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.fill.quaternary, lineWidth: 5)
                    }
                Spacer()
                VStack {
                    Text("Played for \(timeFromTimeInterval())")
                        .foregroundStyle(.primary)
                        .bold()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Text("N/A")
                }
            }
        }
        
        /*
        ZStack {
            Image(uiImage: image)
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .blur(radius: 6)
            VStack {
                Text(timeFromTimeInterval())
                    .foregroundStyle(.primary)
                    .font(.callout)
                    .bold()
            }
        }
         */
    }
}

struct PlayTimeWidget: Widget {
    let kind: String = "PlayTimeWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            PlayTimeWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Play Time")
        .description("See how long a game has been played")
        .supportedFamilies([.systemSmall])
    }
}
