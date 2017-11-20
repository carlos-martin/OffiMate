//
//  MainViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 21/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//
import UIKit
import Firebase

enum MainSection: Int {
    case createNewChannel = 0
    case currentChannel
}

class MainViewController: UITableViewController {
    
    var senderDisplayName:  String?
    var newChannel:         Channel?
    var newChannelButton:   UIButton?
    var newChannelIsHide:   Bool = true
    var lastContentOffset:  CGFloat = 0
    
    //MARK:- Spinner
    var firstAccess: Bool = true
    
    var stopLoading: Bool! {
        didSet {
            if self.firstAccess {
                if self.stopLoading! {
                    self.spinnerView.isHidden = true
                    self.spinnerView.stopAnimating()
                } else {
                    self.spinnerView.isHidden = false
                    self.spinnerView.startAnimating()
                }
            } else {
                if self.stopLoading! { self.spinner?.stop() } else { self.spinner?.start() }
            }
        }
    }
    
    var startLoading: Bool! {
        set { self.stopLoading = (newValue != nil ? !(newValue!) : true) }
        get { return !(self.stopLoading!) }
    }
    
    //MARK:- Boostcard
    var unreadBoostcard: [BoostCard]! {
        didSet { if !self.unreadBoostcard.isEmpty { self.profileButton.addBadge() } }
        willSet { if self.unreadBoostcard != nil { if newValue.isEmpty && !self.unreadBoostcard.isEmpty {self.profileButton.removeBadge()} } }
    }
    
    //MARK:- UI
    var profileButton:  UIBarButtonItem!
    var menuButton:     UIBarButtonItem!
    
    var spinner: SpinnerLoader?
    @IBOutlet weak var emptyChannelsLabel: UILabel! 
    @IBOutlet weak var spinnerView: UIActivityIndicatorView!
    
    //MARK:- Firebase variables
    private lazy var channelRef:    DatabaseReference = Database.database().reference().child("channels")
    private lazy var boostcardRef:  DatabaseReference = Database.database().reference().child("boostcard")
    
    private var channelRefHandle:   DatabaseHandle?
    private var messageRefHandle:   DatabaseHandle?
    private var deletedRefHandle:   DatabaseHandle?
    private var boostcardRefHandle: DatabaseHandle?
    
