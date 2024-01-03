import SwiftUI

class AppState: ObservableObject {
    @Published var participants = [Participant]()
    
}

struct Participant: Identifiable {
    let id = UUID()
    var name: String
    var score: Int
}
