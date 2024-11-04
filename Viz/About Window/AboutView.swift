import SwiftUI
import AlinFoundation

struct AboutView: View {
    @EnvironmentObject var updater: Updater

    var body: some View {

        VStack(spacing: 0) {

            HStack {
                Spacer()
                if updater.updateAvailable {
                    UpdateBadge(updater: updater)
                        .frame(width: 200)
                        .padding()
                } else {
                    HStack {
                        Text("No updates available")
                            .foregroundStyle(.secondary)
                        Button("Refresh") {
                            updater.checkForUpdatesForce(showSheet: false)
                        }
                    }
                    .padding()

                }
            }

            Spacer()

            FrequencyView(updater: updater)
                .frame(width: 250)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.1))
                    //                        .strokeBorder(.secondary.opacity(0.5), lineWidth: 1)
                }




            Image(nsImage: NSApp.applicationIconImage ?? NSImage())
                .padding()

            Text(Bundle.main.name)
                .font(.title)
                .bold()
                .foregroundStyle(
                    LinearGradient(
                        colors: [.red, .purple, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Version \(Bundle.main.version) (Build \(Bundle.main.buildVersion))")
                .padding(.top, 4)

            Spacer()

            HStack(spacing: 0){
                Spacer()
                Text("Made with ❤️ by ")
                Text("Alin Lupascu")
                    .bold()
                Spacer()
            }
            .padding()

        }
        .ignoresSafeArea(edges: .top)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
