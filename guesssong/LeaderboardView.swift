import SwiftUI
import Combine

struct LeaderboardView: View {
    @ObservedObject var appState: AppState
    @State private var selectedParticipant: Participant?

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(appState.participants) { participant in
                        HStack {
                            Text(participant.name)
                            Spacer()
                            Text("Score: \(participant.score)")
                        }
                        .onTapGesture {
                            selectedParticipant = participant
                        }
                    }
                }
                .refreshable {
                    // Refresh data based on scores
                    appState.participants.sort(by: { $0.score > $1.score })
                }
                
                Button("Add Points") {
                    // Implement adding points functionality
                    if let selectedParticipant = selectedParticipant,
                       let index = appState.participants.firstIndex(where: { $0.id == selectedParticipant.id }) {
                        appState.participants[index].score += 10
                    }
                }
                .padding()
                .navigationTitle("Leaderboard")
            }
        }
    }
}
