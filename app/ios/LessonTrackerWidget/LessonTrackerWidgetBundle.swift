//
//  LessonTrackerWidgetBundle.swift
//  LessonTrackerWidget
//
//  Created by mehmet ali ışık on 24.02.2026.
//

import WidgetKit
import SwiftUI

@main
struct LessonTrackerWidgetBundle: WidgetBundle {
    var body: some Widget {
        NextLessonWidget()
        DeadlineWidget()
        StudyTimeWidget()
    }
}
