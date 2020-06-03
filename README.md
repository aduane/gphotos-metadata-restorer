# Google Photos Metadata Restorer

This acts on a google photos google takeout archive and uses their provided
metadata files to ensure the correct metadata tags are set on your photos and
video. This is a good step to take before uploading your photos elsewhere,
since you can sometimes end up with missing or incorrect
dates/times/timezones.

# Sorry, this doesn't work just yet.

Still working on it. So far it does a pretty good job of choosing the correct
metadata json file for each picture/video in the takeout archive.


# Instructions

1. Download your google photos archive from google takeout. Depending on the
   size of the archive, it may be split into multiple .zip files.
2. Unzip all parts of the archive and merge them into a single `Takeout/`
   directory. One way to do this is with `rsync`. Assuming a directory
   structure with 58 different Takeout folders named "Takeout 1", "Takeout 2",
   "Takeout 3", ..., "Takeout 57", "Takeout 58". (Note that we have renamed
   the first one from "Takeout" to "Takeout 1") Make the folder for them to be
   combined into: `mkdir Takeout`, then
   `for i in {1..58}; do echo "Takeout\ $i"; rsync -a ./Takeout\ $i/ ./Takeout/; done`
3. Edit `restore.rb` to use your absolute path to the directory.
4. Make a copy of your photos! I'd hate to have something mess up your photos
   if it goes wrong. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
   KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
   NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
   DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
   OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
   USE OR OTHER DEALINGS IN THE SOFTWARE.
5. `ruby restore.rb`
