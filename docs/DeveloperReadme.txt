Where to find the files you are looking for:

share/      icons and other such binary files
themes/     all graphics, menu music, etc
game/       the source code of the game
libda/      the source code of libda (the audio I/O library)

When adding new data files, you may need to edit the CMakeLists.txt file in that
folder to have CMake actually install it. When adding new source code files,
you don't need to edit CMakeLists.txt, but you need to remove CMakeCache.txt and
run cmake again for it to rescan for files.


The game folder in detail:

main.cc contains not only the main function (including commandline argument
handling etc) but also the main loop of the game. The main function also owns
the base objects (that some might consider global) of the game.

screen*.cc/hh contain implementation of screens. A screen should ideally by only
a "view" with as little game logic or other things in it as possible. Keyboard
input, being tightly coupled with UIs, is also handled there. ScreenManager's
activateScreen("foo") function is used for moving from one screen to another.

You may currently access ScreenManager by a singleton, but this is discouraged
and the singleton is to be removed because singletons are evil (but it is not
buggy at the moment, so we are not rushing that).

Notes of the song and TXT file parsing are in song.cc/hh.

Most other files either implement little helpers for loading and displaying
images (surface), playing sound (audio), decoding video/audio (ffmpeg),
rendering and displaying text (opengl_text), etc.

The program configuration is stored in a global variable named config, declared
in configuration.hh. The code there is agnostic about the specific config
options, so you probably don't need to touch it even if you add new options.

Adding new options is very easy. In C++ you simply use something like
config["some/identfier"].get_b() to read the value and that's it. There are
different getters for different types of config variables (get_b is for bool).
You need to add your new option to data/performous.xml so that it appears in
the config menu and has a suitable default value.

One rather widely used tool is animvalue, which implements variables that change
their value smoothly over time. This effect is most prominent it the song
browser, but it is used in various other parts of the UI and we also abuse it
as a simple timer in some places.

The game logic runs as a separate thread so that slow OpenGL rendering or other
such factors don't disturb it (engine.cc/hh). This engine runs in an endless
loop, polling the audio analyzer code (pitch.cc/hh) for data that it then uses
to calculate points and to record pitch history. Capture objects (owned by the
main function) own a set of Analyzers each (one per microphone) and also a libda
record object (corresponding to a sound card) that uses a callback to deliver
the Capture object with new PCM data and then the Capture distributes that to
Analyzers' input buffers (no processing is done here because it would block
audio libraries for too long time).

The game heavily uses threads, primarily to simplify implementation of things
that need to stay responsive even though some other parts of the program might
block, but also to improve performance. You can largely ignore this fact, as
the threads are hidden inside classes so that things don't break even when
you don't realize that there is a thread. Just be aware of that there are
plenty of them everywhere. Ask Tronic before touching any thread code directly.


Coding style & Boost:

Use good C++ style. No C strings (char*), atoi or other things you may have
become familiar with when coding "C/C++".

All header files begin with line #pragma once, which is not standard, but is
supported by all compilers that we care of. Include guards should not be used
even though some older headers might still have them instead of #pragma once.

We do not use delete, delete[] or new[] and we avoid using "new". Instead,
standard library containers are used when arrays are needed and
Boost.ptr_containers (e.g. boost::ptr_vector) are used when containers of
non-movable or polymorphic objects (i.e. something that you need to allocate
with new) need to be stored. Additionally, boost::scoped_ptr is similarly used
when there is only one object. All these Boost tools automatically call delete
on their contents once done, so we can avoid having to do that manually.

(no more memory leaks, yay)

We use references instead of pointers whenever possible. Resources are always
managed by RAII (see http://www.hackcraft.net/raii/ ). We generally avoid
inheritance (when not directly useful). Errors are always handled by throwing
std::runtime_error (for errors in input data, etc) or std::logic_error
(internal errors of Performous), or something derived from those.

Indentation is one tab character per a pair of {}. Long lines that are
split over several use "small indent" of two spaces. Labels (public/private,
case/default) are one level "higher" than they should (i.e. one less tab) but
have a small indent of two spaces instead. Do not try to align anything with the
next/previous line of code. Maintaining the alignment wastes time and it also
easily breaks with Emacs (which cannot understand that it should not convert
those spaces that you used for alignment into tab characters).

We prefer short and simple code. E-g- if (foo) bar(); is easiest to read when it
is all on one line, so don't make it three or four lines long by adding braces,
no matter what your Java professor said (he is simply wrong).

When you can, use "if" with return, break, continue and throw to handle
conditional situations instead of using if-elses. This makes the code much
easier to read.

Write more comments than we do! (to describe the intention, larger logical
blocks of code and the external behavior of functions, but do not duplicate your
C++ in English).



TODO: move the documentation in this file to the website developers page?
