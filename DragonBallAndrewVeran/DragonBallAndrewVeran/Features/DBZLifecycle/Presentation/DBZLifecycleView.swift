import SwiftUI
import UIKit

/// Pantalla 4: ciclo de vida UIKit en contexto DBZ.
///
/// Muestra callbacks reales de UIViewController y los imprime en consola.
struct DBZLifecycleView: View {
    @State private var swiftUIAppearCount: Int = 0
    @State private var swiftUIDisappearCount: Int = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 4: UIKit Lifecycle (DBZ)")
                    .font(.title2.bold())

                GroupBox("Que aprendes aqui") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1) Callbacks UIKit reales: viewDidLoad, viewWillAppear, viewDidAppear...")
                        Text("2) Diferencia con SwiftUI: .onAppear y .onDisappear")
                        Text("3) Como integrar UIKit dentro de SwiftUI")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                GroupBox("Orden esperado en UIKit") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("viewDidLoad (1 vez)")
                        Text("viewWillAppear")
                        Text("viewDidAppear")
                        Text("viewWillDisappear")
                        Text("viewDidDisappear")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                Text("SwiftUI onAppear runs: \(swiftUIAppearCount)")
                Text("SwiftUI onDisappear runs: \(swiftUIDisappearCount)")
                    .foregroundStyle(.secondary)

                DBZLifecycleControllerContainer()
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.gray.opacity(0.25), lineWidth: 1)
                    )
            }
            .padding()
        }
        .navigationTitle("DBZ UIKit Lifecycle")
        .onAppear {
            swiftUIAppearCount += 1
            print("[SWIFTUI][LIFECYCLE] onAppear count=\(swiftUIAppearCount)")
        }
        .onDisappear {
            swiftUIDisappearCount += 1
            print("[SWIFTUI][LIFECYCLE] onDisappear count=\(swiftUIDisappearCount)")
        }
    }
}

/// Bridge SwiftUI -> UIKit.
private struct DBZLifecycleControllerContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> DBZLifecycleViewController {
        DBZLifecycleViewController()
    }

    func updateUIViewController(_ uiViewController: DBZLifecycleViewController, context: Context) {
        // No-op: esta demo solo observa lifecycle.
    }
}

/// UIViewController real para mostrar callbacks clásicos de UIKit.
private final class DBZLifecycleViewController: UIViewController {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("[UIKIT][LIFECYCLE] viewDidLoad")

        view.backgroundColor = UIColor.systemBackground
        configureUI()
        statusLabel.text = "viewDidLoad: Cámara entra a Namek"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("[UIKIT][LIFECYCLE] viewWillAppear")
        statusLabel.text = "viewWillAppear: Goku se prepara"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("[UIKIT][LIFECYCLE] viewDidAppear")
        statusLabel.text = "viewDidAppear: Goku aparece en pantalla"
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("[UIKIT][LIFECYCLE] viewWillDisappear")
        statusLabel.text = "viewWillDisappear: Goku se va de la escena"
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("[UIKIT][LIFECYCLE] viewDidDisappear")
    }

    private func configureUI() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = "Goku Lifecycle Arena"
        titleLabel.font = .preferredFont(forTextStyle: .title2)

        subtitleLabel.text = "Mira consola para ver el orden de callbacks UIKit"
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        statusLabel.font = .preferredFont(forTextStyle: .body)
        statusLabel.numberOfLines = 0

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            statusLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
}
