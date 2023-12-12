import UIKit
import Network
import Firebase
import FirebaseStorage

class MusicViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == navigationCollectionView) {
            return navSections.count
        } else if (collectionView == sectionCollectionView) {
            return mainSections.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == navigationCollectionView) {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "navCell", for: indexPath) as? NavigationCollectionViewCell else {
                        fatalError("unable to dequeue a reusable cell")
            }
            cell.navTitle.setTitle(navSections[indexPath.row], for: .normal)
            cell.navTitle.setTitleColor(.systemGray3, for: .normal)
          //  cell.navTitle.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)

            
            return cell
        } else if (collectionView == sectionCollectionView) {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sectionCell", for: indexPath) as? SectionCollectionViewCell else {
                        fatalError("unable to dequeue a reusable cell")
            }
            cell.sectionTitle.text = mainSections[indexPath.row]
            
            cell.songCollectionView.delegate = cell
            cell.songCollectionView.dataSource = cell
            
            cell.songCollectionView.reloadData()
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView == navigationCollectionView) {
            return CGSize(width: 100, height: 40)
        } else if (collectionView == sectionCollectionView) {
            return CGSize(width: 390, height: 240)
        } else {
            fatalError()
        }
    }

    @IBOutlet weak var sectionCollectionView: UICollectionView!
    @IBOutlet weak var navigationCollectionView: UICollectionView!
    var soundURLs: [URL] = []
    let defaults = UserDefaults.standard
    static var songs: [String] = []
    static var authors: [String] = []
    let navSections: [String] = ["Featured", "Songs", "Authors", "Albums"]
    let mainSections: [String] = ["Recently Played", "Artists", "Hip-Hop", "Phonk", "Rap"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.overrideUserInterfaceStyle = .dark
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.title = "soundstore"
        sectionCollectionView.delegate = self
        sectionCollectionView.dataSource = self
        navigationCollectionView.delegate = self
        navigationCollectionView.dataSource = self
        Helping.checkInternetConnection(from: self.navigationController)
        getSongs()
    }
    
    func getSongs(){
        guard Auth.auth().currentUser != nil else {
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
                                            
                                            MusicViewController.songs.append(song)
                                            MusicViewController.authors.append(creator)
                                            DispatchQueue.main.async {
                                                self.sectionCollectionView.reloadData()
                                            }
                                            
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

extension SectionCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("================== \(MusicViewController.songs.count)")
        return MusicViewController.songs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "songCell", for: indexPath) as? SongCollectionViewCell else {
                fatalError("unable to dequeue a reusable cell")
            }
    
            let songTitle = MusicViewController.songs[indexPath.row]
            let author = MusicViewController.authors[indexPath.row]
    
            cell.configure(with: songTitle, author: author)
    
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 170, height: 215)
    }
}
