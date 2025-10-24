import Foundation

public protocol WallLabel {
    func marshalJSON() -> Result<Data, Error>
    mutating func setProperty(key: String, value: Any) -> Bool
}

/// Return the ordered list of keys  to display in a UITableView.
public func displayKeys() -> [String] {
    
    let keys: [String] = [
        "title",
        "date",
        "creator",
        "location",
        "medium",
        "creditline",
        "accession_number",
        "latitude",
        "longitude",
        "timestamp",
        "input",
    ]
    return keys
}


/// Boolean method signaling whether a given key's value may be edited.
public func isKeyEditable(key: String) -> Bool {
    
    switch (key) {
    case "title", "date", "creator", "medium", "location", "creditline":
        return true
    default:
        return false
    }
}

