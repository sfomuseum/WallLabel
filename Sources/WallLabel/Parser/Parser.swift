public protocol Parser {
    
    init(instructions: String, model: String?)
    
    func parse(text: String) async -> Result<WallLabel, Error>
}
