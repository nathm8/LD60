package graphics;

import h2d.col.PixelsCollider;
import utilities.MessageManager;
import utilities.MessageManager.MessageListener;
import slide.easing.SmoothStep;
import utilities.RNGManager;
import utilities.Vector2D;
import hxd.Res;
import h2d.Bitmap;
import gamelogic.Updateable;
import h2d.Object;

class Porcupine extends Object implements Updateable implements MessageListener {

    var body: Bitmap;
    var is_dead = false;
    var collider: PixelsCollider;

    public function new(p: Object) {
        super(p);

        body = new Bitmap(Res.img.Porc.toTile().center(), this);
        Main.tweenManager.delay(RNGManager.srand(5, true), () -> wander()).start();

        collider = new PixelsCollider(Res.img.PorcHitbox.getPixels());

        MessageManager.addListener(this);
    }

    public function update(dt:Float):Bool {
        return true;
    }

    function wander() {
        var destination = new Vector2D(RNGManager.random(200)-100, RNGManager.random(200)-100);
        body.tile.xFlip = destination.x < 0;
        var time = destination.magnitude/100 * (1 + RNGManager.srand(2, true));
        Main.tweenManager.animateTo(body, {x: body.x+destination.x, y: body.y+destination.y}, time, SmoothStep.easeInOut).start();
        Main.tweenManager.animateTo(body, {rotation: -Math.PI/12}, time/3, SmoothStep.easeIn,
            () -> Main.tweenManager.animateTo(body, {rotation: Math.PI/12}, time/3, SmoothStep.easeIn,
                () -> Main.tweenManager.animateTo(body, {rotation: 0}, time/3, SmoothStep.easeIn).start(),
            ).start()).start();
        Main.tweenManager.delay(time + RNGManager.srand(5, true), () -> wander()).start();
    }

    public function delete() {}

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, MoveWorld)) {
            var params = cast(msg, MoveWorld);
            x -= params.move.x;
            y += params.move.y;
        } if (Std.isOfType(msg, WeaponDamageCheck)) {
            var params = cast(msg, WeaponDamageCheck);
            var p = params.pos;
            var q = body.globalToLocal(p);
            var q_c = q;
            q_c.x += Res.img.Porc.getSize().width/2;
            q_c.y += Res.img.Porc.getSize().height/2;
            if (collider.contains(q_c)) {
                if ((params.pos - params.prev).magnitude > 10) {
                    MessageManager.send(new SpawnBloodSpray(p));
                }
            }
        }
        return false;
    }
}