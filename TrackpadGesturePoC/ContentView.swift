import SwiftUI

struct ContentView: View {
    @StateObject private var gestureListener = GestureListener()
    @State private var detectedGestures: [String] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("トラックパッドジェスチャ検出 PoC")
                .font(.title)
                .padding()
            
            HStack {
                Button("開始") {
                    gestureListener.startListening()
                }
                .disabled(gestureListener.isListening)
                
                Button("停止") {
                    gestureListener.stopListening()
                }
                .disabled(!gestureListener.isListening)
            }
            
            Text("状態: \(gestureListener.isListening ? "検出中" : "停止中")")
                .foregroundColor(gestureListener.isListening ? .green : .red)
            
            Divider()
            
            Text("検出されたジェスチャ:")
                .font(.headline)
            
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(detectedGestures.indices, id: \.self) { index in
                        Text("\(index + 1). \(detectedGestures[index])")
                            .padding(.vertical, 2)
                    }
                }
            }
            .frame(maxHeight: 200)
            .border(Color.gray, width: 1)
            
            Button("ログクリア") {
                detectedGestures.removeAll()
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 500)
        .onReceive(gestureListener.$lastGesture) { gesture in
            if let gesture = gesture {
                let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
                detectedGestures.append("[\(timestamp)] \(gesture)")
            }
        }
    }
}