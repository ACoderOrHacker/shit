module termcolor.gradient;
@safe:

public import termcolor;
import std.stdio;
import std.stdio;
import std.range;
import std.algorithm;
import std.math;

RGBColor hsvToRGB(float h, float s, float v)
{
    ubyte r, g, b;
    h = h % 360;
    if (h < 0)
        h += 360;

    immutable float c = v * s;
    immutable float x = c * (1 - abs((h / 60) % 2 - 1));
    immutable float m = v - c;

    float r1, g1, b1;
    if (h < 60)
    {
        r1 = c;
        g1 = x;
        b1 = 0;
    }
    else if (h < 120)
    {
        r1 = x;
        g1 = c;
        b1 = 0;
    }
    else if (h < 180)
    {
        r1 = 0;
        g1 = c;
        b1 = x;
    }
    else if (h < 240)
    {
        r1 = 0;
        g1 = x;
        b1 = c;
    }
    else if (h < 300)
    {
        r1 = x;
        g1 = 0;
        b1 = c;
    }
    else
    {
        r1 = c;
        g1 = 0;
        b1 = x;
    }

    r = cast(ubyte)((r1 + m) * 255);
    g = cast(ubyte)((g1 + m) * 255);
    b = cast(ubyte)((b1 + m) * 255);

    return RGBColor(r, g, b);
}

void lolcat(string text, float freq = 0.1, float baseHue = 30.0) @trusted
{
    foreach (i, char c; text)
    {
        immutable float hue = (baseHue + i * freq * 360) % 360;
        RGBColor color = hsvToRGB(hue, 1.0, 1.0);
        stdout.setColor(color)
            .write(c);
    }
    stdout.setColor(Colors.reset);
}

void lolcatRange(string text, float freq = 0.1, float minHue = 20.0, float maxHue = 80.0) @trusted
{
    immutable float range = maxHue - minHue;
    foreach (i, char c; text)
    {
        immutable float hue = minHue + (sin(i * freq) + 1) / 2 * range;
        RGBColor color = hsvToRGB(hue, 1.0, 1.0);
        stdout.setColor(color)
            .write(c);
    }
    stdout.setColor(Colors.reset);
}
