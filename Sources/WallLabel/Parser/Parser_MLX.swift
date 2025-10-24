import Foundation
import Logging

import MLX
import MLXLLM
import MLXLMCommon

enum MLXParserErrors: Error {
    case missingModel
    case unknownModel
}
    
public struct MLXParser: Parser {
    
    var instructions: String
    var logger: Logger?
    var model: LMModel
    
    public init(_ parser_uri: String, instructions: String, logger: Logger?) throws {
        
        guard let u = URL(string: parser_uri) else {
            throw ParserErrors.invalidURI
        }
        
        guard let components = URLComponents(url: u, resolvingAgainstBaseURL: false) else {
            throw ParserErrors.invalidURI
        }
        
        guard let model_name = components.queryItems?.first(where: { $0.name == "model" })?.value else {
            throw MLXParserErrors.missingModel
        }
        var model: LMModel?
        
        for m in MLXService.availableModels {
            
            if m.name == model_name {
                model = m
                break
            }
        }
        
        if model == nil {
            throw MLXParserErrors.unknownModel
        }
        
        self.instructions = instructions
        self.logger = logger
        self.model = model!
    }
    
    public func parse(text: String) async -> Result<WallLabel, any Error> {
        
        let mlxService = MLXService()
        //let selectedModel: LMModel = MLXService.availableModels.first!
        
        let prompt: String = self.instructions + " The text to parse is: " + text
        var result: String = ""
        
        var messages: [Message] = [
            .system("You are a helpful assistant!")
        ]
        
        messages.append(.user(prompt))
        messages.append(.assistant(""))
        
        do {
            for await generation in try await mlxService.generate(
                messages: messages, model: self.model, logger: self.logger)
            {
                switch generation {
                case .chunk(let chunk):
                    result += chunk
                case .info(let info):
                    self.logger?.debug("INFO \(info)")
                case .toolCall(_):
                    // print("TOOL \(call)")
                    break
                }
            }
        } catch {
            return .failure(error)
        }
        
        self.logger?.debug("DONE \(result)")
        
        let data = result.data(using: .utf8)
        
        do {
            
            var label = try JSONDecoder().decode(WallLabelNotGenerable.self, from: data!)
            
            label.input = text
            label.timestamp = Int(NSDate().timeIntervalSince1970)
            label.latitude = 0.0
            label.longitude = 0.0

            return .success(label)
        } catch {
            return .failure(error)
        }
        
    }

}

