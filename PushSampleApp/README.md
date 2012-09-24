# Push Receiver Sample Application Description #

The Push Receiver sample application demonstrates how to write a BlackBerry 10 Adobe AIR application that is able to receive pushes. 

Consult the **net.rim.blackberry.push** package from the API reference for useful examples and a full description of how to use the
push APIs. The API reference can be found [here while in beta](https://developer.blackberry.com/air/beta/apis/) or, if no longer in beta,
[here](https://developer.blackberry.com/air/apis).

There is also a very valuable developer guide for this sample push-enabled application that you can find [here](https://developer.blackberry.com/air/beta/documentation/overview_air_1976130_11.html).

The developer guide offers the following topics:

1. An overview of push and the Push Service architecture
2. The requirements for creating a full push solution
3. How to setup Adobe Flash Builder 4.6 to work with the Push Receiver sample application (This is also described below.)
4. How to configure the sample application when it's loaded on your BlackBerry 10 device (This is also described below.)
5. Code samples to help you write your own push application using the BlackBerry 10 AIR SDK

The sample code for this application is Open Source under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html).


**Applies To**

* [BlackBerry 10 SDK for Adobe AIR Beta 3](https://developer.blackberry.com/air/beta/download/sdk)

**Author(s)** 

* [Matthew D'Andrea](https://github.com/mdandrea)
* [Marco Di Cesare](https://github.com/mdicesare)

**To contribute code to this repository you must be [signed up as an official contributor](http://blackberry.github.com/howToContribute.html).**

# How to Download

Download the source code as a zip from [here](https://developer.blackberry.com/air/beta/files/release/samples/PushServiceAIR_SampleApp.zip).
Unzip it locally to a folder named **PushReceiver** in a location of your choosing.

## How to Deploy

You can deploy the pre-compiled Push Receiver sample application by:

1. Take the provided **PushReceiver/PushReceiver.bar** and deploy it using blackberry-deploy (or blackberry-deploy.bat) available from your BlackBerry 10 SDK for Adobe AIR install:
Adobe-AIR-SDK-install-directory/bin/blackberry-deploy
2. Deploy the application using the following syntax:
``blackberry-deploy -installApp -password <device password> -device <IP_address> -package <BAR file path>/PushReceiver.bar``


## How to Build

The project files supplied are for Flash Builder 4.6 [http://www.adobe.com/products/flash-builder.html](http://www.adobe.com/products/flash-builder.html).
 
Note: You will need to first download the [BlackBerry 10 SDK for Adobe AIR Beta 3](https://developer.blackberry.com/air/beta/download/sdk).

You can import the existing project files in Adobe Flash Builder 4.6 and build/deploy it from there:

1. In Flash Builder select File > Import and select the **PushReceiver** folder. 
2. Run the **PushReceiver** project by right-clicking on the project and going to **Run As/Debug As > Mobile Application**.

Or, you can create a brand new project in Adobe Flash Builder 4.6 and build/deploy it from there, for example:

1. Start Adobe Flash Builder.
2. Click **File > New > ActionScript Mobile Project**.
3. In the Project Name field, type **PushReceiver**.
4. Clear the **Use default location** check box and browse to the **PushReceiver** folder you downloaded and unzipped above.  Also, make sure that the default SDK is the Adobe Flex SDK 4.6.
5. Click **Next**.
6. In the **Target platforms** list, select **BlackBerry**.
7. Click **Next**.
8. On the **Library path** tab, perform the following actions:
    1. Click **Add SWC**.
    2. Locate and add Adobe-AIR-SDK-install-directory\frameworks\libs\qnx\qnxui.swc, where Adobe-AIR-SDK-install-directory is the directory where the BlackBerry 10 SDK for Adobe AIR is installed.
    3. Click **Add SWC**.
    4. Locate and add Adobe-AIR-SDK-install-directory\frameworks\libs\air\qnx-air.swc.
    5. Change the link type to **External**.
9. On the **Native Extensions** tab, perform the following actions:
    1. Click **Add ANE**.
    2. Locate and add Adobe-AIR-SDK-install-directory\frameworks\libs\blackberry\ane\BlackBerryPushService.ane.
    3. Locate and add Adobe-AIR-SDK-install-directory\frameworks\libs\qnx\ane\QNXDevice.ane.
    4. Locate and add Adobe-AIR-SDK-install-directory\frameworks\libs\qnx\ane\QNXSkins.ane.
10. Click **Finish**.
11. Right-click on the **PushReceiver** project and go to **Properties**.
12. Click on the **ActionScript Build Packaging > BlackBerry** property and go to the **Native Extensions** tab.
13. Under the **Package** heading, check the check boxes for the three listed ANEs and click OK.
14. Run the **PushReceiver** project by right-clicking on the project and going to **Run As/Debug As > Mobile Application**.
15. Did you enable the signing of your application through your run / debug configuration settings?  Check by clicking on the **Build Packaging** link from **Run > Run Configurations** (or **Run > Debug Configurations**).
Under the **Digital Signature** tab, check **Enable digital signing** if you would like your application to be signed.
16. If you decided to sign your application, you need to make sure your invoke target ID is unique to your application (signing requires that it cannot match the invoke target ID used by someone else who is also attempting to sign the Push Receiver sample application):
   1. Change the "sample.pushreceiver.invoke.target" value in **bar-descriptor.xml** to something unique of your choosing.
   2. Also, change the **INVOKE_TARGET_ID** constant in **net.rim.blackberry.pushreceiver.service.PushNotificationServiceImpl** to have this same value. 
   3. Try **Run As/Debug As > Mobile Application** again.
    

## How to send a push

In order to be able to send pushes to the Push Receiver sample app, you will need to write a server-side push application (called a Push Initiator) to send out pushes with.
Luckily, this is fairly easy to do using the Push Service SDK available [here](https://developer.blackberry.com/services/push).

You'll find all the documentation for the Push Service SDK [here](http://docs.blackberry.com/en/developers/subcategories/?userType=21&category=Push+Service).

Note that in order to use the Push Service for developing an application for the general public, you will have to first register [here](https://www.blackberry.com/profile/?eventId=8121).


## How to receive a push

1. Start the Push Receiver sample application (if you haven't done so already).
2. Tap the **Config** action at the bottom of the device screen.  The configuration dialog will appear.
3. Click **Public/BIS** if the PPG is the BlackBerry Internet Service or **Enterprise/BES** if the PPG is the BlackBerry Enterprise Server.
4. Clear the **Use Push Service SDK as Push Initiator** check box if one of the following is true:
    * You implemented a Push Initiator that does not use the Push Service SDK.
    * Your Push Initiator only uses the low-level APIs without subscription support from the Push Service SDK.
5. If the **Use Push Service SDK as Push Initiator** check box is selected, in the **Application ID** field, perform one of the
following actions:
    * If you are using the BlackBerry Internet Service as the PPG, type the application ID specified in the confirmation
email message that you received from RIM.
    * If you are using the BlackBerry Enterprise Server as the PPG, type a unique application ID of your choosing. If you
clear the **Use Push Service SDK as Push Initiator** check box, you cannot type an application ID. In this case, the
Push Service APIs create an application ID for you automatically.
6. If you are using the BlackBerry Internet Service as the PPG, in the **PPG URL** field, type the PPG base URL specified in
the confirmation email message. The sample application uses this URL to create a channel to the PPG. For an
evaluation environment, the URL is http://cp{cpid}.pushapi.eval.blackberry.com, where {cpid} is your content
provider ID. For a production environment, the URL is http://cp{cpid}.pushapi.na.blackberry.com.
7. If the **Use Push Service SDK as Push Initiator** check box is selected, in the **Push Initiator URL** field, 
type https://{server_address}/pushsdk, where {server_address} is the address of the server where the pushsdk helper
application is deployed. The SDK includes the pushsdk helper application that is deployed on a server, such as the
Apache Tomcat server. The URL must be accessible from the Internet.  Of course, you can also point to your own
running Push Initiator application instead of the provided pushsdk helper one.
8. Click the **Launch App on New Push** check box if you want to start the sample application if it is not already started
when a new push message arrives. Leave the check box unchecked if you do not want to start the sample application
when a new push message arrives.
9. Click **Save**.
10. Tap the **Register** action at the bottom of the device screen.
11. If you had previously checked the **Use Push Service SDK as Push Initiator** check box, you will be required to enter a username and password.
These will be mapped, after authentication, to a subscriber ID in your Push Initiator.  If the **Use Push Service SDK as Push Initiator** check box
had not been checked, then it will jump straight into the register (i.e. create channel) operation.
12. You're all set to receive pushes!


## More Info

* [BlackBerry 10 SDK for Adobe AIR Beta 3](https://developer.blackberry.com/air)
* [Push Service SDK Download](https://developer.blackberry.com/services/push)
* [Push Service SDK Development Guides](http://docs.blackberry.com/en/developers/subcategories/?userType=21&category=Push+Service)
* [Push Service Registration Form](https://www.blackberry.com/profile/?eventId=8121)

## Disclaimer

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.