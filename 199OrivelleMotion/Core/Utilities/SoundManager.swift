import AudioToolbox

enum SoundManager {
    static func playTick() {
        AudioServicesPlaySystemSound(1003)
    }

    static func playSave() {
        AudioServicesPlaySystemSound(1104)
    }

    static func playCaptionSave() {
        AudioServicesPlaySystemSound(1105)
    }

    static func playSuccess() {
        AudioServicesPlaySystemSound(1057)
    }
}
