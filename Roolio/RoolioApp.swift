import SwiftUI
import CoreText
import ImageIO
import UIKit

@main
struct RoolioApp: App {
    init() {
        ["DMSans", "DMSans-Italic"].forEach { name in
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else { return }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    var body: some Scene {
        WindowGroup {
            RoolioFlow()
        }
    }
}

private enum Screen: String {
    case shelf, home, detail, setup, setupGuide, invite, first, ready, horizontal
}

private enum Palette {
    static let paper = Color(hex: 0xF8F5EE)
    static let cream = Color(hex: 0xFCF9F2)
    static let ink = Color(hex: 0x1C3631)
    static let blueInk = Color(hex: 0x1D3653)
    static let blue = Color(hex: 0x244E76)
    static let mutedBlue = Color(hex: 0x637D98)
    static let green = Color(hex: 0x214E46)
    static let coral = Color(hex: 0xB85745)
    static let orange = Color(hex: 0xFC613A)
    static let yellow = Color(hex: 0xFFBA08)
    static let brown = Color(hex: 0x382A20)
}

private extension Color {
    init(hex: UInt, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 255) / 255,
                  green: Double((hex >> 8) & 255) / 255,
                  blue: Double(hex & 255) / 255,
                  opacity: opacity)
    }
}

private extension Font {
    static func dm(_ size: CGFloat, _ weight: Weight = .regular) -> Font {
        .custom("DM Sans", fixedSize: size).weight(weight)
    }
}

private extension View {
    func placed(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat,
                alignment: Alignment = .topLeading) -> some View {
        frame(width: width, height: height, alignment: alignment)
            .position(x: x + width / 2, y: y + height / 2)
    }
}

private struct RoolioFlow: View {
    @State private var screen: Screen

    init() {
        let value = ProcessInfo.processInfo.arguments
            .first(where: { $0.hasPrefix("--screen=") })
            .map { String($0.dropFirst(9)) }
        _screen = State(initialValue: value.flatMap(Screen.init(rawValue:)) ?? .home)
    }

    var body: some View {
        GeometryReader { proxy in
            let isLandscapeGame = screen == .horizontal && proxy.size.width > proxy.size.height
            let designSize = isLandscapeGame ? CGSize(width: 874, height: 402) : size(for: screen)
            let widthScale = proxy.size.width / designSize.width

            ZStack(alignment: .bottom) {
                if designSize.height > proxy.size.height {
                    ScrollView(.vertical) {
                        screenContent(isLandscapeGame: isLandscapeGame)
                            .frame(width: designSize.width, height: designSize.height, alignment: .topLeading)
                            .scaleEffect(widthScale, anchor: .topLeading)
                            .frame(width: designSize.width * widthScale,
                                   height: designSize.height * widthScale,
                                   alignment: .topLeading)
                    }
                    .scrollIndicators(.hidden)
                } else {
                    screenContent(isLandscapeGame: isLandscapeGame)
                        .frame(width: designSize.width, height: designSize.height, alignment: .topLeading)
                        .scaleEffect(widthScale, anchor: .top)
                        .frame(width: designSize.width * widthScale,
                               height: designSize.height * widthScale,
                               alignment: .top)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }

                if !isLandscapeGame && [.home, .shelf, .detail].contains(screen) {
                    fixedBottomNav
                }
                }
        }
        .background(Color.white)
        .ignoresSafeArea()
        .preferredColorScheme(screen == .detail ? .dark : .light)
    }

    @ViewBuilder
    private func screenContent(isLandscapeGame: Bool) -> some View {
        Group {
            if isLandscapeGame {
                LandscapeActionScreen()
            } else {
                switch screen {
                case .shelf: ShelfScreen(go: go)
                case .home: HomeScreen(go: go)
                case .detail: DetailScreen(go: go)
                case .setup: SetupScreen(go: go)
                case .setupGuide: SetupGuideScreen(go: go)
                case .invite: InviteScreen(go: go)
                case .first: FirstPlayerScreen(go: go)
                case .ready: ReadyScreen(go: go)
                case .horizontal: HorizontalPrompt(go: go)
                }
            }
        }
    }

    private var fixedBottomNav: some View {
        ZStack {
            Asset(name: "P34Cabinet", mode: .fill).opacity(0.54).clipped()
            BottomNav(selected: screen == .shelf ? 2 : 0, go: go)
                .frame(width: 370, height: 64)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 97)
    }

    private func size(for screen: Screen) -> CGSize {
        switch screen {
        case .shelf: CGSize(width: 402, height: 901)
        case .home: CGSize(width: 402, height: 908)
        case .detail: CGSize(width: 402, height: 1220)
        case .invite, .horizontal: CGSize(width: 392, height: 874)
        default: CGSize(width: 402, height: 874)
        }
    }

    private func go(_ destination: Screen) { screen = destination }
}

private struct Asset: View {
    let name: String
    var mode: ContentMode = .fit
    var body: some View { Image(name).resizable().aspectRatio(contentMode: mode) }
}

private struct BackButton: View {
    let action: () -> Void
    var asset: String = "P34Back"
    var body: some View {
        Button(action: action) {
            Asset(name: asset).frame(width: 14, height: 14)
                .frame(width: 38, height: 38)
        }
            .buttonStyle(.plain)
    }
}

