import Foundation

import MLX
import MLXLLM
import MLXLMCommon

public struct MLXParser: Parser {
    
    var instructions: String
    
    public init(instructions: String, model: String?) {
        self.instructions = instructions
    }
    
    public func parse(text: String) async -> Result<WallLabel, any Error> {
        
        var label = WallLabel(text)
        label.timestamp = Int(NSDate().timeIntervalSince1970)
        label.latitude = 0.0
        label.longitude = 0.0
        
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
                    print("INFO \(info)")
                case .toolCall(_):
                    // print("TOOL \(call)")
                    break
                }
            }
        } catch {
            return .failure(error)
        }
        
        print("DONE \(result)")
        
        let data = result.data(using: .utf8)
        
        do {
            let l = try JSONDecoder().decode(WallLabel.self, from: data!)
            label.title = l.title
            label.date = l.date
            // and so on...
            
            return .success(label)
        } catch {
            return .failure(error)
        }
        
    }

}

