
Explain each of it indepth explanation for it just as before

If no, how do you suggest to add it?  Rust built-in?  Python extension?


Alexey Potapov
12:25 PM
Yes, your questions is exactly why we have not yet added it :)
There is a stalled discussion what to do with libraries, which should be built on top of standard grounded types like numbers or strings. On the one hand, having separate implementations for Python space, Rust space, etc. makes some sense. Say, grounded Python objects live in Python space. OTOH, this requires implementing each grounded operation for each space. This might not be extremely terrible if most operations would be implemented for one space. But it's not clear to what extent it will be the case. Many people say that Python is a language used for AI de facto, and it would be easy just to focus on it. But maybe the success for MeTTa could come from its interoperability with other languages to which it could bring the power of AI and be used by people who don't want to use Python for some reason. But if it involves neural networks, it goes back to Python after all. But still having MeTTa space by itself (not Rust space vs Python space) is appealing. But in this case, in order to achieve good interoperability with other languages (which we do want), it will be necessary to make automatic conversion each time the atom goes outside the native space. If one wants to fill in a tensor with a number defined in a MeTTa script, this number should be converted to a Python object to be passed to the corresponding tensor constructor. Or if an element of the tensor is taken and passed to the function defined in MeTTa, it should be automatically converted from the Python object to native MeTTa atom.
Right now, if randoms are implemented in Rust they will not be usable in Python unless there is a grounded function, which can be explicitly called to make this conversion. Maybe, it's not a huge problem to try doing this right now.
Hmm... maybe, we can try doing this even without manual conversion and without introducing breaking changed.

Say, we introduce a grounded function in Rust, we returns a Rust grounded number.
We implement an API function in hyperonpy.cpp, which extracts the numeric value from a given grounded Rust atom and returns it as a Python object.
We extend OperationObject in atoms.py in such a way that if unwrap=True and the given atom is a grounded Rust atom of a numeric type, execute calls the function from (2) instead of trying get_object().content.
If it works, nothing is broken, and we can use random in Rust and see if there is any limitation. Maybe, function (2) should be called not by execute of OperationObject, but by get_object of GroundedAtom. Hmm... I see there is already a similar workaround for GROUNDED_SPACE, in which case instead of just doing hp.atom_get_object(self.catom), SpaceRef._from_cspace(hp.atom_get_space(self.catom)) is constructed. Yeah... this is the perfect place to add more automatic conversion. But we still need the function from (2), because we don't just rewrap a Rust grounding space into a Python object, but convert data.
I believe it would be useful even if we are not going to get rid of arithmetic operations in Python right away.
It doesn't solve the problem of putting Python objects back to Rust functions, though. Well, we can add the backward conversion into OperationObject.exeucte with unwrap=True for numbers and strings. But this will affect how MeTTa operates. This can be considered as the next step... 

Show less

Nil Geisweiller
2:51 PM
I wonder, what about writing such random generator in pure MeTTa?  I understand it would make it quite inefficient.  It also poses the question of how it should behave across non deterministic branches.  Should it "split" (lock-free multi-threaded random generation)?  Or should it interact between parallel branches (global lock)? 

Of course the question of multi-threaded vs single-threaded applies regardless of whether it is implemented in Rust, Python or MeTTa. 


Alexey Potapov
11:43 PM

A pseudo-random number generator can indeed be written in pure MeTTa with the current state either explicitly wrapped into the calls (like in state monad) or kept in the space of the rng library. If the state is passed explicitly, then it will be the same in alternative branches. This can be either a good or bad feature depending on the case. Creating a global state will introduce locks in alternative branches, so they will not be concurrent in principle. Currently, it doesn't matter, but if we want to avoid this, we would need rng to rely not only on the state, but also on something like process / thread / branch id or something like this. It will make rng a special part of the interpreter. When we proceed to stochastic optimization algorithms for the core inference engine, we may find that the interpreter needs its own internal rng, which can be just exposed to MeTTa. Meanwhile, any of Rust / Python / MeTTa rngs can work as a placeholder.

How to implement is-closed in MeTTa?  (EDIT: I have a solution). 

I have something that almost works

;; Return True iff $x is a variable
(: is-variable (-> Atom Bool))
(= (is-variable $x)
   (case (collapse (superpose (let $x 1 True)))
     ((True True)
      (%void% False))))

;; Return True iff $x is closed
(: is-closed (-> Atom Bool))
(= (is-closed $x) (if (is-variable $x)
                      False
                      (case $x
                        ((($abs $arg) (and (is-closed $abs) (is-closed $arg)))
                         ($x True)))))
But it is kinda semi-decidable, i.e. it only terminates if the atom is closed. 

As soon there is a variable, $x unifies with ($abs $arg) and spawns the algorithm in a run-away recursion. 


Nil Geisweiller
3:22 PM
It works, so I won't complain, but I wonder if we can do better, more elegant? 

BTW, it only works for unary expressions, but that's OK in my case.


Nil Geisweiller
3:35 PM
I'm facing again the situation that if I could enforce determinism then I could write a more elegant algorithm, such as

;; Return True iff $x is closed
(: is-closed (->> Atom Bool))
(= (is-closed ($f $x)) (and (is-closed $f) (is-closed $x)))
(= (is-closed $x) (not (is-variable $x)))
January 24, 2024

Alexey Potapov
1:41 PM
@Nil Geisweiller , doesn't (get-metatype $x) work?

This code seems to be working for me

(: is-closed (-> Atom Bool))
(= (is-closed $x)
   (case ($x (get-metatype $x))
      ((($_ Variable) False)
       ((($abs $arg) Expression) (and (is-closed $abs) (is-closed $arg)))
       ($_ True))))
if I could enforce determinism then I could write a more elegant algorithm

Yes, there was a discussion to have annotations for functions to tell the interpreter that they are total, deterministic, etc. But this is not a priority for now. And case is exactly this sequential mutually exclusive pattern matching. It is less declarative, though. We may introduce sequential and parallel composition in the future, but not now.


Alexey Potapov
1:51 PM
This should work for arbitrary expressions

(: is-closed (-> Atom Bool))
(= (is-closed $x)
   (case ($x (get-metatype $x))
      (((  $_   Variable  ) False)
       ((  ()   Expression) True)
       ((($one) Expression) (is-closed $one))
       ((  $_   Expression)
        (let ($car $cdr) ((car-atom $x) (cdr-atom $x))
             (and (is-closed $car) (is-closed $cdr))))
       ($_ True))))
This line ((($one) Expression) (is-closed $one)) is actually not needed

I wanted grounded operations to support custom matching involving their arguments, so such operations could work as deconstructors as well. In this case we may not need let, but could pattern-match against (cons-atom $car $cdr) case, and it would look nicer. But this has also not yet been implemented. 

Basically, it could look like

(= (is-closed $x)
   (case ($x (get-metatype $x))
      ((($_ Variable) False)
       (((cons-atom $car $cdr) Expression)
        (and (is-closed $car) (is-closed $cdr)))
       ($_ True))))


One possibility to is to create a helper: 