private struct BottomNav: View {
    let selected: Int
    let go: (Screen) -> Void
    private let items = [
        ("P34Home", "Home"), ("P34Explore", "Explore"), ("P34Shelf", "Shelf"),
        ("P34Coolibo", "Coolibo"), ("P34Profile", "Profile")
    ]

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Asset(name: "P34Cabinet", mode: .fill).clipped().opacity(0.54)
                LinearGradient(colors: [Color(hex: 0xEED3AB, opacity: 0.8), Color(hex: 0xC49766, opacity: 0.68)],
                               startPoint: .top, endPoint: .bottom)
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: 0xF2DDBB, opacity: 0.34))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.5), lineWidth: 1))
                    .padding(10)
                HStack(spacing: 4.5) {
                    ForEach(items.indices, id: \.self) { index in
                        Button {
                            if index == 0 { go(.home) }
                            if index == 2 { go(.shelf) }
                        } label: {
                            VStack(spacing: 3) {
                                Asset(name: items[index].0).frame(width: index == 3 ? 17 : 18, height: 18)
                                Text(items[index].1).font(.dm(10, index == selected ? .bold : .medium))
                            }
                            .foregroundStyle(index == selected ? Color(hex: 0x793821) : Palette.brown)
                            .frame(width: 68, height: 49)
                            .background(index == selected ? Color(hex: 0xFFF1D8, opacity: 0.62) : .clear)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay {
                                if index == selected {
                                    RoundedRectangle(cornerRadius: 12).stroke(Color(hex: 0xFFF0CC, opacity: 0.62))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color(hex: 0x9A7149, opacity: 0.65)))
        .shadow(color: Color.black.opacity(0.14), radius: 5, y: -1)
    }
}

private struct GameCover: View {
    let name: String
    var body: some View {
        Asset(name: name, mode: .fill).clipped()
            .shadow(color: Color.black.opacity(0.23), radius: 3, x: 1, y: 3)
    }
}

private struct ShelfScreen: View {
    let go: (Screen) -> Void
    @State private var sortLabel = "Recently added"
    @State private var showAddGameNotice = false
    var body: some View {
        ZStack(alignment: .topLeading) {
            Asset(name: "P34Wood", mode: .fill).clipped()
            BackButton { go(.home) }.placed(14, 68, 38, 38)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 18).fill(Color(hex: 0x3D2D21, opacity: 0.87))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your shelf").font(.dm(22, .bold)).foregroundStyle(.white)
                    Text("7 games in your collection").font(.dm(9.5)).foregroundStyle(.white.opacity(0.9))
                }.padding(.leading, 18).padding(.top, 11)
                HStack(spacing: 11) {
                    Menu {
                        Button("Recently added") { sortLabel = "Recently added" }
                        Button("Title") { sortLabel = "Title" }
                        Button("Play time") { sortLabel = "Play time" }
                    } label: {
                        Asset(name: "P34Sort").frame(width: 18, height: 18).padding(8).background(Color(hex: 0xE8C79E)).clipShape(Circle())
                    }
                    Button { showAddGameNotice = true } label: {
                        Text("+").font(.dm(26, .medium)).frame(width: 34, height: 34).background(Color(hex: 0xE8C79E)).clipShape(Circle())
                    }.buttonStyle(.plain)
                }.foregroundStyle(Palette.brown).offset(x: 284, y: 17)
            }.placed(16, 137, 374, 69)

            cabinet.placed(14, 212, 378, 599)
        }
        .frame(width: 402, height: 901)
        .alert("Add a game", isPresented: $showAddGameNotice) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Game search is not connected yet. Your current shelf remains available offline.")
        }
    }

    private var cabinet: some View {
        ZStack(alignment: .topLeading) {
            Color(hex: 0xDAB78D)
            Asset(name: "P34Wood", mode: .fill).opacity(0.45).clipped()
            LinearGradient(colors: [Color(hex: 0x633617, opacity: 0.49),
                                    Color(hex: 0x925F3E, opacity: 0.13),
                                    Color(hex: 0xFFF0D1, opacity: 0.24),
                                    Color(hex: 0x785033, opacity: 0.17)],
                           startPoint: .top, endPoint: .bottom)
            Rectangle().fill(Color.white.opacity(0.34))
            Rectangle().fill(Color(hex: 0x5D371E, opacity: 0.20)).frame(width: 5, height: 586)
            Rectangle().fill(Color(hex: 0x5D371E, opacity: 0.20)).frame(width: 5, height: 586).offset(x: 373)
            shelfRow(y: 10, names: ["P34SplendorCover", "P34Forbidden", "P34Cascadia"], widths: [93, 94, 100], heights: [111, 110, 98])
            shelfRow(y: 158, names: ["P34TeaWitches", "P34Wayfinders", "P34Catan"], widths: [99, 103, 90], heights: [97, 101, 88])
            shelfRow(y: 306, names: ["P34Azul", "P34Wingspan"], widths: [94, 100], heights: [99, 98])
            ForEach([137.0, 287.0, 436.0, 585.0], id: \.self) { y in
                Rectangle().fill(LinearGradient(colors: [Color(hex: 0xFFE3AC, opacity: 0.72), Color(hex: 0x75451E, opacity: 0.46)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 378, height: 19).offset(y: y)
                    .overlay(Rectangle().fill(Color(hex: 0xFFE9BC, opacity: 0.76)).frame(width: 378, height: 2).offset(y: y))
            }
        }
        .clipped()
        .overlay(Rectangle().stroke(Color(hex: 0xC89765), lineWidth: 2))
    }

    private func shelfRow(y: CGFloat, names: [String], widths: [CGFloat], heights: [CGFloat]) -> some View {
        HStack(alignment: .bottom, spacing: 17) {
            ForEach(names.indices, id: \.self) { index in
                GameCover(name: names[index]).frame(width: widths[index], height: heights[index])
            }
        }
        .frame(width: 328, height: 127, alignment: .bottomLeading)
        .offset(x: 25, y: y)
    }
}

private struct HomeScreen: View {
    let go: (Screen) -> Void
    @State private var showAddGameNotice = false
    var body: some View {
        ZStack(alignment: .topLeading) {
            Palette.paper
            Button { showAddGameNotice = true } label: { Text("+").font(.dm(26)).foregroundStyle(Palette.brown).frame(width: 34, height: 34).background(Color.white).clipShape(Circle()).shadow(color: .black.opacity(0.18), radius: 2, y: 2) }
                .buttonStyle(.plain).placed(21, 59, 34, 34)
            Asset(name: "P34Logo").placed(158, 66, 84, 28)
            Asset(name: "P34Avatar", mode: .fill).clipShape(Circle()).overlay(Circle().stroke(Color(hex: 0xD2A04A))).placed(345, 59, 34, 34)

            Text("Hi, Anna,").font(.dm(14)).foregroundStyle(.black).placed(22, 125, 358, 20)
            Text("What are we playing for\ntoday?")
                .font(.dm(28.323, .bold)).tracking(-0.6).lineSpacing(2).foregroundStyle(.black)
                .fixedSize(horizontal: false, vertical: true)
                .placed(22, 145, 358, 63)

            featured.placed(22, 229, 358, 223)
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Your shelf").font(.dm(21.014, .bold)).foregroundStyle(Palette.ink)
                    Text("5 games in your collection").font(.dm(10.05, .medium)).foregroundStyle(Color(hex: 0x6D7974))
                }
                Spacer()
                Button { go(.shelf) } label: {
                    HStack(spacing: 5) { Text("View all"); Asset(name: "P34Right").frame(width: 14, height: 14) }
                        .font(.dm(10.964, .bold)).foregroundStyle(Palette.green).padding(.top, 10)
                }.buttonStyle(.plain)
            }.placed(22, 464, 358, 45)
            miniShelf.placed(22, 516, 358, 282.314)

        }
        .frame(width: 402, height: 908)
        .alert("Add a game", isPresented: $showAddGameNotice) {
            Button("View shelf") { go(.shelf) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Game search is not connected yet. You can manage the current collection from your shelf.")
        }
    }

    private var featured: some View {
        Button { go(.detail) } label: {
            ZStack(alignment: .topLeading) {
                Asset(name: "P34Wood", mode: .fill).clipped()
                Color.white.opacity(0.40)
                RoundedRectangle(cornerRadius: 20).stroke(Color(hex: 0xE7C79C), lineWidth: 1.2)
                Text("FEATURED GUIDE").font(.dm(9.136, .bold)).foregroundStyle(.black).offset(x: 19, y: 20)
                Asset(name: "P34SplendorTitle").frame(width: 146.1, height: 64.73).offset(x: 19, y: 37.9)
                Text("Collect gems, acquire\ndevelopments...").font(.dm(11)).foregroundStyle(Color(hex: 0x2B2B2B)).offset(x: 19, y: 101.93)
                HStack(spacing: 8) {
                    infoPill("P34Players", "2–4 players")
                    infoPill("P34Clock", "30 min")
                }.offset(x: 19, y: 139)
                HStack { Text("Start learning"); Spacer(); Asset(name: "P34Forward").frame(width: 16, height: 16) }
                    .font(.dm(9.8, .bold)).foregroundStyle(.white).padding(.horizontal, 13)
                    .frame(width: 145.27, height: 30.59).background(Palette.coral).clipShape(RoundedRectangle(cornerRadius: 9)).offset(x: 19, y: 173.41)
                GameCover(name: "P34SplendorCover").frame(width: 122, height: 160).rotationEffect(.degrees(3)).offset(x: 220, y: 30)
            }
        }.buttonStyle(.plain).clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func infoPill(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 4) { Asset(name: icon).frame(width: 13, height: 13); Text(text) }
            .font(.dm(8.2, .medium)).foregroundStyle(Color(hex: 0x625769)).padding(.horizontal, 8).frame(height: 26)
            .background(.white).clipShape(Capsule())
    }

    private var miniShelf: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18.273).fill(Color(hex: 0xF9F1E5))
            RoundedRectangle(cornerRadius: 10.964)
                .fill(LinearGradient(colors: [Color(hex: 0xFDF9F1), Color(hex: 0xFFFDF8)], startPoint: .top, endPoint: .bottom))
                .frame(width: 338, height: 255).offset(x: 10, y: 21)
            RoundedRectangle(cornerRadius: 1.827).fill(LinearGradient(colors: [Color(hex: 0xF0D5AE), Color(hex: 0xD6A773)], startPoint: .top, endPoint: .bottom)).frame(width: 9.136, height: 266.782).offset(x: 8.22, y: 10.05)
            RoundedRectangle(cornerRadius: 1.827).fill(LinearGradient(colors: [Color(hex: 0xF0D5AE), Color(hex: 0xD6A773)], startPoint: .top, endPoint: .bottom)).frame(width: 9.136, height: 266.782).offset(x: 340.79, y: 10.05)
            RoundedRectangle(cornerRadius: 8.223).fill(LinearGradient(colors: [Color(hex: 0xFEFCF8), Color(hex: 0xFFF9EC)], startPoint: .top, endPoint: .bottom)).frame(width: 324, height: 114).offset(x: 17, y: 20.58)
            RoundedRectangle(cornerRadius: 8.223).fill(LinearGradient(colors: [Color(hex: 0xFEFCF8), Color(hex: 0xFFF9EC)], startPoint: .top, endPoint: .bottom)).frame(width: 324, height: 139).offset(x: 17, y: 136.58)
            GameCover(name: "P34SplendorCover").frame(width: 85.882, height: 107.809).offset(x: 35.63, y: 14.62)
            GameCover(name: "P34Forbidden").frame(width: 84.055, height: 106.895).offset(x: 136.13, y: 15.53)
            GameCover(name: "P34Cascadia").frame(width: 95.018, height: 95.018).offset(x: 232.06, y: 26.5)
            GameCover(name: "P34Azul").frame(width: 85.882, height: 95.932).offset(x: 37.46, y: 154.4)
            GameCover(name: "P34Wingspan").frame(width: 93.191, height: 93.191).offset(x: 133.39, y: 158.97)
            Button { showAddGameNotice = true } label: {
                VStack(spacing: 1) { Asset(name: "P34Add").frame(width: 31.064, height: 31.064); Text("Add a game").font(.dm(10.05, .bold)) }
                    .foregroundStyle(Palette.green).frame(width: 86, height: 90)
                    .background(Color(hex: 0xF8FBF6, opacity: 0.62)).clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: 0xC9D8C7), style: StrokeStyle(lineWidth: 1, dash: [4])))
            }.buttonStyle(.plain).offset(x: 239, y: 159)
            ledge(121.51)
            ledge(252.16)
        }.clipped()
    }

    private func ledge(_ y: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 0.914).fill(LinearGradient(colors: [Color(hex: 0xEECFA5), Color(hex: 0xD9AD77)], startPoint: .top, endPoint: .bottom)).frame(width: 336.218, height: 6.395)
            RoundedRectangle(cornerRadius: 2.741).fill(LinearGradient(colors: [Color(hex: 0xE0B682), Color(hex: 0xC99965)], startPoint: .top, endPoint: .bottom)).frame(width: 339.873, height: 12.791).offset(x: -1.827, y: 6.4)
            Rectangle().fill(Color(hex: 0xFFF5DE)).frame(width: 323.427, height: 1.827).offset(x: 6.4)
        }.offset(x: 10.96, y: y)
    }
}

