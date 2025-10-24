import Logging

public protocol Parser {
    
    init(instructions: String, model: String?, logger: Logger?)
    
    func parse(text: String) async -> Result<WallLabel, Error>
}
