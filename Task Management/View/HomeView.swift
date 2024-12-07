//
//  HomeView.swift
//  Task Management
//
//  Created by KhuePM on 10/11/24.
//

import SwiftUI

struct HomeView: View {
    // MARK:  property
    @StateObject var taskViewModel: TaskViewModel = .init()
    @Namespace var animation

    // MARK:  Body
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]) {
                Section {
                    // MARK:  Current week view
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(taskViewModel.currentWeek, id: \.self) { day in
                                VStack(spacing: 10) {

                                    Text(taskViewModel.extraDate(date: day, format: "dd"))
                                        .font(.system(size: 15))
                                        .fontWeight(.semibold)

                                    Text(taskViewModel.extraDate(date: day, format: "EEE"))
                                        .font(.system(size: 14))

                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 8, height: 8)
                                        .opacity(taskViewModel.isToday(date: day) ? 1 : 0)

                                }
                                .foregroundStyle(taskViewModel.isToday(date: day) ? Color.white : Color.black)
                                .frame(width: 45, height: 90)
                                .background {
                                    ZStack {
                                        if taskViewModel.isToday(date: day) {
                                            Capsule()
                                                .fill(Color.black)
                                                .matchedGeometryEffect(id: "CURRENTDAY", in: animation)
                                        }
                                    }
                                }
                                .contentShape(Capsule())
                                .onTapGesture {
                                    withAnimation {
                                        print("Khue: \(day)")
                                        taskViewModel.selectedDate = day
                                        taskViewModel.filterTasksByDay(for: day)
                                    }
                                }
                            }
                        }
                    }
                    .padding()

                    TaskView()

                } header: {
                    HeaderView()
                }
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .overlay(alignment: .bottom) {
            Button(action: {
                taskViewModel.openEditTask.toggle()
            }, label: {
                Label {
                    Text("Add Task")
                        .font(.callout)
                        .fontWeight(.semibold)
                } icon: {
                    Image(systemName: "plus.app.fill")
                }
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background(.black, in: Capsule())
            })
            .padding(.top, 10)
            .frame(maxWidth: .infinity)
            .background {
                LinearGradient(colors: [
                    .white.opacity(0.05),
                    .white.opacity(0.4),
                    .white.opacity(0.7)
                ],
                               startPoint: .top,
                               endPoint: .bottom)
                .ignoresSafeArea()
            }
        }
        .fullScreenCover(isPresented: $taskViewModel.openEditTask) {
            taskViewModel.resetTaskData()
        } content: {
            AddNewTaskView()
                .environmentObject(taskViewModel)
        }
    }

    // MARK:  TaskView
    func TaskView() -> some View {
        LazyVStack(spacing: 25) {
            if taskViewModel.filteredTasks.isEmpty {
                Text("no Task found")
                    .font(.system(size: 16))
                    .fontWeight(.light)
                    .offset(y: 100)
            } else {
                ForEach(taskViewModel.filteredTasks) {task in
                    TaskCardView(task: task)
                }
            }
        }
        .padding()
        .padding(.top)
    }

    // MARK:  TaskCardView
    func TaskCardView(task: Task) -> some View {
        HStack(alignment: .top, spacing: 30) {
            VStack(spacing: 10) {
                Circle()
                    .fill(taskViewModel.isCurrentHour(date: task.deadline) ? Color.black : .clear)
                    .frame(width: 15, height: 15)
                    .background(
                        Circle()
                            .stroke(.black, lineWidth: 1)
                            .padding(-3)
                    )
                    .scaleEffect(taskViewModel.isCurrentHour(date: task.deadline) ? 1 : 0.8)
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 3)
            }

            VStack {
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(task.title)
                            .font(.title2.bold())

                        Text(task.taskDescription)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .hLeading()

                    Text(task.deadline.formatted(date: .omitted, time: .shortened))
                }
                if taskViewModel.isCurrentHour(date: task.deadline) {
                    HStack(spacing: 0) {
                        Button(action: {
                            taskViewModel.markTaskAsComplete(task)
                        }, label: {
                            Image(systemName: task.isCompleted ? "checkmark" : "arrow.uturn.left")
                                .foregroundStyle(Color.black)
                                .padding(10)
                                .background(Color.white, in: RoundedRectangle(cornerRadius: 5))
                        })

                        Text("Mark Task as completed")
                            .font(.caption)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    .hLeading()
                }

            }
            .foregroundStyle(taskViewModel.isCurrentHour(date: task.deadline) ? .white : .black)
            .padding(taskViewModel.isCurrentHour(date: task.deadline) ? 15 : 0)
            .padding(.bottom, taskViewModel.isCurrentHour(date: task.deadline) ? 0 : 10)
            .hLeading()
            .background(
                Color(task.color)
                    .cornerRadius(25)
                    .opacity(taskViewModel.isCurrentHour(date: task.deadline) ? 1 : 0)
            )
        }
        .hLeading()
    }

    // MARK:  Header
    func HeaderView() -> some View {
        HStack(spacing: 10) {
            Text("Task Management")
                .font(.largeTitle.bold())
                .hLeading()
            VStack(alignment: .leading, spacing: 10) {
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .foregroundStyle(.gray)
                Text("Today")
                    .font(.callout.bold())
            }

        }
        .padding()
        .padding(.top, getSafeAreaInsets().top)
        .background(.white)
    }
}

#Preview {
    HomeView()
}
