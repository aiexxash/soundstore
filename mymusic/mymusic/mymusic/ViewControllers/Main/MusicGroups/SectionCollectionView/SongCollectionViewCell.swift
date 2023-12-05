import UIKit

class SongCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    func configure(with songTitle: String, author: String) {
            titleLabel.text = songTitle
            authorLabel.text = author
            imageView.backgroundColor = UIColor.systemOrange
    }
}
