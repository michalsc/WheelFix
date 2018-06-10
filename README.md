# WheelFix
After being frustrated with the new mouse wheel behavior of macOS I have decided to give myself another try. All solutions I have found on network until now were either expensive or not satisfying me. The App is also a kind of excercise for me. Until now I was not writing any software for macOS (well, I did but not using native toolkit) and at the same time the first attempt to code in swift. Please forgive any mistakes (or correct me where I am doing it wrong :-))

In my attempt I am not trying to blindly modify all wheel events my app receives. Instead I'm distinguishing two cases:
* Beginning of the wheel movement (i.e. temporal distance between last wheel movement and the actual one is large)
* Within wheel movement (i.e. temporal distance between last wheel movement and the actual one is small)

In case of the latter my App does not allow for a change of movement direction. If such event happens, it will be discarded. I have found out that this one solved almost all of the mouse wheel issues in my case. Future versions will add an App window for fine-tuning of the wheel filter as well as some fancy wheel speed correction curves (user customizable of course)


