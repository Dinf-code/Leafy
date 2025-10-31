//
//  IdentifyView.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-10-31.
//
import SwiftUI
import AVFoundation
import Combine

struct IdentifyView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = IdentifyViewModel()
    @StateObject private var cameraManager = CameraManager()
    @Environment(\.dismiss) private var dismiss

    @State private var showImagePicker = false
    @State private var capturedImage: UIImage?
    @State private var showPlantDetail = false

    var body: some View {
        NavigationStack {
            ZStack {
                cameraBackground
                gradientOverlays
                
                VStack {
                    // Top bar
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 3)
                        }
                        .padding()
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Center instruction
                    if !vm.isLoading {
                        Text("Position the plant in frame to identify")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 4)
                    }
                    
                    Spacer()
                    
                    // Bottom toolbar
                    bottomToolbar
                        .padding(.bottom, 40)
                }
                
                loadingOverlay
                errorBanner
            }
            .onAppear { cameraManager.startSession() }
            .onDisappear { cameraManager.stopSession() }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $capturedImage)
            }
            .onChange(of: capturedImage) { img in
                if let image = img { processImage(image) }
            }
            .onChange(of: vm.result) { result in
                if result != nil { showPlantDetail = true }
            }
            // Navigation flow
            .navigationDestination(isPresented: $showPlantDetail) {
                if let plant = vm.result {
                    if appState.isGuest {
                        GuestPlantDetailView(plant: plant)
                            .environmentObject(appState)
                    } else {
                        RegisteredPlantDetailView(plant: plant)
                            .environmentObject(appState)
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - UI Components

    private var cameraBackground: some View {
        CameraPreviewView(cameraManager: cameraManager)
            .background(Color.black)
            .ignoresSafeArea()
    }

    private var gradientOverlays: some View {
        VStack {
            LinearGradient(colors: [Color.black.opacity(0.5), .clear],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 150)
            Spacer()
            LinearGradient(colors: [.clear, Color.black.opacity(0.5)],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 200)
        }
        .ignoresSafeArea()
    }

    private var bottomToolbar: some View {
        HStack(spacing: 40) {
            // Flash
            Button(action: { cameraManager.toggleFlash() }) {
                VStack(spacing: 4) {
                    Image(systemName: cameraManager.flashMode == .on ? "bolt.fill" : "bolt.slash.fill")
                        .font(.title2)
                    Text("Flash").font(.caption)
                }.foregroundColor(.white.opacity(vm.isLoading ? 0.4 : 1))
            }
            .disabled(vm.isLoading)

            // Capture
            Button(action: capturePhoto) {
                ZStack {
                    Circle()
                        .stroke(vm.isLoading ? Color.gray : Color.white, lineWidth: 4)
                        .frame(width: 72, height: 72)
                    Circle()
                        .fill(vm.isLoading ? Color.gray : Color.white)
                        .frame(width: 60, height: 60)
                }
            }
            .disabled(vm.isLoading)

            // Gallery
            Button(action: { showImagePicker = true }) {
                VStack(spacing: 4) {
                    Image(systemName: "photo.on.rectangle").font(.title2)
                    Text("Gallery").font(.caption)
                }
                .foregroundColor(.white.opacity(vm.isLoading ? 0.4 : 1))
            }
            .disabled(vm.isLoading)
        }
        .animation(.easeInOut(duration: 0.3), value: vm.isLoading)
    }

    private var loadingOverlay: some View {
        Group {
            if vm.isLoading {
                ZStack {
                    Color.black.opacity(0.8).ignoresSafeArea()
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Text("Analyzing your plant…")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .transition(.opacity)
            }
        }
    }

    private var errorBanner: some View {
        Group {
            if let error = vm.errorMessage {
                VStack {
                    Spacer()
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.white)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.red.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .padding(.bottom, 120)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: vm.errorMessage)
    }

    // MARK: - Actions

    private func capturePhoto() {
        cameraManager.capturePhoto { image in
            if let image = image { processImage(image) }
        }
    }

    private func processImage(_ image: UIImage) {
        Task { await vm.identify(image: image) }
    }
}

// MARK: - Camera Manager / Preview / ImagePicker

final class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var photoCompletion: ((UIImage?) -> Void)?
    var previewLayer: AVCaptureVideoPreviewLayer?

    override init() {
        super.init()
        setupCamera()
    }

    private func setupCamera() {
        session.beginConfiguration()
        session.sessionPreset = .photo
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.isHighResolutionCaptureEnabled = true
        }
        session.commitConfiguration()
    }

    func startSession() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { self.session.startRunning() }
    }

    func stopSession() {
        guard session.isRunning else { return }
        session.stopRunning()
    }

    func toggleFlash() {
        flashMode = (flashMode == .on ? .off : .on)
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode
        photoCompletion = completion
        output.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            photoCompletion?(nil)
            return
        }
        photoCompletion?(image)
    }
}

struct CameraPreviewView: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager

    func makeUIView(context: Context) -> UIView {
        let v = UIView(frame: .zero)
        let layer = AVCaptureVideoPreviewLayer(session: cameraManager.session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = v.bounds
        v.layer.addSublayer(layer)
        cameraManager.previewLayer = layer
        return v
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            (uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer)?.frame = uiView.bounds
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let img = info[.originalImage] as? UIImage { parent.image = img }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    IdentifyView()
        .environmentObject(AppState())
}
