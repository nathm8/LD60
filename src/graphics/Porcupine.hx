package graphics;

import h2d.col.PixelsCollider;
import utilities.MessageManager;
import utilities.MessageManager.MessageListener;
import utilities.RNGManager;
import utilities.Vector2D;
import hxd.Res;
import h2d.Bitmap;
import gamelogic.Updateable;
import h2d.Object;

enum PorcBehaviour {
    Idle;
    Wander;
    Flee;
}

class Porcupine extends Object implements Updateable implements MessageListener {

    var body: Bitmap;
    var collider: PixelsCollider;
    var health = 40.0;
    var isEaten = false;
    var behaviour = Idle;
    var velocity: Vector2D;
    var timeInBehaviour = 0.0;
    var totalTimeInBehaviour = 0.0;
    
    public function new(p: Object) {
        super(p);

        body = new Bitmap(Res.img.Porc.toTile().center(), this);
        Main.tweenManager.delay(RNGManager.srand(5, true), () -> wander()).start();

        collider = new PixelsCollider(Res.img.PorcHitbox.getPixels());

        scale(1 + RNGManager.srand(0.2));

        MessageManager.addListener(this);
    }

    public function update(dt:Float):Bool {
        if (health <= 0) return false;
        timeInBehaviour += dt;
        if (behaviour == Idle && timeInBehaviour > 5)
            wander();
        if (behaviour == Wander) {
            body.x += velocity.x*dt;
            body.y += velocity.y*dt;
            var r = timeInBehaviour/totalTimeInBehaviour;
            if (r < 1/3) body.rotation += 0.5*dt;
            else if (r < 2/3) body.rotation -= dt;
            else body.rotation += 0.5*dt;
            if (r >= 1) {
                timeInBehaviour = 0;
                behaviour = Idle;
            }
        } if (behaviour == Flee) {
            body.x += velocity.x*dt;
            body.y += velocity.y*dt;
            if (timeInBehaviour % 0.5 >= 0.25)
                body.rotation += 2*dt;
            else
                body.rotation -= 2*dt;
        }
        return false;
    }

    function wander() {
        behaviour = Wander;
        velocity = new Vector2D(RNGManager.srand(50), RNGManager.srand(50));
        body.tile.xFlip = velocity.x < 0;
        timeInBehaviour = 0;
        totalTimeInBehaviour = 1 + RNGManager.srand(2, true);
    }

    function flee() {
        if (behaviour == Flee) return;
        behaviour = Flee;
        body.rotation = 0;
        var speed = 200 + RNGManager.srand(150 + 50*Sky.night, true);
        velocity = new Vector2D(RNGManager.srand(1), RNGManager.srand(1)).normalize()*speed;
        body.tile.xFlip = velocity.x < 0;
        timeInBehaviour = 0;
        totalTimeInBehaviour = velocity.magnitude;
    }

    public function delete() {}

    function die() {
        var tmp = body.tile.xFlip;
        body.tile = Res.img.PorcDead.toTile().center();
        body.tile.xFlip = tmp;
        MessageManager.send(new SmallBeastDeath());
    }

    function pointCollisionCheck(point: Vector2D): Bool {
        var q = body.globalToLocal(point);
        q.x += Res.img.Porc.getSize().width/2;
        q.y += Res.img.Porc.getSize().height/2;
        return collider.contains(q);
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
                health -= params.damage;
                if (health <= 0) die();
                flee();
                MessageManager.send(new SpawnBloodSpray(params.pos, params.damage));
            }
        } if (Std.isOfType(msg, PlayerCollisionCheck)) {
            var player = cast(msg, PlayerCollisionCheck).player;
            var v: Vector2D = (player.body.getAbsPos().getPosition() - body.getAbsPos().getPosition());
            var dist = v.magnitude;
            if (dist < 50) {
                if (health > 0 || isEaten) return false;
                isEaten = true;
                var tmp = body.tile.xFlip;
                body.tile = Res.img.PorcEaten.toTile().center();
                body.tile.xFlip = tmp;
                MessageManager.send(new AnimalEaten(0.2));
            } if (dist < 150 + Sky.night*50 && Sky.night > 0) {
                if (health <= 0) return false;
                flee();
            }
        }
        return false;
    }
}
