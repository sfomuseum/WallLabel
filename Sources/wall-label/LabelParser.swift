import Foundation
import ArgumentParser

@main
struct LabelParser: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "wall-label",
    subcommands: [Parse.self],
    defaultSubcommand: Parse.self,
  )
}
