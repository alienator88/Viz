import SwiftUI

struct AboutView: View {

    let icon: NSImage
    let name: String
    let version: String
    let build: String
    let developerName: String

    var body: some View {

        VStack {

            Image(nsImage: icon)
                .padding()
//                .padding(.bottom, 5)

            Text(name)
                .font(.title)
                .bold()
                .foregroundStyle(
                    LinearGradient(
                        colors: [.red, .purple, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Version \(version) (Build \(build))")
                .padding(.top, 4)

            Spacer()

//            Divider()
//                .padding(.vertical)

//            HStack() {
//                Text("Resources").font(.title2).bold()
//                Spacer()
//            }
//            .padding()
//
//            HStack{
//                VStack(alignment: .leading){
//                    Text("App Icon")
//                    Text("ChatGPT").font(.footnote)
//                }
//                Spacer()
//                Button
//                {
//                    NSWorkspace.shared.open(URL(string: "https://www.freepik.com/free-vector/classic-spartan-helmet-with-gradient-style_3272693.htm")!)
//                } label: {
//                    Label("Site", systemImage: "paperplane")
//                }
//            }
//            .padding()

            HStack(spacing: 0){
                Spacer()
                Text("Made with ❤️ by ")
                Text("\(developerName) (dev@itsalin.com)")
                    .bold()
                Spacer()
            }
            .padding()


        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
