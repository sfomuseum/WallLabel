import ArgumentParser

import WallLabel

struct Parse: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "...")
    
    @Option(help: "...")
    var model: String = ""
    
    @Option(help: "...")
    var label_text: String = ""
    
    func run() async throws {
        print("BOOP")
        
        let p = MLXParser(instructions: default_instructions, model: model)
        
        let r = await p.parse(text: label_text)
        
        switch r {
        case .success(let label):
            print(label)
        case .failure(let err):
            print("SAD \(err)")
        }
        
    }
}
