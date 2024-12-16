/**
 * @file nunchuck.ino
 * @author Casey Wolfe
 * @brief Basic IO conversion to convert the Wii Nunchuck Controller (i2c) to UART.
 *        This code in particular reads the joystick x and y axis, packs them into 8
 *        bits (4 bits per axis) and sends the byte over the arduino default serial port.
 * @version 1.0
 * @date 2024-12-16
 * 
 */


#include <WiiChuck.h>

Accessory nunchuck1;

void setup() {
	Serial.begin(9600);
	nunchuck1.begin();
}

void loop()
{
	nunchuck1.readData();
	uint8_t joystickValueX = nunchuck1.values[0] / 16;
	uint8_t joystickValueY = nunchuck1.values[1] / 16;
	uint8_t dataPayload = (joystickValueX) | (joystickValueY << 4);
	Serial.write(dataPayload);
	delay(20);
}