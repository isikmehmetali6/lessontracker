import WidgetKit
import SwiftUI

// MARK: - Shared Data Provider

struct LessonEntry: TimelineEntry {
    let date: Date
    let courseName: String
    let courseLocation: String
    let courseTime: String
    let courseColorHex: String
    let hasCourse: Bool
    let deadlineCount: Int
    let deadline0Title: String
    let deadline0Days: String
    let deadline1Title: String
    let deadline1Days: String
    let deadline2Title: String
    let deadline2Days: String
    let studyTime: String
    let studyMinutes: Int
}

struct LessonProvider: TimelineProvider {
    let appGroupId = "group.com.lessontracker.app"
    
    func placeholder(in context: Context) -> LessonEntry {
        LessonEntry(
            date: Date(),
            courseName: "Mathematics 101",
            courseLocation: "Room A-204",
            courseTime: "09:00 - 10:50",
            courseColorHex: "FF6B6B",
            hasCourse: true,
            deadlineCount: 2,
            deadline0Title: "Math Assignment",
            deadline0Days: "2d",
            deadline1Title: "Physics Lab",
            deadline1Days: "5d",
            deadline2Title: "",
            deadline2Days: "",
            studyTime: "2h 30m",
            studyMinutes: 150
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (LessonEntry) -> Void) {
        let entry = readEntry()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<LessonEntry>) -> Void) {
        let entry = readEntry()
        // Her 30 dakikada bir güncelle
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func readEntry() -> LessonEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        
        return LessonEntry(
            date: Date(),
            courseName: defaults?.string(forKey: "courseName") ?? "No upcoming classes",
            courseLocation: defaults?.string(forKey: "courseLocation") ?? "",
            courseTime: defaults?.string(forKey: "courseTime") ?? "Relax & Recharge",
            courseColorHex: defaults?.string(forKey: "courseColor") ?? "7C4DFF",
            hasCourse: defaults?.bool(forKey: "hasCourse") ?? false,
            deadlineCount: defaults?.integer(forKey: "deadlineCount") ?? 0,
            deadline0Title: defaults?.string(forKey: "deadline0Title") ?? "",
            deadline0Days: defaults?.string(forKey: "deadline0Days") ?? "",
            deadline1Title: defaults?.string(forKey: "deadline1Title") ?? "",
            deadline1Days: defaults?.string(forKey: "deadline1Days") ?? "",
            deadline2Title: defaults?.string(forKey: "deadline2Title") ?? "",
            deadline2Days: defaults?.string(forKey: "deadline2Days") ?? "",
            studyTime: defaults?.string(forKey: "studyTime") ?? "0h 0m",
            studyMinutes: defaults?.integer(forKey: "studyMinutes") ?? 0
        )
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 124, 77, 255) // Default purple
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Next Lesson Widget (Medium)

struct NextLessonWidgetView: View {
    let entry: LessonEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: "book.fill")
                    .font(.caption2)
                    .foregroundColor(Color(hex: entry.courseColorHex))
                Text("NEXT CLASS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: "graduationcap.fill")
                    .font(.caption)
                    .foregroundColor(Color(hex: entry.courseColorHex))
            }
            
            if entry.hasCourse {
                // Course Name
                Text(entry.courseName)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // Time & Location
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: entry.courseColorHex))
                        Text(entry.courseTime)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    if !entry.courseLocation.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: entry.courseColorHex))
                            Text(entry.courseLocation)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            } else {
                // No class
                Text(entry.courseName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(entry.courseTime)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Bottom bar - Deadlines
            if entry.deadlineCount > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.orange)
                    Text("\(entry.deadlineCount) upcoming deadline\(entry.deadlineCount > 1 ? "s" : "")")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.orange)
                }
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.green)
                    Text("All caught up!")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.green)
                }
            }
        }
        .padding(16)
    }
}

struct NextLessonWidget: Widget {
    let kind: String = "NextLessonWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LessonProvider()) { entry in
            if #available(iOS 17.0, *) {
                NextLessonWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                NextLessonWidgetView(entry: entry)
                    .background(Color(.systemBackground))
            }
        }
        .configurationDisplayName("Next Class")
        .description("See your next upcoming class at a glance.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Deadline Widget (Small)

struct DeadlineWidgetView: View {
    let entry: LessonEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.caption)
                    .foregroundColor(.orange)
                Spacer()
                Text("\(entry.deadlineCount)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.orange)
            }
            
            Text("Deadlines")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            if entry.deadlineCount > 0 {
                VStack(alignment: .leading, spacing: 3) {
                    if !entry.deadline0Title.isEmpty {
                        deadlineRow(title: entry.deadline0Title, days: entry.deadline0Days)
                    }
                    if !entry.deadline1Title.isEmpty {
                        deadlineRow(title: entry.deadline1Title, days: entry.deadline1Days)
                    }
                    if !entry.deadline2Title.isEmpty {
                        deadlineRow(title: entry.deadline2Title, days: entry.deadline2Days)
                    }
                }
            } else {
                Text("All clear! 🎉")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(10)
    }
    
    func deadlineRow(title: String, days: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.primary)
                .lineLimit(1)
            Spacer()
            Text(days)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.red)
        }
    }
}

struct DeadlineWidget: Widget {
    let kind: String = "DeadlineWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LessonProvider()) { entry in
            if #available(iOS 17.0, *) {
                DeadlineWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                DeadlineWidgetView(entry: entry)
                    .background(Color(.systemBackground))
            }
        }
        .configurationDisplayName("Deadlines")
        .description("Track your upcoming deadlines.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Study Time Widget (Small)

struct StudyTimeWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: LessonEntry
    
    var progressValue: Double {
        // Hedef: 4 saat = 240 dakika
        min(Double(entry.studyMinutes) / 240.0, 1.0)
    }
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                Circle()
                    .stroke(Color.primary.opacity(0.2), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: progressValue)
                    .stroke(Color.primary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    Image(systemName: "timer")
                        .font(.system(size: 10))
                    Text(entry.studyTime)
                        .font(.system(size: 12, weight: .bold))
                }
            }
        default:
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.caption)
                        .foregroundColor(.purple)
                    Spacer()
                    Text("TODAY")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Circular progress (System Small)
                ZStack {
                    Circle()
                        .stroke(Color.purple.opacity(0.15), lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: progressValue)
                        .stroke(Color.purple, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text(entry.studyTime)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.primary)
                        Text("studied")
                            .font(.system(size: 7))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 70, height: 70)
                
                Spacer()
            }
            .padding(10)
        }
    }
}

struct StudyTimeWidget: Widget {
    let kind: String = "StudyTimeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LessonProvider()) { entry in
            if #available(iOS 17.0, *) {
                StudyTimeWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                StudyTimeWidgetView(entry: entry)
                    .background(Color(.systemBackground))
            }
        }
        .configurationDisplayName("Study Tracker")
        .description("Track study progress on home & lock screen.")
        .supportedFamilies([.systemSmall, .accessoryCircular])
    }
}
