//
//  LastPlayedWidget.swift
//  LastPlayedWidget
//
//  Created by Jarrod Norwell on 13/11/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import WidgetKit
import SwiftUI

struct User : Codable {
    struct Game : Codable {
        let icon: Data?
        let sha256: String
        var lastPlayed, playTime: TimeInterval
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
        
        return SimpleEntry(isPlaceHolder: true, game: .init( icon: data, sha256: "", lastPlayed: Date.now.timeIntervalSince1970,
                                playTime: Date.now.timeIntervalSince1970), date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        var data: Data? = nil
        if let image = UIImage(named: "Icon_Dark") {
            data = image.pngData()
        }
        
        return SimpleEntry(isPlaceHolder: true, game: .init(icon: data, sha256: "", lastPlayed: Date.now.timeIntervalSince1970,
                                playTime: Date.now.timeIntervalSince1970), date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        if let userDefaults = UserDefaults(suiteName: "group.com.antique.Folium"), let data = userDefaults.data(forKey: "user") {
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                user.games.forEach { game in
                    entries.append(.init(game: game, date: Date.now, configuration: configuration))
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
    var isPlaceHolder: Bool = false
    let game: User.Game
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct LastPlayedWidgetEntryView : View {
    var entry: Provider.Entry
    
    func dateFromTimeInterval() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date(timeIntervalSince1970: entry.game.lastPlayed))
    }
    
    func timeFromTimeInterval() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date(timeIntervalSince1970: entry.game.lastPlayed))
    }
    
    func relativeTimeFromTimeInterval() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: Date(timeIntervalSince1970: entry.game.lastPlayed), relativeTo: Date())
    }
    
    var image: UIImage {
        return if let data = entry.game.icon {
            if entry.isPlaceHolder {
                .init(data: data) ?? .init()
            } else {
                data.decodeRGB565(width: 48, height: 48) ?? .init()
            }
        } else {
            .init()
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Image(uiImage: image)
                .clipShape(.rect(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.fill.quaternary, lineWidth: 5)
                }
            Spacer()
            VStack(alignment: .leading) {
                Text("Last played \(relativeTimeFromTimeInterval())")
                   .foregroundStyle(.primary)
                   .bold()
                /*
                 Text(dateFromTimeInterval())
                    .foregroundStyle(.primary)
                    .bold()
                Text(timeFromTimeInterval())
                    .foregroundStyle(.primary)
                    .bold()
                 */
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
        /*
        ZStack {
            Image(uiImage: image)
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .blur(radius: 6)
            VStack {
                Text(dateFromTimeInterval())
                    .foregroundStyle(.primary)
                    .font(.callout)
                    .bold()
                Text("@ \(timeFromTimeInterval())")
                    .foregroundStyle(.primary)
                    .font(.callout)
                    .bold()
            }
        }
         */
    }
}

struct LastPlayedWidget: Widget {
    let kind: String = "LastPlayedWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            LastPlayedWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Last Played")
        .description("See when you last played a game")
        .supportedFamilies([.systemSmall])
    }
}
