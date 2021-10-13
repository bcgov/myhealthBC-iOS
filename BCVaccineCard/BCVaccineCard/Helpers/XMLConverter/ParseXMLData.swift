//
//  ParseXMLData.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-12.
//

import Foundation

class ParseXMLData: NSObject, XMLParserDelegate {
    
    var parser: XMLParser
    var elementArr = [String]()
    var arrayElementArr = [String]()
    var str = "{"
    
    init(xml: String) {
        parser = XMLParser(data: xml.replaceAnd().replaceAposWithApos().data(using: String.Encoding.utf8)!)
        super.init()
        parser.delegate = self
    }
    
    func parseXML() -> String {
        parser.parse()
        
        // Do all below steps serially otherwise it may lead to wrong result
        for i in self.elementArr{
            if str.contains("\(i)@},\"\(i)\":"){
                if !self.arrayElementArr.contains(i){
                    self.arrayElementArr.append(i)
                }
            }
            str = str.replacingOccurrences(of: "\(i)@},\"\(i)\":", with: "},") //"\(element)@},\"\(element)\":"
        }
        
        for i in self.arrayElementArr{
            str = str.replacingOccurrences(of: "\"\(i)\":", with: "\"\(i)\":[") //"\"\(arrayElement)\":}"
        }
        
        for i in self.arrayElementArr{
            str = str.replacingOccurrences(of: "\(i)@}", with: "\(i)@}]") //"\(arrayElement)@}"
        }
        
        for i in self.elementArr{
            str = str.replacingOccurrences(of: "\(i)@", with: "") //"\(element)@"
        }
        
        // For most complex xml (You can ommit this step for simple xml data)
        self.str = self.str.removeNewLine()
        self.str = self.str.replacingOccurrences(of: ":[\\s]?\"[\\s]+?\"#", with: ":{", options: .regularExpression, range: nil)
        
        return self.str.replacingOccurrences(of: "\\", with: "").appending("}")
    }
    
    // MARK: XML Parser Delegate
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        //print("\n Start elementName: ",elementName)
        
        if !self.elementArr.contains(elementName){
            self.elementArr.append(elementName)
        }
        
        if self.str.last == "\""{
            self.str = "\(self.str),"
        }
        
        if self.str.last == "}"{
            self.str = "\(self.str),"
        }
        
        self.str = "\(self.str)\"\(elementName)\":{"
        
        var attributeCount = attributeDict.count
        for (k,v) in attributeDict{
            //print("key: ",k,"value: ",v)
            attributeCount = attributeCount - 1
            let comma = attributeCount > 0 ? "," : ""
            self.str = "\(self.str)\"_\(k)\":\"\(v)\"\(comma)" // add _ for key to differentiate with attribute key type
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if self.str.last == "{"{
            self.str.removeLast()
            self.str = "\(self.str)\"\(string)\"#" // insert pattern # to detect found characters added
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        //print("\n End elementName \n",elementName)
        if self.str.last == "#"{ // Detect pattern #
            self.str.removeLast()
        }else{
            self.str = "\(self.str)\(elementName)@}"
        }
    }
}
