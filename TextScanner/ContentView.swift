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
                self.recognizedTexts = [String]()
            }, label: {
                HStack {
                    Image(systemName: "camera")
                    Text("Re-take picture")
                }
            })
            
            List {
                ForEach(self.recognizedTexts, id: \.self) {
                    Text("\($0)")
                }
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
}