(= (cons-atom $car $cdr  $cons)
   (case ...
handle the different input modes ... 

heh actually I still dont know why you guys are using functions at all ..

MeTTa easily compiles to predicates .. better than to functions.. by adding a final argument top the predicate (that represents function's output)..  (in the example given by @Alexey Potapov  cons-atom) the last (hidden) argument is used as in input. 

33 replies

Adam Vandervorst
last year
Heh, actually, I still don't know why you guys are using functions at all.

I tentatively agree with this statement. Except for grounding (which is quite crucial), the MeTTa behavior can be best described in terms of straight unification over predicates.


Douglas Miles
last year
definitely one is allowd to have grounding predicates  (i cant write predicate logic code without having a few predicates that work in jsut one directrion) 


Adam Vandervorst
last year
Can you elaborate on how that's done in SOTA systems?
The last time I looked into that, I was disappointed with the limitations predicate languages posed on grounded functions.

last yr.
(I know about is as opposed to =, but that's hardly satisfactory)


Douglas Miles
last year
#= perhaps.. thius works woith mboth grounded and ungrounded functions

last yr.
``
i need a definition of grounded functions maybe.. like when they actualy need to be 

last yr.
the + operator for example doesnt need to be grounded


Adam Vandervorst
last year
From what I find, #= requires CLP(FD), which is something we have for integers, but not for e.g. hypervectors, or anything else we want to experiment with.


Douglas Miles
last year
oh yeah.. i had to write workaround code for clp(FD)(R)(Q) this to make it work good for MeTTa   :(  https://github.com/logicmoo/vspace-metta/blob/22e3077a2a7ecc655f7cd8b816c42353707082dc/metta_vspace/pyswip/metta_eval.pl#L1361-L1410

all the undeclared math +/-**/abs etc operators are covered by line 1367

Mainly i want to mix and match these interal represeatyions  


Adam Vandervorst
last year
the + operator for example doesnt need to be grounded

The example from yesterday's hypervector call is adding some highly optimized C++ routine on a custom datatype
(MAJ VS)
Or simply think about
(MATMUL A B)


Douglas Miles
last year
ideallyu if it wasnt grounded what would you want to happen?  (this sounds more like eveyones is going to use it properly so it wont matter if is grounded of not) .. this concern it needs to be ground should be fixable with a type check? 


Adam Vandervorst
last year
Not sure how to answer that; how would this not be grounded?


Douglas Miles
last year
exactly its already grounded.. so its fine.. if the function was also an ungrounded function it would still be fine.. (in other words no one needs care if it was grounded .. other than a bug hunting system  and docs reminding the library's user they need to use sane values) 


Adam Vandervorst
last year
What would the default behavior be here making it fine?


Douglas Miles
last year
the default behavour is that if you give its usable values it will return useable results.. sort of exactly like is is 

last yr.
but is can be expanded to take ungrounded values as well.. and that would not damage its grounded behaviour .. So i was saying that about ther C++ functions as well.. it would be ok for the C++ functions to become twice as capable 


Adam Vandervorst
last year
You know what, I'll just implement it and we can try it haha


Douglas Miles
last year
there is a merit to what you arte sayingh.. "we have lib functions that cant handle ungrounded terms .. they are fast .. we are not going to change them" 

last yr.
it should just have no impoact of design or impl of metta


Adam Vandervorst
last year
Having written WebMeTTa, although match is excellent, the current evaluation semantics don't scale to an app.
Temporal streams would make it more usable. But there are many options.


Douglas Miles
last year
how it iterates could represent either temporal or spatial? 


Adam Vandervorst
last year
That's the billion dollar question. @greg.meredith proposed to overload them using monadic comprehension.

last yr.
OpenCog Classic just has them as a second-class citizen.

last yr.
I think @Luke Peterson proposed doing it implicitly (so all spatial operators (well, mainly transform) get updated over time).

last yr.
There's one thing we can not do, and that's ignore it.


Robert Haas
last year
What meaning of temporal and spatial are you referring here to? Do these terms have a life of their own in the context of computation? 


Adam Vandervorst
last year
@Robert Haas what if there are non-user inputs to the system? E.g., a sensor adding a data point to a space.
Currently, you'd need a callback or clock to check and gather updates, which is neither native nor elegant.

You could listen for this using a comprehension, or you could have a mechanism that automatically propagates the addition through the queries over that space.


Robert Haas
last year
Sounds like a space with multiple write and multiple read requirement, where it doesn't matter if the user is a human or a machine. How to fulfill that requirement elegantly is beyond my capability to talk about. I was just wondering if temporal and spatial are used as technical terms in models of computation, or if it refers to the usual meaning of the words.


Adam Vandervorst
last year
So spatially, you'd have a match statement match &positions (Near Edge $x) Backoff.
And temporally you have updates to the content of the space.

Note you don't strictly need this functionality to be native (e.g. Haskell or Scala's Typelevel stack compile to a while loop), but I believe it'd be a mistake to be satisfied with that solution at this stage.


Ben Goertzel
last year
"I was just wondering if temporal and spatial are used as technical terms in models of computation, or if it refers to the usual meaning of the words." ==> Temporal has the standard meaning.  Spatial refers to "spread across distinct locations with a cost of getting info from one location to another" but the degree of spatial-ness in this sense is not equivalent to the degree of spatial-ness in the physical world.   I.e. you can have two physically distant memory locations in a computer memory that are not spatially separated in a computational sense, because the computational model in question treats them as if they're in the same place.

last yr.
@Adam Vandervorst some languages use comprehensions to provide concise manipulation of streams, right?  


Adam Vandervorst
last year
Yes, correct @Ben Goertzel 
Here's an example of a quadruple sequenced for comprehension on temporal streams in Scala
https://fs2.io/#/guide?id=asynchronous-effects-callbacks-invoked-multiple-times


Adam Vandervorst
last year
There's a joke that Swift has 4 different keywords for handing a) things that can fail, b) things from collections, c) things from the future, and d) things that may not be present, while Scala just has for with the Try, Iterable, Future, and Option monads.
This is the power of the monad abstraction: it's a uniform interface. 


Thread
Metta Coders
Follow

Alexey Potapov
last year
@here 
Head up. We are going to merge https://github.com/trueagi-io/hyperon-experimental/pull/580 , which is half-baked, but we need to eat an elephant one bite at a time. Some known backward incompatibilities atm although the tests are green (meaning that we need more tests):

`extend-py!` is merged with `import!`, so you should use `!(import! &self my-extension)` now. .py should not be included . Importing from paths doesn’t fully work now. But this provides a way for a module to load a space and tokens all together.
`load_py_module` and `import_file` are now absent in Python API. There are other functions, but they don’t have the same functionality. If one used, `MeTTa().import_file(“path-to-my-file”)` before, it is necessary to load the file and use `MeTTa.run` on its content. Instead of `load_py_module`, one can try running `!(import! &self my-python-module)`
There are also some other differences. For example, stdlib is added as a space in any module imported into its own space.

Please report your issues on github and use the release https://github.com/trueagi-io/hyperon-experimental/releases/tag/v0.1.6 if there are no workarounds atm.

Show more
3 replies

Adam Vandervorst
last year
Not sure if a bug or intended change: &self used to refer to space a statement is evaluated from, and now it seems to refer to the space it was written in.

; utils.metta
(= (transform $pattern $template) (match &self $pattern $template))
; main.metta
(import &self utils.metta)
(A X)
(transform (A $x) $x)
; now [], used to be X

Alexey Potapov
last year
@Luke Peterson

Alexey Potapov
last year
@Adam Vandervorst , please, raise an issue on github. I don't have strong opinion on whether this bug or desirable behavior. I needs some discussion


hedra
last year




Iterating through the contents of the space: importing vs creating a new-space

The following works,  


!(bind! &db (new-space))
!(add-atom &db (test 5 6))
!(add-atom &db (test 7 8))
!(add-atom &db (test 9 10))

;; test
!(let ($a $b $c) (get-atoms &db) $b)
!(match &db ($a $b $c) $b)
But, this one doesn't,

!(import! &db sample)
;; sample.metta contains the following
; (test 5 6)
; (test 7 8)
; (test 9 10) 

;; test
!(let ($a $b $c) (get-atoms &db) $b)
!(match &db ($a $b $c) $b)
I am testing with minimetta, i.e It is set default = ["pkg_mgmt", "minimal"] 

6 replies

hedra
last year
@Vitaly Bogdanov please have a look at this one as well.


Vitaly Bogdanov
last year
I guess the reason is that imported space includes stdlib as an additional atoms inside. @hedra could you please paste the result of the !(get-atoms &db) ?


hedra
last year
[(test 9 10), (test 7 8), (test 5 6), GroundingSpace-top:corelib, GroundingSpace-top:stdlib]


Vitaly Bogdanov
last year
So yes, I am right, it is because import adds stdlib into an imported space. @Luke Peterson works on include! feature, which will behave exactly as you expect. It will add all atoms but not import stdlib.


hedra
last year
Thank you Vitaly. No need to raise an issue on github I guess.


Vitaly Bogdanov
last year
Yes, I believe @Luke Peterson has one


Douglas Miles
last year
Ahah,


!(import! &kb go_rel)

(: bc (-> $a Nat $a))
(= (bc (: $prf $ccln) $_1) (match &kb (: $prf $ccln) (: $prf $ccln)))
(= (bc (: ($prfabs $prfarg) $ccln) (S $k))
   (let* (((: $prfabs (-> $prms $ccln)) 
                      (bc (: $prfabs (-> $prms $ccln)) $k))
          ((: $prfarg $prms) 
                      (bc (: $prfarg $prms) $k)))           
     (: ($prfabs $prfarg) $ccln)))

!(bc (: $prf (member $g $o $k)) (S (S (S Z))))
works

vs


(: bc (-> $a Nat $a))
(= (bc (: $prf $ccln) $_1) (match &kb (: $prf $ccln) (: $prf $ccln)))
(= (bc (: ($prfabs $prfarg) $ccln) (S $k))
   (let* (((: $prfabs (-> $prms $ccln)) 
                      (bc (: $prfabs (-> $prms $ccln)) $k))
          ((: $prfarg $prms) 
                      (bc (: $prfarg $prms) $k)))           
     (: ($prfabs $prfarg) $ccln)))

!(import! &kb go_rel)

!(bc (: $prf (member $g $o $k)) (S (S (S Z))))
does not.. 

[()]
[()]
[(Error (match &kb (: $prf (member $g $o $k)) (: $prf (member $g $o $k))) match expects a space as the first argument)]
this is because 

&kb is not defined at the time the backchainer code is defined?  @Vitaly Bogdanov @Luke Peterson   

Show more
5 replies
last yr.
@hedra @Nil Geisweiller  @Abdulrahman Omar 


Nil Geisweiller
last year
Yeah, Hedra and I have experienced that, that is also why we tend to pass the kb in argument instead.


Vitaly Bogdanov
last year
Yeah, it is a know restriction of the bind! and import!. Both operations adds bound symbol to the tokenizer which mean it is applied only to the code which is parsed after !(import! ...) or !(bind! ...).

As a workaround one can add function which is defined after call to bind! or import! and returns new symbol. Then use this function instead of original symbol. For example this should work:

(= (bc ...) .... (kb) ...)

!(import! &kb go_rel)
(= (kb) &kb)
last yr.
As a long-term fix we could implement beta-reduction of constants (see https://github.com/trueagi-io/hyperon-experimental/issues/134) and add (= &kb <grounded-space>) into the space instead of adding symbol into tokenizer. 


Douglas Miles
last year
that (= &kb <grounded-space>)  makes sense since when it is all about finding &kb within the space scope resolution .. not the tokenizer 


Roman Treutlein
last year
How can i add the results of a match into a space? add-atoms expects a single atom instead of a list.

2 replies

Nil Geisweiller
last year
If the results are in superposition, then the following should work

(let $one-result MY-SUPERPOSED-RESULTS (add-atom SPACE $one-result)

Nil Geisweiller
last year

@Roman Treutlein, just found out about add-reduct should do what you're looking as well

okay figured it out don't to (add-atom kb (match ..)) but (match kb _ (add-atom kb var))


hedra
last year
Is this a bug?

!(let $dummy (superpose (1 2 3)) (test)) ;; returns [(test), (test), (test)]
!(let $dummy (1 2 3) (test)) ;; returns [(test)]
I have a usecase like the first and its giving me a bunch of results

2 replies

Douglas Miles
last year
those are correct returns values.. the first one superpose converts a list to an iterator  and the  system iterates out the 3 elements. and (test) is returning itself each of those times 


Douglas Miles
last year
if the first one gives more or less than three there is a bug 
Roman Treutlein
last year
Is there a way to save a space to a file?



4 replies

Douglas Miles
last year
in MeTTalog you can add a function to do this like...

!(add-atom &corelib
 (= (save-space! $0 $1)
  (setup-call-cleanup!
    (open! $1 write $2 ())
    (with-output-to! $2
      (forall!
        (get-atoms! $0 $3)
        (write-src! $3)))
    (close! $2)))))
but not in regular metta 

last yr.
mettalog is compiled to a host language that has crazy amount of predefined functions with-output-to open close etc  

last yr.
( the whole of the mettalog interpreter is redefinable in itself this way as well  .. i mean introspectable / and changable) 


Roman Treutlein
last year
guess i'll have to take a closer look at MeTTalog


How to use type-check pragma?  I tried the following

!(pragma! type-check no)

(: foo (-> Bool Bool))
(= (foo $x) $x)
!(foo 42)
without success.  I replaced no by false, False or 0, but still no success (i.e. (foo 42) is still typed checked).  Any idea?



Alexey Potapov
last year




If you need to turn off type-checking completely, then it is not implemented. If it is necessary, we can discuss if we have bandwidth to do this.

2 replies

Nil Geisweiller
last year
I have a work around, I simply use my backward chainer on new symbols instead of existing typed symbols, but it would indeed be more convenient if I could turn it off completely.

last yr.
This can wait for after AGI-24.



Metta Coders
Follow

Douglas Miles
11 months ago
what was the name of the function that    (<function> foo) ==> (f o o)    ? 

3 replies

Douglas Miles
11 months ago
OK I found https://chat.singularitynet.io/chat/pl/5i4jhhfy3j8hfy4n8ph6cs68so

Nil Geisweiller
September 12, 2023
We have Char primitive type, not just String, so I was thinking, instead of "test" being sugar syntax for (string (t e s t)), we may have functions to convert strings to tuples of chars and back, such that (string->chars "test") == ('t' 'e' 's' 't') and (chars->string ('t' 'e' 's' 't') == "test").  The names chars->string and string->chars are illustrative, please suggest better names if you have some.

Show more
Only visible to users in ~Metta Coders
11mo ago
So the final name was stringToChars i guess 


Nil Geisweiller
11 months ago
Yes, in principle it is complete, but I find it cumbersome to program and slow to run.  I think we need 


Roman Treutlein
11 months ago
I am using NIls curried chainer and want to filter the output to contain only outputs where the Rules where applied completely this is done by:

(= (clean $a)
    (case $a
     (((: $prf (-> $c $d)) (empty))
      ($_ $a))))
But for some reason this only returns a single result even if there are multiple
I tested it with a simple non deterministic function and there it works.
The only difference between that function and the chainer output is that the chainer output is wrappen in 2 brackes so [[(expr1),(expr2),...]] instead of just on [(expr1),(expr2),...]

7 replies

Nil Geisweiller
11 months ago
@Roman Treutlein, you wish to filter out results with theorems that start with implication, correct?

11mo ago
Note that case performs a full unification in MeTTa, so for instance if you call (clean (: Axiom $thrm)) it will actually be filtered out because $thrm unifies with (-> $c $d). 

11mo ago
I've been advocating for MeTTa to also support single-sided unification https://github.com/trueagi-io/hyperon-experimental/issues/674

GitHub
MeTTa should support single sided matching · Issue #674 · trueagi-io/hyperon-experimental
Describe the bug I believe MeTTa should seamlessly offer single sided matching alongside double sided matching. In the sense that the developer should be able to easily specify when reduction shoul...

MeTTa should support single sided matching · Issue #674 · trueagi-io/hyperon-experimental
11mo ago
In the meantime you may do that is by deconstructing the term yourself, see for instance https://github.com/trueagi-io/chaining/blob/5bdeb8edb0e38784c52a669adfcea05474b68dd5/experimental/converters/calculi-converter.metta#L553

GitHub
chaining/experimental/converters/calculi-converter.metta at 5bdeb8edb0e38784c52a669adfcea05474b68dd5 · trueagi-io/chaining
MeTTa module containing various flavors of backward and forward chaining, as well as converters between these flavors. - trueagi-io/chaining

chaining/experimental/converters/calculi-converter.metta at 5bdeb8edb0e38784c52a669adfcea05474b68dd5 · trueagi-io/chaining
11mo ago
which basically is a combination of case over the metatype of a term, followed by if-then-else constructs.  It feels a bit like we're back to C++. 


Roman Treutlein
11 months ago
@Nil Geisweiller no i want to filter out rules that where not applied completely for example  (: (ModusPonens ab) (-> A B))) ModusPonens has 2 premisis in the above only 1 was applied. So it has nothing to do with implications. So in your example if we had $thrm on the end then filtering this out would be totally fine.
It seems the issue only happens if i call that from python in metta directly there is no issue.


Nil Geisweiller
11 months ago
I meant implication as in the arrow type.

I've just cloned two of the MeTTa implementations, built the Docker images locally, and uploaded them to my docker.io account. They can be used as follows:

mettalog
docker pull antecedens/mettalog-2024-08-28
docker run -it antecedens/mettalog-2024-08-28

# interactively
mettalog --repl
!(/ 355 113)
# press CTRL+D to exit the REPL

# non-interactively
echo '!(/ 355 113)' > test.metta
mettalog test.metta
# not sure how to prevent the prolog warning of "Found file test.metta relative to the current working directory."
hyperon-experimental
docker pull antecedens/he-2024-08-27
docker run -it antecedens/he-2024-08-27

# interactively
metta-repl
!(/ 355 113)
# press CTRL+D to exit the REPL

# non-interactively
echo '!(/ 355 113)' > test.metta
metta test.metta
You can also mount a local folder in the containers by passing an additional argument to the docker run command. This enables you to edit .metta files on your normal operating system and run them inside the containers (without having to restart them in between and without having to move files around):

mkdir $HOME/my_metta_files
docker run -v "$HOME/my_metta_files:/my_metta_files" -it antecedens/he-2024-08-27
cd /my_metta_files
# Create test.metta with your favorite editor in the local directory my_metta_files in your home
metta test.metta


Follow

Douglas Miles
10 months ago
i am documenting some of the Python functions

;; Public MeTTa
(@doc py-list
  (@desc "Converts a MeTTa Expression into a Python list and returns it as a PyObject.")
  (@params (
    (@param (@type Expression) (@desc "A MeTTa List that will be converted into a Python list"))
  ))
  (@return (@type PyObject) (@desc "A Python list object that represents the given MeTTa Expression as a PyObject"))
)
(: py-list (-> Expression PyObject))
;; Implemented from Interpreters
Is this too much?

(:> ValueAtom Atom)
(:> ValueAtom Grounded)
(:> ForeignObject ValueAtom)
(:> PyObject ForeignObject)
1 reply

Douglas Miles
10 months ago
or should i go further and even make py-list return a  PyList 
PyList  -> PyCollection -> PyObject
make py-tuple return a PyTuple 
and ``PyTuple -> PyCollection` ? 


Douglas Miles
8:12 AM
Should we treat argument type Expression as non evaluable the way we treat Atom like in the case of format-args?  Example is https://github.com/trueagi-io/metta-wam/blob/main/src/canary/stdlib_mettalog.metta#L1022

8:12 AM







 (let () (println! (format-args "Function {}: {} {}" ($item $type $descr)))
when $item was a function that took two arguments there was a problem here obviously

or in the case of 

 (format-args "{} {} {}" (+ 1 1))


Follow

Ben Goertzel
10 months ago
simple dumb metta syntax question... why doesn't this work?

; Define Cons as a simple pair of head and tail
(: Cons (-> A A A))
(= create-list (cons 1 (cons 2 (cons 3 ()))))

; Force the evaluation by calling the function and printing the result
!(create-list)

21 replies

Adam Vandervorst
10 months ago
Perhaps you meant to write(= (create-list) (cons 1 (cons 2 (cons 3 ()))))


Ben Goertzel
10 months ago
Hmm, 

10mo ago
; Define Cons as a simple pair of head and tail
(: cons (-> A A A))
(= (create-list) (cons 1 (cons 2 (cons 3 ()))))

; Force the evaluation by calling the function and printing the result
!(create-list)

gives 

[(Error 1 BadType)]

In MeTTa Playground... 

10mo ago
...

10mo ago
I have not played with MeTTa code in sometime, I guess it shows ;)

10mo ago
whereas

; Define Cons as a simple pair of head and tail
(: cons (-> A A A))
(= create-list (cons 1 (cons 2 (cons 3 ()))))

; Force the evaluation by calling the function and printing the result
!(create-list)

gives

[(create-list)]

10mo ago
I guess some minor variation will give

(1 2 3) 


Adam Vandervorst
10 months ago
What would type A be instantiated to?

10mo ago
You may want something like (: cons (-> $T $A $A))


Ben Goertzel
10 months ago
that doesn't help but maybe something in that direction will...

10mo ago
time to leave for Qorxi's soccer practice, will experiment again this Pacific evening...


Adam Vandervorst
10 months ago
What's the goal for writing cons?

10mo ago
You may be looking for cdr-atom/car-atom/cons-atom 

10mo ago
E.g.

(: cons (-> $T $A $A))
(= (cons $t $a) (cons-atom $t $a))
(= (create-list) (cons 1 (cons 2 (cons 3 ()))))
!(create-list)

Ben Goertzel
10 months ago
Ah yah that works 

10mo ago
Thanks!

10mo ago
I have no direct goal with this code snippet, just using it to try to isolate/debug a problem with a bigger piece of code ;)


Ben Goertzel
10 months ago
Still it would be good to fully grok why the other variants fail...


Ben Goertzel
10 months ago
I also wonder why the output is

[(1 2 3)]

and not just

(1 2 3)

???


Adam Vandervorst
10 months ago
Well, everything is a superposition, even single results 


Alexey Potapov
10 months ago
@Ben Goertzel 

Still it would be good to fully grok why the other variants fail..

This code:

(: cons (-> A A A))
(= (create-list) (cons 1 (cons 2 (cons 3 ()))))
doesn't work, because A is a symbol (not a variable), and 1 is not of type A.

I'm somewhat surprised that this works atm:
```
(: cons (-> $A $A $A))
(= (create-list) (cons 1 (cons 2 (cons 3 ()))))
``
It shouldn't work because 3 and () should have different types, but () is typed as %Undefined%. But it works in sense it doesn't return type error (that is, cons works as a constructor).


Roy Ward
9 months ago
A question about let* - are the bindings considered to be done in parallel like the LISP let*?

I want to do something like this where the $y depends on the $x:

(let* (($x (f $otherstuff)) ($y (g $x))) ...)
It seems to work in both MeTTalog and the Rust version of MeTTa, but that could be just those implementations. Should I convert it to the slightly more verbose:

(let $x (f $otherstuff) (let $y (g $x) ...))
It's not quite analogous to LISP, as the LISP let allows multiple parts and specifies sequential binding, whereas the MeTTa let only allows a single binding. 

25 replies

Douglas Miles
9 months ago
I've seen people in Metta get multiple bindings in a single let

!(let ($item1 $item2)  ((+ 1 2)  (+ 3 4))
   (+ $item1 $item2))
This would have to be parallel 


Douglas Miles
9 months ago
so far everyone uses let* as if it is supposed to be done sequentially .. but good question..  is it supposed to sequential or parallel ? 


Roy Ward
9 months ago
Maybe I'll ask about that in study group


Patrick Hammer
9 months ago
So far it was behaving sequentially which we also exploited in MeTTa-NARS, and at some point I remember Alexey also proposed it as a way to handle sequential execution so I assume that is the intended behavior.


adricktench
9 months ago
docs suggest sequential is intended
https://metta-lang.dev/docs/learn/tutorials/stdlib_overview/control_flow.html#let-1


Douglas Miles
9 months ago
guess one can do...

(= (progn $n) $n)
(= (progn $1 $n) (let* (($_ $1)) $n))
(= (progn $1 $2 $n) (let* (($_ $1)($_ $2)) $n))
(= (progn $1 $2 $3 $n) (let* (($_ $1)($_ $2)($_ $3)) $n))
(= (progn $1 $2 $3 $4 $n) (let* (($_ $1)($_ $2)($_ $3)($_ $4)) $n))

Patrick Hammer
9 months ago
@adricktench: good catch, thank you!

9mo ago
@Douglas Miles I also have a generator for these functions in MeTTa in case you need it. :)


Douglas Miles
9 months ago
would love to see it.. probably can use it to

9mo ago
also what all functions are you generating?  it would be nice to just fully implement a scheme or lisp in metta so that people can already know it first. then learn all the new tricks that unificiation and nondeterminism adds

9mo ago
and CLP/Constraint Narrowing and laziness and all the other features that would be too difficult to do without metta


Alexey Potapov
9 months ago
yes, let* is supposed to be sequential


seb
9 months ago
@Douglas Miles how would you type that if one function can take variable no. of args?


Douglas Miles
9 months ago
i am assuming a person has to write a type declarations for each arity

9mo ago
Rather than calling each arg an Atom it would be nice to say something better like  Evaluable 


seb
9 months ago
okay but then wouldn't your output be cluttered with (Error IncorrectNumberOfArguments) or the like? can be easily filtered out I suppose when using the result tho


Roy Ward
9 months ago
For Douglas's example:

!(let ($item1 $item2)  ((+ 1 2)  (+ 3 4))
   (+ $item1 $item2))
It would make sense that that is parallel, and that's a property of evaluating a two element list before assigning to a two element list, not the let or let*. It's nice to be able to do that, as it allows parallel and sequential behavior to be mixed and matched to some extent.

It would also be worth adding a note about sequential evaluation to the @doc so as to not trip up anyone coming from LISP. @doc was the first place that I looked. 


adricktench
9 months ago
i am assuming a person has to write a type declarations for each arity

society if MeTTa had actual support for variable-arity functions & named arguments



Vitaly Bogdanov
9 months ago
@seb, @adricktench, one way to handle variable number of args is to pass them as a tuple to a function and analyze the tuple inside a function's body:

(: varargfoo (-> Expression ...))
(= (varargfoo $args) ...)
!(varargfoo (arg1 arg2))
!(varargfoo (arg1 arg2 arg3))
but then it cannot be called using (varargfoo arg1 arg2 arg3).


Nil Geisweiller
9 months ago
One can also write a function generator to generate arbitrary n-ary versions, and insert the functions back to &self.


Nil Geisweiller
9 months ago
BTW, is there any variadic built-ins in MeTTa?  I can't think of any (+ is binary, so is and, etc).

9mo ago
So if there is no variadic built-in, then I suppose it makes adding variadic function support somewhat optional. 


Vitaly Bogdanov
9 months ago
It is possible to write a variadic grounded function. For instance import! is variadic as far as I remember. It is not possible to write variadic function in MeTTa.


Vitaly Bogdanov
9 months ago
For example one can try writing (call-vararg <function> <arg1> <arg2> ... <argN>) which tries both (<function> <arg1> ... <argN>) and (<function> (<arg1> ... <argN>)).  Thus it will be able to call both variadic and non-variadic <function>.

9mo ago
If it is interesting I can try doing it.


Roman Treutlein
9 months ago
I was playing around with dependent types in metta but it seems the type checker doesn't yet check the body of functions as i can define the following:
(: mapV (-> (-> $a $b) (Vec $n $a) (Vec $n $b)))
(= (mapV $f empty) (cons 1 empty))
The type definition indicates that the output vector will have the same length as the input but the function violates that.

1 reply

Nil Geisweiller
9 months ago

@Roman Treutlein, the MeTTa built-in type checker does not support dependent types, but you can type check your function using the backward chainer!  Let me know if you need more help.


Are there recommended ways to count 1) all Atoms in a given space, 2) Atoms of particular types in a given space, 3) elements in a match result? I've searched the channel and saw some discussions about using a grounded function, perhaps adding counts to the space API, etc. but I'm not sure what the outcomes are to date.

I'm roughly having in mind equivalents to SQL queries such as

SELECT COUNT(*) FROM nodes
SELECT COUNT(*) FROM nodes WHERE type == "Disease"
SELECT COUNT(*) FROM nodes WHERE id LIKE "%Leukemia%"
The last example leads to another question: Is there a recommended way to do substring matching against all Atoms of a space? I suppose a grounded function is the default way to dissect Atoms given their atomic nature in MeTTa itself? 

5 replies

Vitaly Bogdanov
9 months ago
First two queries can be represented in the following way:

(: a A)
(: aaa A)
(: b B)
(: bbb B)

a
aaa
b
bbb

(= (count $x)
   (if (== $x ())
     0
     (+ (count (cdr-atom $x)) 1)))

!(count (collapse (match &self (, $x (: $x C)) $x)))
!(count (collapse (match &self (, $x (: $x A)) $x)))
If we presume atom types are kept in the space in an explicit form.

If atom types should be extracted you can do it in the following way:

(= (check-type $x $type)
   (let $real-type (get-type $x)
     (if (== $real-type $type) $x (empty))))

!(count (collapse (match &self $x (check-type $x C))))
!(count (collapse (match &self $x (check-type $x B))))
Also one can use match-types internal function to check whether atom type can be casted to the specified:

(= (check-type' $x $type $space)
  (let $res (type-cast $x $type $space)
    (if-error $res (empty) $x)))

!(count (collapse (match &self $x (check-type' $x C &self))))
!(count (collapse (match &self $x (check-type' $x B &self))))
Show more
9mo ago
 Is there a recommended way to do substring matching against all Atoms of a space? 

I would say the proper way of doing it is to add couple of functions: atom-to-string and like-string and then similarly to example above add filter:

(= (check-like $x $str)
  (let $str' (atom-to-string $x)
    (if (like-string $str' $str) $x (empty))))

!(count (collapse (match &self $x (check-like $x C &self))))
!(count (collapse (match &self $x (check-like $x B &self))))

Robert Haas
9 months ago
Thanks for the swift reply and the nice examples. I wasn't aware of cdr-atom yet. Is there a similar built-in to get only unique items in a list? There seems to be a built-in unique function but I've not figure out how to use it. I'd like to use !(some-func (a b a b c)) to get (a b c).

9mo ago
Or an argument to the pattern matcher so that each item in the results is present exactly once.


Douglas Miles
9 months ago

!(collapse (unique (superpose (a b a b c)))) 

ouglas Miles
9 months ago




 Rust MeTTa if it fails a assertEqual test it dies on the whole file.. so effectively the Rust system only works with one assertEqual* per file?   This is somewhat recent behaviour  Maybe it never used to fail tests so no one noticed :)   I am trying to get an accurate comparison between it an MeTTaLog .  Any way to change that the Rust dies on the first failure? 

6 replies

Douglas Miles
9 months ago
I asked GPT-4

If you’re running tests and want the test suite to continue running after an assertion fails, you can use cargo test --no-fail-fast. This prevents the test suite from stopping after the first failure and ensures that all tests are run, regardless of failures.

Rust itself doesn’t have a RUST_ASSERT_KEEP_GOING environment variable, but you can control panic behavior with RUST_BACKTRACE and panic = "unwind" or panic = "abort" (set in Cargo.toml). 


Alexey Potapov
9 months ago
It was the intended behaviour - the program stops, when a critical error occurs. This behaviour has nothing to do with Rust, I believe. It's more a question to the runner, which just stops, when the current atom is evaluated to Error-expression.
I understand your concern regarding running getting all error messages from one unit test script. Whether evaluation continues after receiving Error expression or not could be controlled by pragma. @Vitaly Bogdanov , what do you think?


Vitaly Bogdanov
9 months ago
It can be implemented as a pragma though I am not sure if pragma is convenient for the @Douglas Miles purposes. Only if one sets it in the global metta config file.

9mo ago
It is also a question for me do we want to return Error from assert... functions or something else to not stop the program.


Alexey Potapov
9 months ago
Well, the very purpose of assert... is to throw an exception, which typically terminates the program. Maybe, we can replace assert... with something else in unit tests if it is desirable to collect all the errors.


Vitaly Bogdanov
9 months ago
Or wrap them by some Error handler. Current implementation of the assert... is not convenient for using inside functions to check invariant because assert... returns () in case of success. Thus if we are going to use asserts more widely than for testing I would suggest changing signature to something like (-> Atom Atom Atom Atom) one more argument to return in case check is successful.
In any case usually test runners doesn't throw error to the runtime by instead collecting them to provide statistics to the user. Thus I would also suggest adding some outer wrapper to collect errors.


adricktench
9 months ago




I have a question about typing. (Perhaps the advanced typing tutorial would contain the answer, but it is still "coming soon" https://metta-lang.dev/docs/learn/tutorials/types_adv/intro.html)
I want a function that takes a type as an argument and the result is of that type. i.e. (eval-for Atom Type) which returns the result(s) of evaluating Atom that are of Type.
How can I fully specify that in the type system? (-> Atom Type Atom) is weak because the result should be of the type of the arg2. (-> Atom $t $t) is incorrect, the result is not the same type as the arg2 it is of the type of the arg2, and I still want to restrict the arg2 to be a Type.
I imagine writing something like (-> Atom Type @arg2), but I don't know if MeTTa allows for such a thing or what the syntax actually looks like.

7 replies

Nil Geisweiller
9 months ago
I'm not 100% sure what you mean, @adricktench, could you provide a code sample with the desired out?


adricktench
9 months ago
Sure, for example

(= (foo) 1)
(= (foo) "a")

!(foo) ;; [1, "a"]
!(eval-for (foo) Number) ;; [1]
!(eval-for (foo) String ;; ["a"]
The question is, what can the type declaration for eval-for be that captures both that the arg2 must be a type and that the return is of that type?


Nil Geisweiller
9 months ago
I see, I remember doing something like that in Idris by providing typing information in the call, I forgot the exact syntax but I could look it up, if that can be used as a source of inspiration.  What do you think, @Alexey Potapov, @Vitaly Bogdanov?

9mo ago
I suppose translated to MeTTa that would just be

(: (foo) Number)
to output [1], and

(: (foo) String)
to output ["a"], but maybe that would be more tricky than that.


Vitaly Bogdanov
9 months ago
My understanding the original question is "how to specify such type" of the eval-for function. @adricktench unfortunately there is no syntax in MeTTa to specify exactly what you described. There is metta function which has the similar type signature and I used (: -> Atom Type Atom). You are right it is weak but it is only possibility I see for now.


Douglas Miles
9 months ago
this would work in simple cases?
 

(: only-string (- > String String))
(: only-number (- > Number Number ))

(= (only-string $v) $v)
(= (only-number $v) $v)

(: eval-for (-> Atom Type Atom))
( = (eval-for $v $type)
   (case $type
    ( String (only-string $v))
    ( Number (only-number $v))
  ....))
    


Vitaly Bogdanov
9 months ago
@Douglas Miles you are right, if it is possible to list all of the types it should work for sure.



timverhaegen
8 months ago




hey,
I'm building a little MeTTa library for interacting with the ETH network. I want to implement event listeners & build a KG from incoming transactions (bit like TheGraph). What would be the best way to achieve the necessary inversion of control?

my current solution looks like this:

!(import! &self metta-web3)

(= (process-tx $from $to $amount)
    (
        superpose (
            (println! (TRANSACTION ALERT: $from sent (/ $amount 1e18) AGIX to $to))
            (add-atom &self (Transaction ($from $to (/ $amount 1e18))))
        )
    )
)

!(AAA)
!(transaction process-tx)
!(BBB)
as expected, it prints AAA but not BBB, as the transaction grounded atom from my MeTTa library opens a WS connection and listens for events

Show more
11 replies

Adam Vandervorst
8 months ago
I believe @Douglas Miles had a somewhat clear answer for this in MeTTaLog.
We do need to figure out a general solution in any case but I believe 

@Alexey Potapov's thoughts are to have spaces communicate with each other via sending over atoms or grounded match
Linas' (retired) thoughts are to construct a data flow graph that an async kernel can then handle
@greg.meredith's thoughts are the operations (at the finest level) are submitted to an async (parallel) kernel
I've tried all three and each has its advantages and disadvantages. Notably Greg's solution I've implemented in CZ2 (predecessor to MORK) and it works quite well, but I didn't figure out how to do multiple (duplicate) atoms efficiently. Linas' solution requires just a choice of framework (e.g. https://github.com/TimelyDataflow/timely-dataflow) which @Luke Peterson may like to help you with. Alexey's solution can be implemented via Python-driven callbacks (somewhat ugly, but it works since you can call eval on custom grounded atoms). 


timverhaegen
8 months ago
I don't quite understand the commonality between these solutions. I like the idea of an asynchronous kernel using an event loop. Going to play around with that for a bit... is it possible to create external MeTTa libraries in Rust currently?


Adam Vandervorst
8 months ago
All of them are ways to achieve an inversion of control. 

8mo ago
You can create grounded ops like so for experimentation https://github.com/trueagi-io/hyperon-experimental/blob/05968709a91c203e76e3318228ea84db277d4523/lib/src/metta/runner/stdlib_minimal.rs#L1041

8mo ago
You likely want to ask the question of how to create a Rust library for HE to @Vitaly Bogdanov, though


Luke Peterson
8 months ago
Do i correctly understand that you have your own rust program that links hyperon-experimental, and you want to add your own grounded atoms or space implementations, implemented in rust? 


timverhaegen
8 months ago
I have a python module that registers some grounded atoms:

@register_atoms(pass_metta=True)
def web3_atoms(metta):
    result = {
        "transaction": OperationAtom(
            "transaction", lambda cb: [ValueAtom(transaction(metta, cb))], unwrap=False
        ),
        "bind-remote!": OperationAtom(
            "bind-remote!",
            lambda space_ref, domain, path, token: import_space(metta, space_ref, domain, path, token),
            unwrap=False,
        ),
        "write-atom!": OperationAtom(
            "write-atom!",
            lambda space_ref, atom: [ValueAtom(write_atom(metta, space_ref, atom))],
            unwrap=False
        )
    }

    return result
The problem is that the interpreter is synchronous & blocking

Show more
8mo ago
The core problem seems to me that you have to go "all the way" in terms of async code, it needs to be part of the interpreter, you can't create an event loop in the library I'm creating


Douglas Miles
8 months ago
yes, in mettalog, i had to design a completely new type of async interpreter where the entire thing keeps track to do/undo/redo/etc .. the only backend language that was designed to support the chaining (async and sync chaining) was what i used/created in mettalog.    Admittedly i designed it over 24 years ago, and not very many companies and applications need the sort of powers it offered ..  but CYC did in order to scale (that was why , despite the fact i had no secretary clearances in 1999 , i was asked to recreate the CYC under my system).  MeTTa also needs "it" in order to scale.

"it" = 

you have to go "all the way" in terms of async code

yes.. and even synchronous code needed it .. sometimes i have simulated this from linked streams or iterators.  but that still requires "all the way" as you say..  as an example when i access certain languages in mettalog:  python i have to access it in a yield manner or else some form of blocking or a collapse like problem takes over and fouls up the rest of the interpreter 

8mo ago
the requirement was that i keep two extra stacks around .. one for the past and one for the future (so i can relocate the iterators haphazardly)  

8mo ago
extra because they don't follow the interpreter stacks  (following them would kill my iterators or would allowed garbage collection at the wrong times)

the problem with most designs is they have enough cases that still follow the interpreter stack.. so the implementors assume they can follow conventional technologies and not realize they could have engineered what was actually needed :)    "it" 


vyzo
7 months ago




Hey folks, I have been thinking about the abysmal performance problems and what can be done to efficiently compile metta programs.

I think at the root of the problem is the fact that metta is an fexpr lisp of sorts, with a blend of prolog. Fexprs were deprecated in lisps in ancient times because they do not permit static analysis, which is the basis of optimizations.... and then we have dynamic modification of atom spaces that makes matters even worse.

However, i think there is a saving grace: types, and in particular arrows.
My thesis is that it should possible to efficiently compile modules given a strict mode of sorts.
If within a module atom space all procedures (ok atoms) are strictly typed and we disallow space modification of the module (so readonly after the module is loaded), then i am reasonably certain that we can compile said modules to relatively efficient machine code.
I plan to experiment with this approach in a Gerbil Scheme implementation of metta.
I have started thinking about it here in the hyperon meeting in brazil, so i expect to have a working prototype soon enough.

Context: i am a long time schemer, with nontrivial contributions in plt scheme (before it was racket) and gambit, and the original author and primary maintainer of Gerbil Scheme -- see https://cons.io

This is my declaration of intent and i hope something good comes out of it. 

Show more
5 replies

Alexey Potapov
7 months ago
Well, as you can see, we already have a bunch of efforts for optimizing/compiling/transpiling Metta. Besides presented MORK, Jetta, and MettaLog, there is also Metta-Morph, which uses chicken-scheme compilation. And there is metta to rholang compiler as well. We do have plans to compile modules, when it will be possible... While everyone can try creating their own optimization, since there are already a number of projects on this, whether one more implementation is needed or not should really be considered carefully. But light-weight experiments are not a problem of course.


vyzo
7 months ago
sure, it is more of an experiment for me

7mo ago
also, re scheme translation, i saw mettamorph, but chicken is so slow....


Ben Goertzel
7 months ago
MORK, Jetta and Mettalog are all showing quite good preliminary results at interpreting and compiling MeTTA orders of magnitude faster than Hyperon Experimental... None of them are integrated with the main HE MeTTa framework yet, but they are pretty far along and I am pretty confident these are all going to give vastly faster performance than HE, and it looks like these will be integrated into HE in a few months at most, quite possibly faster.   Of course there is always more to be learned from additional efforts, but like @Alexey Potapov said, it's not clear that an additional MeTTa optimization project is desperately needed right now as opposed to other missing tooling......


Alexey Potapov
7 months ago
None of them are integrated with the main HE MeTTa framework yet

Jetta is integrated, although its repo is not open yet 


Benjamin Schwerdtner
7 months ago




https://metta-lang.dev/docs/learn/tutorials/ground_up/nested_queries.html
Hi I'm looking at this section and I'm stuck with the (different $x $y) part. The user should try to implement 'different'? In general, how to express the notion that 2 things are not the same, declaritively? I sort of get that I can say 'is the same' by using the same variable. 

12 replies

Benjamin Schwerdtner
7 months ago
Now I have a version with if that works. I suppose the 'declaritive' style would allow the (different $x $z) to be a pattern? 


(= (different-4 $x $y)
   (not (== $x $y)))

(= (get-sister-6 $x)
   (match
       &self
     (,(Parent $y $x)
       (Parent $y $z)
       (Female $z))
     (if (different-4 $z $x)
         $z
         (empty))))

!(get-sister-6 Bob)
;; [Liz]
!(get-sister-6 Liz)
;; []

Alexey Potapov
7 months ago
Well, the tutorial doesn't say that different should be implemented declaratively, and indeed it was not that straightforward to implement different with the previous version of MeTTa. However, you can use unify now:

(= (different $x $y)
   (unify $x $y False True))
; or
(= (keep-different $x $y)
   (unify $x $y Empty $x))

Douglas Miles
7 months ago
in mettalog

(= (different $x $y)
    (call-p! dif $x $y))
7mo ago
this adds a living constraint on variables that means they are never allowed to unify.  So if code tries to change those into the same value the kernel calls backtracking 

7mo ago
now you can use different declaratively so

!("." 
 (different $x $y) 
   (let ($x $y) 
      ((superpose (1 2 3))
       (superpose (1 2 3)))
  ($x $y)))
outputs
[(. . 1 2), (. . 1 3), (. . 2 1), (. . 1 3), (. . 3 2), (. . 3 1)]

is this what you wanted? 


Douglas Miles
7 months ago
also different operates the in your if as you'd expect 


Benjamin Schwerdtner
7 months ago
ah that's interesting. 
So from going through the tutorial I was imagining that I could write this somehow: 

(= (get-sister $x)
   (match
       &self
     (,(Parent $y $x)
       (Parent $y $z)
       (Female $z)
       (different $z $x))
     $z))
But I guess match doesn't evalute patterns. 
Probably it's me coming from datalog, where you have rules and functions in the queries.  


Alexey Potapov
7 months ago
In MeTTa, queries are the basic operations, and functions are built on top of queries


Douglas Miles
7 months ago
The H-E way?

(= (get-sister $x)
   (match
       &self
     (,(Parent $y $x)
       (Parent $y $z)
       (Female $z))
     (if (different $z $x) ($z) (empty)))
7mo ago
The mettalog way:

(= (different $x $y)
    (call-p! dif $x $y))

(= (get-sister $x)
  (let
      True (different $x $y)
      (match
       &self
     (,(Parent $y $x)
       (Parent $y $z)
       (Female $z))     
     $z)))
7mo ago
with mettalogs
(different $x $y) 
it is declarative so if you did that first 
it will prevent match from ever trying to bind the same values  stopping it early so that you don't have to do post processing 

7mo ago
i was thinking about letting users call function during match in mettalog.. many people had thought it was odd to not allow.. 

maybe mettalog should expect the user to be explicit and mark it like?

(= (get-sister $x)
   (match
       &self
     (,(Parent $y $x)
       (Parent $y $z)
       (Female $z)
       (eval (different $z $x)))
     $z))
Just make sure its not guessing since match can also match $variable heads

in  the defense of H-E.. technically its up to user or someone to write a match-allowing-functions for H-E (and it is not very hard.. just once you start doing it you also realize your new masterful match deserves query reordering and all sorts of optimizations) 


Any body knows how to use py-atom to define a function that appends two strings?


Alexey Potapov
11:49 AM
(= (concat $a $b)
   ((py-dot $a __add__) $b))
!(concat "AA" "BB")

Nil Geisweiller
11:53 AM
Thank you!


Alexey Potapov
11:55 AM
There is also the following hack:

(= (concat $a $b)
   (py-atom ($a + $b)))
!(concat "AA" "BB")
because py-atom secretly turns its argument into a Python code and does its inline execution. 

But I'd recommend to use py-dot as a more solid appoach


Nil Geisweiller
12:04 PM
Also, how to set the random seed of random-int?

It looks like it is using the Rust random generator, so I can't do that via Python, it seems.


Alexey Potapov
12:11 PM
I'm afraid it is implemented in Rust and no metta function is now provided for setting the random seed. It needs to be implemented. I've asked to do this. 


Nil Geisweiller
1:15 PM
py-dot seemed to work great but I'm now facing a very odd issue https://github.com/trueagi-io/hyperon-experimental/issues/841, could someone look into it?

Roman Treutlein
5 months ago




How do i pass an Atom to the python library?

15 replies

Alexey Potapov
5 months ago
https://metta-lang.dev/docs/learn/tutorials/python_use/tokenizer.html#unwrapping-python-objects-from-atoms
You need to set unwrap=False when defining OperationAtom.


Roman Treutlein
5 months ago
Ah i was just trying to call an function with py-atom guess i'll try that


Alexey Potapov
5 months ago
Well, yes, py-atom creates an OperationAtom with unwrap=True flag. We didn't consider application of py-atom to functions, which process atoms. We can possibly extend py-atom to accept the unwrap flag if it is needed


Roman Treutlein
5 months ago
Okay that works but how do i load that into metta !(import! &self library) doesn't seemt to run the register_atom or at least not on &self.

5mo ago
Or should i just call my mettafile from python?


Alexey Potapov
5 months ago
Yeah, it was supposed to be in advanced tutorials, but this tutorial was not written. You should use hyperon.ext and @register_atom or @register_token decorator. See this example https://github.com/trueagi-io/hyperon-experimental/tree/main/python/sandbox/bhv_binding or other examples in the sandbox

GitHub
hyperon-experimental/python/sandbox/bhv_binding at main · trueagi-io/hyperon-experimental
MeTTa programming language implementation. Contribute to trueagi-io/hyperon-experimental development by creating an account on GitHub.

hyperon-experimental/python/sandbox/bhv_binding at main · trueagi-io/hyperon-experimental

Roman Treutlein
5 months ago
('Error loading Python module: ', 'test', TypeError("unhashable type: 'GroundedAtom'"))

5mo ago
I just copied the code from mettalang-dev and added the @register_atoms


Alexey Potapov
5 months ago
Have you taken a look at the example? The decorator should be added not to a function, which you want to turn into an atom, but there should be a function, which returns a hashmap between tokens (to be used in MeTTa code) and atoms.


Roman Treutlein
5 months ago
Thats what i'm doing this is the code:

from hyperon.ext import register_atoms

def plus(atom1, atom2):
    from hyperon import ValueAtom
    sum = atom1.get_object().value + atom2.get_object().value
    return [ValueAtom(sum, 'Number')]

from hyperon import OperationAtom, MeTTa
plus_atom = OperationAtom("plus", plus,
    ['Number', 'Number', 'Number'], unwrap=False)

@register_atoms
def my_atoms():
    return {"plus", plus_atom }
5mo ago
ah syntax error

5mo ago
the , should be a : sorry


Douglas Miles
5 months ago
@Alexey Potapov i been getting a similar question in mettalog .. how do you propose the unwrap=False be specified syntactically? 


Douglas Miles
5 months ago
though the return type Atom or Number also tells my code what is expected %Undefined% unwrap vs Atom or PyObject to mean "dont mess with it" 


Alexey Potapov
5 months ago
Well, py-atom already has an optional parameter (the object type), so we can add just one more optional parameter. However, since py-atom itself uses unwrap=False in our implementation, it doesn't utilize Kwargs processing done by automatic unwrapping. So, it will either be necessary to specify the atom type as well, when one wants to set unwrap=True, and the call will look like (py-atom mymodule.myfunc (-> Number Atom Atom) False), or py-atom should process its arguments in some custom way, so one could pass (py-atom m.f False) or (py-atom m.f (unwrap False)) without the necessity to specify the type. Custom argument processing can be convenient, but can also be confusing because of notations differing from defaults. I'm not sure what is the lesser evil here


Yeabsira Nigusse
5 months ago




I recently updated the metta version, and the get-type built-in function is returning an additional %Undefined% type for the following code. Does anyone know why it is returning a non-deterministic type?

(: (C) (AV 20 30 10))

! (get-type (C))
returns [(AV 20 30 10), %Undefined%]

3 replies

Zarathustra Goertzel
5 months ago
Hmm, I'm just getting into MeTTa myself.

I note that when I do the folowing, I get the answer you might expect:

$>(: C (AV 20 30 10))
$>!(get-type C)
[(AV 20 30 10)]

I've found the semantics of singular Symbol atoms wrapped in parentheses to be a bit confusing.

Looking at the Concrete Types page, I think one is recommenedd to define the type of an atom without the parentheses :slightly_smiling_face:  


Alexey Potapov
5 months ago
Well, the reason is that C doesn't have a type. Thus, C is %Undefined%. Thus, (C) can also be %Undefined%. At the same time, (C) is assigned with its own type. So, there are two types, which can be inferred for (C).
As @Zarathustra Goertzel said, you indeed need to define the type of C instead. If what you meant is (: C (AV 20 30 10)), then just use it. If you wanted the type of (C) (that is, application of C as a function with no arguments) to be (AV 20 30 10), then, you should define (: C (-> (AV 20 30 10))).


Yeabsira Nigusse
5 months ago
i just wanted to assign type for expression instead of the symbol.  i get it now, thank you.


Roman Treutlein
5 months ago




What would be cool if we had something similar to @ in haskell so we can do $whole@($part1 $part2) because i find myself often doing
(= (f $arg) (let ($part1 $part2) $arg ...))
so that i can easily refere to the whole and the parts depending on what i need.

17 replies

Douglas Miles
5 months ago
so you wan t to do something like...

(= (f $whole@($part1 $part2)) 
   (use $whole somewhere)
   (use $part1 $part2 somewhere)) ?  

for the syntax .. or ... ? 


Roman Treutlein
5 months ago
Yes

5mo ago
(= (f $whole@($part1 $part2)) (if (== $part1 ()) (f2 $whole) (f3 $part2)))

5mo ago
for example


Douglas Miles
5 months ago
of course you can do (= (f ($part1 $part2))  if you dont need $whole  but i guess this is a situation that you need all  of them, 


Roman Treutlein
5 months ago
Ofcourse but the point is that i do need the $whole

5mo ago
i mean i can always write ($part1 $part2) where i would use $whole but that's just not as nice


Douglas Miles
5 months ago
it seems like (= (f (EachOf@ $whole ($part1 $part2))) ..  might fit  S-Expression syntax  

5mo ago
but be nicer if there were cases that multiple binders exists like


Roman Treutlein
5 months ago
Well its mainly syntactic sugar
(= (f $w@($p1 $p2)) ... ) => (= (f $w) ((let ($p1 $p2) $w ...))
So i don't think it needs to fit the S-Expression syntax but sure whatever works 


Douglas Miles
5 months ago
(= (f (EachOf@ ($whole ($part1 $part2) (happy $part2))) 

5mo ago
in MELD sexpressions we simply use (AndFn .... )  and in other cases (OrFn ...)  right where we want the head matchers 

5mo ago
as in (AndFn $whole ($part1 $part2) ((OrFn happy sad) $part2))

5mo ago
and you know that $part1 is bound to happy or sad

5mo ago
its a way of getting a little of what one needs now and what one might want later

5mo ago
it canonicalizes/transpiles into pretty much the same things as the various term sharing solutions that let makes when it constructs the head filters (just saying it is not inefficient .. and slightly more versitile) 


Roman Treutlein
5 months ago
Thats a lot more powerfull then what i was asking for but yea that would be nice.

n mettalog if you only want to match identical atoms

;; return each alpha equiventant $atom from $space
(= (match-alpha $space $match)
  (progn
     (call! freeze $match (call! =@= $math $explorer)))
      (match $space $explorer  $explorer )))

Douglas Miles
2:22 PM
if you want a looser net

;; return each matching $atom from $space
(= (match-unifiable $space $match)
  (progn
     (call! freeze $match (not (not (call! unify $match $explorer)))))
      (match $space $explorer $explorer)))

Douglas Miles
2:36 PM
this is how mettalog implemented single sided unification


Douglas Miles
2:46 PM







heh for efficently reasons...

(= (match-unifiable $space $match)
  (progn
     (call! freeze $match (not (not (call! unify $match $explorer)))))
      (call! same-index $match $explorer)
       (match $space $explorer $explorer)))

built-in functions in metta
(@kind atom)
        Used for documentation purposes. Shows type of entity to be documented. (@kind atom) in this case
(@kind function)
        Used for documentation purposes. Shows type of entity to be documented. (@kind function) in this case
SpaceType
        Type of the atom which contains space
ErrorType
        Type of the atom which contains error
git-module!
        Provides access to module in a remote git repo, from within MeTTa code. Similar to `register-module!`, this op will bypass the catalog search
subtraction-atom
        Function takes two tuples and returns their subtraction. E.g. !(subtraction-atom (a b b c) (b c c d)) -> (a b)
intersection-atom
        Function takes two tuples and returns their intersection. E.g. (intersection-atom (a b c c) (b c c c d)) -> (b c c)
union-atom
        Function takes two tuples and returns their union. E.g. (union-atom (a b b c) (b c c d)) -> (a b b c b c c d)
unique-atom
        Function takes tuple and returns only unique entities. E.g. (unique-atom (a b c d d)) -> (a b c d)
xor
        Logical exclusive or
==
        Checks equality for two arguments of the same type
>=
        Greater than or equal. Checks if first argument is greater than or equal to second one
<=
        Less than or equal. Checks if first argument is less than or equal to second one
>
        Greater than. Checks if first argument is greater than second one
<
        Less than. Checks if first argument is less than second one
%
        Modulo operator. It returns remainder of dividing first argument by second argument
/
        Divides first argument by second one
*
        Multiplies two numbers
-
        Subtracts second argument from first one
+
        Sums two numbers
sealed
        Replaces all occurrences of any var from var list (first argument) inside atom (second argument) by unique variable. Can be used to create a locally scoped variables
format-args
        Fills {} symbols in the input expression with atoms from the second expression. E.g. (format-args (Probability of {} is {}%) (head 50)) gives [(Probability of head is 50%)]. Atoms in the second input value could be variables
println!
        Prints a line of text to the console
trace!
        Prints its first argument and returns second. Both arguments will be evaluated before processing
bind!
        Registers a new token which is replaced with an atom during the parsing of the rest of the program
include
        Works just like import! but with &self as a first argument. So everything from input file will be included in the current atomspace and evaluated
import!
        Imports module using its relative path (second argument) and binds it to the token (first argument) which will represent imported atomspace. If first argument is &self then everything will be imported to current atomspace
pragma!
        Changes global key's (first argument) value to a new one (second argument).
Possible pragmas:
  (pragma! type-check auto) - check type of the atom before evaluation
  (pragma! interpreter bare-minimal) - use minimal MeTTa semantics when evaluating atom
  (pragma! max-stack-depth <number>) - limit depth of the interpreter's stack, 0 - no limit (default behavior)
capture
        Wraps an atom and capture the current space
case
        Subsequently tests multiple pattern-matching conditions (second argument) for the given value (first argument)
_collapse-add-next-atom-from-collapse-bind-result
        Adds atom from collapse-bind result to the passed list
collapse
        Converts a nondeterministic result into a tuple
superpose
        Turns a tuple (first argument) into a nondeterministic result
assertAlphaEqualToResult
        Same as assertAlphaEqual but it doesn't evaluate second argument. Second argument is considered as a set of values of the first argument's evaluation
assertEqualToResult
        Same as assertEqual but it doesn't evaluate second argument. Second argument is considered as a set of values of the first argument's evaluation
assertAlphaEqual
        Compares (sets of) results of evaluation of two expressions using alpha equality
assertEqual
        Compares (sets of) results of evaluation of two expressions
=alpha
        Checks alpha equality of two expressions
print-mods!
        Prints all modules with their correspondent spaces
mod-space!
        Returns the space of the module (first argument) and tries to load the module if it is not loaded into the module system
register-module!
        Takes a file system path (first argument) and loads the module into the runner
match
        Searches for all declared atoms corresponding to the given pattern (second argument) inside space (first argument) and returns the output template (third argument)
get-state
        Gets a state as an argument and returns its wrapped atom. E.g. (get-state (State 5)) -> 5
change-state!
        Changes input state's wrapped atom to another value (second argument). E.g. (change-state! (State 5) 6) -> (State 6)
new-state
        Creates a new state atom wrapping its argument
get-atoms
        Shows all atoms in the input Atomspace
remove-atom
        Removes atom from the input Atomspace
new-space
        Creates new Atomspace which could be used further in the program as a separate from &self Atomspace
if-equal
        Checks if first two arguments are equal and evaluates third argument if equal, fourth argument - otherwise
get-metatype
        Returns metatype of the input atom
get-type-space
        Returns type notation of input Atom (second argument) relative to a specified atomspace (first argument)
get-type
        Returns type notation of input atom
add-atom
        Adds atom into the atomspace without reducing it
noreduce-eq
        Checks equality of two atoms without reducing them
for-each-in-atom
        Applies function passed as a second argument to each atom inside first argument
help-param!
        Function used by function help! to output parameters using println!
help!
        Function prints documentation for the input atom. Without parameters prints the list of the stdlib functions.
get-doc-atom
        Function used by get-doc (in case of input type Expression) and get-doc-single-atom (in case input value is not a function) to get documentation on input value
get-doc-params
        Function used by get-doc-function to get function's parameters documentation (including return value)
undefined-doc-function-type
        Function used by get-doc-single-atom in case of absence of function's type notation
get-doc-function
        Function used by get-doc-single-atom to get documentation on a function. It returns documentation on a function if it exists or default documentation with no description otherwise
get-doc-single-atom
        Function used by get-doc to get documentation on either function or atom. It checks if input name is the name of function or atom and calls correspondent function
get-doc
        Returns documentation for the given Atom/Function
@params
        Used for function documentation purposes. Contains several @param entities with description of each @param
@type
        Used for documentation purposes. Converts atom/function's type to DocType
@item
        Used for documentation purposes. Converts atom/function's name to DocItem
@doc-formal
        Used for documentation purposes. get-doc returns documentation starting with @doc-formal symbol. @doc-formal contains 6 or 4 parameters depending on the entity being described (functions being described using 6 parameters, atoms - 4 parameters)
@return
        Used for documentation purposes. Description of function return value starts with @return as a part of @doc
@param
        Used for documentation purposes. Description of function parameter starts with @param as a part of @params which is a part of @doc
@desc
        Used for documentation purposes. Description of function starts with @desc as a part of @doc
@doc
        Used for documentation purposes. Function documentation starts with @doc
assertIncludes
        Checks if the content in the second argument is included in the results of the first argument's evaluation
add-atoms
        Function takes space and expression and adds atoms in Expression into given space without reducing them
add-reducts
        Function takes space and expression, evaluates atoms in it and adds them into given space
subtraction
        Function takes two non-deterministic inputs (first and second argument) and returns their subtraction. E.g. !(subtraction (superpose (a b b c)) (superpose (b c c d))) -> [a, b]
intersection
        Function takes two non-deterministic inputs (first and second argument) and returns their intersection. E.g. (intersection (superpose (a b c c)) (superpose (b c c c d))) -> [b, c, c]
union
        Function takes two non-deterministic inputs (first and second argument) and returns their union. E.g. (union (superpose (a b b c)) (superpose (b c c d))) -> [a, b, b, c, b, c, c, d]
unique
        Function takes non-deterministic input (first argument) and returns only unique entities. E.g. (unique (superpose (a b c d d))) -> [a, b, c, d]
empty
        Cuts evaluation of the non-deterministic branch and removes it from the result
nop
        Outputs unit atom
unquote
        Unquotes quoted atom, e.g. (unquote (quote $x)) returns $x
quote
        Prevents atom from being reduced
cdr-atom
        Extracts the tail of an expression (all except first atom)
car-atom
        Extracts the first atom of an expression as a tuple
add-reduct
        Reduces atom (second argument) and adds it into the atomspace (first argument)
let*
        Same as let but inputs list of pairs of atoms to be unified. For example (let* (($v1 (+ 1 2)) ($v2 (* 5 6))) (+ $v1 $v2))
let
        Unify two first argument and apply result of the unification on third argument. Second argument is evaluated before unification.
not
        Logical negation
and
        Logical conjunction of two arguments
or
        Logical disjunction of two arguments
if
        Replace itself by one of the arguments depending on condition.
foldl-atom
        Function takes list of values (first argument), initial value (second argument) and operation (fifth argument) and applies it consequently to the list of values, using init value as a start. It also takes two variables (third and fourth argument) to use them inside
map-atom
        Function takes list of atoms (first argument), variable to be used inside (second variable) and an expression which will be evaluated for each atom in list (third argument). Expression should contain variable. So e.g. (map-atom (1 2 3 4) $v (eval (+ $v 1))) will give (2 3 4 5)
filter-atom
        Function takes list of atoms (first argument), variable (second argument) and filter predicate (third argument) and returns list with items which passed filter. E.g. (filter-atom (1 2 3 4) $v (eval (> $v 2))) will give (3 4)
match-type-or
        Checks if two types (second and third arguments) can be unified and returns result of OR operation between first argument and type checking result
first-from-pair
        Gets a pair as a first argument and returns first atom from pair
match-types
        Checks if two types can be unified and returns third argument if so, fourth - otherwise
type-cast
        Casts atom passed as a first argument to the type passed as a second argument using space as a context
is-function
        Function checks if input type is a function type
switch-internal
        This function is being called inside switch function to test one of the cases and it calls switch once again if current condition is not met
switch
        Subsequently tests multiple pattern-matching conditions (second argument) for the given value (first argument)
return-on-error
        Returns first argument if it is Empty or an error. Returns second argument otherwise.
if-error
        Checks if first argument is an error atom. Returns second argument if so or third argument otherwise.
atom-subst
        Substitutes variable passed as a second argument in the third argument by the first argument
noeval
        Returns its argument
id
        Returns its argument
metta
        Run MeTTa interpreter on atom.
superpose-bind
        Complement to the collapse-bind. It takes result of collapse-bind (first argument) and returns only result atoms without bindings
collapse-bind
        Evaluates minimal MeTTa operation (first argument) and returns an expression which contains all alternative evaluations in a form (Atom Bindings). Bindings are represented in a form of a grounded atom.
isinf-math
        Returns True if input value is positive or negative infinity. False - otherwise
isnan-math
        Returns True if input value is NaN. False - otherwise
atan-math
        Returns result of the arctangent function for an input value (first argument)
tan-math
        Returns result of the tangent function for an input value in radians (first argument)
acos-math
        Returns result of the arccosine function for an input value (first argument)
cos-math
        Returns result of the cosine function for an input value in radians (first argument)
asin-math
        Returns result of the arcsine function for an input value (first argument)
sin-math
        Returns result of the sine function for an input value in radians (first argument)
round-math
        Returns the nearest integer to the input float value (first argument)
floor-math
        Returns the smallest integer less than or equal to the input value (first argument)
ceil-math
        Returns the smallest integer greater than or equal to the input value (first argument)
trunc-math
        Returns integer part of the input value (first argument)
log-math
        Returns result of a logarithm function given base (first argument) and input number (second argument)
abs-math
        Returns absolute value of input number (first argument)
sqrt-math
        Returns square root for input number (first argument) which should be >= 0
pow-math
        Takes base (first argument) and power (second argument) and returns result of a power function (base ^ power)
index-atom
        Returns atom from an expression (first argument) using index (second argument) or error if index is out of bounds
size-atom
        Returns size of an expression (first argument)
max-atom
        Returns atom with max value in the expression (first argument). Only numbers allowed
min-atom
        Returns atom with min value in the expression (first argument). Only numbers allowed
context-space
        Returns the space which is used as a context space in atom evaluation
decons-atom
        Works as a reverse to cons-atom function. It gets Expression as an input and returns it splitted to head and tail, e.g. (decons-atom (Cons X Nil)) -> (Cons (X Nil))
cons-atom
        Constructs an expression using two arguments
unify
        Matches two first arguments and returns third argument if they are matched and forth argument otherwise
chain
        Evaluates first argument, binds it to the variable (second argument) and then evaluates third argument which contains (or not) mentioned variable
evalc
        Evaluates input atom, makes one step of the evaluation
eval
        Evaluates input atom, makes one step of the evaluation
function
        Evaluates the argument until it becomes (return <result>). Then (function (return <result>)) is reduced to the <result>.
return
        Returns value from the (function ...) expression
Error
        Error constructor
=
        A symbol used to define reduction rules for expressions.
[]

the mettalog output  
Any
        The universal type; any value belongs to this type.
RandomGenerator
        Type representing a random number generator.
Atom
        Type representing any atom.
LazyEvaluatable
        A type of Atom/Value that hyperon does not implicitly evaluate
Bool
        Boolean type of True or False.
LazyBool
        A LazyEvaluatable that when evaluated returns True or False.
Expression
        Type representing an S-Expression, which is a combination of atoms.
Number
        Numeric type, including integers and floating-point numbers.
hyperon::space::DynSpace
        Dynamic space type, representing an Atomspace.
ReturnType
        Type representing a function's return value.
Symbol
        Type representing a symbol or identifier.
StateMonad
        Type representing a state monad, used for encapsulating stateful computations.
Type
        Type representing a type.
True
        Boolean value representing truth.
False
        Boolean value representing falsehood.
%Undefined%
        Special type representing an undefined value or type.
Variable
        Type representing a variable in the language.
:
        Type declarion operator
<:
        Super Type declarion operator
type-check
        The value of type-check determines MeTTa's type-checking behavior. Set via pragma!. When set to auto (i.e. !(pragma! type-check auto)), types are checked immediately on adding an expression to the space. By default, when unset (or set to anything other than auto), types are checked only on evaluation. For example !(+ 1 "2") would trigger a type violation, but (= (foo $x) (+ $x "2")) would not, unless type-check is set to auto, in which case both would trigger type violations.
SrcPredicate
        Type representing a source predicate.
SrcFunction
        Type representing a source function.
MeTTaResult
        Type representing the result of a MeTTa evaluation.
NotReducible
        Result indicating that an atom cannot be reduced further.
Empty
        Result indicating an empty evaluation result.
ValueAtom
        Type representing a value atom.
ForeignObject
        Type representing a foreign object, such as a Python object.
PyObject
        Type representing a Python object.
ErrorType
        Type of the atom which contains error
(@kind function)
        Used for documentation purposes. Shows type of entity to be documented. (@kind function) in this case
(@kind atom)
        Used for documentation purposes. Shows type of entity to be documented. (@kind atom) in this case
;; no-results ;;
