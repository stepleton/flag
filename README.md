Transputer/occam flag simulation
================================

This code is a "demo" for a very specific computer configuration: an IBM PC or
PC compatible with the ability to display CGA graphics, running DOS, with a
network of 32-bit [transputers](https://en.wikipedia.org/wiki/Transputer)
fitted and accessible at I/O addresses starting from 0150h with the help of an
[INMOS C012](http://transputer.net/ibooks/dsheets/c012.pdf) link adaptor chip.
An [INMOS B008](http://transputer.net/mg/b008ug/b008ug.html) transputer module
motherboard ISA card is an ordinary way of achieving this setup.

The demo performs a simulation of a flag flying in a breeze (note: the image
links to [a brief YouTube teaser video](
https://www.youtube.com/watch?v=ZY-cUEJT1XQ) that shows the flag flying):

[![An IBM CGA monitor displays an arrangement of blue, magenta, and white dots
that resembles a transgender pride flag fluttering in a breeze](flag.jpg)](
https://www.youtube.com/watch?v=ZY-cUEJT1XQ "Video teaser for this project
on YouTube")

The colouring and pattern on the flag can be changed in a few different ways,
although the [limited colour palette](
https://en.wikipedia.org/wiki/Color_Graphics_Adapter#320%C3%97200) CGA makes
available for its higher-resolution graphics modes makes it difficult to
reproduce most flags in a satisfying or even recognisable way.

Most of the demo's code is in the [occam programming language](
https://en.wikipedia.org/wiki/Occam_(programming_language)), a clever language
designed for programming transputers that's now mostly forgotten. A much
smaller program written in x86 assembly language runs on the PC side, copying
transputer-produced graphics into the PC's video memory.

_**Why is this README so long?** A long README or manual is something of a
personal trademark, but I also really enjoyed this project and wanted to make
every opportunity for the reader to discover the same pleasure I found in
exploring such a nicely-designed computing system. I hope this README is an
effective way for me to go back and leave some breadcrumbs along my path._


Contents
--------

* [Quick-start guide](#quick-start-guide)
* [Usage](#usage)
* [Background about the transputer](#background-about-the-transputer)
* [Why this demo](#why-this-demo)
* [How the flag flies (in other words: theory of operation)](
  #how-the-flag-flies-in-other-words-theory-of-operation)
* [How else does this flag fly?](#how-else-does-this-flag-fly)
* [Learning more: touring the code](#learning-more-touring-the-code)
  - [Some notes about occam for the casual reader](
    #some-notes-about-occam-for-the-casual-reader)
  - [A tour itinerary](#a-tour-itinerary)
* [Nobody owns this demo](#nobody-owns-this-demo)
* [Acknowledgements](#acknowledgements)


Quick-start guide
-----------------

Transputer installations are quite varied, making it difficult to devise
broadly-applicable instructions for the casual user. Here is a best-effort
attempt. The first requirements are:

* Your transputer setup is installed in a PC compatible computer running DOS,
  capable of displaying CGA graphics.
* You must have INMOS's `iserver` program (or someone's derived `iserver`) in
  your PATH.
* You have INMOS's `rspy` program (or someone's derived `rspy`) in your PATH.

Up-to-date versions of both are available for DOS systems from [here](
http://bin.transputer.net/bin2/dos/x86/).

**Method 1:** If you have an INMOS B008 ISA expansion card transputer backplane
(a) with at least seven 32-bit transputers fitted, (b) with all of the hardware
configuration options (i.e. jumpers and switches) in the INMOS factory
configuration, (c) without the built-in INMOS C004 crossbar switch introducing
any more connections beyond the backplane's hardwired chain topology, _and_ (d)
with the transputer in slot 0 having at least a few hundred kilobytes of RAM,
then: just execute `flag.bat`.

**Method 2:** If most of the above applies *except* your B008 is configured to
use a different I/O address than the default 0150h, or if it uses some other
means of communicating with the PC, then:

* Run `rspy` to reset the entire transputer network.
* Run `iserver /sb flagb8.btl`.

**Method 3:** If the closest you can get to the Method 1 configuration is
a single "root" transputer, and if that transputer is accessible at I/O
addresses starting at 0150h --- a configuration that _might_ apply to a B004
single-transputer expansion card --- try executing `flagsngh.bat`.

**Method 4:** If most of the Method 3 conditions apply *except* your card is
configured to use a different I/O address than the default 0150h, or if it uses
some other means of communicating with the PC, then try running
`iserver /sb flagsngl.b4h`.


Usage
-----

If you've successfully started the flag simulation, you should see a bunch of
drifting dots on the display. That's the flag --- and while it looks a little
unnatural when it first starts moving, it'll start to seem a lot more flag-like
in a few minutes.

If you've used **Method 1** or **Method 3** to start the simulation, you can
use the number keys on the main keyboard (i.e. not the keypad) to change the
pattern displayed on the flag. When you're finished with the simulation, use
the Esc key to return to DOS.

If you've used **Method 2** or **Method 4** to start the simulation, there is
no option to change the flag's pattern. Press any key to return to DOS.


Background about the transputer
-------------------------------

Transputer was the name for a series of unique microprocessors designed and
made by [INMOS](https://en.wikipedia.org/wiki/Inmos), a semiconductor
manufacturer headquartered in Bristol, England. Produced from roughly the
mid-1980s to the mid-1990s, these processors had innovative features intended
to make them useful for multiprocessor applications. The idea was that you
would build computing systems for diverse needs by assembling transputers
together like building blocks. (In fact, the name "transputer" is a portmanteau
of "transistor" and "computer" per [this conceptualising text](
https://books.google.com/books?id=rT05AAAAIAAJ&pg=PA343), which includes a
section entitled "THE TRANSPUTER AS A UNIVERSAL COMPONENT".) Some of these
features for multiprocessing included:

* Four 20-megabit serial communication links built into each transputer,
  allowing straightforward construction of multiprocessor networks.
* Process scheduling and multitasking built into the processor (ordinarily,
  operating system software performs process management).
* At least 2 KiB of on-chip RAM, further simplifying system design for settings
  where a lot of computing must be done on a limited amount of data.

Innovative design extended beyond the silicon: [David May](
https://en.wikipedia.org/wiki/David_May_(computer_scientist)), lead architect
of the transputer, also designed the occam programming language for developing
transputer applications --- and in some ways for developing transputers
themselves ([e.g.](http://people.cs.bris.ac.uk/~dave/T414B.pdf)). The occam
language includes built-in constructs and checks that simplify the development
of programs that have processes that run in parallel. Multi-threaded programs
are notoriously challenging to write well: while occam couldn't guarantee that
it would keep the programmer from introducing critical bugs related to parallel
programming, it did make a number of common pitfalls impossible. Some of its
design features are found today in widely-used programming languages like [Go](
https://en.wikipedia.org/wiki/Go_(programming_language)).

When they were introduced, transputers were quite fast in comparison to many
other microprocessor offerings -- and easy to assemble into ensembles that were
faster still. Commodity computer systems eventually eroded this advantage, and
general-purpose transputers retreated from the market in the mid 1990s. The
final descendants of the transputer lived on into the 2000s as [specialised
controllers for TV set-top boxes](
https://www.cpushack.com/2016/02/03/the-end-of-the-omega/). Some modern
microcontrollers by [XMOS](https://en.wikipedia.org/wiki/XMOS), whose founders
include David May and other INMOS alumni, retain transputer-like features.


Why this demo
-------------

There was a time when the transputer concept was inspiring to a lot of people
working in computing ([e.g. 1](
https://www.sciencedirect.com/science/article/abs/pii/014193318990032X),
paywalled, Elsevier unfortunately, [e.g. 2](
http://public.callutheran.edu/~reinhart/CSC521/Week8/Transputers.pdf)), and why
not? If microprocessors made computing cheap, then multiple microprocessors
could make _big_ computing cheap: you just needed to figure out how they would
all work together. The thoughtful features built into transputers and occam
seemed to offer an answer.

Today's most common kind of parallel computing (the "cloud" kind) is not unlike
transputing: in place of linked transputer modules, you have vast racks of
networked individual computers. Processes "live" on only one computer: instead
of somehow diffusing transparently throughout the cloud, applications on many
cloud platforms often build on the abstraction that individual processes will
use networking to collaborate with vast squadrons of identical clones, each one
running on a computer ("node") of its own. (Even processes running on the same
cloud node tend to run in private address spaces, with interprocess
communication often using some kind of channel- or pipe-like interface.)
Metaphorically, application software often "thinks" on the level of what
individual bees do rather than what actions the entire hive is taking.

At least with occam and the rest of INMOS's tools, transputers are also
programmed in the "bee" way rather than the "hive" way. What makes occam and
transputers special is that they were built to be bees from the start! The
computer and software architectures that underlie most cloud systems evolved
from settings where there was only ever one computer: sometimes a large,
expensive minicomputer that hosted multiple users, other times a desktop PC
that was kept running overnight to do various server-like duties. The
facilities that let multiple computers work together were added _post hoc_, and
it shows. Local threads of one program share data in a way that differs from
how separate programs on the same machine share data, which is different to how
programs on separate computers share data --- and so on. Some programmers' aids
like libraries and frameworks try to hide this complexity, but you can always
feel the ancient rivets and seams underneath the shiny new wallpaper. Today's
cloud nodes aren't bees, they're housecats that we coax into cooperating.

**What could it be like to use a clean-sheet design where multiprocessing is
baked deep down into the silicon itself?**

To find out, we need an appropriate task. There are lots of problems that
benefit from being broken down into smaller parts and solved by a team, but
within this collection there is much variety. Some problems are ["embarrassingly
parallel"](https://en.wikipedia.org/wiki/Embarrassingly_parallel): processes
working on small pieces of the problem in parallel don't have to talk to each
other to come up with their part of the answer. (Classic tasks like the
[Mandelbrot set](https://en.wikipedia.org/wiki/Mandelbrot_set) and [ray
tracing](https://en.wikipedia.org/wiki/Ray_tracing_(graphics)) are
embarrassingly parallel, and INMOS used both to demonstrate transputers at
work.) Other parallel processing problems need workers to exchange messages
periodically as they get the job done, and these tend to be more difficult to
program. Fabric simulation (as with a flag) is more that sort of problem: the
workers need to communicate to each other to describe how different parts of
the cloth are tugging at each other. This should be a worthy challenge for
investigating the dream of transputing in detail.


How the flag flies (in other words: theory of operation)
--------------------------------------------------------

Like most fabric simulations, our flag takes the form of simulated point masses
connected to their (four-way) neighbour point masses by simulated springs, each
jostled this way and that by simulated wind and gravity. Unlike most fabric
simulations, our point masses are just points in a two-dimensional space. This
is a poor physical analogue to a real flag, which exists in 3-D, not 2-D. The
idea is just to make something that looks acceptable: it turns out you can get
away with 2-D for a demo.

Our code is essentially an occam port of [this interactive JavaScript demo](
https://codepen.io/dissimulate/pen/nYQrNP), which a person on Reddit claims is
derived from [a tutorial they once made](
https://gamedevelopment.tutsplus.com/tutorials/simulate-tearable-cloth-and-ragdolls-with-simple-verlet-integration--gamedev-519).
Perhaps with half-again as many processors in my network, a true 3-D simulation
might be nearly as fast, but we only have seven transputers in this setup.
There's another constraint, too: of those seven, only two of them have the
ability to do floating point maths in hardware. So, instead of using INMOS's
software floating point library on the rest (too slow!), we use 32-bit integers
for everything: [fixed-point arithmetic](
https://en.wikipedia.org/wiki/Fixed-point_arithmetic). Our representation uses
only 11 bits for the fraction, which is around the minimum for our application:
[bit-shifting](https://en.wikipedia.org/wiki/Bitwise_operation#Bit_shifts) is
important for fixed-point maths, but our transputers don't have a [barrel
shifter](https://en.wikipedia.org/wiki/Barrel_shifter), so shifting a value by
N places takes at least N clock cycles. Better to keep N as small as you can.

(Funny trivia: even though it doesn't make sense to shift a 32-bit integer more
than 32 steps --- after that your integer is just full of 0s --- transputers
like ours will keep on shifting fully as many times as you specify... and you
specify the number of steps you want using a 32-bit integer. [This book about
transputer assembly language programming](
https://www.transputer.net/iset/pdf/transbook.pdf) warns you that if you choose
a very large number of steps, say 2,147,483,647 steps for example, you can lock
up a transputer entirely "for 3 to 4 minutes"!)

**Transputer network:** We now have to choose how to spread the flag simulation
work across the transputer network, so it's useful to describe the network
itself for a moment.  It takes the form of seven TRAMs -- [transputer modules](
https://en.wikipedia.org/wiki/Transputer#/media/File:Transputer_Standardmodule_IMSB404_IMSB418_73.jpg),
each of which carries a transputer chip and some RAM -- mounted on [a special
ISA card that works as a backplane](
https://en.wikipedia.org/wiki/Transputer#/media/File:Transputer_Evaluation_IMSB008_68.jpg).
Fully assembled, it's a formidable construction, with up to three TRAMs of
various sizes and shapes stacked atop one another.

![A view of expansion cards within an IBM PC/AT computer. The star in the
middle of the image is an INMOS B008 ISA transputer backplane, a full-width
ISA-slot card with a number of circuit boards stacked on top of it. These
circuit boards sit flat against the B008 and in some cases atop each other,
like irregular stacks of rectangular plywood offcuts. In one place, the stack
is three layers deep. Each board features arrays of memory chips and one
transputer chip: a large square ceramic package with a gold, square cover
in the centre. Meanwhile, the furthest-back expansion card in the system is
an original IBM CGA card.](b008.jpg)

The transputer backplane ISA board has a hard-wired network for transputer
serial links that connects all of the transputers in a bidirectional chain:
transputer 0 can exchange data with transputer 1; transputer 1 can exchange
data with transputers 0 and 2, transputer 2 can exchange data with 1 and 3, and
so on. There's also a [software-configurable crossbar switch](
http://www.transputer.net/ibooks/dsheets/c004.pdf) that can introduce more
serial link connections between the transputers if we choose, but our flag
simulation will just use the hardwired chain and nothing else. With the network
topology now described, here's how the flag simulation distributes itself
across the network:

![A diagram explaining how the flag simulation distributes itself across the
network. Like a belt across the centre of the image, seven square computer
chips are arranged in a row, numbered from left to right as 6, 5, 4, 3, 2,
1, 0. Chips have red arrows pointing from themselves to their neighbours on the
right and left: these connote communication links. Below the chips is an IBM
PC/AT whose monitor is displaying an image of a rendered flag: two red arrows
connecting to transputer 0 indicate a bidirectional link connection. Above
transputers 6 to 1 are 25-row, 7-column arrays of coloured dots: these are the
flag elements whose movements each of those transputers is helping to simulate.
Above transputer 0 is a pair of stacked screen images containing rendered
flags: these are the video buffers that transputer 0 uses for rendering flag
images.](network.png)

**Roles:** Starting from the right-hand side, transputer 0 on our backplane is
special: besides being one end of the chain, it can also communicate with the
host PC that holds the transputer backplane ISA card. We assign it the role of
the "flag boss", and the rest are "flag workers". The flag workers (transputers
1 through 6) are each responsible for simulating their own strip-like portions
of the flag; the last flag worker in the chain ties one end of flag to a
simulated flagpole so that the whole flag doesn't fly away! Meanwhile, after
first configuring all of the workers, the flag boss repeatedly receives the
locations of all of the "flag elements" (those simulated point masses) and
renders the images that will be copied to our host PC's CGA display. While it
draws new images, the flag boss also transfers older, fully drawn images to the
PC, which copies the image data from transputer 0 to video memory with the help
of a very simple DOS program.

None of these roles require a great deal of RAM, so long as you don't try to
simulate flags with lots of flag elements. The flag boss probably needs a few
hundred kilobytes; flag workers fit comfortably within 32 kilobytes.

**Processes:** Note how the flag boss transputer can be seen to be doing two
things simultaneously: rendering new images and serving older images to the PC.
It accomplishes this by using [multiple image buffers](
https://en.wikipedia.org/wiki/Multiple_buffering#Double_buffering_in_computer_graphics)
but also (and more interestingly) by taking advantage of the transputer's
built-in facilities for processes, process scheduling, and multitasking. By
contrast, although the flag workers also do a little bit of multitasking in a
few places, it's easiest to understand them as sequentially switching back and
forth between a phase where they compute new flag element locations and a phase
where they transfer those locations to the flag boss. (It might be nice for the
flag workers to mimic the flag boss's simultaneous calculate-and-transfer
approach, but memory is limited for some of the worker transputers, and
multiple buffers --- here for flag element locations --- are not an easy
option.)

**Communications for simulation:** The fabric simulation proceeds in
"timesteps", where the simulated time within the simulation advances by a
small, fixed amount. At each timestep, the flag workers compute new locations
for each of the flag elements.  To accomplish this, they consider each element
individually, calculating its new location based on the push-and-pull received
from its neighbour elements.  This iteration repeats several times to arrive at
the final flag element locations for the new simulated time. For flag elements
at the edges of a flag worker's portion of the flag, this requires a round of
bidirectional communication between that worker and its neighbour. Flag element
location updates sweep from the [hoist](
https://en.wikipedia.org/wiki/Glossary_of_vexillology#Flag_elements) on
transputer 6 to the [fly](
https://en.wikipedia.org/wiki/Glossary_of_vexillology#Flag_elements) on
transputer 1, so first transputers 6 and 5 work out the locations of their
border-dwelling elements, then 5 and 4, then 4 and 3, and so on. This process
can pipeline, so even when "lower" transputers are working together to complete
the first location-updating sweep, the "upper" transputers can begin the next
sweep.

Once all transputers have finished computing the timestep's final flag element
locations, they convert the locations to display coordinates for the CGA screen
and pass those converted locations down to the flag boss. The boss receives
these locations in fly-to-hoist order and plots them into one of its image
buffers. Because of the network's chain topology, "lower" flag workers must
pass along locations from the flag workers "above" them, bucket-brigade style.
Note that the boss only receives data from the workers once simulation is
underway: it never sends any messages "up the chain".

**Communications for configuration:** Full simulation is preceded by a
configuration stage where the flag boss is much more chatty. The boss initiates
by passing the first worker the numbers of workers "above" it, who subtracts
one to pass the same information to its worker neighbour, and so on up the
chain. When the topmost worker (transputer 0) is reached, this number will be
0, so after noting to itself that it is responsible for the flag's hoist, that
worker kicks off a downward-moving message chain, where each worker passes
along the smaller of (a) the number of flag elements that it can hold in memory
or (b) the number reported by its "upper" neighbour. In this way, the boss will
eventually learn the number of elements that the most memory-constrained flag
worker can accommodate. This is important information as flag processing work
is distributed evenly among the workers.

Armed with capacity information, the flag boss sends the dimensions of the
complete flag (counted in numbers of flag elements) to the first flag worker,
who calculates the size of its strip and passes the dimensions of the remainder
to the next flag worker, and so on. The topmost worker (transputer 0) reverses
the flow once more, reporting the size of its strip to its neighbour, who adds
the size of its own strip and passes it downwards, and so on. Ultimately, this 
process should report the size of the entire flag back to the boss, which
checks for agreement with its earlier plans to confirm that the transputer
network is fully configured. If all looks well, the boss awaits drawing
coordinates from the workers, who will have already started the simulation.

**Drawing and colours:** The flag boss carries out all rendering of the images
shown on the PC's CGA display. PC-side software does little more than copy
image data directly into CGA video memory.

In one way or another (see below), the PC and the flag boss work together to
display flags with different colours and patterns. The CGA video modes we use
can only display four colours at a time (including black); when the boss draws
a flag element, it refers to a table containing a pattern to decide which
colour to use. CGA offers [six unimpressive colour palettes](
https://en.wikipedia.org/wiki/Color_Graphics_Adapter#320%C3%97200) for our
graphics, so the PC must be configured to use the best possible palette for
whichever flag the boss is drawing.

**Headless and all-in-one modes:** The hardware interface that the B008
transputer backplane ISA card presents to the PC is not very complicated ---
it's not too difficult to write a DOS program that accesses the B008's I/O
ports directly. Nevertheless, most software makes use of the `iserver`: a
utility that runs on the PC, sets up programs to run on transputer networks,
and (once they're running) acts as a broker between transputer 0 and the PC's
operating system and hardware. While the transputer runs a program, the
`iserver` awaits its commands: open a file, print a string, get a character
from the keyboard, and so on. This design makes it easy to use transputers with
all kinds of computer platforms: none of the transputer programs need to
change; only the `iserver` has to be adapted to different computer hosts.

Despite this portability intent, the DOS version of the `iserver` obeys some
powerful extra commands. The transputer can ask the `iserver` to issue an
interrupt, access an I/O port, or copy blocks of data to and from memory. This
extra capability is all the flag boss needs to boss the PC into changing video
modes, setting up colour palettes, and finally displaying rendered flag images.
The main problem with this "all-in-one" method is that it's slow: the `iserver`
was not written to carry out these PC-specific functions rapidly. It's also
difficult to deal with [the way screen rows are ordered in CGA video memory](
https://en.wikipedia.org/wiki/Color_Graphics_Adapter#Limitations,_bugs_and_errata)
in a manner that simultaneously avoids slowdowns and flickering dots on the
screen.

For this reason, there's also a "headless" version of the flag simulator. Here,
once configuration is complete, the flag boss tells the `iserver` to shut down.
The boss then awaits contact from a dedicated DOS program that interfaces
directly with the B008 card and copies data to video memory as quickly as
possible. As the superior display option, the headless system earned additional
features during development, particularly the ability to tell the flag boss to
change the flag colour map to a different pattern. You can choose between ten
different flags by pressing the number keys; thanks to CGA's limitations, some
flags are more recognisable than others.


How else does this flag fly?
----------------------------

This simulated flag flies out of esteem for trans people everywhere!


Learning more: touring the code
-------------------------------

If a few thousand words of theory of operation aren't enough detail for you,
the next step is to examine the code. All of it is luxuriously commented, which
hopefully makes the logic easy to understand. But first:

### Some notes about occam for the casual reader

Virtually all of the code that runs on the transputers is written in occam. As
most programmers will not have used occam before, here are some points that may
make it easier to understand what's been written in this somewhat-unusual but
generally well-thought-out language:

* Like C and Pascal, occam is an imperative, procedural language. (You give
  the computer lists of operations to perform, and these lists can be packaged
  into named groupings that can be used as single operations themselves in
  other lists.)

* Like Python, occam uses indentation to organise nested blocks of code.
  Variables and abbreviations (that is, things like constants and aliases)
  scoped to a block are declared immediately above the block.

* In occam, reserved words like `IF` and `FOR` and `INT` etc. are written in
  all uppercase letters. The language is case-sensitive.

* The underscore `_` isn't available for use in variable and subroutine names.
  Most programs use a dot instead, as in `toledo.ohio` or
  `vegan.beef.stroganoff`. There's no special meaning to `.` in a name: it's
  just like any other valid character.

* Much like C organises multiple operations into blocks surrounded by `{` curly
  braces `}`, and like Pascal does the same with `BEGIN` and `END` keywords,
  occam requires multiple operations to be grouped together into a
  "construction". There are two kinds of constructions: `SEQ` and `PAR`.

  * `SEQ` means: run each of these operations in order, one after the other.

  * `PAR` means: run each of these operations concurrently, in parallel! (In
    practice, the transputer will usually switch between the operations to give
    the illusion of running in parallel: like most single-core CPUs, it can't
    really run more than one process at any one instant.)

* `IF` statements in occam must have at least one branch that gets evaluated,
  or the transputer will hang! The way you say "else" in occam is `TRUE`, and
  the way you do nothing in a branch (similar to `pass` in python) is to say
  `SKIP`.

* The `VAL` keyword declares an immutable alias to the result of an occam
  expression. `VAL foo IS 2 + 2` binds 4 to `foo`. All parameters to procedures
  are assumed to be mutable (see [call by reference](
  https://en.wikipedia.org/wiki/Evaluation_strategy#Call_by_reference)) unless
  they are preceded by `VAL` in the procedure definition, in which case they
  are provided [by value](
  https://en.wikipedia.org/wiki/Evaluation_strategy#Call_by_value), at least
  from the programmer's point of view.

* Version 2 of occam (used here) supports neither recursion nor data structures
  more complicated than arrays.

* There is no precedence among arithmetic operators in occam. You have to use
  brackets (parentheses) to order the operations in an arithmetic expression.
  An ambiguous expression like `1 + 2 * 3` won't even compile.

* Channels are how occam allows you to communicate between concurrent
  processes. A process sends a value into a channel via the `!` operator, as in
  `channel ! 42`, and receives a value from a channel via the `?` operator, as
  in `channel ? the.answer`. Channels are blocking: a sender will wait until
  a receiver collects the value it deposits, or a receiver will wait until a
  sender deposits a value. Beware deadlocks! (See also: [Go](
  https://en.wikipedia.org/wiki/Go_%28programming_language%29#Concurrency:_goroutines_and_channels)).

* Array slicing is available in occam, but slices must be contiguous (there's
  no stepping like in Python): `[my.array FROM first.index FOR slice.size]`.

* `FOR` also pairs up with construction keywords `SEQ` and `PAR` to make
  "replicated" constructions: while `SEQ i = 0 FOR num.iterations` is much like
  a for loop in other languages (except without a way to break out early),
  `PAR i = 0 FOR num.parallel.processes` launches an array of concurrent
  processes in just a few lines of code! There's even `IF i = 0 FOR num.cases`,
  though the significance of this is best left to more authoritative sources.

* `ALT` is a language feature that allows a program to wait for incoming
  messages on multiple channels (for UNIX folks, it's a bit like [select(2)](
  https://man7.org/linux/man-pages/man2/select.2.html)). In this code, the flag
  boss uses it to poll for user input.

* Finally, the `{{{` and `}}}` delimiters mark significant portions of a
  program file for the "F" [folding text editor](
  https://en.wikipedia.org/wiki/Code_folding), one of the utilities INMOS
  provided for transputer development.

If you're now so intrigued by occam that you'd like to learn more, [this book
(PDF link)](https://www.transputer.net/obooks/72-occ-046-00/tuinocc.pdf) offers
a comprehensive tutorial introduction. As an occam learning tool, it will be
better than this program, which (a) is the author's first occam program of any
size and (b) also makes use of some performance optimisations from sources like
[this INMOS technical note](https://www.transputer.net/tn/17/tn17.html), which
make the code a little harder to read.

### A tour itinerary

Go ahead and start with the two files at the heart of the demo:

* [`flagwrkr.occ`](flagwrkr.occ) is most of the flag worker, home to all flag 
  simulation calculations, among other things.
* [`flagboss.occ`](flagboss.occ) is most of the flag boss, featuring concurrent
  dealings with the workers and the PC. There's some awkwardness around
  "headless mode", which was added fairly late as a feature; also, it appears
  that occam lacks a preprocessor like C has, which would have been handy.

You can ignore this one, pretty much:

* [`flaglast.occ`](flaglast.occ) is a convenient wrapper around the flag worker
  code for the topmost flag worker: you don't have to give it channels to talk
  to the worker above it, because there is no worker above it.

You may enjoy seeing some of the graphics code:

* [`flagflag.occ`](flagflag.occ) generates the colour maps for various flags.
  It accomplishes this by interpolating pictures made with arrays of strings
  (a bit like ASCII art but more boring).
* [`cga.occ`](cga.occ) and [`cga.inc`](cga.inc) is what the flag boss uses to
  draw graphics into CGA screen buffers. There are two copies of the same
  routine (for lack of a preprocessor, plus doubts about how well the occam
  compiler does [dead-code elimination](
  https://en.wikipedia.org/wiki/Dead-code_elimination).) One of them draws to
  a flat buffer, where the memory for each successive screen row is arranged
  in a sequential way: this is used for headless operation. The other, for
  all-in-one mode, draws for the actual CGA video frame layout, where all of
  the even rows precede all of the odd rows in memory.
* [`flagdraw.occ`](flagdraw.occ) is more code for the flag boss: this time for
  receiving flag element locations from the workers and drawing them to a CGA
  screen buffer. As above, there are two copies of the routine, one for
  headless mode and the other for all-in-one mode.

Miscellaneous items:

* [`flagconf.occ`](flagconf.occ) is the last of the flag boss's helpers, this
  one for configuring the workers.
* [`intsize.inc`](intsize.inc) is the occam way to say `sizeof(int)`!

Here are the main programs themselves, at least for the code that runs on the
transputers. "Programs" because there are four of them --- once again, a
preprocessor would not be unwelcome:

* [`flagsngl.occ`](flagsngl.occ) runs the flag simulation on a single transputer
  in all-in-one mode. Single-transputer versions will probably run on the
  widest range of transputer setups, at least as long as those setups are on
  PCs running DOS.
* [`flagsngh.occ`](flagsngh.occ) runs the flag simulation on a single transputer
  in headless mode.

The two remaining main programs run on seven-transputer networks like the one
described in the [theory of operation](
#how-the-flag-flies-in-other-words-theory-of-operation) section. These use a
specialisation of occam with additional keywords for "configuration":
describing the layout of the transputer network and which jobs run on which
processors. While these files describe a network of seven transputers, it is
not too difficult to adapt it to a different-sized network if desired.

* [`flagb8.pgm`](flagb8.pgm) runs the flag simulation on the seven-transputer
  network in all-in-one mode.
* [`flagb8h.pgm`](flagb8h.pgm) runs the simulation on seven transputers in
  headless mode. If it runs on your system, this is the best, fastest option.

Finally, some Intel x86 code for a change. If you start the simulation in
headless mode, this is the program you'll need to run to see the flag in
glorious 320x200 4-colour CGA. Although the B008 transputer backplane card
supports DMA, this program simply polls its I/O ports to retrieve data to copy
into video memory. The code uses macros extensively to turn repeated polling
into a (faster) unrolled loop.

* [flagdos.asm](flagdos.asm) is the "head" for headless flag simulation. As
  written, you will need to edit and recompile this file if the base I/O
  address of your transputer backplane expansion card is different than 0150h.


Nobody owns this demo
---------------------

This flag simulation program and any supporting programs, software libraries,
and documentation distributed alongside it are released into the public domain
without any warranty. See the [LICENSE](LICENSE) file for details.


Acknowledgements
----------------

It would not have been possible to write this demo --- or get as much fun out
of it --- without the help of the following people and resources:

* P.B. for giving me a starter set of TRAMs, the B008 board, and transputer
  media.
* Michael Brüstle and his [transputer.net](http://transputer.net) website,
  home to loads of archived documentation, plus updated versions of some
  INMOS transputer support software like `rspy`.
* Ram Meenakshisundaram's transputer resources at
  [transputer.classiccmp.org](http://transputer.classiccmp.org/), especially
  the [software archive](http://transputer.classiccmp.org/software).
* [bitsavers.org](http://bitsavers.org) as usual, for more software and
  documentation.
* Denizens of the `comp.sys.transputer` newsgroup, including the aforementioned
  Michael Brüstle and also Axel Muhr.
* The gang of good folks displaying their favourite retro systems at the 2022
  Retro Computing Festival at the Centre for Computing History in Cambridge.


-- _[Tom Stepleton](mailto:stepleton@gmail.com), 1 December 2022, London_
