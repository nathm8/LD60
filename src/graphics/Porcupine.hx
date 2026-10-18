package graphics;

import h2d.col.Collider;
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
    var collider: PixelsCollider;
    var health = 20.0;
    var isEaten = false;
    
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
        if (health <= 0) return;
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

    function die() {
        var tmp = body.tile.xFlip;
        body.tile = Res.img.PorcDead.toTile().center();
        body.tile.xFlip = tmp;
    }

    function pointCollisionCheck(point: Vector2D): Bool {
        var q = body.globalToLocal(point);
        q.x += Res.img.Porc.getSize().width/2;
        q.y += Res.img.Porc.getSize().height/2;
        return collider.contains(q);
    }

    function playerCollisionCheck(player_pos: Vector2D): Bool {
        return (player_pos - body.getAbsPos().getPosition()).magnitude < 50;
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, MoveWorld)) {
            var params = cast(msg, MoveWorld);
            x -= params.move.x;
            y += params.move.y;
        } if (Std.isOfType(msg, WeaponDamageCheck)) {
            var params = cast(msg, WeaponDamageCheck);
            if (health <= 0) return false;
            if (pointCollisionCheck(params.pos)) {
                var hit_magnitude = (params.pos - params.prev).magnitude;
                if (hit_magnitude > 10) {
                    health -= hit_magnitude;
                    if (health <= 0) die();
                    MessageManager.send(new SpawnBloodSpray(params.pos));
                }
            }
        } if (Std.isOfType(msg, PlayerCollisionCheck)) {
            var player = cast(msg, PlayerCollisionCheck).player;
            // TODO live critter hurt player
            if (playerCollisionCheck(player.body.getAbsPos().getPosition())) {
                if (isEaten) return false;
                isEaten = true;
                var tmp = body.tile.xFlip;
                body.tile = Res.img.PorcEaten.toTile().center();
                body.tile.xFlip = tmp;
                MessageManager.send(new AnimalEaten());
            }
        }
        return false;
    }
}
