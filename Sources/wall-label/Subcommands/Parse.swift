import ArgumentParser

import WallLabel

enum ParseErrors: Error {
    case invalidParser
    case stringifyError
}

struct Parse: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "...")
    
    @Option(help: "...")
    var parser: String = "mlx"
    
    @Option(help: "The name of the model to parse.")
    var model: String = ""
    
    @Option(help: "The label text to parse in to structured data.")
    var label_text: String = ""
    
    func run() async throws {
        
        var label_parser: Parser
        
        switch (parser) {
        case "mlx":
            label_parser = MLXParser(instructions: default_instructions, model: model)
        default:
            throw ParseErrors.invalidParser
        }
        
        let parse_rsp = await label_parser.parse(text: label_text)
        
        switch parse_rsp {
        case .success(let label):
            
            let encode_rsp = label.marshalJSON()
            
            switch (encode_rsp) {
            case .success(let data):
                
                guard let str_data = String(data: data, encoding: .utf8) else {
                    throw ParseErrors.stringifyError
                }
                
                print(str_data)
            case .failure(let err):
                throw err
            }
            
        case .failure(let err):
            throw err
        }
        
    }
}
