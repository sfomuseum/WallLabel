import Foundation
import Logging

public enum ParserErrors: Error {
    case invalidURI
    case unsupportedParser
    case invalidParser
}

public protocol Parser {
    
    init(parser_uri: String, instructions: String,logger: Logger?) throws

    func parse(text: String) async -> Result<WallLabel, Error>
}

public func NewParser(parser_uri: String, logger: Logger?) throws -> Parser {
    
    guard let u = URL(string: parser_uri) else {
        throw ParserErrors.invalidURI
    }
    
    var label_parser: Parser
    
    do {
        switch (u.scheme) {
        case "mlx":
            let instructions = default_instructions + not_generable_instructions
            label_parser = try MLXParser(parser_uri: parser_uri, instructions: instructions, logger: logger)
        case "foundation":
            
            throw ParserErrors.unsupportedParser
            
            /*
            if #available(iOS 26.0, *) {
                label_parser = try FoundationModelParser(instructions: default_instructions, model_name: "", logger: logger)
            } else {
                throw ParserErrors.unsupportedParser
            }
             */
        default:
            throw ParserErrors.invalidParser
        }
    } catch {
        throw error
    }
    
    return label_parser
}