private struct DetailScreen: View {
    let go: (Screen) -> Void
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.white
            hero
            BackButton(action: { go(.home) }, asset: "P34BackWhite").placed(18, 67, 38, 38)
            content.placed(0, 671, 402, 452)
        }.frame(width: 402, height: 1220)
    }

    private var hero: some View {
        ZStack(alignment: .topLeading) {
            Color(hex: 0x163B5C)
            Asset(name: "P34SplendorCover", mode: .fill)
                .frame(width: 402, height: 696).clipped().blur(radius: 25).opacity(0.92)
            Color(hex: 0x143C5B, opacity: 0.48)
            Asset(name: "P34SplendorCover", mode: .fill).clipped()
                .frame(width: 172.57, height: 232.4)
                .shadow(color: Color(hex: 0x102B44, opacity: 0.32), radius: 29.72, y: 16.21)
                .rotationEffect(.degrees(-2)).offset(x: 113.52, y: 165.36)
            Asset(name: "P34SplendorTitle").frame(width: 142, height: 57).offset(x: 130, y: 438)
            Text("2014  ·  SPACE COWBOYS").font(.dm(8, .bold)).tracking(1.5).foregroundStyle(.white).offset(x: 136, y: 498)
            Text("Collect gems, acquire developments, and attract\nnobles to build the most prestigious trade network.")
                .font(.dm(12.37)).multilineTextAlignment(.center).lineSpacing(4).foregroundStyle(.white.opacity(0.86)).frame(width: 340).offset(x: 31, y: 526)
            HStack(spacing: 8) { detailPill("P34Players", "2–4 players"); detailPill("P34Clock", "30 min") }.offset(x: 119, y: 574)
            HStack(spacing: 7) { Text("More details"); Asset(name: "P34More").frame(width: 12, height: 12) }
                .font(.dm(8, .bold)).foregroundStyle(Color(hex: 0xD7C8FF)).offset(x: 165, y: 617)
        }.frame(width: 402, height: 671).clipped()
    }

    private func detailPill(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 4) { Asset(name: icon).frame(width: 15, height: 15); Text(text) }.font(.dm(8.56, .semibold)).foregroundStyle(Color(hex: 0x625769))
            .padding(.horizontal, 9).frame(height: 31).background(.white).clipShape(Capsule())
    }

    private var content: some View {
        ZStack(alignment: .topLeading) {
            Color.white
            Text("Play Mode").font(.dm(22, .bold)).foregroundStyle(Palette.ink).placed(21, 22, 180, 31)
            Asset(name: "P34ArrowLeft").frame(width: 16, height: 16).placed(60, 70, 16, 16)
                .accessibilityHidden(true)
            VStack(spacing: 2) {
                Text("Standard").font(.dm(13.5, .bold)).foregroundStyle(Palette.blueInk)
                Text("Explore standard splendor world!").font(.dm(8.2)).foregroundStyle(Color(hex: 0x3970A4))
            }.placed(112, 62, 178, 38, alignment: .center)
            Asset(name: "P34ArrowRight").frame(width: 16, height: 16).placed(326, 70, 16, 16)
                .accessibilityHidden(true)

            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Acheivements").font(.dm(14))
                    Text("You are in lead of 23.34% players!").font(.dm(7.6)).foregroundStyle(Color(hex: 0x625769))
                }
                Spacer()
                Text("1/4").font(.dm(12, .bold)).foregroundStyle(Color(hex: 0xD0A33B))
            }.placed(32, 132, 338, 29)
            achievements.placed(21, 174, 360, 60)
            VStack(alignment: .leading, spacing: 2) {
                Text("Table Regular").font(.dm(10.5, .bold))
                Text("Earned · 3 of 3 finished games.").font(.dm(7.6)).foregroundStyle(Color(hex: 0x49677F))
            }
            .padding(.horizontal, 9).frame(width: 338, height: 43, alignment: .leading)
            .background(Color(hex: 0xEDF3F8)).clipShape(RoundedRectangle(cornerRadius: 10))
            .placed(32, 256, 338, 43)
            Button { go(.setup) } label: {
                HStack(spacing: 10) {
                    Asset(name: "P34Play").frame(width: 17, height: 17).padding(9).background(Color(hex: 0xF3D68F)).clipShape(RoundedRectangle(cornerRadius: 10))
                    VStack(alignment: .leading, spacing: 0) { Text("Host a Game").font(.dm(16, .bold)); Text("Start your first turn now!").font(.dm(8.5)) }
                    Spacer(); Asset(name: "P34Right").frame(width: 19, height: 19)
                }.foregroundStyle(Color(hex: 0x152A44)).padding(.horizontal, 12).frame(width: 367, height: 78).background(Palette.yellow).clipShape(RoundedRectangle(cornerRadius: 15)).shadow(color: Color(hex: 0x163B5C, opacity: 0.24), radius: 9, y: 8)
            }.buttonStyle(.plain).placed(21, 325, 367, 78)
            HStack(spacing: 6) {
                Asset(name: "P34Info").frame(width: 14, height: 14)
                Text("Rules based on the official Splendor base-game structure. Have questions? →")
                    .font(.dm(7.6)).foregroundStyle(Color(hex: 0x625769))
            }.placed(24, 418, 354, 17)
        }
    }

    private var achievements: some View {
        HStack(spacing: 21) {
            badge("P34BadgeTutor", "Tutor Graduate", Color(hex: 0xDDEBFA))
            badge("P34BadgeTable", "Table Regular", Color(hex: 0x2F8576))
            badge("P34BadgeMerchant", "Gem Merchant", Color(hex: 0xE9E0F5))
            badge("P34BadgeNoble", "Noble Patron", Color(hex: 0xF4E1E6))
        }.frame(width: 360)
    }

    private func badge(_ icon: String, _ name: String, _ color: Color) -> some View {
        VStack(spacing: 3) {
            ZStack {
                RoundedRectangle(cornerRadius: 11).fill(color).rotationEffect(.degrees(45))
                Asset(name: icon).frame(width: 15.224, height: 15.224)
            }.frame(width: 36.157, height: 36.157)
            Text(name).font(.dm(5.7)).foregroundStyle(Palette.blueInk)
        }
            .frame(width: 68)
    }
}

