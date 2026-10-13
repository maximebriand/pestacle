// Envoie une commande au canal de débogage de Pestacle (build Debug) et affiche la réponse.
// Usage : build/pestacle-debug <commande…>
import Foundation

let id = UUID().uuidString
let command = CommandLine.arguments.dropFirst().joined(separator: " ")
let center = DistributedNotificationCenter.default()
var done = false

let observer = center.addObserver(forName: Notification.Name("fr.maximebriand.Pestacle.debug.reply"), object: nil, queue: .main) { note in
    guard note.userInfo?["id"] as? String == id else { return }
    print(note.userInfo?["output"] as? String ?? "")
    done = true
}
center.postNotificationName(Notification.Name("fr.maximebriand.Pestacle.debug.request"), object: nil,
                            userInfo: ["id": id, "command": command], deliverImmediately: true)
let deadline = Date().addingTimeInterval(5)
while !done && Date() < deadline { RunLoop.main.run(until: Date().addingTimeInterval(0.05)) }
center.removeObserver(observer)
if !done {
    FileHandle.standardError.write(Data("pas de réponse de Pestacle (lancé en Debug ?)\n".utf8))
    exit(1)
}
