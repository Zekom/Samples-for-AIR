/*
* Copyright (c) 2011 Research In Motion Limited.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

package samples.utils
{
    /**
     * A list of reusable constants that the Music application uses to parse an invocation from
     * an external application.
     * 
     * Some useful constants to launch a standard sequence of screens. For example, when launching
     * the album songs screen, it makes sense for the user to click the "Back" and see the the
     * albums list screen, and if they click "Back" on that to see the home screen as opposed to
     * just pushing a single screen on the foreground. This allows the Music application to be
     * invoked by external applications to process functions.<br>
     * <br>
     * Presently, the following invocation formats are supported:<br><br>
     * 
     * <li>Launch Albums List: <b>music://albums</b></li>
     * <li>Launch Albums Tracks Browser: <b>music://albums/album?id=<i>albumId</i></b></li>
     * <li>Launch Albums Tracks Browser and play: <b>music://albums/album?id=<i>albumId</i>&play=<i>fid</i></b></li>
     * <li>Launch All Songs List: <b>music://songs</b></li>
     * <li>Launch All Songs List and play: <b>music://songs?play=<i>fid</i></b></li>
     * <li>Launch Artists List: <b>music://artists</b></li>
     * <li>Launch Artist Albums List: <b>music://artists/artist?id=artistID</b></li>
     * <li>Launch Artist Albums List and play: <b>music://artists/artist?id=artistID&play=<i>fid</i></b></li>
     * <li>Launch Genre List: <b>music://genres</b></li>
     * <li>Launch Genre Songs List: <b>music://genres/genre?id=<i>genreID</i></b></li>
     * <li>Launch Genre Songs List and play: <b>music://genres/genre?id=<i>genreID</i>&play=<i>fid</i></b></li>
     * <li>Launch Playlist List: <b>music://playlists/playlist?id=<i>playlistID</i></b></li>
     * <li>Launch Playlist List and play: <b>music://playlists/playlist?id=<i>playlistID</i>&play=<i>fid</i></b></li>
     *
     */
    
    public class MusicAppLauncherUtil
    {
        /** All the media corresponding to an album of an artist. */
        public static const ALBUM_TRACKS:String = "album";
        
        /** The albums list that is displayed when a user clicks on the "Albums" cell in the home screen. */
        public static const ALBUMS:String = "albums";
        
        /** The songs list that is displayed when a user clicks on the "All Songs" cell in the home screen. */
        public static const ALL_SONGS:String = "songs";
        
        /** All the albums and corresponding media for an artist. */
        public static const ARTIST_ALBUMS:String = "artist";
        
        /** The artists list that is displayed when a user clicks on the "Artists" cell in the home screen. */
        public static const ARTISTS:String = "artists";
        
        /** The screen that allows the user to modify the dynamic playlist. */
        public static const EDITABLE_PLAYLIST:String = "editable";
        
        /** The genres list that is displayed when a user clicks on the "Genres" cell in the home screen. */
        public static const GENRES:String = "genres";
        
        /** All the media associated with a specific genre. */
        public static const GENRE_MEDIA:String = "genre";
        
        /** A potential text that is to be placed on the back button of a screen. */
        public static const PARAMETER_BACK_TEXT:String = "back";
        
        /** A potential unique ID associated with the screen that we wish to launch (ie: if we wish to launch the album tracks list, we need to pass in the ID of the album to this screen). */
        public static const PARAMETER_ID:String = "id";
        
        /** An argument one can pass in if they wish for a screen to be able to begin playback for a certain media in that screen. */
        public static const PARAMETER_PLAY:String = "play";
        
        /** A unique constant mapping to the playlists in the media library. */
        public static const PLAYLISTS:String = "playlists";
        
        /** All the media associated with a specific playlist. */
        public static const PLAYLIST:String = "playlist";
        
        /** The prefix that should precede an invocation. */
        public static const PREFIX:String = "music://";
        
        /** The screen displayed when a user clicks on the "Search All" button on the title bar of the Music application. */
        public static const SEARCH:String = "search";
        
        /** Separates one parameter token from another ("&"). */
        public static const SEPARATOR_PARAMETERS:String = "&";
        
        /** Separates one screen token from another for the screens ("/"). */
        public static const SEPARATOR_SCREEN:String = "/";
        
        /** Separates the sequence of screen tokens from the sequence of parameter tokens ("?"). */
        public static const SEPARATOR_SCREEN_PARAMETERS:String = "?";
        
        /** Separates the value from the parameter name ("="). */
        public static const SEPARATOR_VALUE:String = "=";
        
        /** Invoke the Music application with this parameter to launch the Artists list. */
        public static const LAUNCH_ARTISTS:String = PREFIX+ARTISTS;
        
        /** Invoke the Music application with this parameter to launch the Albums list. */
        public static const LAUNCH_ALBUMS:String = PREFIX+ALBUMS;
        
        /** Invoke the Music application with this parameter to launch the dynamic playlist screen. */
        public static const LAUNCH_EDITABLE_PLAYLIST:String = PREFIX+EDITABLE_PLAYLIST;
        
        /** Invoke the Music application with this parameter to launch the Genres list. */
        public static const LAUNCH_GENRES:String = PREFIX+GENRES;
        
        
        /**
         * Invoke the Music application with this parameter to launch the All Songs list.
         * @param fid The file ID at which to begin playing. If this is argument is omitted, then we do not
         * begin immediate playback.
         * @return For example if fid=<code>6</code>, then
         * <code>music://songs?&play=6</code> is returned.
         */
        public static function launchAllSongs(fid:uint=0):String
        {
            var suffix:String = fid ? SEPARATOR_SCREEN_PARAMETERS+PARAMETER_PLAY+SEPARATOR_VALUE+fid : "";
            
            return PREFIX+ALL_SONGS+suffix; // music://songs?play=45
        }
        
        
        /**
         * Invoke the Music application with this parameter to launch the sequence of screens
         * associated with the artist albums list.
         * @param aid The unique ID associated with this artist in the database.
         * @param fid The file ID at which to begin playing. If this is argument is omitted, then we do not
         * begin immediate playback.
         * @return For example if aid=<code>5</code> and fid=<code>6</code>, then
         * <code>music://artists/artist?id=5&play=6</code> is returned. If the fid
         * is ommitted, then the following is returned: <code>music://artists/artist?id=5</code>
         */
        public static function launchArtistAlbums(aid:uint, fid:uint=0):String
        {
            return PREFIX+ARTISTS+SEPARATOR_SCREEN+launchArtistAlbumsLeaf(aid, fid); // music://artists/artist?id=5&play=45
        }
        
        
        /**
         * Invoke the Music application with this parameter to launch only the artist albums list
         * where hitting the back button will simply bring the user back to the home screen instead of
         * the artists list.
         * @param aid The unique ID associated with this artist in the database.
         * @param fid The file ID at which to begin playing. If this is argument is omitted, then we do not
         * begin immediate playback.
         * @return For example if aid=<code>5</code> and fid=<code>6</code>, then
         * <code>artist?id=5&play=6</code> is returned. If the fid
         * is ommitted, then the following is returned: <code>artist?id=5</code>
         */
        public static function launchArtistAlbumsLeaf(aid:uint, fid:uint=0):String
        {
            return ARTIST_ALBUMS+getIDString(aid)+getFileIDString(fid); // artist?id=5&play=45
        }
        
        
        /**
         * Invoke the Music application with this parameter to launch the sequence of screens
         * associated with the albums tracks list.
         * @param fid The file ID at which to begin playing. If this is argument is omitted, then we do not
         * begin immediate playback.
         * @return For example if aid=<code>5</code> and fid=<code>6</code>, then
         * <code>music://albums/album?id=5&play=6</code> is returned. If the fid
         * is ommitted, then the following is returned: <code>music://artists/artist?id=5</code>
         */
        public static function launchAlbumTracks(aid:uint, fid:uint=0):String
        {
            return PREFIX+ALBUMS+SEPARATOR_SCREEN+launchAlbumTracksLeaf(aid, fid); // music://albums/album?id=5&play=45;
        }
        
        
        /**
         * Invoke the Music application with this parameter to launch only the album tracks browser
         * where hitting the back button will simply bring the user back to the home screen instead of
         * the albums list.
         * @param fid The file ID at which to begin playing. If this is argument is omitted, then we do not
         * begin immediate playback.
         * @return For example if aid=<code>5</code> and fid=<code>6</code>, then
         * <code>albums/album?id=5&play=6</code> is returned. If the fid
         * is ommitted, then the following is returned: <code>albums/album?id=5</code>
         */
        public static function launchAlbumTracksLeaf(aid:uint, fid:uint=0):String
        {
            return ALBUM_TRACKS+getIDString(aid)+getFileIDString(fid); // music://albums/album?id=5&play=45;
        }
        
        
        
        /**
         * Invoke the Music application with this parameter to launch the Genres tracks list.
         * @param pid The unique ID associated with this genre in the database.
         * @param fid The file ID at which to begin playing. If this is argument is omitted, then we do not
         * begin immediate playback.
         * @return For example if gid=<code>5</code> and fid=<code>6</code>, then
         * <code>music://genres/genre?id=5&play=6</code> is returned. If the fid
         * is ommitted, then the following is returned: <code>music://genres/genre?id=5</code>
         */
        public static function launchGenreTracks(gid:uint, fid:uint=0):String
        {
            return PREFIX+GENRES+SEPARATOR_SCREEN+launchGenreTracksLeaf(gid, fid); // music://genres/genre?id=5&play=45;
        }
        
        
        /**
         * Invoke the Music application with this parameter to launch only the genre tracks list
         * where hitting the back button will simply bring the user back to the home screen instead of
         * the genres screen.
         * @param pid The unique ID associated with this genre in the database.
         * @param fid The file ID at which to begin playing. If this is argument is omitted, then we do not
         * begin immediate playback.
         * @return For example if gid=<code>5</code> and fid=<code>6</code>, then
         * <code>genre?id=5&play=6</code> is returned. If the fid
         * is ommitted, then the following is returned: <code>genre?id=5</code>
         */
        public static function launchGenreTracksLeaf(gid:uint, fid:uint=0):String
        {
            return GENRE_MEDIA+getIDString(gid)+getFileIDString(fid); // genre?id=5&play=45;
        }
        
        
        /**
         * Invoke the Music application with this parameter to launch the Playlist tracks list.
         * @param pid The unique ID associated with this playlist in the database.
         * @param fid The file ID at which to begin playing. If this is argument is omitted, then we do not
         * begin immediate playback.
         * @return For example if pid=<code>5</code> and fid=<code>6</code>, then
         * <code>music://playlists/playlist?id=5&play=6</code> is returned. If the fid
         * is ommitted, then the following is returned: <code>music://playlists/playlist?id=5</code>
         */
        public static function launchPlaylistTracks(pid:uint, fid:uint=0):String
        {
            return PREFIX+PLAYLISTS+SEPARATOR_SCREEN+PLAYLIST+getIDString(pid)+getFileIDString(fid); // music://playlists/playlist?id=5&play=45;
        }
        
        
        /**
         * Invoke the Music application with this parameter to launch the Search list where the
         * back button will show the specified text.
         * @param backText The text to display on the back button in the title bar.
         * @return For example if backText=<code>Artists</code> then
         * <code>music://search?back=Artists</code> is returned.
         */
        public static function launchSearchLeaf(backText:String):String
        {
            return SEARCH+SEPARATOR_SCREEN_PARAMETERS+PARAMETER_BACK_TEXT+SEPARATOR_VALUE+backText; // search?back=Artists;
        }
        
        
        /**
         * Gets the String to append to the invocation URL to specify the unique library ID
         * association with a screen.
         * @param id The unique library key associated with the screen.
         * @return For example if <code>7</code> is given as a parameter, <code>?id=7</code> is returned.
         * The question mark is returned because we always assume the ID is the first argument.
         */
        private static function getIDString(id:uint):String
        {
            return SEPARATOR_SCREEN_PARAMETERS+PARAMETER_ID+SEPARATOR_VALUE+id;
        }
        
        
        /**
         * Gets the String to append to the invocation URL to specify the unique library file-ID
         * for playback with a screen.
         * @param fid The file ID at which to begin playing. If this is argument is omitted, then we do not
         * begin immediate playback.
         * @return For example if <code>7</code> is given as a parameter, <code>&play=7</code> is returned.
         * The ampersand mark is returned because we always assume the ID is the first argument
         * and thus this would be the second.
         */
        private static function getFileIDString(fid:uint):String
        {
            return fid ? SEPARATOR_PARAMETERS+PARAMETER_PLAY+SEPARATOR_VALUE+fid : ""; // &play=45
        }
    }
}