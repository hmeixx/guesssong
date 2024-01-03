import Foundation
import SwiftUI

struct TrackInfo {
    let trackId: Int
    let trackName: String
    var lyrics: String? // Add a property for lyrics
}

class SongData: ObservableObject {
    @Published var trackInfos: [TrackInfo] = []

    func fetchData() async {
        do {
            let trackIds = try await fetchTrackIds()
            trackInfos = trackIds

            for i in 0..<trackInfos.count {
                do {
                    let lyrics = try await fetchLyrics(trackId: trackInfos[i].trackId)
                    trackInfos[i].lyrics = lyrics
                } catch {
                    print("Error fetching lyrics: \(error)")
                }
            }
        } catch {
            print("Error fetching data: \(error)")
        }
    }

    private func fetchTrackIds() async throws -> [TrackInfo] {
        let url = URL(string: "https://api.musixmatch.com/ws/1.1/chart.tracks.get?apikey=d33beaacbc0e9952ec769bdbf464beed&chart_name=top&page=1&page_size=100&country=TW&f_has_lyrics=1")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        guard let message = json["message"] as? [String: Any],
              let body = message["body"] as? [String: Any],
              let trackList = body["track_list"] as? [[String: Any]] else {
            throw NetworkError.invalidResponse
        }

        var trackInfos = [TrackInfo]()
        for trackInfo in trackList {
            if let track = trackInfo["track"] as? [String: Any],
               let trackId = track["track_id"] as? Int,
               let trackName = track["track_name"] as? String {
                let info = TrackInfo(trackId: trackId, trackName: trackName)
                trackInfos.append(info)
            }
        }

        return trackInfos
    }

    private func fetchLyrics(trackId: Int) async throws -> String {
        let url = URL(string: "https://api.musixmatch.com/ws/1.1/track.lyrics.get?apikey=d33beaacbc0e9952ec769bdbf464beed&track_id=\(trackId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        guard let message = json["message"] as? [String: Any],
              let body = message["body"] as? [String: Any],
              let lyrics = body["lyrics"] as? [String: Any],
              let lyricsBody = lyrics["lyrics_body"] as? String else {
            throw NetworkError.invalidResponse
        }

        return lyricsBody
    }
}

enum NetworkError: Error {
    case invalidResponse
}

struct LyricsView: View {
    @StateObject private var songData = SongData()

    var body: some View {
        NavigationView {
            List(songData.trackInfos, id: \.trackId) { trackInfo in
                NavigationLink(destination: LyricsDetailView(lyrics: trackInfo.lyrics)) {
                    Text(trackInfo.trackName)
                }
            }
            .navigationTitle("Songs")
        }
        .task {
            await songData.fetchData()
        }
    }
}

struct LyricsDetailView: View {
    let lyrics: String?

    var body: some View {
        ScrollView {
            Text(lyrics ?? "Lyrics not available")
                .padding()
                .navigationTitle("Lyrics")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LyricsView()
    }
}
