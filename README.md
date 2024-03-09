# Media-Editor





The Media Editor app is a versatile tool for editing photos, built with SwiftUI, CoreData, CoreGraphics, Swift Concurrency, CoreImage, PhotoKit and Combine frameworks. It empowers users to manipulate images with ease, offering a range of editing features.

<h2>Features</h2>

* <b>Project Management</b>: Create and manage multiple projects.
* <b>Layer Manipulation</b>: Easily manipulate multiple layers within a project by relocating, resizing, rotating, and flipping them.
* <b>Filters</b>: Apply a wide range of filters to individual layers to enhance or modify their appearance.
* <b>Cropping and Clipping</b>: Crop layers to remove unnecessary parts of picture. Additionally, you can clip layers into various shapes such as ellipses or hexagons.
* <b>Merging</b>: Combine multiple layers into a single layer, simplifying your project.
* <b>Background Editing</b>: Resize the background canvas and change its color to suit your preferences.
* <b>Auto-save Feature</b>: Your progress is automatically saved to ensure you never lose your work.
* <b>Undo/Redo</b>: Seamlessly revert or reapply changes with the undo and redo feature.
* <b>Exporting</b>: Export the final edited media content in format of choice to your device's photo library.
  
<h2>Presentation</h2>


https://github.com/lukaszbielawski/Media-Editor/assets/44624897/67cc5fef-33ce-44bf-822d-73de08933b9e




<h2>Requirements</h2>

* Xcode 13.0+
* Swift 5.5+
* iOS/iPadOS 15.0+

<h2>Installation</h2>

1. Clone the repository:

```bash
git clone https://github.com/lukaszbielawski/Media-Editor
```

2. Open the project in Xcode.
3. Build and run the app on a simulator or a physical device running iOS 15.0 or later.

<h2>Usage</h2>

<h3>Project Creation</h3>

1. Launch the Media Editor app on your device.
2. Click <i>Plus</i> icon to display a menu from which you can select images to start your project with.
3. Slide the slider to create a new project with the currently selected images.

<h3>Project Management</h3>

1. Launch the Media Editor app on your device.
2. Select the <i>Three dots</i> icon to open project options sheet.
3. You can change the current title of the project.
4. Create a new project or open an existing one to begin editing your media content.
5. Alternatively, you may remove the project from the disk.

<h3>Layer Manipulation</h3>

1. When you first encounter a project, the initially selected layer will be displayed.
1. Simply tap once on a layer to select it from the screen.
2. A dedicated frame will appear, enabling relocation, resizing, rotation, and deletion.

<h3>Filter Application</h3>

1. Tap once on a layer to select it from the screen.
2. Select the <i>Filters</i> tool option from the toolbar.
3. Explore a variety of filters available within the app to customize your media content.
4. Adjust the slider to modify the filter settings if possible.
5. A preview of the filter effect will be displayed.
6. Press <i>Checkmark</i> icon to save your filter, or choose to go back to discard it.

<h3>Cropping and Layer Resizing</h3>

1. Tap once on a layer to select it from the screen.
2. Select the <i>Crop</i> tool option from the toolbar.
3. Drag the cropping frame to select the part of the image you want to retain.
4. Resize the cropping frame to ensure that your crop size matches your desired dimensions.
5. You can drag the slider to set a fixed aspect ratio for the cropping frame, allowing you to retain the aspect ratio when resizing the frame.
6. You can change the clip shape from the default rectangle to other shapes such as ellipses or hexagons.
7. Press the <i>Checkmark</i> icon to perform the crop, or choose to go back to discard it.

<h3>Layer Background Editing</h3>

1. Tap once on a layer to select it from the screen.
2. Select the <i>Background</i> tool option from the toolbar.
3. Customize the layer background color by choosing from a list of predefined colors or selecting a custom color using the system color picker.
4. You can adjust the opacity value using the slider.
5. A preview of the applied background color will be displayed.
6. Press the <i>Checkmark</i> icon to save the background color change, or choose to go back to discard it.

<h3>Flipping image</h3>

1. Tap once on a layer to select it from the screen.
2. Select the <i>Flip</i> tool option from the toolbar.
3. Select one of the two flipping options available, each corresponding to one axis.

<h3>Copying layer</h3>

1. Tap once on a layer to select it from the screen.
2. Select the <i>Copy</i> tool option from the toolbar.
3. The layer will be copied and become active for further manipulation.

<h3>Adding photo to project</h3>

1. Make sure that you do not have any layer selected, or deselect currently selected layer.
2. Select the <i>Add</i> tool option from the toolbar.
3. Click <i>Plus</i> icon to display a menu from which you can select images to add to your project.
4. After selecting images, tap on the icon of the image to display it on the screen.
5. Alternatively, you can press the </i>Trash</i> icon to remove it from the project.

<h3>Merging Layers</h3>

1. Make sure that you do not have any layer selected, or deselect currently selected layer.
2. Select the <i>Merge</i> tool option from the toolbar.
3. Select layers to merge by tapping them on the screen or choose from the list of available layers below.
4. Slide the slider to execute the merge operation.

<h3>Project Background Resizing</h3>

1. Make sure that you do not have any layer selected, or deselect currently selected layer.
2. Select the <i>Resize</i> tool option from the toolbar.
3. Adjust the background canvas size by manipulating dedicated sliders or by entering specific dimensions into the provided text fields.

<h3>Project Background Color</h3>

1. Make sure that you do not have any layer selected, or deselect currently selected layer.
2. Select the <i>Background</i> tool option from the toolbar
3. Customize the background color by choosing from a list of predefined colors or selecting a custom color using the system color picker.
4. You can adjust the opacity value using the slider.

<h3>Undo/Redo</h3>

1. Tap the <i>Undo</i> icon located at top of the screen to revert the most recent action.
2. Tap the <i>Redo</i> icon located at top of the screen to reapply the action that was previously undone.
3. Please note that when you exit a project, the undo/redo history will be lost.

<h3>Exporting</h3>

1. Tap the <i>Export</i> labeled button located at the top right of the screen to export layers to a file.
2. In the newly displayed view, you can see a preview of your artwork.
3. You can choose an image format for exporting.
4. You can select a smaller export size.
5. Press the export button to export the final result to the device's photo library.
6. You can continue editing a project.

<h2>License</h2>

<p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><a property="dct:title" rel="cc:attributionURL" href="https://github.com/lukaszbielawski/Media-Editor">Media-Editor</a> by <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://github.com/lukaszbielawski">Łukasz Bielawski</a> is licensed under <a href="http://creativecommons.org/licenses/by-nc-nd/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY-NC-ND 4.0</a></p>