private struct SetupScreen: View {
    let go: (Screen) -> Void
    var body: some View {
        ZStack(alignment: .topLeading) {
            Asset(name: "P34SetupBackground", mode: .fill)
                .frame(width: 402, height: 874).clipped()
            Color.white.opacity(0.80).frame(width: 402, height: 874)
            BackButton { go(.detail) }.placed(17, 67, 38, 38)
            Asset(name: "P34SetupBox", mode: .fill)
                .frame(width: 228, height: 228).clipped().clipShape(RoundedRectangle(cornerRadius: 42))
                .position(x: 201, y: 314)
            VStack(spacing: 12) { Text("Setup").font(.dm(28, .bold)); Text("Do you need set up instruction?").font(.dm(14)).foregroundStyle(Color(hex: 0x68756D)) }
                .foregroundStyle(Palette.blue).placed(24, 433, 354, 73, alignment: .top)
            Button { go(.setupGuide) } label: { HStack { Text("Yes, let’s go setup"); Asset(name: "P34Forward").frame(width: 18, height: 18) }.font(.dm(16, .bold)).foregroundStyle(.white).frame(width: 354, height: 48).background(Palette.blue).clipShape(RoundedRectangle(cornerRadius: 12)) }.buttonStyle(.plain).placed(24, 520, 354, 48)
            Button { go(.invite) } label: { Text("Skip setup").font(.dm(16, .bold)).foregroundStyle(Palette.blue).frame(width: 354, height: 48).background(.white).clipShape(RoundedRectangle(cornerRadius: 12)).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: 0xDDD8CA))) }.buttonStyle(.plain).placed(24, 578, 354, 48)
        }.frame(width: 402, height: 874)
    }
}

