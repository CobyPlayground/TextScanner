//
//  ContentView.swift
//  TextScanner
//
//  Created by Coby Kim on 4/4/24.
//

import SwiftUI
import Vision

struct ContentView: View {
    
    @State private var cameraOpen = false
    @State private var imageTaken: UIImage?
    @State private var recognizedTexts = [String]()
    @State private var isLoading = false
    
    // 카드 스캔
    @State private var cardNumber: String = ""
    @State private var validDate: String = ""
    
    func recognizeCardText() {
        print("reading text ")
        
        let requestHandler = VNImageRequestHandler(cgImage: self.imageTaken!.cgImage!)
        
        let recognizeTextRequest = VNRecognizeTextRequest { (request, error) in
            // 1. Parse the results
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            // 2. Extract the data you want
            for observation in observations {
                let recognizedText = observation.topCandidates(1).first!.string
                self.recognizedTexts.append(recognizedText)
                
                if self.isCardFormat(recognizedText) {
                    self.cardNumber = recognizedText
                }
                
                if self.isValidDate(recognizedText) {
                    self.validDate = recognizedText
                }
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([recognizeTextRequest])
                self.isLoading = false
            } catch {
                print(error)
            }
        }
    }
    
    var pictureTakenView: some View {
        VStack {
            Image(uiImage: self.imageTaken!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            
            Button(action: {
                self.imageTaken = nil
                self.cardNumber = ""
                self.validDate = ""
                self.recognizedTexts = [String]()
            }, label: {
                HStack {
                    Image(systemName: "camera")
                    Text("Re-take picture")
                }
            })
            
            List {
//                ForEach(self.recognizedTexts, id: \.self) {
//                    Text("\($0)")
//                }
                Text("카드번호: \(self.cardNumber)")
                Text("유효기간: \(self.validDate)")
            }
        }
    }
    
    var body: some View {
        VStack {
            if self.imageTaken == nil {
                CameraView(image: self.$imageTaken)
            } else {
                if !self.isLoading {
                    self.pictureTakenView
                        .onAppear {
                            self.recognizeCardText()
                        }
                } else {
                    ProgressView()
                }
            }
        }
    }
    
    // 카드번호 판단
    func isCardFormat(_ text: String) -> Bool {
        let pattern = "^\\d{4} \\d{4} \\d{4} \\d{4}$"
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: text.utf16.count))
        return matches.count > 0
    }
    
    // 유효기간 판단
    func isValidDate(_ text: String) -> Bool {
        let pattern = "^\\d{2}/\\d{2}$"
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: text.utf16.count))
        return matches.count > 0
    }
}
