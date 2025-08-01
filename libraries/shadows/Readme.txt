   _____ _               _                   
  / ____| |             | |                  
 | (___ | |__   __ _  __| | _____      _____ 
  \___ \| '_ \ / _` |/ _` |/ _ \ \ /\ / / __|
  ____) | | | | (_| | (_| | (_) \ V  V /\__ \
 |_____/|_| |_|\__,_|\__,_|\___/ \_/\_/ |___/
                                             
                                             
by AcousticJamm, help from Vitellary
-----------------------------------------------

This is one of my more simple libraries to use at the moment.
In fact, I won't take much time explaining it. Just do the following:

1) Create a rectangle object on your map named: shadow
2) (OPTIONAL) Give your object a float (int works too) parameter named "scale" and set that to whatever you want. The higher the number, the lower actor shadows reach.
3) (OPTIONAL) Give your object a float (int works too) parameter named "opacity" and set that to whatever you want. The higher the number, the more opaque the shadows.
4) (OPTIONAL) Give your object a float (int works too) parameter named "shear" and set that to whatever you want. Positive numbers shear left.

NOTE: Shadows will only draw inside of the shadow object you have placed.
NOTE: Put the shadow object at the BOTTOM OBJECT LAYER. THIS IS IMPORTANT IF YOU WANT IT TO LOOK RIGHT.









⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣴⣶⣶⣶⣶⣶⣶⣦⣤⣀⣴⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠠⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⠈⢿⣤⣀⠀⠀⠀⠀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣦⣄⣀⠀⠀⠀⠀⠀⠀⠀⠈⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⣘⣿⣿⣿⡒⠿⣿⣿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠈⢿⣿⣿⣿⣶⣶⣶⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣾⣿⣿⣿⣿⣿⣿⣦⣽⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠈⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠉⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠋⠙⠛⠿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠈⠙⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⣰⠘⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⢰⣿⡇⠘⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠋⠘⠛⠠⠤⠼⢿⣯⣴⣶⡄⣤⢳⡦⠄⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣀⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠘⠳⢦⡀⠀⢀⡼⠏⣿⣿⣿⣿⡎⡇⠀⠀⠀⢀
⠀⣤⣤⣤⣶⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣶⣾⣟⡛⠉⠀⠀⢹⣿⠿⢿⡿⠃⠀⠀⣰⠏
⠀⠈⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣅⠀⠀⣸⡏⠠⣤⣀⠀⢀⡞⠁⠀
⠀⠀⠀⠀⠈⠙⠛⠻⠿⠿⣿⣿⣿⡿⠿⠿⠛⠉⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⠀⣰⣿⣿⣷⣦⡉⣷⠞⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⢿⣿⣿⡿⠻⣿⣿⣿⣿⣿⡏⠹⣿⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⢿⣿⣿⣿⣿⣷⣰⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠉⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⡟⠀⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠳⢤⣭⡿⣿⣿⣿⡿⠀⠀⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⢀⣠⠶⢟⣿⣿⣿⠇⠀⠀⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠏⠀⢀⣼⣿⣿⡏⣠⠇⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⡿⠳⠋⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣶⠀⠀⠀⣿⣿⣿⣷⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⠿⣿⣿⣿⣿⣿⡃⠀⢠⣤⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣹⣤⣀⣈⣉⣭⣽⡗⢦⣸⡿⠿⢿⢿⠿⠿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣷⠈⣯⣤⣤⣤⣤⣤⣴⠾⠅⠀⠀⠀⠀⢀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡿⠁⡴⠀⠉⠻⣿⣿⣿⣶⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀⠈⠙⣶⣄⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣇⠂⣁⠀⠀⠇⣿⣿⡟⣿⠛⠍⡻⣿⣿⣿⣿⣿⣿⣄⠀⠀⠀⠀⣸⢿⣿⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠛⠳⠶⠾⠿⠿⠿⠋⢰⡏⠀⢀⡄⠀⠉⠛⠿⣿⠻⣿⡶⠷⠞⠛⣁⣾⡿⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⢿⣾⣁⣤⣤⣄⣼⡿⠀⠈⠙⠛⠛⠛⠉⠉⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡈⠉⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

worth it lmao