private struct SetupGuideScreen: View {
    let go: (Screen) -> Void
    private let steps = [
        ("1", "Sort the gems", "Place each gem color in a separate pile within everyone’s reach."),
        ("2", "Build the market", "Reveal four development cards from each level."),
        ("3", "Place the nobles", "Reveal one more noble tile than the number of players.")
    ]

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(hex: 0xF3F7FC)
            BackButton { go(.setup) }.placed(17, 67, 38, 38)
            GameIdentity().placed(43, 116, 300, 116)
            VStack(alignment: .leading, spacing: 6) {
                Text("Set up Splendor").font(.dm(29, .bold)).foregroundStyle(Palette.blueInk)
                Text("Prepare the table before inviting everyone in.").font(.dm(13)).foregroundStyle(Palette.mutedBlue)
            }.placed(24, 244, 354, 67)

            VStack(spacing: 12) {
                ForEach(steps, id: \.0) { step in
                    HStack(alignment: .top, spacing: 13) {
                        Text(step.0).font(.dm(13, .bold)).foregroundStyle(.white)
                            .frame(width: 30, height: 30).background(Palette.blue).clipShape(Circle())
                        VStack(alignment: .leading, spacing: 3) {
                            Text(step.1).font(.dm(15, .bold)).foregroundStyle(Palette.blueInk)
                            Text(step.2).font(.dm(10.5)).foregroundStyle(Palette.mutedBlue).fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(15)
                    .frame(width: 354, height: 96, alignment: .topLeading)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: 0xD6E3F1)))
                }
            }.placed(24, 330, 354, 312)

            Button { go(.invite) } label: {
                HStack { Text("Invite players"); Asset(name: "P34Forward").frame(width: 18, height: 18) }
                    .font(.dm(16, .bold)).foregroundStyle(.white)
                    .frame(width: 354, height: 50).background(Palette.blue).clipShape(RoundedRectangle(cornerRadius: 12))
            }.buttonStyle(.plain).placed(24, 790, 354, 50)
        }.frame(width: 402, height: 874)
    }
}

