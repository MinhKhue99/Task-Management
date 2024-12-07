//
//  Task.swift
//  Task Management
//
//  Created by KhuePM on 10/11/24.
//

import Foundation
import RealmSwift

class Task: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String
    @Persisted var taskDescription: String
    @Persisted var deadline: Date
    @Persisted var color: String
    @Persisted var type: String
    @Persisted var isCompleted: Bool
}
