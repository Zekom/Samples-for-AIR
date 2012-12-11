Photo Editor Sample

========================================================================
Sample Description.

The Photo Editor sample is a simple application to show you how to create and interact with Composer, Previewer, and Picker Cards.
The main application and all 3 cards are bundled into the same application. You would not want to create an application that uses its own cards,
but setting it up this way helps illustrate the point without having multiple applications.

The picker card is used to display a list of images from the camera folder on the device. Before running the sample, make sure to use the camera to take some pictures.
The composer card is used to tint the selected image by adjusting the red/green/blue channels.
The previewer card is used to view the edited image. It also uses the Invoke Framework to display a list of invokable targets to use with the image.

The imagesaver.ane file is a compiled ane from the following Community Sample. https://github.com/blackberry/Community-APIs-for-AIR/tree/master/BlackBerry10/ImageSaver
It is used to save the altered image to disk before passing the file path to the invoked target.

You will learn:
 - How to create and interact with a Picker, Composer, and Previewer Card.
 - How to query invokable targets on the device.

========================================================================
Requirements:

BlackBerry 10 SDK for Adobe AIR

========================================================================
Running the example:

The project files contained in the repository are for FDT 5.5. http://fdt.powerflasher.com/
In FDT select File > Import and select the root folder.