private struct GameIdentity: View {
    var coverOffset: CGSize = .zero
    var body: some View {
        HStack(spacing: 24) {
            GameCover(name: "P34SplendorCover").frame(width: 66, height: 79).rotationEffect(.degrees(-10.86))
                .offset(x: coverOffset.width, y: coverOffset.height)
            VStack(alignment: .leading, spacing: 2) { Text("Splendor").font(.dm(25.86, .bold)); Text("Standard game").font(.dm(12.37)).foregroundStyle(Palette.mutedBlue) }
        }.foregroundStyle(Palette.blueInk)
    }
}

private struct StepTitle: View {
    let number: String
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(number).font(.dm(12.5, .bold)).foregroundStyle(.white).frame(width: 27, height: 27).background(Palette.orange).clipShape(Circle())
            Text(title).font(.dm(29, .bold)).foregroundStyle(number == "1" ? Palette.blueInk : Color(hex: 0x173C36))
            Text(subtitle).font(.dm(15)).foregroundStyle(Color(hex: 0x476059))
        }
    }
}

private struct InviteScreen: View {
    let go: (Screen) -> Void
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.white
            BackButton { go(.setup) }.placed(14, 67, 38, 38)
            GameIdentity(coverOffset: CGSize(width: -31, height: -35)).placed(74, 161, 252, 110)
            StepTitle(number: "1", title: "Invite your friends", subtitle: "Waiting for players.").placed(70, 279, 324, 126)
            Text("Room").font(.dm(9.1, .bold)).foregroundStyle(Palette.mutedBlue).placed(34, 385, 50, 12)
            table.placed(35, 412, 322, 126)
            playerRows.placed(34, 550, 325, 171)
            HStack(alignment: .top, spacing: 10) { Asset(name: "P34Players").frame(width: 16, height: 18); VStack(alignment: .leading, spacing: 2) { Text("You are the host").font(.dm(9, .medium)); Text("Keep this phone open to ensure everyone join the room.\nStart this game when everyone is ready.").font(.dm(9)).lineSpacing(2) } }.foregroundStyle(Palette.mutedBlue).placed(43, 730, 310, 54)
            Button { go(.first) } label: { HStack { Text("Next Step"); Asset(name: "P34Forward").frame(width: 18, height: 18) }.font(.dm(16, .bold)).foregroundStyle(.white).frame(width: 352, height: 50).background(Palette.blue).clipShape(RoundedRectangle(cornerRadius: 12)).shadow(color: .black.opacity(0.14), radius: 8, y: 5) }.buttonStyle(.plain).placed(20, 804, 352, 50)
        }.frame(width: 392, height: 874)
    }

    private var table: some View {
        ZStack {
            Asset(name: "P34Table").frame(width: 322, height: 126)
            Asset(name: "P34Felt").frame(width: 294, height: 97)
            Text("Waiting...").font(.dm(15, .bold)).foregroundStyle(.white).offset(y: 1)
            Text("Minimum player reached").font(.dm(7)).foregroundStyle(.white.opacity(0.75)).offset(y: 19)
            seat("MC", "Maya", 0, -52, 98)
            seat("JL", "Jordan", -113, 0, 87)
            seat("A", "You", 0, 51, 98)
            HStack(spacing: 4) { Text("+").font(.dm(13)); Text("Open seat").font(.dm(11, .medium)) }.foregroundStyle(.white).padding(.horizontal, 8).frame(height: 27).overlay(Capsule().stroke(.white.opacity(0.7), style: StrokeStyle(lineWidth: 1, dash: [3]))).offset(x: 104)
        }
    }

    private func seat(_ initials: String, _ name: String, _ x: CGFloat, _ y: CGFloat, _ width: CGFloat) -> some View {
        HStack(spacing: 5) { Text(initials).font(.dm(9, .medium)).frame(width: 24, height: 24).background(Color(hex: 0xE5EFFB)).clipShape(Circle()); Text(name).font(.dm(11, .bold)); Spacer(minLength: 0) }
            .foregroundStyle(Color(hex: 0x243C38)).padding(.horizontal, 4).frame(width: width, height: 30).background(Color(hex: 0xFFF8E9)).clipShape(Capsule()).overlay(Capsule().stroke(Color(hex: 0xDBB985))).offset(x: x, y: y)
    }

    private var playerRows: some View {
        VStack(spacing: 0) {
            player("JL", "Jordan Lee", "@jordanlee", "Joining ...", false)
            player("SR", "Sam Rivera", "@samrivera", "Joined ✓", true)
            player("MC", "Maya Chen", "@mayachen", "Joined ✓", true)
        }
    }

    private func player(_ initials: String, _ name: String, _ handle: String, _ status: String, _ joined: Bool) -> some View {
        HStack(spacing: 10) { Text(initials).font(.dm(9, .medium)).foregroundStyle(Color(hex: 0x447569)).frame(width: 34, height: 34).background(Color(hex: 0xE5EFFB)).clipShape(Circle()); VStack(alignment: .leading, spacing: 1) { Text(name).font(.dm(11, .bold)); Text(handle).font(.dm(8)).foregroundStyle(Color(hex: 0x66716C)) }; Spacer(); Text(status).font(.dm(10, .bold)).foregroundStyle(joined ? Color(hex: 0x26533E) : .white).frame(width: 100, height: 29).background(joined ? Color(hex: 0xDCE6D8) : Palette.blue).clipShape(RoundedRectangle(cornerRadius: 9)) }.frame(height: 57).overlay(alignment: .bottom) { Rectangle().fill(Color(hex: 0xDDD8CA)).frame(height: 1) }
    }
}

