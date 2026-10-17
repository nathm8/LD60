package graphics;

import hxd.Res;
import h2d.Bitmap;
import h2d.filter.Mask;
import hxsl.Types.Vec4;
import utilities.Vector2D;
import gamelogic.Updateable;
import h2d.Graphics;
import h2d.Object;

final SKY_COLOUR_PROGRESSION = [0xff932200, 0xff8a92ff, 0xff17172e];

class Sky extends Object implements Updateable {

    var timeElapsed = 0.0;
    var totalDayTime = 90.0;
    var sun: Graphics;
    var sky: Graphics;
    var dark: Graphics;

    public function new(p: Object) {
        super(p);

        sky = new Graphics(this);
        sky.beginFill(0xFFFFFF);
        sky.drawRect(0, 0, 1600, 200);

        var sun_mask_rect = new Bitmap(Res.img.SunMask.toTile(), this);

        sun = new Graphics(this);
        sun.beginFill(0xcbb400);
        sun.drawCircle(0, 0, 100);
        sun.filter = new Mask(sun_mask_rect);

        dark = new Graphics(this);
        dark.beginFill(SKY_COLOUR_PROGRESSION[2]);
        dark.drawRect(0, 0, 1600, 900);
        dark.alpha = 0.0;
    }

    public function update(dt:Float):Bool {
        timeElapsed += dt;
        var r = Math.min(timeElapsed/totalDayTime, 1.0);
        var min_angle = 2*Math.PI-Math.PI/22;
        var max_angle = Math.PI+2*Math.PI/22;
        var v = new Vector2D(110, 200).rotateAboutPoint(min_angle + r*max_angle, new Vector2D(800, 200));
        sun.x = v.x;
        sun.y = v.y;

        // graduate sky colour, and darken everything near dusk
        dark.alpha = 0.0;
        if (r <= 0.1)
            sky.color = Vec4.fromColor(SKY_COLOUR_PROGRESSION[0]);
        else if (r <= 0.8) {
            var q = (2*r-0.1)/0.7;
            if (q >= 1.0)
                sky.color = Vec4.fromColor(SKY_COLOUR_PROGRESSION[1]);
            else
                sky.color = Vec4.fromColor(SKY_COLOUR_PROGRESSION[0], 1 - q) + Vec4.fromColor(SKY_COLOUR_PROGRESSION[1], q);
        } else {
            var q = (r-0.8)/0.2;
            dark.alpha = q*q - 0.01;
            sky.color = Vec4.fromColor(SKY_COLOUR_PROGRESSION[1], 1 - q) + Vec4.fromColor(SKY_COLOUR_PROGRESSION[2], q);
        }


        return false;
    }

    public function delete() {}
}