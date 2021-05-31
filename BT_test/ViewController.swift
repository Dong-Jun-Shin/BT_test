//
//  ViewController.swift
//  BT_test
//
//  Created by 임시 사용자 (DJ) on 2021/05/30.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    @IBOutlet weak var tblOfList: UITableView!
    @IBOutlet weak var btnOfScan: UIButton!
    @IBOutlet weak var btnOfDiscon: UIButton!
    @IBOutlet weak var lblOfDeviceName: UILabel!
    @IBOutlet weak var lblOfState: UILabel!
    @IBOutlet weak var txtOfLog: UITextView!
    @IBOutlet weak var txtOfSendMsg: UITextView!
    @IBOutlet weak var btnOfSend: UIButton!
    
    var peripherals:[CBPeripheral] = []
    var peripheralObj: CBPeripheral!
    var centralManager: CBCentralManager!
    var characteristic: CBCharacteristic!
    
    let deviceCharCBUUID = CBUUID(string: "FFE1")
    let data = NSMutableData()
    
    /*화면 터치해서 키보드 내리는 함수*/
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /*초기화 함수*/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblOfList.delegate = self
        tblOfList.dataSource = self
        
        self.tblOfList.tableFooterView = UIView()
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }
    
    /*연결 해제 함수*/
    @IBAction func btnDisconClick(_ sender: Any) {
        if peripheralObj != nil {
            centralManager.cancelPeripheralConnection(peripheralObj)
        }else{
            txtOfLog.text = "Not Connection"
        }
    }
    
    /*스캔 함수*/
    @IBAction func btnScanClick( sender: Any) {
        txtOfLog.text = "scan Start"
        
        if(centralManager.isScanning) {
            centralManager.stopScan()
        }
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    /*데이터 전송*/
    @IBAction func btnSendClick(_ sender: Any) {
        let data = String(format: "%@", txtOfSendMsg.text)
        guard let valueString = data.data(using: String.Encoding.utf8) else { return }
        writeValueToChar(withCharacteristic: characteristic, withValue: valueString)
    }
    
}
/*테이블 뷰 관련 확장 ViewController*/
extension ViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblOfList.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        let peripheral = peripherals[indexPath.row]
        cell.textLabel?.text = peripheral.name
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = peripherals[indexPath.row]
        txtOfLog.text = "Details : \(peripheral)"
        
        peripheralObj = peripheral
        centralManager.connect(peripheralObj)
    }
}
/*블루투스 관련 확장 ViewController*/
extension ViewController : CBPeripheralDelegate, CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            lblOfState.text = "unknown"
        case .resetting:
            lblOfState.text = "resetting"
        case .unsupported:
            lblOfState.text = "unsupported"
        case .unauthorized:
            lblOfState.text = "unauthorized"
        case .poweredOff:
            lblOfState.text = "poweredOff"
        case .poweredOn:
            lblOfState.text = "poweredOn"
        @unknown default:
            fatalError()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !(peripheral.name ?? "").isEmpty {
            var check:Bool = false
            for p in peripherals {
                if(p.name == peripheral.name) {
                    check = true
                }
            }
            
            if(!check) {
                self.peripherals.append(peripheral)

                DispatchQueue.main.async(execute: {
                    self.tblOfList.reloadData()
                    self.tblOfList.contentOffset = .zero
                })
                
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        txtOfLog.text = "Connected to "+peripheral.name!
        centralManager?.stopScan()
        txtOfLog.text = txtOfLog.text + "\nScanning stopped"
        
        peripheralObj.delegate = self
        peripheralObj.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        txtOfLog.text = "Disconnected"
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics([deviceCharCBUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let chars = service.characteristics else { return }
        
        for char in chars {
            characteristic = char
            if char.uuid.isEqual(deviceCharCBUUID) {
                peripheral.setNotifyValue(true, for: char)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // 여기서부터 체크
        guard let stringFromData = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue) else {
            print("Invalid data")
            return
        }
        
        // Have we got everything we need?
        if stringFromData.isEqual(to: "EOM") {
            // We have, so show the data,
            txtOfLog.text = String(data: data.copy() as! Data, encoding: String.Encoding.utf8)
            
            // Cancel our subscription to the characteristic
            peripheral.setNotifyValue(false, for: characteristic)
            
            // and disconnect from the peripehral
            centralManager?.cancelPeripheralConnection(peripheral)
        } else {
            // Otherwise, just add the data on to what we already have
            data.append(characteristic.value!)
            
            // Log it
            print("Received: \(stringFromData)")
        }
    }
    
    func writeValueToChar( withCharacteristic characteristic: CBCharacteristic, withValue value: Data){
        if characteristic.properties.contains(.writeWithoutResponse) && peripheralObj != nil {
            peripheralObj.writeValue(value, for: characteristic, type: .withoutResponse)
        }
    }
}