private struct FirstPlayerScreen: View {
    let go: (Screen) -> Void
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.white
            BackButton { go(.invite) }.placed(14, 67, 38, 38)
            GameIdentity().placed(43, 132, 300, 116)
            StepTitle(number: "2", title: "Who goes first?", subtitle: "Draw one card to find out who starts.").placed(39, 256, 340, 112)
            Button { go(.ready) } label: { Asset(name: "P34CardBack", mode: .fill).clipped().clipShape(RoundedRectangle(cornerRadius: 14)).shadow(color: Color(hex: 0x1A304A, opacity: 0.23), radius: 9, y: 8) }.buttonStyle(.plain).placed(136, 421, 132, 162)
            Text("Tap to draw").font(.dm(13)).foregroundStyle(Color(hex: 0x68756D)).placed(140, 651, 122, 24, alignment: .center)
        }.frame(width: 402, height: 874)
    }
}

private struct ReadyScreen: View {
    let go: (Screen) -> Void
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.white
            BackButton { go(.first) }.placed(14, 67, 38, 38)
            GameIdentity().placed(43, 124, 300, 116)
            StepTitle(number: "3", title: "All set to go!", subtitle: "View your play order here").placed(39, 248, 340, 111)
            ZStack(alignment: .topLeading) {
                Asset(name: "P34OrderMiddle", mode: .fill)
                    .frame(width: 130, height: 180).clipped()
            }
            .frame(width: 130, height: 180).clipped().clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.28), lineWidth: 1))
            .shadow(color: Color(hex: 0x1A304A, opacity: 0.23), radius: 8, y: 8)
            .position(x: 206, y: 465)
            Text("You are the 1st").font(.dm(9.8, .bold)).foregroundStyle(Color(hex: 0x235047)).frame(width: 185, height: 25).background(Color(hex: 0xE6EFE9)).clipShape(Capsule()).placed(110, 568, 185, 25)
            Text("Full orders").font(.dm(11, .bold)).tracking(0.7).foregroundStyle(Color(hex: 0x68756D)).placed(150, 634, 102, 18, alignment: .center)
            HStack(spacing: 19) { order("A", "You", "1st", Color(hex: 0xD8E6F7), Color(hex: 0x203B62)); order("MC", "Maya", "3rd", Color(hex: 0xDCEBD8), Color(hex: 0x26533E)); order("JL", "Jordan", "2nd", Color(hex: 0xFFF8E9), Color(hex: 0x62421D)) }.placed(39, 660, 335, 34)
            Button { go(.horizontal) } label: { HStack { Text("All set? Let’s Start!"); Asset(name: "P34Right").frame(width: 18, height: 18) }.font(.dm(16, .bold)).foregroundStyle(Palette.brown).frame(width: 352, height: 50).background(Palette.yellow).clipShape(RoundedRectangle(cornerRadius: 12)).shadow(color: .black.opacity(0.12), radius: 8, y: 5) }.buttonStyle(.plain).placed(25, 803, 352, 50)
        }.frame(width: 402, height: 874)
    }

    private func order(_ initials: String, _ name: String, _ place: String, _ bg: Color, _ fg: Color) -> some View {
        HStack(spacing: 6) { Text(initials).font(.dm(9)).frame(width: 24, height: 24).background(bg).clipShape(Circle()); Text(name).font(.dm(10, .bold)); Text(place).font(.dm(10, .bold)) }.foregroundStyle(fg).padding(.horizontal, 5).frame(height: 34).background(Color.white).clipShape(Capsule()).overlay(Capsule().stroke(fg.opacity(0.65)))
    }
}

private struct HorizontalPrompt: View {
    let go: (Screen) -> Void
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.white
            BackButton { go(.ready) }.placed(14, 67, 38, 38)
            RoundedRectangle(cornerRadius: 24).stroke(Color(hex: 0xFAF9F5), lineWidth: 1).placed(26, 234, 341, 236)
            AnimatedGIF(resource: "HorizontalTurn").placed(66, 249, 260, 206)
            Text("Turn your phone sideways to\nstart the game.").font(.dm(26.495, .bold)).tracking(-1.27).lineSpacing(1).multilineTextAlignment(.center).foregroundStyle(Palette.blueInk).placed(25, 475, 342, 70, alignment: .center)
        }.frame(width: 392, height: 874)
    }
}

private struct LandscapeActionScreen: View {
    @State private var selectedAction: ActionChoice?
    @State private var showingQuestion = false

    private enum ActionChoice: String {
        case gem = "Get a gem"
        case card = "Trade a card"

