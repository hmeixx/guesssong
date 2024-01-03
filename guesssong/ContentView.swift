import SwiftUI
import TipKit

struct ContentView: View {
    @StateObject private var appState = AppState()
   
    var body: some View {
        TabView {
            EnterNameView(appState: appState)
                .tabItem {
                    Label("Enter Name", systemImage: "person")
                }
            
            GuessSongView()
                .tabItem {
                    Label("Guess Song", systemImage: "music.note")
                }
            LyricsView()
                .tabItem {
                    Label("Lyrics", systemImage: "doc.text.magnifyingglass")
                }
            LeaderboardView(appState: appState)
                .tabItem {
                    Label("Leaderboard", systemImage: "list.number")
                }
            ShareView()
                .tabItem {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            
        }
    }
}

struct View_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
