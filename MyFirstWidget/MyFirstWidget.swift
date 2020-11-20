import WidgetKit
import SwiftUI

@main
struct MyFirstWidget: Widget {
    private let kind: String = "CommitCheckerWidget"
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CommitTimeline()) { entry in
            CommitCheckerWidgetView(entry: entry)
        }
        .configurationDisplayName("Swift's Latest Commit")
        .description("Shows the last commit at the Swift repo.")
    }
}

struct Commit {
    let message: String
    let author: String
    let date: String
}

struct CommitLoader {
    static func fetch(completion: @escaping (Result<Commit, Error>) -> Void) {
        let branchContentsURL = URL(string: "https://api.github.com/repos/apple/swift/branches/main")!
        //let branchContentsURL = URL(string: "https://api.github.com/repos/angelicahg001/ExampleWidget/branches/master")!
        let task = URLSession.shared.dataTask(with: branchContentsURL) { (data, response, error) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            let commit = getCommitInfo(fromData: data!)
            completion(.success(commit))
        }
        task.resume()
    }
    static func getCommitInfo(fromData data: Foundation.Data) -> Commit {
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        if json.keys.count > 2 {
            let commitParentJson = json["commit"] as! [String: Any]
            let commitJson = commitParentJson["commit"] as! [String: Any]
            let authorJson = commitJson["author"] as! [String: Any]
            let message = commitJson["message"] as! String
            let author = authorJson["name"] as! String
            let date = authorJson["date"] as! String
            return Commit(message: message, author: author, date: date)
        } else {
            return  Commit(message: "Error", author: "error", date: "10-03-1989")
        }

    }
}

struct CommitTimeline: TimelineProvider {
    func placeholder(in context: Context) -> LastCommitEntry {
        let fakeCommit = Commit(message: "Fixed stuff", author: "Ahg Appleseed", date: "2020-06-23")
        return LastCommitEntry(date: Date(), commit: fakeCommit)
    }

    func getSnapshot(in context: Context, completion: @escaping (LastCommitEntry) -> Void) {
        let fakeCommit = Commit(message: "Fixed stuff", author: "John Appleseed", date: "2020-06-23")
        let entry = LastCommitEntry(date: Date(), commit: fakeCommit)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LastCommitEntry>) -> Void) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        CommitLoader.fetch { result in
            let commit: Commit
            if case .success(let fetchedCommit) = result {
                commit = fetchedCommit
            } else {
                commit = Commit(message: "Failed to load commits", author: "", date: "")
            }
            let entry = LastCommitEntry(date: currentDate, commit: commit)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }

    typealias Entry = LastCommitEntry
    /* protocol methods implemented below! */
}

struct LastCommitEntry: TimelineEntry {
    public let date: Date
    public let commit: Commit
}

struct LastCommit: TimelineEntry {
    public let date: Date
    public let commit: Commit
    var relevance: TimelineEntryRelevance? {
        return TimelineEntryRelevance(score: 10) // 0 - not important | 100 - very important
    }
}

// WidgetView

struct PlaceholderView : View {
    var body: some View {
        Text("Loading...")
    }
}

struct CommitCheckerWidgetView : View {
    let entry: LastCommitEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("apple/swift's Latest Commit")
                .font(.system(.title3))
                .foregroundColor(.black)
            Text(entry.commit.message)
                .font(.system(.callout))
                .foregroundColor(.black)
                .bold()
            Text("by \(entry.commit.author) at \(entry.commit.date)")
                .font(.system(.caption))
                .foregroundColor(.black)
            Text("Updated at \(Self.format(date:entry.date))")
                .font(.system(.caption2))
                .foregroundColor(.black)
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .top, endPoint: .bottom))
    }
    static func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy HH:mm"
        return formatter.string(from: date)
    }
}


/*
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
*/