        var instruction: String {
            switch self {
            case .gem:
                return "Take three gems of different colors, or two gems of the same color when at least four remain."
            case .card:
                return "Choose a development card you can afford, return its gem cost, and place the card in front of you."
            }
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Asset(name: "P34SetupBackground", mode: .fill)
                .frame(width: 874, height: 402).clipped().blur(radius: 18).scaleEffect(1.08)
            Color(hex: 0x0B2E52, opacity: 0.56)

            VStack(alignment: .leading, spacing: 4) {
                Text("Choose your action").font(.dm(27, .bold)).foregroundStyle(.white)
                Text("Splendor · Your turn").font(.dm(11, .medium)).foregroundStyle(.white.opacity(0.72))
            }.placed(42, 26, 360, 58)

            HStack(spacing: 18) {
                actionCard(.gem, asset: "P34BadgeMerchant")
                actionCard(.card, asset: "P34CardBack")
            }.placed(42, 102, 470, 184)

            if let selectedAction {
                VStack(alignment: .leading, spacing: 10) {
                    Text(selectedAction.rawValue).font(.dm(21, .bold)).foregroundStyle(Palette.blueInk)
                    Text(selectedAction.instruction).font(.dm(12)).lineSpacing(3).foregroundStyle(Color(hex: 0x49677F))
                    Text("Tap the other option any time to compare.").font(.dm(9, .medium)).foregroundStyle(Palette.mutedBlue)
                }
                .padding(19)
                .frame(width: 292, height: 184, alignment: .topLeading)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.55)))
                .placed(540, 102, 292, 184)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pick one to continue").font(.dm(20, .bold))
                    Text("Detailed instructions appear here after you select an action.").font(.dm(12)).lineSpacing(3)
                }
                .foregroundStyle(.white)
                .padding(19)
                .frame(width: 292, height: 184, alignment: .topLeading)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.4)))
                .placed(540, 102, 292, 184)
            }

            Button { showingQuestion = true } label: {
                Text("Ask a question  ↑").font(.dm(12, .bold)).foregroundStyle(Palette.blueInk)
                    .frame(width: 180, height: 42)
                    .background(.ultraThinMaterial)
                    .clipShape(Trapezoid())
                    .overlay(Trapezoid().stroke(.white.opacity(0.65)))
            }
            .buttonStyle(.plain)
            .placed(347, 346, 180, 42)
        }
        .frame(width: 874, height: 402)
        .sheet(isPresented: $showingQuestion) { QuestionComposer() }
    }

    private func actionCard(_ choice: ActionChoice, asset: String) -> some View {
        Button { selectedAction = choice } label: {
            VStack(spacing: 10) {
                Asset(name: asset, mode: .fit).frame(width: choice == .gem ? 54 : 46, height: 58)
                Text(choice.rawValue).font(.dm(16, .bold))
                Text(choice == .gem ? "Collect tokens" : "Buy a development")
                    .font(.dm(9.5)).foregroundStyle(Palette.mutedBlue)
            }
            .foregroundStyle(Palette.blueInk)
            .frame(width: 226, height: 184)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(selectedAction == choice ? Color(hex: 0xB9F04A) : .white.opacity(0.55), lineWidth: selectedAction == choice ? 3 : 1))
        }.buttonStyle(.plain)
    }
}

private struct QuestionComposer: View {
    @Environment(\.dismiss) private var dismiss
    @State private var question = ""
    @State private var showingVoiceNotice = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Ask a question").font(.dm(23, .bold)).foregroundStyle(Palette.blueInk)
                Spacer()
                Button("Done") { dismiss() }.font(.dm(14, .bold))
            }
            Text("Type your question or choose voice input.").font(.dm(12)).foregroundStyle(Palette.mutedBlue)
            TextField("What would you like to know?", text: $question, axis: .vertical)
                .font(.dm(15)).padding(14).frame(minHeight: 54)
                .background(Color(hex: 0xEEF4FA)).clipShape(RoundedRectangle(cornerRadius: 14))
            HStack(spacing: 12) {
                Button("Use voice") { showingVoiceNotice = true }
                    .font(.dm(14, .bold)).foregroundStyle(Palette.blue)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Palette.blue))
                Button("Send") { dismiss() }
                    .font(.dm(14, .bold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Palette.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            Spacer()
        }
        .padding(24)
        .presentationDetents([.medium])
        .alert("Voice input", isPresented: $showingVoiceNotice) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Microphone transcription will be connected when the speech service is enabled. Text input is available now.")
        }
    }
}

private struct Trapezoid: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.width * 0.12, y: 0))
            path.addLine(to: CGPoint(x: rect.width * 0.88, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.closeSubpath()
        }
    }
}

private struct AnimatedGIF: UIViewRepresentable {
    let resource: String
    func makeUIView(context: Context) -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.image = Self.load(resource)
        return view
    }
    func updateUIView(_ uiView: UIImageView, context: Context) {}

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIImageView, context: Context) -> CGSize? {
        CGSize(width: proposal.width ?? 260, height: proposal.height ?? 206)
    }

    private static func load(_ name: String) -> UIImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "gif"),
              let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let count = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var duration = 0.0
        for index in 0..<count {
            guard let image = CGImageSourceCreateImageAtIndex(source, index, nil) else { continue }
            images.append(UIImage(cgImage: image))
            let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any]
            let gif = properties?[kCGImagePropertyGIFDictionary] as? [CFString: Any]
            duration += gif?[kCGImagePropertyGIFUnclampedDelayTime] as? Double
                ?? gif?[kCGImagePropertyGIFDelayTime] as? Double ?? 0.1
        }
        guard !images.isEmpty else { return nil }
        if UIAccessibility.isReduceMotionEnabled || ProcessInfo.processInfo.arguments.contains("--freeze-motion") {
            return images.first
        }
        return UIImage.animatedImage(with: images, duration: max(duration, 0.1))
    }
}
