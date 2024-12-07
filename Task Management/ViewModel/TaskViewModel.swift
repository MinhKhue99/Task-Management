//
//  TaskViewModel.swift
//  Task Management
//
//  Created by KhuePM on 10/11/24.
//

import Foundation
import SwiftUI
import RealmSwift
import Combine

class TaskViewModel: ObservableObject {
    @Published var currentWeek: [Date] = []
    @Published var selectedDate = Date()
    @Published var filteredTasks: [Task] = []
    @Published var taskTitle: String = ""
    @Published var taskDescription: String = ""
    @Published var taskColor: String = "RedCard"
    @Published var taskDeadline: Date = Date()
    @Published var taskType: String = "Basic"
    @Published var isCompleted: Bool = false
    @Published var showDatePicker: Bool = false
    @Published var exitTask: Task?
    @Published var openEditTask: Bool = false

    private var realm: Realm
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Initialize the Realm database
        do {
            realm = try Realm()

        } catch let error {
            print("Failed to initialize Realm: \(error.localizedDescription)")
            realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "Fallback"))
        }

        fetchCurrentWeek()
        filterTasksByDay(for: selectedDate)
    }

    private func fetchCurrentWeek() {
        let calendar = Calendar.current
        let today = Date()

        // Find the start of the current week (assuming week starts on Sunday)
        if let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start {

            // Generate the dates for the current week
            for dayOffset in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) {
                    currentWeek.append(date)
                }
            }
        }
    }

    func extraDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(selectedDate, inSameDayAs: date)
    }

    func isCurrentHour(date: Date) -> Bool {
        let calendar = Calendar.current
        // Extract hour and minute components from both dates
        let givenHour = calendar.component(.hour, from: date)
        let givenMinute = calendar.component(.minute, from: date)

        let currentHour = calendar.component(.hour, from: Date())
        let currentMinute = calendar.component(.minute, from: Date())

        return (givenHour > currentHour) || ((givenHour == currentHour) && (givenMinute >= currentMinute))

    }

    // MARK:  Filter tasks by selected day
    func filterTasksByDay(for date: Date) {
        let calendar = Calendar.current

        // Calculate start and end of the day
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) ?? startOfDay

        // Query Realm for tasks within the day range
        let results = realm.objects(Task.self)
            .filter("deadline >= %@ AND deadline <= %@", startOfDay, endOfDay)
            .sorted(byKeyPath: "deadline", ascending: true)

        // Convert Results to Array
        filteredTasks = Array(results)
    }

    private func setupBindings() {
        $selectedDate
            .sink { [weak self] date in
                self?.filterTasksByDay(for: date)
            }
            .store(in: &cancellables)
    }

    // MARK:  Add task or Update task
    func addTask() -> Bool {
        // Check if a task with the same properties already exists
        if let existingTask = realm.objects(Task.self).filter("title == %@ AND deadline == %@", taskTitle, taskDeadline).first {
            // Update the existing task
            do {
                try realm.write {
                    // Update if needed
                    existingTask.taskDescription = taskDescription
                    existingTask.color = taskColor
                    existingTask.type = taskType
                    existingTask.isCompleted = isCompleted
                    existingTask.deadline = taskDeadline

                    filterTasksByDay(for: selectedDate)
                }
                print("Task updated successfully")
                return true
            } catch let error {
                print("Failed to update task: \(error.localizedDescription)")
            }
        } else {
            // Add the new task
            let newTask = Task()

            newTask.title = taskTitle
            newTask.taskDescription = taskDescription
            newTask.deadline = taskDeadline
            newTask.color = taskColor
            newTask.type = taskType
            newTask.isCompleted = isCompleted
            do {
                try realm.write {
                    realm.add(newTask)
                    filterTasksByDay(for: selectedDate)
                }
                print("Task added successfully \(self.filteredTasks)")
                return true
            } catch let error {
                print("Failed to add task: \(error.localizedDescription)")
            }
        }
        return false
    }

    // MARK:  Mark task as completed
    func markTaskAsComplete(_ task: Task) {
        do {
            try realm.write {
                task.isCompleted.toggle()
                filterTasksByDay(for: selectedDate)
            }
        } catch {
            print("Failed to mark task as complete: \(error.localizedDescription)")
        }
    }

    // MARK:  Delete Task
    func deleteTask(task: Task) {
        do {
            try realm.write {
                realm.delete(task)
                filterTasksByDay(for: selectedDate)
            }
        } catch let error {
            print("Failed to delete task: \(error.localizedDescription)")
        }
    }

    func resetTaskData() {
        taskType = "Basic"
        taskColor = "Red"
        taskTitle = ""
        taskDescription = ""
        taskDeadline = Date()
    }

    func setupTask() {
        if let exitTask = exitTask {
            taskType = exitTask.type
            taskColor = exitTask.color
            taskDeadline = exitTask.deadline
            taskTitle = exitTask.title
            taskDescription = exitTask.taskDescription
            isCompleted = exitTask.isCompleted
        }
    }
}
