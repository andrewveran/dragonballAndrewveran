import SwiftUI

struct DBZInstrumentsCoreAnimationView: View {
    @State private var stressMode = false
    @State private var spin = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 18: Instruments - Core Animation")
                    .font(.title3.bold())

                Text("Normal: render liviano. Problema: muchas capas translucidas + blur + animacion continua.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button("Escenario normal (UI liviana)") {
                    stressMode = false
                    spin = false
                }
                .buttonStyle(.borderedProminent)

                Button("Escenario problema (stress de render)") {
                    stressMode = true
                    spin = true
                }
                .buttonStyle(.bordered)

                if stressMode {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(0..<90, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .red, .yellow],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 72)
                                .overlay(Text("#\(index)").foregroundStyle(.white))
                                .shadow(color: .black.opacity(0.35), radius: 10)
                                .blur(radius: spin ? 0.8 : 0)
                                .rotationEffect(.degrees(spin ? 360 : 0))
                                .animation(.linear(duration: 1.3).repeatForever(autoreverses: false), value: spin)
                        }
                    }
                } else {
                    VStack(spacing: 10) {
                        ForEach(0..<20, id: \.self) { index in
                            HStack {
                                Image(systemName: "bolt.fill")
                                Text("Fighter card \(index)")
                                Spacer()
                            }
                            .padding(10)
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }

                Text("Instruments sugerido: Core Animation")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("DBZ Core Animation")
    }
}
