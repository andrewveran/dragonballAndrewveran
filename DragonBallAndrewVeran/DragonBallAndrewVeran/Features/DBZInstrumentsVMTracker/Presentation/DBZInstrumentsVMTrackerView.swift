import Foundation
import SwiftUI
import Combine

@MainActor
private final class DBZInstrumentsVMTrackerViewModel: ObservableObject {
    @Published private(set) var cacheObjects = 0
    @Published private(set) var retainedObjects = 0

    private let cache = NSCache<NSString, NSData>()
    private var retained: [Data] = []

    init() {
        cache.countLimit = 20
    }

    func runNormal() {
        for index in 0..<80 {
            let data = Data(count: 1_000_000)
            cache.setObject(data as NSData, forKey: "ki-\(index)" as NSString)
        }
        cacheObjects = cache.totalCostLimit == 0 ? min(80, 20) : 20
    }

    func runProblem() {
        for _ in 0..<25 {
            retained.append(Data(count: 2_000_000))
        }
        retainedObjects = retained.count
    }

    func clear() {
        cache.removeAllObjects()
        retained.removeAll()
        cacheObjects = 0
        retainedObjects = 0
    }
}

struct DBZInstrumentsVMTrackerView: View {
    @StateObject private var viewModel = DBZInstrumentsVMTrackerViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 16: Instruments - VM Tracker")
                    .font(.title3.bold())

                Text("Normal: NSCache con eviccion. Problema: buffer retenido sin limite.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Cache aprox: \(viewModel.cacheObjects) objs | Retenidos: \(viewModel.retainedObjects) objs")
                    .font(.callout.monospacedDigit())

                Button("Escenario normal (cache)") {
                    viewModel.runNormal()
                }
                .buttonStyle(.borderedProminent)

                Button("Escenario problema (retencion)") {
                    viewModel.runProblem()
                }
                .buttonStyle(.bordered)

                Button("Limpiar") {
                    viewModel.clear()
                }
                .buttonStyle(.bordered)

                Text("Instruments sugerido: VM Tracker")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("DBZ VM Tracker")
    }
}
