import AVFoundation

class SoundPlayer {
    static let shared = SoundPlayer()
    private var audioPlayer: AVAudioPlayer?

    func playSound(_ filename: String, withExtension ext: String, volume: Float = 0.5) { // Add default volume
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext) else {
            print("Sound file \(filename).\(ext) not found in bundle!")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = volume // Set the volume (range: 0.0 to 1.0)
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
}
