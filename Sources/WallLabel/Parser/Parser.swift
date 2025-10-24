import Foundation
import Logging

public enum ParserErrors: Error {
    case invalidURI
    case unsupportedParser
    case invalidParser
}

public protocol Parser {
    
    init(_ parser_uri: String, instructions: String, logger: Logger?) throws
    
    func parse(text: String) async -> Result<WallLabel, Error>
}

public func NewParser(_ parser_uri: String, logger: Logger?) throws -> Parser {
    
    guard let u = URL(string: parser_uri) else {
        throw ParserErrors.invalidURI
    }
    
    var instructions: String
    
    switch (u.scheme) {
    case "mlx":
        instructions = default_instructions + not_generable_instructions
    default:
        instructions = default_instructions
    }
    
    return try NewParserWithInstructions(parser_uri, instructions: instructions, logger: logger)
}

public func NewParserWithInstructions(_ parser_uri: String, instructions: String, logger: Logger?) throws -> Parser {
    
    guard let u = URL(string: parser_uri) else {
        throw ParserErrors.invalidURI
    }
    
    var label_parser: Parser
    
    do {
        switch (u.scheme) {
        case "mlx":
            label_parser = try MLXParser(parser_uri, instructions: instructions, logger: logger)
        case "foundation":
            
            if #available(iOS 26.0, macOS 26.0, *) {
                label_parser = try FoundationModelParser(parser_uri, instructions: instructions, logger: logger)
            } else {
                throw ParserErrors.unsupportedParser
            }
            
        default:
            throw ParserErrors.invalidParser
        }
    } catch {
        throw error
    }
    
    return label_parser
}
