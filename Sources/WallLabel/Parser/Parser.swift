import Logging

public enum ParserErrors: Error {
    case invalidParser
}

public protocol Parser {
    
    init(instructions: String, model_name: String?, logger: Logger?) throws
    
    func parse(text: String) async -> Result<WallLabel, Error>
}

public func NewParser(scheme: String, model_name: String?, logger: Logger?) throws -> Parser {
    
    var label_parser: Parser
    
    do {
        switch (scheme) {
        case "mlx":
            label_parser = try MLXParser(instructions: default_instructions, model_name: model_name, logger: logger)
        default:
            throw ParserErrors.invalidParser
        }
    } catch {
        throw error
    }
    
    return label_parser
}
