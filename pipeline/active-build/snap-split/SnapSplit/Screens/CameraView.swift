import SwiftUI
import AVFoundation
import Vision

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var capturedImage: UIImage?
    @State private var isProcessing = false
    @State private var showImagePicker = false
    var onScanComplete: (SplitSession) -> Void

    var body: some View {
        ZStack {
            Theme.Color.background
                .ignoresSafeArea()

            // Camera placeholder with receipt frame overlay
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button(action: {
                        Theme.Haptic.tap()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(.black.opacity(0.5)))
                    }

                    Spacer()

                    Text("Scan Receipt")
                        .font(Theme.Font.label())
                        .foregroundColor(.white)

                    Spacer()

                    // Flash toggle placeholder
                    Button(action: { Theme.Haptic.tap() }) {
                        Image(systemName: "bolt.slash.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(.black.opacity(0.5)))
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.top, Theme.Spacing.md)

                Spacer()

                // Camera preview area with receipt-shaped frame
                ZStack {
                    // Simulated camera background
                    RoundedRectangle(cornerRadius: Theme.Radius.medium)
                        .fill(Color.black.opacity(0.3))
                        .frame(maxWidth: .infinity)
                        .frame(height: 460)
                        .padding(.horizontal, Theme.Spacing.lg)

                    // Receipt-shaped scanning frame
                    RoundedRectangle(cornerRadius: Theme.Radius.medium)
                        .stroke(
                            isProcessing ? Theme.Color.accent : Theme.Color.primary,
                            lineWidth: 3
                        )
                        .frame(width: 260, height: 400)
                        .animation(Theme.Anim.default, value: isProcessing)

                    // Scanning guide corners
                    VStack {
                        HStack {
                            ScanCorner(rotation: 0)
                            Spacer()
                            ScanCorner(rotation: 90)
                        }
                        Spacer()
                        HStack {
                            ScanCorner(rotation: 270)
                            Spacer()
                            ScanCorner(rotation: 180)
                        }
                    }
                    .frame(width: 270, height: 410)

                    if isProcessing {
                        VStack(spacing: Theme.Spacing.md) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Theme.Color.primary))
                                .scaleEffect(1.5)
                            Text("Reading receipt...")
                                .font(Theme.Font.label())
                                .foregroundColor(.white)
                        }
                    } else {
                        VStack(spacing: Theme.Spacing.sm) {
                            Image(systemName: "doc.text.viewfinder")
                                .font(.system(size: 48, weight: .thin))
                                .foregroundColor(Theme.Color.primary.opacity(0.6))
                            Text("Align receipt within frame")
                                .font(Theme.Font.caption())
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }

                Spacer()

                // Bottom controls
                HStack(spacing: Theme.Spacing.xl) {
                    // Photo library button
                    Button(action: {
                        Theme.Haptic.tap()
                        showImagePicker = true
                    }) {
                        VStack(spacing: Theme.Spacing.xs) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            Text("Library")
                                .font(Theme.Font.caption())
                                .foregroundColor(Theme.Color.textLight)
                        }
                    }

                    // Capture button
                    Button(action: {
                        Theme.Haptic.tap()
                        simulateScan()
                    }) {
                        ZStack {
                            Circle()
                                .stroke(Theme.Color.primary, lineWidth: 4)
                                .frame(width: 72, height: 72)
                            Circle()
                                .fill(Theme.Color.primary)
                                .frame(width: 60, height: 60)
                        }
                    }
                    .disabled(isProcessing)

                    // Demo receipt button
                    Button(action: {
                        Theme.Haptic.tap()
                        loadDemoReceipt()
                    }) {
                        VStack(spacing: Theme.Spacing.xs) {
                            Image(systemName: "list.clipboard")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            Text("Demo")
                                .font(Theme.Font.caption())
                                .foregroundColor(Theme.Color.textLight)
                        }
                    }
                }
                .padding(.bottom, Theme.Spacing.xl)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $capturedImage)
        }
        .onChange(of: capturedImage) { _, newImage in
            if let image = newImage {
                processImage(image)
            }
        }
    }

    private func simulateScan() {
        // In production, this would capture from the camera
        // For now, load a demo receipt
        loadDemoReceipt()
    }

    private func loadDemoReceipt() {
        isProcessing = true

        // Demo data simulating an OCR scan result
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let demoItems: [ReceiptItem] = [
                ReceiptItem(name: "Margherita Pizza", price: 16.99),
                ReceiptItem(name: "Caesar Salad", price: 12.50),
                ReceiptItem(name: "Pasta Carbonara", price: 18.99),
                ReceiptItem(name: "Grilled Salmon", price: 24.99),
                ReceiptItem(name: "Bruschetta", price: 10.99),
                ReceiptItem(name: "Tiramisu", price: 9.50),
                ReceiptItem(name: "Craft Beer", price: 8.00),
                ReceiptItem(name: "Glass of Wine", price: 12.00),
            ]

            let subtotal = demoItems.reduce(0) { $0 + $1.price }
            let session = SplitSession(
                date: Date(),
                restaurantName: "Demo Restaurant",
                items: demoItems,
                friends: [],
                subtotal: subtotal,
                tax: subtotal * 0.0875,
                tip: 0
            )

            isProcessing = false
            Theme.Haptic.success()
            onScanComplete(session)
            dismiss()
        }
    }

    private func processImage(_ image: UIImage) {
        isProcessing = true

        ReceiptScanner.scan(image: image) { result in
            let items = result.items.map { ReceiptItem(name: $0.name, price: $0.price) }
            let subtotal = result.subtotal ?? items.reduce(0) { $0 + $1.price }

            let session = SplitSession(
                date: Date(),
                restaurantName: "Scanned Receipt",
                items: items,
                friends: [],
                subtotal: subtotal,
                tax: result.tax ?? subtotal * 0.0875,
                tip: 0
            )

            isProcessing = false
            Theme.Haptic.success()
            onScanComplete(session)
            dismiss()
        }
    }
}

// MARK: - Scan Corner
struct ScanCorner: View {
    let rotation: Double

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 20))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 20, y: 0))
        }
        .stroke(Theme.Color.primary, lineWidth: 3)
        .frame(width: 20, height: 20)
        .rotationEffect(.degrees(rotation))
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
