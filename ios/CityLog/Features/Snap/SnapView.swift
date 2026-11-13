// Copyright © 2026 CityLog. All rights reserved.

import SwiftUI
import PhotosUI

struct SnapView: View {
    @StateObject var viewModel: SnapViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var pickedItem: PhotosPickerItem?
    @State private var showCamera = false

    var body: some View {
        let s = AppStrings.current
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Metrics.spacing) {
                    if !viewModel.isConfigured { banner(s.snapNotConfigured) }
                    photoArea(s)
                    TextField(s.snapQuestionPlaceholder, text: $viewModel.question, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                    Button(viewModel.isLoading ? s.snapThinking : s.snapAsk) {
                        Task { await viewModel.ask() }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!viewModel.canAsk)
                    .opacity(viewModel.canAsk ? 1 : 0.5)

                    if let error = viewModel.errorMessage {
                        Text(error).font(.footnote).foregroundStyle(Color.clError)
                    }
                    if let answer = viewModel.answer {
                        Card { Text(answer).font(.body).foregroundStyle(Color.clTextPrimary) }
                        Button(s.snapSave) { viewModel.save(); dismiss() }
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(Metrics.screenPadding)
            }
            .background(Color.clBackground)
            .navigationTitle(s.walkSnap)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button(s.cancel) { dismiss() } } }
        }
        .onChange(of: pickedItem) { loadPickedItem() }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker { image in viewModel.photoJPEG = ImageUtil.compactJPEG(image) }
                .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private func photoArea(_ s: AppStrings) -> some View {
        if let data = viewModel.photoJPEG, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))
        }
        HStack(spacing: 8) {
            if CameraPicker.isAvailable {
                Button { showCamera = true } label: { Label(s.snapCamera, systemImage: "camera") }
            }
            PhotosPicker(selection: $pickedItem, matching: .images) {
                Label(s.snapLibrary, systemImage: "photo.on.rectangle")
            }
        }
        .buttonStyle(.bordered)
    }

    private func banner(_ text: String) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(Color.clTextPrimary)
            .padding(Metrics.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.clWarningSurface)
            .clipShape(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))
    }

    private func loadPickedItem() {
        guard let pickedItem else { return }
        Task {
            guard let data = try? await pickedItem.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else { return }
            viewModel.photoJPEG = ImageUtil.compactJPEG(image)
        }
    }
}

/// 系统相机。模拟器没有相机时不显示入口。
struct CameraPicker: UIViewControllerRepresentable {
    static var isAvailable: Bool { UIImagePickerController.isSourceTypeAvailable(.camera) }

    let onImage: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage { parent.onImage(image) }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