    //MARK:- View Func
    override func viewDidLoad() {
        self.initUI()
        self.observeChannels()
        self.observeChannelsChanges()
        self.observeBoostCard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !Tools.isInternetAvailable() {
           Tools.goToWaitingRoom(vc: self)
        }
        
        self.reloadView()
        if self.spinner == nil {
            self.spinner = SpinnerLoader(view: self.navigationController!.view, alpha: 0.1)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.spinner = nil
        self.firstAccess = false
    }
    
    deinit {
        if let refChannelHandle = channelRefHandle {
            channelRef.removeObserver(withHandle: refChannelHandle)
        }
        if let refMessageHandle = messageRefHandle {
            channelRef.removeObserver(withHandle: refMessageHandle)
        }
        if let refDeletedHandle = deletedRefHandle {
            channelRef.removeObserver(withHandle: refDeletedHandle)
        }
        if let refBoostcardHandle = boostcardRefHandle {
            boostcardRef.removeObserver(withHandle: refBoostcardHandle)
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func onboardActionButton(_ sender: Any) {
        Tools.goToProfile(vc: self)
    }
    
    @objc func menuActionButton(_ sender: Any) {
        guard let vc = UIStoryboard(name: "Coworkers", bundle: nil).instantiateViewController(withIdentifier: "Coworkers") as? CoworkersViewController else {
            let message = "Could not instantiate view controller with identifier of type CoworkersViewController"
            Alert.showFailiureAlert(message: message)
            return
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:- Init and Fetching Data Functions
    
    private func initUI() {
        self.firstAccess = true
        
        self.unreadBoostcard = []
        
        self.profileButton = UIBarButtonItem(
            image: UIImage(named: "user"),
            style: .plain,
            target: self,
            action: #selector(onboardActionButton(_:)))
        
        self.menuButton = UIBarButtonItem(
            image: UIImage(named: "coworkers"),
            style: .plain,
            target: self,
            action: #selector(menuActionButton(_:)))
        
        self.navigationItem.rightBarButtonItem = menuButton
        self.navigationItem.leftBarButtonItem = profileButton
        self.navigationItem.title = "OffiMate"
        self.emptyChannelsLabel.isHidden = (CurrentUser.channels.isEmpty ? false : true)
        self.spinner = SpinnerLoader(view: self.navigationController!.view, alpha: 0.1)
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.viewRespectsSystemMinimumLayoutMargins = false
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func reloadView() {
        self.tableView.reloadData()
        if CurrentUser.channels.count > 0 {
            self.emptyChannelsLabel.isHidden = true
        } else {
            self.emptyChannelsLabel.isHidden = false
        }
    }
    
    //MARK:- Firebase related methods
    
    private func observeChannels() {
        self.startLoading = true
        self.channelRefHandle = channelRef.queryOrdered(byChild: "officeId").queryEqual(toValue: CurrentUser.office!.id).observe(.childAdded, with: { (snapshot: DataSnapshot) in
            self.stopLoading = true
            if let channelData = snapshot.value as? Dictionary<String, AnyObject> {
                let id = snapshot.key
                if let name = channelData["name"] as! String!, let creator = channelData["creator"] as! String! {
                    let channel: Channel
                    
                    if let messages = channelData["messages"] as! Dictionary<String, AnyObject>! {
                        channel = Channel(id: id, name: name, creator: creator, messages: messages)
                    } else {
                        channel = Channel(id: id, name: name, creator: creator)
                    }
                    
                    if let index = self.getChannelIndex(channel: channel) {
                        let lastAccess = NewDate(id: CurrentUser.channelsLastAccess[index])
                        CurrentUser.updateChannel(channel: channel, lastAccess: lastAccess)
                    } else {
                        CurrentUser.addChannel(channel: channel)
                    }
                    
                    self.reloadView()
                }
            }
        })
        
        channelRef.queryOrdered(byChild: "officeId").queryEqual(toValue: CurrentUser.office!.id).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if snapshot.childrenCount == 0 {
                self.stopLoading = true
                self.emptyChannelsLabel.isHidden = false
            }
        }
    }
    
    private func observeChannelsChanges() {
        self.messageRefHandle = channelRef.queryOrdered(byChild: "officeId").queryEqual(toValue: CurrentUser.office!.id).observe(.childChanged, with: { (snapshot: DataSnapshot) in
            if let channelData = snapshot.value as? Dictionary<String, AnyObject> {
                let id = snapshot.key
                if let name = channelData["name"] as! String!, let creator = channelData["creator"] as! String!, let messages = channelData["messages"] as! Dictionary<String, AnyObject>! {
                    let channel = Channel(id: id, name: name, creator: creator, messages: messages)
                    if let index = self.getChannelIndex(channel: channel) {
                        if CurrentUser.channels[index].messages.count != messages.count {
                            CurrentUser.updateChannel(channel: channel)
                            self.reloadView()
                        }
                    }
                }
            }
        })
        
        self.deletedRefHandle = channelRef.queryOrdered(byChild: "officeId").queryEqual(toValue: CurrentUser.office!.id).observe(.childRemoved, with: { (snapshot: DataSnapshot) in
            if let channelData = snapshot.value as? Dictionary<String, AnyObject> {
                let id = snapshot.key
                if let name = channelData["name"] as! String!, let creator = channelData["creator"] as! String! {
                    let channel = Channel(id: id, name: name, creator: creator)
                    if let index = self.getChannelIndex(channel: channel) {
                        let indexPath = IndexPath(row: index, section: MainSection.currentChannel.rawValue)
                        self.deleteChannelUI(indexPath: indexPath)
                    }
                }
            }
        })
    }
    
    private func observeBoostCard() {
        let receiverId = CurrentUser.user!.uid
        self.boostcardRefHandle = self.boostcardRef.queryOrdered(byChild: "receiverId").queryEqual(toValue: receiverId).observe(.childAdded, with: { (snapshot: DataSnapshot) in
            let id = snapshot.key
            if let rawData = snapshot.value as? Dictionary<String, AnyObject> {
                let header =    rawData["header"]   as! String
                let message =   rawData["message"]  as! String
                let senderId =  rawData["senderId"] as! String
                let unread =    rawData["unread"]   as! Bool
                let date =      rawData["date"]     as! Int64
                let _type =     rawData["type"]     as! String
                let type = (_type == "passion" ? BoostCardType(rawValue: 0) : BoostCardType(rawValue: 1))!
                let boostcard = BoostCard(id: id, senderId: senderId, receiverId: receiverId, type: type, header: header, message: message, date: NewDate(id: date))
                
                if unread {
                    if self.unreadBoostcard.index(of: boostcard) == nil {
                        self.unreadBoostcard.append(boostcard)
                    }
                }
                
            }
        })
        
    }
    
    private func getChannelIndex (channel: Channel) -> Int? {
        var index: Int = 0
        var fond: Bool = false
        for i in CurrentUser.channels {
            if i.id == channel.id {
                fond = true
                break
            }
            index += 1
        }
        if fond {
            return index
        } else {
            return nil
        }
    }
    
    func createChannelFB(_ sender: UITextField) {
        if !(sender.text!.isEmpty) {
            let name = sender.text!
            let newChannelRef = channelRef.childByAutoId()
            let channelItem = [
                "name":     name,
                "creator":  CurrentUser.user!.uid,
                "officeId": CurrentUser.office!.id
            ]
            newChannelRef.setValue(channelItem)
            sender.text! = ""
        } else {
            Tools.textFieldErrorAnimation(textField: sender)
        }
    }
    
    func deleteChannelFB(_ sender: Channel, completion: @escaping (_ error: Error?) -> Void) {
        let toRemoveChannelRef = channelRef.child(sender.id)
        toRemoveChannelRef.removeValue { (error: Error?, ref: DatabaseReference) in
            completion(error)
        }
    }
    
    func deleteChannelUI(indexPath: IndexPath) {
        if indexPath.row < CurrentUser.channels.count {
            print("~\(indexPath.row)~")
            CurrentUser.removeChannel(index: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
            self.tableView.endUpdates()
            self.reloadView()
        } else {
            self.reloadView()
        }
    }
    
    //MARK:- Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                var controller: ChatViewController
                if let navigationController = segue.destination as? UINavigationController {
                    controller = navigationController.topViewController as! ChatViewController
                } else {
                    controller = segue.destination as! ChatViewController
                }
                let channel = CurrentUser.channels[indexPath.row]
                controller.channel = channel
                controller.channelRef = channelRef.child(channel.id)
                controller.totalMessages = channel.messages.count
            }
        }
    }
    
    //MARK:- Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection: MainSection = MainSection(rawValue: section) {
            switch currentSection {
            case .createNewChannel:
                return (self.newChannelIsHide ? 0 : 1)
            case .currentChannel:
                return CurrentUser.channels.count
            }
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let currentSection: MainSection = MainSection(rawValue: section) {
            switch currentSection {
            case .createNewChannel:
                return CGFloat.leastNonzeroMagnitude
            case .currentChannel:
                return (CurrentUser.channels.isEmpty ? 0.1 : UITableViewAutomaticDimension)
            }
        } else {
            return CGFloat.leastNonzeroMagnitude
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let currentSection: MainSection = MainSection(rawValue: section) {
            switch currentSection {
            case .createNewChannel:
                return CGFloat.leastNonzeroMagnitude
            case .currentChannel:
                return (CurrentUser.channels.isEmpty ? 0.1 : UITableViewAutomaticDimension)
            }
        } else {
            return CGFloat.leastNonzeroMagnitude
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let currentSection: MainSection = MainSection(rawValue: section) {
            switch currentSection {
            case .createNewChannel:
                return nil
            case .currentChannel:
                return (CurrentUser.channels.isEmpty ? nil : "Channels")
            }
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentSection: MainSection = MainSection(rawValue: indexPath.section) {
            switch currentSection {
            case .createNewChannel:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "NewChannelCell", for: indexPath) as? NewChannelViewCell
                cell?.newChannelTextField.delegate = self
                cell?.newChannelTextField.placeholder = "Create a New Channel"
                cell?.selectionStyle = .none
                return cell!
            case .currentChannel:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as? MainViewCell
                let channel = CurrentUser.channels[indexPath.row]
                let lastAccess = CurrentUser.channelsLastAccess[indexPath.row]
                
                if channel.creator == CurrentUser.user!.uid {
                    cell?.label.textColor = UIColor.jsq_messageBubbleBlue()
                } else {
                    cell?.label.textColor = UIColor.darkGray
                }
                
                cell?.label.text = channel.name
                
                let counter = channel.getUnread(from: lastAccess)
                if counter == 0 {
                    cell?.counter.isHidden = true
                    cell?.labelRigthConstraint.constant = 0.0
                } else {
                    cell?.counter.isHidden = false
                    cell?.labelRigthConstraint.constant = 23.0
                    cell?.counter.text = String(counter)
                    cell?.counter.textColor = UIColor.white
                    cell?.counter.layer.backgroundColor = UIColor.red.cgColor
                    cell?.counter.layer.cornerRadius = 9
                    cell?.counter.layer.borderWidth = 0.5
                    cell?.counter.layer.borderColor = UIColor.red.cgColor
                }
                return cell!
            }
        } else {
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let currentSection: MainSection = MainSection(rawValue: indexPath.section) {
            switch currentSection {
            case .createNewChannel:
                return false
            case .currentChannel:
                let row = indexPath.row
                if CurrentUser.channels[row].creator == CurrentUser.user!.uid {
                    return true
                } else {
                    return false
                }
            }
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let index = indexPath.row
            let channel = CurrentUser.channels[index]
            let lastAccess = CurrentUser.channelsLastAccess[index]
            let title   = "Do you wanna continue?"
            let message = "You are gonna delete \"\(channel.name)\" channel"
            
            Alert.showAlertOptions(title: title, message: message, okAction: { (_) in
                self.deleteChannelUI(indexPath: indexPath)
                self.deleteChannelFB(channel, completion: { (error: Error?) in
                    if error != nil {
                        Alert.showFailiureAlert(error: error!)
                        CurrentUser.insertChannel(at: index, channel: channel, lastAccess: NewDate(id: lastAccess))
                    }
                })
            }, cancelAction: { (_) in
                print("Deleting channel canceled")
            })
        }
    }
    
    //MARK:- ScrollView
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if actualPosition.y > 0 && self.newChannelIsHide {
            // Dragging down
            self.newChannelIsHide = false
            self.tableView.reloadSections(IndexSet(integer: 0), with: .bottom)
            
        } else if actualPosition.y < 0 && !self.newChannelIsHide {
            // Dragging up
            self.newChannelIsHide = true
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            
        }
    }
    
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //TODO: add action to create a channel
        self.createChannelFB(textField)
        self.view.endEditing(true)
        return true
    }
}

//MARK:- BarButtonItme badge

//MARK:- Badge
private var handle: UInt8 = 0

extension CAShapeLayer {
    func drawCircleAtLocation(location: CGPoint, withRadius radius: CGFloat, andColor color: UIColor, filled: Bool) {
        fillColor = filled ? color.cgColor : UIColor.white.cgColor
        strokeColor = color.cgColor
        let origin = CGPoint(x: location.x - radius, y: location.y - radius)
        path = UIBezierPath(ovalIn: CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))).cgPath
    }
}

extension UIBarButtonItem {
    private var badgeLayer: CAShapeLayer? {
        if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
            return b as? CAShapeLayer
        } else {
            return nil
        }
    }
    
    func addBadge(number: Int?=nil, withOffset offset: CGPoint = CGPoint.zero, andColor color: UIColor = UIColor.red, andFilled filled: Bool = true) {
        guard let view = self.value(forKey: "view") as? UIView else { return }
        
        badgeLayer?.removeFromSuperlayer()
        
        // Initialize Badge
        let badge = CAShapeLayer()
        let radius = (number == nil ? CGFloat(5) : CGFloat(7))
        let location = CGPoint(x: view.frame.width - (radius + offset.x), y: (radius + offset.y))
        badge.drawCircleAtLocation(location: location, withRadius: radius, andColor: color, filled: filled)
        view.layer.addSublayer(badge)
        
        // Initialiaze Badge's label
        let label = CATextLayer()
        label.string = (number == nil ? "" : "\(number!)")
        label.alignmentMode = kCAAlignmentCenter
        label.fontSize = 11
        label.frame = CGRect(origin: CGPoint(x: location.x - 4, y: offset.y), size: CGSize(width: 8, height: 16))
        label.foregroundColor = filled ? UIColor.white.cgColor : color.cgColor
        label.backgroundColor = UIColor.clear.cgColor
        label.contentsScale = UIScreen.main.scale
        badge.addSublayer(label)
        
        // Save Badge as UIBarButtonItem property
        objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func updateBadge(number: Int) {
        if let text = badgeLayer?.sublayers?.filter({ $0 is CATextLayer }).first as? CATextLayer {
            text.string = "\(number)"
        }
    }
    
    func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }
}
