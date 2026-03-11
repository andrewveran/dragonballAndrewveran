import SwiftUI
import Combine

@MainActor
private final class DBZInstrumentsFileActivityViewModel: ObservableObject {
    @Published private(set) var filesWritten = 0
    @Published private(set) var bytesProcessed = 0
    @Published private(set) var status = "Idle"

    private let folderURL: URL = FileManager.default.temporaryDirectory.appendingPathComponent("dbz_file_activity", isDirectory: true)

    init() {
        try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
    }

    func runNormal() {
        status = "Escribiendo archivo unico..."
        let fileURL = folderURL.appendingPathComponent("normal.txt")
        let data = Data(repeating: 0x41, count: 512_000)

        do {
            try data.write(to: fileURL, options: .atomic)
            filesWritten += 1
            bytesProcessed += data.count
            status = "Normal completado"
        } catch {
            status = "Error: \(error.localizedDescription)"
        }
    }

    func runProblem() {
        status = "Escribiendo y leyendo multiples archivos..."

        do {
            var total = 0
            var count = 0

            for index in 0..<120 {
                let url = folderURL.appendingPathComponent("stress_\(index).bin")
                let payload = Data(repeating: UInt8(index % 255), count: 120_000)
                try payload.write(to: url, options: .atomic)
                total += payload.count
                count += 1
            }

            let urls = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            for url in urls {
                total += (try Data(contentsOf: url)).count
            }

            filesWritten += count
            bytesProcessed += total
            status = "Stress completado"
        } catch {
            status = "Error: \(error.localizedDescription)"
        }
    }

    func cleanup() {
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            for url in urls {
                try? FileManager.default.removeItem(at: url)
            }
            status = "Carpeta limpiada"
        } catch {
            status = "Error: \(error.localizedDescription)"
        }
    }
}

struct DBZInstrumentsFileActivityView: View {
    @StateObject private var viewModel = DBZInstrumentsFileActivityViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 20: Instruments - File Activity")
                    .font(.title3.bold())

                Text("Normal: I/O minimo. Problema: muchas escrituras y lecturas en lote.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Archivos: \(viewModel.filesWritten) | Bytes: \(viewModel.bytesProcessed) | Estado: \(viewModel.status)")
                    .font(.callout.monospacedDigit())

                Button("Escenario normal") {
                    viewModel.runNormal()
                }
                .buttonStyle(.borderedProminent)

                Button("Escenario problema (I/O masivo)") {
                    viewModel.runProblem()
                }
                .buttonStyle(.bordered)

                Button("Limpiar carpeta temporal") {
                    viewModel.cleanup()
                }
                .buttonStyle(.bordered)

                Text("Instruments sugerido: File Activity")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("DBZ File Activity")
    }
}
