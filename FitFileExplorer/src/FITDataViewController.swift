//
//  FITDataViewController.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 21/05/2017.
//  Copyright © 2017 Brice Rosenzweig. All rights reserved.
//

import Cocoa
import RZFitFile

class FITDataViewController: NSViewController {

    /*
     - Select Record or Lap or Session Field
     - Session/1 message -> find related fields or display field of message
     - display as table with line for each field
     - for each field-> Value, Avg, Min, Max
     - Surrounding Session or Lap (option)
     - for each field, map into other section where timestamp in [start_time/timestamp]:
  			ex: speed -> session speed, session max speed, etc
     - Containing: Lap or Record
     - find record/lap (from start_time -> timestamp)
     - average/max from record.
     
     - Select Field in session:
     - find matching fields from record/lap, compute between start_time/timestamp:
     - avg, min, max
     - if nothing found: just display field
     
     - Compute Stats using: record/Lap for session/Lap/all
     - session: using record/lap for session/all
     - lap: using record for lap/session/all
     - record: using record for lap/session/all
     */

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var statsUsing: NSPopUpButton!
    @IBOutlet weak var statsFor: NSPopUpButton!
    
    var fitDataSource:FITDataListDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        
        if let ds = self.fitDataSource {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(selectionContextChanged(notification:)),
                                                   name: FITSelectionContext.kFITNotificationConfigurationChanged,
                                                   object: ds.selectionContext)

        }
        self.updatePopup()
        super.viewWillAppear()
    }
    override func viewWillDisappear() {
        super.viewWillDisappear()
        NotificationCenter.default.removeObserver(self)
    }
    func update(with source:FITDataListDataSource){
        NotificationCenter.default.removeObserver(self)
        self.fitDataSource = source
        source.updateStatistics()
        self.tableView.dataSource = source
        self.tableView.delegate = source
        self.tableView.reloadData()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(selectionContextChanged(notification:)),
                                               name: FITSelectionContext.kFITNotificationConfigurationChanged,
                                               object: source.selectionContext)
        self.updatePopup()
    }
    
    func updatePopup() {
        if let ds = self.fitDataSource{
            if let mt = ds.selectionContext.statsUsing,
                let title = ds.selectionContext.fitFile.messageTypeDescription(messageType: mt){
                self.statsUsing.selectItem(withTitle: title)
            }
            if let mt = ds.selectionContext.statsFor,
                let title = ds.selectionContext.fitFile.messageTypeDescription(messageType: mt){
                self.statsFor.selectItem(withTitle: title)
            }
        }
    }
    
    @objc func selectionContextChanged(notification: Notification){
        self.updatePopup()
    }

    
    @IBAction func updateStatsFor(_ sender: NSPopUpButton) {
        if
            let value = sender.selectedItem?.title,
            let mesgnum = RZFitFile.messageType(forDescription: value),
            let ds = self.fitDataSource{
            ds.selectionContext.statsFor = mesgnum
            ds.updateStatistics()
            self.tableView.reloadData()
        }
    }
    @IBAction func updateStatsUsing(_ sender: NSPopUpButton) {
        if
            let value = sender.selectedItem?.title,
            let mesgnum = RZFitFile.messageType(forDescription: value),
            let dataSource = self.fitDataSource{
            dataSource.selectionContext.statsUsing = mesgnum
            dataSource.updateStatistics()
            self.tableView.reloadData()
        }
    }
    
    
}
