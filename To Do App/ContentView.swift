import SwiftUI

// Görev Modeli
struct Task: Identifiable {
    var id = UUID()
    var title: String
    var description: String?
    var dueDate: Date
    var category: Category
    var isCompleted: Bool
}

enum Category: String, CaseIterable {
    case work = "İş"
    case home = "Ev"
    case school = "Okul"
    case personal = "Kişisel"
}


class TaskManager: ObservableObject {
    @Published var tasks: [Task] = []
    
    func addTask(title: String, description: String?, dueDate: Date, category: Category) {
        let newTask = Task(title: title, description: description, dueDate: dueDate, category: category, isCompleted: false)
        tasks.append(newTask)
    }
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    func toggleCompletion(for task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }
    
    func updateTask(_ task: Task, newTitle: String, newDescription: String?, newDueDate: Date, newCategory: Category) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].title = newTitle
            tasks[index].description = newDescription
            tasks[index].dueDate = newDueDate
            tasks[index].category = newCategory
        }
    }
}

struct EditTaskView: View {
    @Binding var task: Task
    @Environment(\.dismiss) var dismiss
    
    @State private var newTitle: String
    @State private var newDescription: String
    @State private var newCategory: Category
    @State private var newDueDate: Date
    
    init(task: Binding<Task>) {
        _task = task
        _newTitle = State(initialValue: task.wrappedValue.title)
        _newDescription = State(initialValue: task.wrappedValue.description ?? "")
        _newCategory = State(initialValue: task.wrappedValue.category)
        _newDueDate = State(initialValue: task.wrappedValue.dueDate)
    }
    
    var body: some View {
        Form {
            TextField("Görev Başlığı", text: $newTitle)
            TextField("Görev Açıklaması", text: $newDescription)
            
            Picker("Kategori", selection: $newCategory) {
                ForEach(Category.allCases, id: \.self) { category in
                    Text(category.rawValue)
                }
            }
            
            DatePicker("Son Tarih", selection: $newDueDate, displayedComponents: .date)
                .environment(\.locale, Locale(identifier: "tr_TR"))
            
            Button("Kaydet") {
                task.title = newTitle
                task.description = newDescription
                task.category = newCategory
                task.dueDate = newDueDate
                dismiss()
            }
        }
        .navigationTitle("Görev Düzenle")
    }
}

struct ContentView: View {
    @ObservedObject var taskManager = TaskManager()
    
    @State private var newTaskTitle = ""
    @State private var newTaskDescription = ""
    @State private var newTaskCategory = Category.work
    @State private var newTaskDueDate: Date = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    TextField("Yeni Görev Başlığı", text: $newTaskTitle)
                    TextField("Yeni Görev Açıklaması", text: $newTaskDescription)
                    
                    Picker("Kategori", selection: $newTaskCategory) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Text(category.rawValue)
                        }
                    }
                    
                    DatePicker("Son Tarih", selection: $newTaskDueDate, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "tr_TR"))  
                    
                    Button("Görev Ekle") {
                        taskManager.addTask(title: newTaskTitle, description: newTaskDescription, dueDate: newTaskDueDate, category: newTaskCategory)
                        newTaskTitle = ""
                        newTaskDescription = ""
                        newTaskCategory = .work
                        newTaskDueDate = Date()
                    }
                }
                
                List {
                    ForEach($taskManager.tasks) { $task in
                        HStack {
                            Text(task.title)
                                .strikethrough(task.isCompleted, color: .gray)
                                .foregroundColor(task.isCompleted ? .gray : .black)
                            
                            Spacer()
                            
                            Button(action: {
                                taskManager.toggleCompletion(for: task)
                            }) {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(task.isCompleted ? .green : .blue)
                            }
                            
                            NavigationLink(destination: EditTaskView(task: $task)) {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .onDelete(perform: taskManager.deleteTask)
                }
                .navigationTitle("Yapılacaklar Listesi")
                .navigationBarItems(trailing: EditButton())
            }
        }
    }
}
