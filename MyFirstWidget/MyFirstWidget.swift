//
//  MyFirstWidget.swift
//  MyFirstWidget
//
//  Created by Jose Luis Cadena on 19/11/20.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    //representacion generica del widget
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), username: "Angie1")
    }

    //datos de muestra mientras se obtiene la información
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), username: "Angie2")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, username: "Angie3")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)

        let branchContentsURL = URL(string: "https://api.github.com/orgs/google/members")!
        let task = URLSession.shared.dataTask(with: branchContentsURL) { (data, response, error) in
            guard error == nil else {
                completion(Timeline(entries: entries, policy: .atEnd))
                return
            }
            //let commit = getCommitInfo(fromData: data!)
            print(data as Any)
            completion(Timeline(entries: entries, policy: .atEnd))
        }
        task.resume()


    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    var username: String
}

//configuración del widget
struct MyFirstWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.username)
                .font(.body)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding([.trailing], 15)
                .foregroundColor(.red)
            Text(entry.date, style: .date)
                .font(.body)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding([.trailing], 15)
                .foregroundColor(.blue)
            Image("edyen")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .padding()
        .cornerRadius(6)

    }
}

@main
struct MyFirstWidget: Widget {
    let kind: String = "MyFirstWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MyFirstWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("EDYEN")
        .description("Este widget muestra el nombre del usuario")
    }
}

struct MyFirstWidget_Previews: PreviewProvider {
    static var previews: some View {
        MyFirstWidgetEntryView(entry: SimpleEntry(date: Date(), username: "Angie"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
