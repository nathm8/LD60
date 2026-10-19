package graphics;

import hxd.res.DefaultFont;
import utilities.MessageManager;
import hxd.Key;
import utilities.MessageManager.KeyUp;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;
import h2d.Text;
import hxd.Res;
import h2d.Bitmap;
import h2d.filter.Mask;
import hxsl.Types.Vec4;
import utilities.Vector2D;
import gamelogic.Updateable;
import h2d.Graphics;
import h2d.Object;

final SKY_COLOUR_PROGRESSION = [0xff932200, 0xff8a92ff, 0xff17172e];

class Sky extends Object implements Updateable implements MessageListener {

    var timeElapsed = 0.0;
    var totalDayTime = 90.0;
    var sun: Graphics;
    var sky: Graphics;
    var dark: Graphics;

    var canSleep = false;
    var sleeping = false;
    var text: Text;

    // kill stats
    var small = 0;
    var large = 0;
    var human = 0;
    var totalTime = 0.0;
    var victory = false;

    public static var night = 0;

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

        text = new Text(DefaultFont.get(), this);
        text.x = 800;
        text.y = 450;
        text.scale(2);
        text.textAlign = Center;

        MessageManager.addListener(this);
    }

    public function update(dt:Float):Bool {
        if (victory) return false;
        totalTime += dt;

        if (!canSleep) {
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
            
            if (r == 1) {
                MessageManager.send(new PauseHunger());
                text.text = "press Z to Zzz";
                canSleep = true;
            }
        }
            
        return false;
    }

    public function delete() {}

    function newDay() {
        sleeping = false;
        canSleep = false;        
        sky.color = Vec4.fromColor(SKY_COLOUR_PROGRESSION[0]);
        timeElapsed = 0;
        Main.tweenManager.animateTo(dark, {alpha: 0}, 1).start();
        Main.tweenManager.delay(1, () -> text.text = "").start();
        Main.tweenManager.delay(1, () -> MessageManager.send(new UnpauseHunger())).start();
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, KeyUp)) {
            var e = cast(msg, KeyUp);
            if (e.keycode == Key.Z) {
                if (!canSleep || sleeping) return false;
                if (night == 0) {
                    MessageManager.send(new NightPasses(night));
                    text.text = "you invented Spear!\nclick to throw";
                } else
                    text.text = "";
                night++;
                sleeping = true;
                Main.tweenManager.delay(3, () -> newDay()).start();
            }
        }
        // if (Std.isOfType(msg, Restart))
        //     night = 0;
        if (Std.isOfType(msg, SmallBeastDeath))
            small++;
        if (Std.isOfType(msg, LargeBeastDeath))
            large++;
        if (Std.isOfType(msg, HumanDeath))
            human++;
        if (Std.isOfType(msg, Victory)) {
            MessageManager.send(new PauseHunger());
            victory = true;

            Main.tweenManager.animateTo(dark, {alpha: 1}, 1).start();
            text.y -= 100;
            var labels = new Text(DefaultFont.get(), text);
            labels.x = -100;
            labels.y = 50;
            labels.textAlign = Left;
            labels.text = 'small beasts killed:\nlarge beasts killed:\nhumans killed:\nnights passed:\ntotal time taken:';
            labels.visible = false;

            var stats = new Text(DefaultFont.get(), text);
            stats.x = 100;
            stats.y = 50;
            stats.textAlign = Right;
            stats.text = '$small\n$large\n$human\n$night\n${Math.round(totalTime)}';
            stats.visible = false;
            Main.tweenManager.delay(1, () -> text.text = "you acquired Agriculture!\nyou have survived!\n\n").start();
            Main.tweenManager.delay(1, () -> labels.visible = true).start();
            Main.tweenManager.delay(1, () -> stats.visible = true).start();
        }
        return false;
    }
}