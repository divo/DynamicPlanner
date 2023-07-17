# Markdown driven swift UI
-[] Create dynamic UI elements
    - Text
    - TextField
    - TextArea
    - Checkbox
    - "Hour" - Some abstract structure, no idea what that looks like yet
    - etc
-[] Parse markdown (use a package) and build UI from these
-[] State store backing elements that can be serialized


# 1 Parsing
Where do I parse the content and draw it? On appear is too late? I need to bind the string as a view state and then build the view off of that while staying type safe.
    Nah, I can just bind the string with state and build the thing

# 2 Persistence
I need some sort of datamodel I can bind to any old view. I do know what the view is no need to have it completely generic.
I could just have each element handle all of it. Serialization is just one big markdown string, so I'll I need to do is have each view represent itself as a String to serialize it. That's a lot simpler than all that reflection nonsense I had to do.
    But, how do I construct the elements and keep references to them I can access later. A drawing loop needs to have evey statement return a View, can pretty sure I can't parse the thing in body either as I also need to return views. Could do it in onAppear I suppose
    I didn't need to do that before because I have a view model I use to build the UI, I serialize the view model and just draw the UI from it.
    Why cant I draw any array of structs that conform to View. Do the have inherit from View directly?? That seems wrong.
