import UIKit
import Network
import Firebase
import FirebaseStorage

class MusicViewController: UIViewController {
    @IBOutlet weak var sectionCollectionView: UICollectionView!
    @IBOutlet weak var navigationCollectionView: UICollectionView!
    var soundURLs: [URL] = []
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        Helping.checkInternetConnection(from: self.navigationController)
        getSongs()
    }
    
    func getSongs(){
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference().child("songs")
        
        storageRef.listAll { (result, error) in
            if let error = error {
                print("Error listing items: \(error.localizedDescription)")
                return
            }
            
            for item in result!.items {
                // Download each MP3 file
                item.downloadURL { (url, error) in
                    if let error = error {
                        print("Error downloading file: \(error.localizedDescription)")
                        return
                    }
                    
                    if let downloadURL = url {
                        // Add the download URL to the array
                        self.soundURLs.append(downloadURL)
                        
                        // Optionally, you can perform additional actions with the download URL
                        
                        // If all files are downloaded, you can proceed with your logic
                        if self.soundURLs.count == result!.items.count {
                            // Now soundURLs array contains URLs of all MP3 files
                            print("Downloaded \(self.soundURLs.count) MP3 files.")
                            // Call a function or perform actions with soundURLs array
                            // e.g., update UI, play the downloaded sounds, etc.
                            self.handleDownloadedSounds(self.soundURLs)
                            for urlString in self.soundURLs {
                                let stringRepresentation = urlString.absoluteString
                                if let pathComponents = URLComponents(string: stringRepresentation)?.path.components(separatedBy: "/") {
                                    // Get the last path component (file name) and remove the ".mp3" extension
                                    if let fileName = pathComponents.last?.replacingOccurrences(of: ".mp3", with: "") {
                                        // Split the file name into creator and song
                                        let components = fileName.components(separatedBy: "_")
                                        
                                        // Ensure we have at least two components
                                        if components.count >= 2 {
                                            var creator = components[0].replacingOccurrences(of: "-", with: " ")
                                            let song = components[1].replacingOccurrences(of: "-", with: " ")
                                            
                                            creator = creator.replacingOccurrences(of: "&", with: ", ")
                                            
                                            // Now you have 'creator' and 'song' variables
                                            print("Creator: \(creator)")
                                            print("Song: \(song)")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func handleDownloadedSounds(_ soundURLs: [URL]) {
        // Handle the downloaded sound URLs, e.g., update UI, play sounds, etc.
        print("Handling downloaded sounds...")
        for url in soundURLs {
        // Perform actions with each URL, such as displaying or playing the sound
            print("Sound URL: \(url)")
        }
    }
}
