# BPS AIR Native Extension Sample

This sample shows how you could create an AIR Native extension using the BPS library found in the BlackBerry NDK. AIR Native Extensions allow you to write native C/C++ code and have it run in your AIR applications. 

This specific example shows how to create ANE that uses the Azimuth Pitch and Roll sensor.

There are three parts to this sample.

The native folder contains all of the C code for interacting with the BPS library. You must download and install the BlackBerry NDK in order to compile this code. You should be able to simply import the project into the NDK.

The ane folder contains the ActionScript library code that loads and interacts with the native C code. This code should be compiled into a .swc file. 

The app folder has a sample application showing how to use the ANE.

Both the ane and app folder can be directly imported into Flash Builder 4.6 or higher.

#Building the ANE
Once you have compiled the native code and the compiled ActionScript library in the ane folder, you can package the ane file. Unfortunately the only way to do this right now is with the command line. The devbuild.sh file included in this project will help with packaging. This is set up to run on a osx and will need to be altered in order to work on Windows. Before running the devbuild.sh script you will need to adjust the paths in the script to point to your AIR SDK directory bin directory. Also, make sure that the paths to the files that it uses are correct.

## Disclaimer

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

