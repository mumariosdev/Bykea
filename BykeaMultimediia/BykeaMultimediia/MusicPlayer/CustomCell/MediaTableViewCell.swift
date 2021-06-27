//
//  MediaTableViewCell.swift
//  BykeaMultimediia
//
//  Created by Muhammad Umar on 27/06/2021.
//

import UIKit

class MediaTableViewCell: UITableViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var playingHintLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setdata(data: Results?, isPlaying: Bool){
        if let result  =  data{
            if let url = URL(string: result.artworkUrl60 ?? "") {
                getData(from: url) { data, response, error in
                    guard let data = data, error == nil else { return }
                    print(response?.suggestedFilename ?? url.lastPathComponent)
                    DispatchQueue.main.async() { [weak self] in
                        self?.imgView.image = UIImage(data: data)
                    }
                }
            }
            
            songName.text = result.collectionName ?? "N/A"
            artistName.text = result.artistName ?? "N/A"
            albumName.text = result.collectionName ?? "N/A"
        }
        if isPlaying{
            playingHintLbl.isHidden =  false
        } else {
            playingHintLbl.isHidden =  true
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
}
