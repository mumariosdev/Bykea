//
//  ViewController.swift
//  BykeaMultimediia
//
//  Created by Muhammad Umar on 27/06/2021.
//

import UIKit
import AVFoundation

class MusicPlayerVC: UIViewController {
    
    //MARK:- Variables
    var musicRecords = [Results]()
    var searchKeyword = ""
    var player: AVAudioPlayer?
    var urlString = ""
    var selectedRow =  -1
    
    //MARK:- Outlets
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var searchField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblError.isHidden = false
        lblError.text =  "Search Artist to listen music"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func playAction(_ sender: Any) {
        if let player = player, !player.isPlaying{
        if let url = URL(string: urlString){
        play(url: url)
        }
        }
    }
    
    @IBAction func pauseAction(_ sender: Any) {
        if let player = player, player.isPlaying{
            player.stop()
            selectedRow = -1
            self.tblView.reloadData()
        }
    }
    
    @IBAction func stopAction(_ sender: Any) {
        
        if let player = player, player.isPlaying{
            player.stop()
            self.tblView.reloadData()
        }
        selectedRow = -1
        mediaView.isHidden = true
    }
    
    func downloadFileFromURL(url: URL){
         var downloadTask:URLSessionDownloadTask
         downloadTask = URLSession.shared.downloadTask(with: url) { (url, response, error) in
             self.play(url: url!)
         }
         downloadTask.resume()
     }
    
    func play(url:URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url as URL)
            player?.prepareToPlay()
            player?.volume = 2.0
            player?.play()
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
        
    }
    
//    func playMusic(){
//        if let url = URL(string: urlString){
//            if let player = player, player.isPlaying{
//
//            } else {
//                do {
//                    try AVAudioSession.sharedInstance().setMode(.default)
//                    try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
//
//                    player = try AVAudioPlayer(contentsOf: url)
//                    guard let player = player else {
//                        return
//                    }
//                    player.play()
//                } catch{
//                    print("Cant Play")
//                }
//            }
//        }
//    }
    
}

//MARK:- API Service
extension MusicPlayerVC{
    
    fileprivate func fetchMusic(completion: @escaping (Result<MusicBaseResponse, Error>) -> ()){
        let urlString = "https://itunes.apple.com/search?term=\(searchKeyword)&entity=audiobook"
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (music, resp, err) in
            
            if let err = err{
                completion(.failure(err))
                return
            }
            do {
                let musics = try JSONDecoder().decode(MusicBaseResponse.self, from: music!)
                completion(.success(musics))
                
            }catch let jsonErr {
                completion(.failure(jsonErr))
            }
            
        }.resume()
    }
}

//MARK:- Text Field Delegate
extension MusicPlayerVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        lblError.isHidden = true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchKeyword = textField.text ?? ""
        fetchMusic { (res)  in
            switch res{
            case .success(let data):
                if let records = data.results{
                    if records.count ==  0 {
                        self.lblError.isHidden = false
                        self.lblError.text = "No Records Found"
                    }
                    self.musicRecords = records
                    DispatchQueue.main.async {
                        self.tblView.reloadData()
                    }
                    
                } else {
                    self.lblError.text = "No Results Found"
                    self.lblError.isHidden = false
                }
                
            case .failure(let err):
                self.lblError.text  = err.localizedDescription
                self.lblError.isHidden = false
         
                
            }
        }
    }
}

//MARK:- TableView Delegates and dataSource
extension MusicPlayerVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MediaTableViewCell") as? MediaTableViewCell{
            var isPlaying =  false
            if indexPath.row == selectedRow{
                isPlaying = true
            }
            cell.setdata(data: musicRecords[indexPath.row], isPlaying: isPlaying)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mediaView.isHidden = false
        selectedRow = indexPath.row
        urlString  = musicRecords[indexPath.row].previewUrl ?? ""
        if let url = URL(string: musicRecords[indexPath.row].previewUrl ?? ""){
        downloadFileFromURL(url: url)
        }
        self.tblView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
}
