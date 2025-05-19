1. Input Data
You'll be given a folder called video_data containing a sequence of images (frames) that make up a video
Each image is 480x360 pixels in size
These images are in JPG format
Think of it like a flipbook - each image is one page, and when you flip through them quickly, you see a video
2. Basic Concepts
A. What is Video Compression?
When you watch a video on YouTube or Netflix, the file size is much smaller than it could be
This is because of compression - making the file smaller while keeping the video watchable
Our project is about understanding how this works by implementing a simple version
B. Key Concepts in Simple Terms:
Macroblocks (8x8 blocks)
Instead of processing the whole image at once, we break it into small 8x8 pixel blocks
Like breaking a big puzzle into smaller pieces
This makes it easier to process and find patterns
DCT (Discrete Cosine Transform)
This is like a magic trick that changes how we look at the image
Instead of seeing pixels, we see patterns
Some patterns are more important than others
Think of it like a recipe - some ingredients are essential, others can be adjusted
Quantization
This is where we make the file smaller by simplifying the patterns
We keep the important patterns and simplify the less important ones
Like rounding numbers - 3.14159 becomes 3.14
I-Frames and P-Frames
I-Frames: Complete pictures (like keyframes in animation)
P-Frames: Only store what changed from the previous frame
Like in a flipbook, you don't need to redraw everything on each page, just what moved
GOP (Group of Pictures)
A sequence of frames starting with an I-frame followed by P-frames
Like a chapter in a book, starting with a full picture and then only showing changes
3. The Process in Simple Steps:
Input: You get a folder of images (frames) from a video
Processing:
Break each frame into 8x8 blocks
For I-frames:
Process each block completely
Store all the information
For P-frames:
Only store what changed from the previous frame
This saves space
Output:
A compressed file (result.bin)
When decompressed, it should look similar to the original video
4. Why This Matters:
Understanding these concepts helps you understand how:
YouTube videos load quickly
Netflix can stream HD content
Your phone can store videos
Video calls work smoothly
5. The Project's Goal:
Implement this compression process
Make the video file smaller while keeping it watchable
Understand how real video compression works
Would you like me to:
Explain any of these concepts in more detail?
Show you how to start working with the input data?
Explain how to implement any specific part?
Let me know what interests you most, and we can dive deeper into that aspect!
