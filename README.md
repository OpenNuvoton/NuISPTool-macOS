# NuISPTool-macOS

 The “NuISPTool APP” (Nuvoton In-System Programming tool APP) allows the embedded Flash memory to be
reprogrammed under software control through the firmware using on-chip connectivity interface,
such as UART and USB, without removing any microcontroller from the system.
For NuMicro®

 Family microcontroller (MCU) products, the on-chip Flash memory is partitioned into
three blocks: APROM, Data Flash and LDROM. The APROM saves the user application program
developed for a specific application; the Data Flash provides storage for nonvolatile application
data; and the LDROM saves the ISP code for MCU to update its APROM/Data Flash/CONFIG.

 User can update the MCU’s APROM, Data Flash, and User Configuration bits with Nuvoton
standard ISP code programmed in LDROM easily by using the ISP function.
 
Version 1.0.1 currently only supports the HID interface.

# How to start 
 
 1. If you want to use the USB HID interface in NuISPTool, connect the device to a Mac computer via USB and enable LDROM to enter ISP mode. After that, you can directly connect to it.
 
# How to Run
1. Open the NuISP application.<br>
2. Connect the device using USB HID.<br>
 
<img src="https://github.com/OpenNuvoton/NuISPTool-macOS/blob/main/1714985887383@2x.jpg" alt="Logo" style="width: 400px;">

3. Click on "connect" to establish the connection (ensure that the device has entered LDROM ISP mode).<br>
4. Once connected successfully, retrieve the relevant information about the device.<br>
 
<img src="https://github.com/OpenNuvoton/NuISPTool-macOS/blob/main/1714985902400@2x.jpg?raw=true" alt="Logo" style="width: 400px;">

5. Click on "Setting" to enter the configuration mode.<br>
6. Press "Updata" to configure the settings in CONFIG mode.<br>
 
<img src="https://github.com/OpenNuvoton/NuISPTool-macOS/blob/main/1714986650409@2x.jpg?raw=true" alt="Logo" style="width: 400px;">

7. Click on the bin file you want to burn.<br>
8. Select the function you want to burn.<br>
9. Click on "Start" to begin the burning process.<br>
10. Wait for the burning process to complete.<br>

<img src="https://github.com/OpenNuvoton/NuISPTool-macOS/blob/main/1714987513023.jpg?raw=true" alt="Logo" style="width: 400px;">
