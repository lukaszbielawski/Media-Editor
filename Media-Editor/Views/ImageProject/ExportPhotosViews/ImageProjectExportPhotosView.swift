//
//  ImageProjectExportPhotosView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 27/02/2024.
//

import SwiftUI

struct ImageProjectExportPhotosView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @State var pickerFormatValue: PhotoFormatType = .png
    @State var pickerRenderSizeValue: RenderSizeType = .raw

    var body: some View {
        VStack {
            Text("Export your photos")
                .padding()
                .font(.custom("Kaushan Script", size: 32))
                .foregroundStyle(Color(.tint))
            if let previewPhoto = vm.previewPhoto,
               let marginedWorkspaceSize = vm.marginedWorkspaceSize
            {
                Image(decorative: previewPhoto, scale: 1.0)
                    .resizable()
                    .border(Color(.secondary), width: 1)
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: marginedWorkspaceSize.width, maxHeight: marginedWorkspaceSize.width)
                    .shadow(radius: 10.0)
            }
            Form {
                Section {
                    Picker("Format", selection: $pickerFormatValue) {
                        ForEach(PhotoFormatType.allCases, id: \.self) { formatType in
                            Text(formatType.toString)
                        }
                    }
                    .padding(.vertical, 8.0)
                    .pickerStyle(.segmented)
                } header: {
                    Text("Image Format")
                        .foregroundStyle(Color(.tint))
                }
                Section {
                    Picker("Size", selection: $pickerRenderSizeValue) {
                        ForEach(RenderSizeType.allCases, id: \.self) { renderSizeType in
                            Text(renderSizeType.toString)
                        }
                    }
                    .padding(.vertical, 8.0)
                    .pickerStyle(.segmented)
                } header: {
                    Text("Render Size")
                        .foregroundStyle(Color(.tint))
                }
                Section {
                    Button {
                        Task {
                            await vm.renderPhoto(renderSize: pickerRenderSizeValue, photoFormat: pickerFormatValue)
                        }
                    } label: {
                        Text("Export image")
                    }.foregroundStyle(Color(.image))
                } header: {
                    Text("Export")
                        .foregroundStyle(Color(.tint))
                }
            }
            .modifier(FormHiddenBackground())
            Spacer()
        }
        .task {
            await vm.renderPhoto(renderSize: .preview)
        }
    }
}
