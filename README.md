My PowersHELL profile — I use mpv in the console for listening to music.

|/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\|

---

## Features

- Custom `play` command:
  - Plays audio files with **mpv**
  - Defaults: `--no-video` and `--volume=35`
  - Supports wildcards (`play *.mp3`) and single files/paths
- Crazy color scheme, i like it btw
- Dependency installer script (`install-deps.ps1`) for:
  - **FFmpeg**
  - **yt-dlp**
  - **mpv**
   Command to install: .\scripts\install-deps.ps1





---

## Usage

# play one file
play "track.mp3"

# play all mp3 files in folder
play *.mp3

# set your own volume
play --volume=55 *.mp3

# download audio from YouTube
ytmp3 <url>

or

yt-dlp -f bestaudio --extract-audio --audio-format mp3 <url>

 
