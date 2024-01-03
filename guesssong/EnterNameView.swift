import SwiftUI

struct EnterNameView: View {
    @ObservedObject var appState: AppState
    @State private var playerName = ""

    var body: some View {
        VStack {
            TextField("Enter Your Name", text: $playerName)
                .padding()
            Button("Submit") {
                appState.participants.append(Participant(name: playerName, score: 0))
                playerName = ""
            }
            .padding()
        }
        .navigationTitle("Enter Name")
    }
}

