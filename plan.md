# Markdown driven swift UI
- [x] Create dynamic UI elements
     - Text
     - TextField
     - TextArea
     - Checkbox
     - "Hour" - Some abstract structure, no idea what that looks like yet
     - etc
- [x] Parse markdown (use a package) and build UI from these
- [x] State store backing elements that can be serialized
- [x] Improve iCloud file sync with NSMetadataQuery etc
- [x] Add file extension
- [ ] Release osx build
- [ ] Add different views/journals each with their own template
- [x] Make text area size dynamic
- [ ] Improve template editor experience
- [x] Legend
- [x] Parser tests
~~- [ ] Project website~~ Scratch that, I don't need to manage a bunch of sites and domains. Use the gallery approach on my personal site but spend some time on a nicer theme


# 1 Parsing
Where do I parse the content and draw it? On appear is too late? I need to bind the string as a view state and then build the view off of that while staying type safe.
    Nah, I can just bind the string with state and build the thing

# 2 Persistence
I need some sort of datamodel I can bind to any old view. I do know what the view is no need to have it completely generic.
I could just have each element handle all of it. Serialization is just one big markdown string, so I'll I need to do is have each view represent itself as a String to serialize it. That's a lot simpler than all that reflection nonsense I had to do.
    But, how do I construct the elements and keep references to them I can access later. A drawing loop needs to have evey statement return a View, can pretty sure I can't parse the thing in body either as I also need to return views. Could do it in onAppear I suppose
    I didn't need to do that before because I have a view model I use to build the UI, I serialize the view model and just draw the UI from it.
    Why cant I draw any array of structs that conform to View. Do the have inherit from View directly?? That seems wrong.
    Stuck trying to draw array of views, errors are useless.
The only way to do this seems to be using TypeErasure.
1. Use type erasure on the on the View array and possibly screw performance.
    I don't think this is too fruitful. The type erased array also seems pretty useless as I can no longer get at the underlying views. 
2. Draw the views based on the MD content and have some way of binding out just the state so I can pull that later. An array/hash for each type inside a view model keyed by id might do it.

# Next
I need a plan. Write it out what are the spikes I need to do to unblock each part. So far 1) Type information in subclasses, 2) Deserialization and tokenizatio, 3) Serialization 4) Elements (Text, TextField, TextEditor, Checkbox, Reminder, Multiselect, Addition button! (this will be spicey)) 5) UI 6) Behaviours. That's all I can think of for now.


