import SwiftUI
import AVKit

// 定義歌曲結構
struct Song {
    var name: String
    var previewURL: URL
}

struct GuessSongView: View {
    @State private var songName = ""
    @State private var isCorrect = false
    @State private var showAlert = false
    @State private var currentSongIndex = 0

    // 使用 @State 而非全域變數
    @State private var songs: [Song] = []
    @State private var accessToken = "BQBk0YR-ppAWg8J7VXbAMExSuSxDP85wJBC5jW2_npmRsiDzlXEEELCzA2cuZi940UeE_hoFFkFV-RnsCebaWJR2RQC3mcWq_7-03XQ_mVohUFIXfpjwX3IwopVQT0D0YJmHjU4N_2bJ2E2EH-85FXNptkJG7XyXBTYpCbRkzcNqg89hFOkkDoJPhD6TQ8bwwasc7M1hQGPKDn2-OQw"
    var body: some View {
        VStack {
            Text("猜歌遊戲")
                .font(.largeTitle)
                .padding()

            // 確保在取得歌曲資料後再使用
            if !songs.isEmpty {
                AVPlayerContainer(url: songs[currentSongIndex].previewURL)
                    .id(UUID()) // 使用 UUID 來強制刷新 AVPlayerContainer
            }

            Text("猜一首歌的名稱：")

            TextField("輸入歌曲名稱", text: $songName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
            Button("提交答案") {
                checkAnswer()
            }
            .padding()

            Button("下一首") {
                nextSong()
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(isCorrect ? "恭喜你！" : "很抱歉..."),
                message: Text(isCorrect ? "你猜對了！" : "再試一次吧。"),
                dismissButton: .default(Text("OK")) {
                    resetGame()
                }
            )
        }
        .padding()
        .onAppear {
            // 在視圖出現時取得歌曲資料
            fetchSpotifyData()
        }
    }

    func checkAnswer() {
        let correctSongName = songs[currentSongIndex].name
        isCorrect = songName.lowercased() == correctSongName.lowercased()
        showAlert = true
    }

    func resetGame() {
        songName = ""
        isCorrect = false
        showAlert = false
    }

    func nextSong() {
        PlayerManager.shared.player?.pause()
        currentSongIndex = (currentSongIndex + 1) % songs.count
        resetGame()
    }

    // 修改 fetchSpotifyData()，將歌曲資料放入 @State 變數中
    func fetchSpotifyData() {
        let apiUrl = "https://api.spotify.com/v1/playlists/37i9dQZF1E4wUfFoMWkgbY/tracks"

        guard let url = URL(string: apiUrl) else {
            print("Invalid URL")
            return
        }

        refreshAccessToken()
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)

//        let accessToken = "BQBk0YR-ppAWg8J7VXbAMExSuSxDP85wJBC5jW2_npmRsiDzlXEEELCzA2cuZi940UeE_hoFFkFV-RnsCebaWJR2RQC3mcWq_7-03XQ_mVohUFIXfpjwX3IwopVQT0D0YJmHjU4N_2bJ2E2EH-85FXNptkJG7XyXBTYpCbRkzcNqg89hFOkkDoJPhD6TQ8bwwasc7M1hQGPKDn2-OQw"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let items = json["items"] as? [[String: Any]] {
                        var fetchedSongs: [Song] = []

                        for item in items {
                            if let track = item["track"] as? [String: Any] {
                                if let name = track["name"] as? String,
                                   let previewUrl = track["preview_url"] as? String {
                                    let song = Song(name: name, previewURL: URL(string: previewUrl)!)
                                    fetchedSongs.append(song)
                                }
                            }
                        }

                        // 在主線程中更新 @State 變數
                        DispatchQueue.main.async {
                            songs = fetchedSongs
                        }
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }

        task.resume()
    }
}
func refreshAccessToken() {
    let parameters = "grant_type=refresh_token&refresh_token=AQAv68zBbsHGYFQHcPcHIAoIib2fVUmaob4wjKNh2kxXreMBfwgii8qextNgy-qbJ3XQBFGAIQOFqAcit8fY1YZnG19OZx6A9VTyfnPmuTU7LF9uQgrd9Ih5a_TLQbSGtQc"
    let postData =  parameters.data(using: .utf8)

    var request = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!,timeoutInterval: Double.infinity)
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.addValue("Basic MTE3MjMzMmE3MTE5NDYxMmE1NzBmNThjODZiODY4OTk6ZTZiYWQwYzkzZDJmNDQxYzg5ZjI1YzcwNGQ1Y2IxYzk=", forHTTPHeaderField: "Authorization")
    request.addValue("__Host-device_id=AQBMUWP8zJ-e-FevGbygF8udxs2bKVO8UReK1fwQnxK0UmIPmKr7SvznNHayWQeC4NDZ927xnHcliI-4Vzq8rIEhV6B44CxJrgI; sp_tr=false", forHTTPHeaderField: "Cookie")

    request.httpMethod = "POST"
    request.httpBody = postData

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      guard let data = data else {
        print(String(describing: error))
        return
      }
      print(String(data: data, encoding: .utf8)!)
    }

    task.resume()

    }


struct AVPlayerContainer: UIViewControllerRepresentable {
    let url: URL
    let playerID = UUID()

    @StateObject private var playerManager = PlayerManager.shared

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        let player = AVPlayer(url: url)
        playerManager.player = player // 將 player 賦值給 PlayerManager
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        controller.addChild(playerViewController)
        controller.view.addSubview(playerViewController.view)
        playerViewController.view.frame = controller.view.frame
        player.play()
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update logic here
    }
}
class PlayerManager: ObservableObject {
    @Published var player: AVPlayer?

    static let shared = PlayerManager()

    private init() {}
}

struct GuessSongView_Previews: PreviewProvider {
    static var previews: some View {
        GuessSongView()
    }
}
