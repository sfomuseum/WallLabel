import Foundation
import Logging

import MLX
import MLXLLM
import MLXLMCommon

public struct MLXParser: Parser {
    
    var instructions: String
    var logger: Logger?
    
    public init(instructions: String, model: String?, logger: Logger?) {
        self.instructions = instructions
        self.logger = logger
    }
    
    public func parse(text: String) async -> Result<WallLabel, any Error> {
        
        let mlxService = MLXService()
        let selectedModel: LMModel = MLXService.availableModels.first!
        
        let prompt: String = self.instructions + " The text to parse is: " + text
        var result: String = ""
        
        var messages: [Message] = [
            .system("You are a helpful assistant!")
        ]
        
        messages.append(.user(prompt))
        messages.append(.assistant(""))
        
        do {
            for await generation in try await mlxService.generate(
                messages: messages, model: selectedModel)
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
            
            var label = try JSONDecoder().decode(WallLabel.self, from: data!)
            
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

