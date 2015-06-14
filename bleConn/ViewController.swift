//
//  ViewController.swift
//  bleConn
//
//  Created by Kang Shiang on 2015-06-13.
//  Copyright (c) 2015 Lex. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet var myLabel: UILabel!
    //BLE
    var centralManager: CBCentralManager!
    var tagPeripheral: CBPeripheral!
    
    @IBAction func connectBtnClicked(sender:UIButton){
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if(central.state == CBCentralManagerState.PoweredOn){
            central.scanForPeripheralsWithServices(nil, options: nil)
            myLabel.text = "Bluetooth is already on"
            println("I am here")
        }else{
            myLabel.text = "Bluetooth is not turned on"
            println("Bluetooth is not turned on")
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        //let deviceName = "KIET"
        //let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        myLabel.text = "Looking for device \(peripheral.name)"
        //if(nameOfDeviceFound == deviceName){
        self.centralManager.stopScan()
        self.tagPeripheral = peripheral
        self.tagPeripheral.delegate = self
        self.centralManager.connectPeripheral(tagPeripheral, options: nil)
        
            //myLabel.text = "Device is found!"
        //}else{
          //  myLabel.text = "Device not found!"
           // println("Device not found!")
        //}
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        myLabel.text = "fail to connect"
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        //self.tagPeripheral.delegate = self
        peripheral.discoverServices(nil)
        self.tagPeripheral = peripheral
        self.tagPeripheral.delegate = self
        myLabel.text = "Connecting to device"
        var localNotification: UILocalNotification = UILocalNotification()
        localNotification.alertAction = "Testing notifications on IOS"
        localNotification.alertBody = "Connected to device"
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 1)
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        println("Connected")
    }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        myLabel.text = "Disconnected from device"
        self.centralManager.connectPeripheral(tagPeripheral, options: nil)
        var localNotification: UILocalNotification = UILocalNotification()
        localNotification.alertAction = "Testing notifications on IOS"
        localNotification.alertBody = "Disconnected"
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 1)
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        println("Disconnected")
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        myLabel.text = "Looking at peripheral's services"
        for service in peripheral.services{
            let thisService = service as! CBService
            peripheral.discoverCharacteristics(nil, forService: thisService)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        myLabel.text = "Connected to device."
        var enableValue = 1
        let enablebytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
        for characteristic in service.characteristics{
            let thisCharacteristic = characteristic as! CBCharacteristic
            self.tagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            self.tagPeripheral.writeValue(enablebytes, forCharacteristic: thisCharacteristic, type: CBCharacteristicWriteType.WithoutResponse)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        myLabel.text = "Here I am"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        centralManager = CBCentralManager(delegate: self, queue: nil)
        myLabel.text = "Starting"
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

